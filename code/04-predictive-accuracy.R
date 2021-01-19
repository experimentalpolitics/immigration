# =================================================================== #
# Project: Sources of Misperception
# Author: Nick (w/ updates by Patrick)
# Date: 10/19/2020 (updated: 01/08/2021)
# Summary: Analyze OE responses to measure ambivalence
# =================================================================== #


# Packages ----------------------------------------------------------------

library(here)
library(readr)
library(tidyverse)
library(caret)
library(quanteda)
quanteda_options(threads = RcppParallel::defaultNumThreads()) # max threads for parallel processing
library(quanteda.textmodels)


# Load & recode data ------------------------------------------------------------

# Main data file
dat <- read_csv(here("data/immigration_20191219_clean.csv")) %>%
    mutate(
        # Create `prefer` and `exposure`
        prefer = (tv_fox - tv_msnbc == 0) + 2 * (tv_fox - tv_msnbc > 0),
        prefer = factor(prefer, labels = c("msnbc", "neutral", "fox")),
        exposure = ((prefer == "fox" & tweet == "msnbc") | (prefer == "msnbc" & tweet == "fox")) +
            2 * (prefer == "neutral" & tweet != "control") + 3 * (prefer == tweet),
        exposure = factor(exposure, labels = c("control", "inconsistent", "neutral", "consistent")),
        
        # Create "folded" measures to get at the intensity of answer
        folded_taxes = abs(taxes_pos - 0.5),
        folded_jobs = abs(jobs_pos - 0.5)
    )


# "Bag-of-words" vector space model of text data.

# 1. dichotomize data (label) (NOTE: Neutral answers should be omitted)
dat$taxes_label <- ifelse(dat$taxes_pos >= .5, "positive", "negative")
dat$taxes_label[dat$taxes_pos == .5] <- NA
dat$jobs_label <- ifelse(dat$jobs_pos >= .5, "positive", "negative")
dat$jobs_label[dat$jobs_pos == .5] <- NA

# check for imbalance (splits about 65-35 for each)
table(dat$taxes_label)
table(dat$jobs_label)

# Isolate the relevant data; can be rejoined later
# - remove neutral responses and OEs that only contain a single word (13 cases)
# - recast data to "pool" observations -- we do this to to maximize data available. 
# - Also, we believe there is a common data generating process and these can be pooled
oe_dat <- dat %>%
    select(id, condition, exposure, taxes_oe, jobs_oe, taxes_label, jobs_label) %>%
    gather(key, value, -id, -condition, -exposure) %>%
    separate(key, c("question", "key"), "_") %>% 
    mutate(key = dplyr::recode(key, `oe` = "response")) %>% 
    spread(key, value) %>%
    filter(
        !is.na(label),
        !is.na(exposure), # not sure where these NAs are coming from, need to investigate
        sapply(gregexpr("[[:alpha:]]+", response), function(x) sum(x > 0)) > 1
    )

# 2. pre-process the text

# create corpus (note that 4 obs do not have response text)
docs <- corpus(oe_dat$response)

# assign document names that id unique responses
docnames(docs) <- paste(oe_dat$id, oe_dat$question, sep = "_")

# additional document meta data (don't want to lose this information). 
# The `_` is to make sure you don't mix these up with features of the same name
docvars(docs, "id_") <- oe_dat$id
docvars(docs, "label_") <- oe_dat$label
docvars(docs, "question_") <- oe_dat$question
docvars(docs, "condition_") <- oe_dat$condition
docvars(docs, "exposure_") <- oe_dat$exposure

## NEW: use control condition and consistent exposure as training set
## - this is not ideal, but we need to maximize inconsistent exposure cases in test set
## (total cases are too low if training/test status is assigned randomly)
docvars(docs, "training_") <- oe_dat$exposure != "inconsistent"

# - They do not stem, or remove stopwords or other tokens. 
# We should imagine they have reduced case and removed punctuation, but it is not clear.

# create a document-feature matrix containing n-grams
docs_dfm <- tokens(docs) %>%
    tokens_remove("\\p{P}", valuetype = "regex", padding = FALSE) %>% # punctuation
    dfm() # convert to DFM

# find number of features and top 100 features
nfeat(docs_dfm) # 2,694 features
topfeatures(docs_dfm, 100) 

# - Note that the original paper "fixes vocabulary" which is intended to address the 
# *finite sample bias* problem explored by Gentzkow, Shapiro, and Taddy (2016, NBER working paper). 
# The idea behind this is that speakers have many phrases/words to choose from relative to the 
# amount of speech we have on record. It could be the case that a speech contains a phrase or word 
# that appears there but is not a substantive signal of party. However, as Gentzkow et al. explain, 
# naive estimators don't understand the substantive signal and therefore would use such terms as 
# though they were credible signals of party label. This could overstate the signal in the 
# classifier; instead, fixing the size of the vocabulary is thought to prevent this. I have 
# specifically eliminated certain terms in other work (i.e. proper nouns which might correlate 
# with labels) and it appears that Gentzkow et al. (2016) use a LASSO to effectively eliminate 
# "weak" terms. Petersen and Spirling "fix" the vocabulary by removing terms which appear in less 
# than 200 speeches, which is 0.0057143 percent of their data. I am not sure we need to concern 
# ourselves here, but in case I only include terms which appear in more than one answer.

# drops features appearing in only one document
docs_dfm <- dfm_trim(docs_dfm, min_docfreq = 2, docfreq_type = "count")
nfeat(docs_dfm) # 1,323 features (~51% reduction)

# 3. select algorithms & apply to data; 10-fold CV
#   - Note that the original paper runs four algorithms over the data for each legislative session to classify party. They indicate that the best performing (highest accuracy in CV) is chosen for each session. They also create inversely proportional weights to balance the classes in each session. For our purposes, we do not have temporally segmented data. We do have very different class frequencies.

# first split the data into training and test sets by randomly pulling a sample of 50% of the data. if we want to weight by label or by question we can do so. we can also change how much of the data we use to train

# first create train and test sets by randomly holding out 50% of data
set.seed(42)
train_ids <- docnames(docs_dfm)[docvars(docs_dfm, "training_")]
test_ids <- docnames(docs_dfm)[!(docnames(docs_dfm) %in% train_ids)]
length(test_ids[test_ids %in% train_ids]) # must evaluate to zero; it does

# get training set
dfmat_train <- docs_dfm[train_ids, ]
# get test set
dfmat_test <- docs_dfm[test_ids, ]

#   - It is not clear to me that we need to use these four; in fact, the advice from the authors is to use Naive Bayes or some other fast, scalable option (and then to check with a few different alternatives).

# https://rpubs.com/FaiHas/197581 --perceptron
# Stochastic Gradient Descent, which is better for large data (http://deeplearning.stanford.edu/tutorial/supervised/OptimizationStochasticGradientDescent/)
# "passive-agressive" GLM with hinge-loss parameter would need to be hand-coded
# logit with specific loss, regularization parameters fit with stochastic average gradient descent would also need to be coded by hand in R

# we have decided to use Naive Bayes instead. this can be done in quanteda (earlier version included SVM)

# ensure compatible dimensionality of train, test sets
dfmat_matched <- dfm_match(dfmat_test, featnames(dfmat_train))

# set the seed to get reproducible results
set.seed(42)

# NB model
mod_nb <- textmodel_nb(dfmat_train, docvars(dfmat_train, "label_"))

# save NB predictions and meta-information for test data
nb_dat <- tibble(
    id = docvars(dfmat_matched, "id_"),
    condition = docvars(dfmat_matched, "condition_"),
    exposure = docvars(dfmat_matched, "exposure_"),
    question = docvars(dfmat_matched, "question_"),
    actual_class = docvars(dfmat_matched, "label_"),
    predicted_class = predict(mod_nb, newdata = dfmat_matched)
)

# store the label matrix
tab_class <- table(nb_dat$actual_class, nb_dat$predicted_class)

# print the label matrix in the console and look at F1
confusionMatrix(tab_class, positive = "positive", mode = "prec_recall")

# compare F1 score across inconsistent forced exposure / free choice condition
extractAccuracy <- function(x) {
    tmp <- x %>% 
        select(actual_class, predicted_class) %>%
        table() %>% 
        confusionMatrix(positive = "positive", mode = "prec_recall")
    out <- c(tmp$overall["Accuracy"],
             tmp$byClass["F1"])
    return(out)
}

# 4. accuracy (all true / all obs) where class is determined by a p >=.5
#   - Note that the original authors are using balanced classes, and can get away with simple accuracy as a metric of classification error. However, there are different approaches to measuring classification error that are better for class imbalanced data, such as F1 (harmonic mean of precision, recall).

# 5. Establish ambivalence from accuracy, where low accuracy means high ambivalence.

p8 <- nb_dat %>%
    filter(exposure == "inconsistent") %>%
    split(paste0(.$condition,"_",.$question)) %>% 
    map_dfr(extractAccuracy, .id = "condition") %>%
    separate(condition, c("condition", "question")) %>% 
    mutate(condition = recode_factor(condition,
                                     `assigned` = "Forced exposure",
                                     `choice` = "Free choice"),
           question = recode_factor(question,
                                    `jobs` = "Immigrants create jobs",
                                    `taxes` = "Immigrants pay taxes")) %>% 
    ggplot(aes(x = condition, y = Accuracy, fill = condition)) +
    geom_col() + 
    theme_light(base_size = 8) + 
    facet_wrap(~question) +
    theme(legend.position = "none") +
    labs(y = "Predictive Accuracy",
         x = NULL) +
    scale_fill_brewer(palette = "Paired") +
    ylim(0,1)
