# =================================================================== #
# Project: Sources of Misperception
# Author: Nick
# Date: 10/19/2020
# Summary: Explore/analyze OE responses using different methods.
# =================================================================== #

cd("~/Dropbox/github-local/experimentalpolitics/immigration")

# packages
library(here)
library(readr)
library(tidyverse)
library(caret)
library(quanteda)
quanteda_options(threads = RcppParallel::defaultNumThreads()) # max threads for parallel processing
library(quanteda.textmodels)

# prep the data for LIWC program
dat <- read_csv(here("data/immigration_20191219_clean.csv"))

# write out -- !DON'T PROCESS THIS AFTER FIRST RUN! (commented out)
# dat %>%
#     select(., id, taxes_oe) %>%
#     write_csv(., "data/taxes_oe.csv")

# dat %>%
#     select(., id, jobs_oe) %>%
#     write_csv(., "data/jobs_oe.csv")

# read back in processed scores
tmp <- read_csv(here("data/LIWC2015 Results (taxes_oe).csv"))
tmp <- rename(tmp, id = `Source (A)`, tentat_taxes = tentat, certain_taxes = certain)

dat <- tmp %>%
    select(., id, tentat_taxes, certain_taxes) %>%
    left_join(dat, ., by = "id")

tmp <- read_csv(here("data/LIWC2015 Results (jobs_oe).csv"))
tmp <- rename(tmp, id = `Source (A)`, tentat_jobs = tentat, certain_jobs = certain)

# add to data and remove tmp
dat <- tmp %>%
    select(., id, tentat_jobs, certain_jobs) %>%
    left_join(dat, ., by = "id")
rm(tmp)

# create `prefer` and `exposure`
dat <- dat %>%
    mutate(.,
        prefer = (tv_fox - tv_msnbc == 0) + 2 * (tv_fox - tv_msnbc > 0),
        prefer = factor(prefer, labels = c("msnbc", "neutral", "fox")),
        exposure = ((prefer == "fox" & tweet == "msnbc") | (prefer == "msnbc" & tweet == "fox")) +
           2 * (prefer == "neutral" & tweet != "control") + 3 * (prefer == tweet),
        exposure = factor(exposure, labels = c("control", "inconsistent", "neutral", "consistent")))

# create "folded" measures to get at the intensity of answer
dat$folded_taxes <- abs(as.numeric(scale(dat$taxes_pos, center = TRUE, scale = FALSE)))
dat$folded_jobs <- abs(as.numeric(scale(dat$jobs_pos, center = TRUE, scale = FALSE)))

# correlation between closed ended responses and tentativeness
cor.test(dat$taxes_pos, dat$tentat_taxes)
cor.test(dat$jobs_pos, dat$tentat_jobs)

# correlation between folded responses and tentativeness
cor.test(dat$folded_taxes, dat$tentat_taxes)
cor.test(dat$folded_jobs, dat$tentat_jobs)

# we want to understand if the association of the first pair is smaller than the association of the second pair. Since the first pair is not stat. sig. we would say that the relationship of the second pair is indeed stronger (0 < ~0.15). The sign of the second correlation is negative, meaning more "extreme" answers are less tentative.

# This first step indicates that we have a reasonable measure of ambivalence because the correlation is stronger with the folded (extremity) indicator than the positional indicator. We then want to test whether there is a difference in the measure of ambivalence between choice treated which select consistent and those which select inconsistent media.

dat$exposure2 <- ifelse(dat$exposure %in% c("control", "neutral"), NA, dat$exposure) %>%
    factor(., labels = c("inconsistent", "consistent"))

dat %>%
    filter(., condition == "assigned" & !is.na(exposure2)) %>%
    t.test(tentat_taxes ~ exposure2, data = .)

# the sample is not balanced (48 incons vs 74 cons), but we might think that this finding indicates assigning does not change ambivalence

dat %>%
    filter(., condition == "choice" & !is.na(exposure2)) %>%
    t.test(tentat_taxes ~ exposure2, data = .)

# here we are seeing that there isn't a difference, meaning that whether they choose consistent or inconsistent sources ambivalence is not stat. different. Samples are very unbalance; 21 incons and 102 consistent


# "Bag-of-words" vector space model of text data.

# 1. dichotomize data (label)
dat$taxes_label <- ifelse(dat$taxes_pos >= .5, "positive", "negative")
dat$jobs_label <- ifelse(dat$jobs_pos >= .5, "positive", "negative")

# isolate the relevant data; can be rejoined later
oe_dat <- dat %>%
    select(., id, condition, taxes_label, taxes_oe, jobs_label, jobs_oe)

# check for imbalance (splits about 70-30 for each)
table(oe_dat$taxes_label)
table(oe_dat$jobs_label)

# recast data to "pool" observations -- we do this to to maximize data available. Also, we believe there is a common data generating process and these can be pooled
oe_dat <- oe_dat %>%
    select(., id, condition, taxes_oe, jobs_oe, taxes_label, jobs_label) %>%
    gather(., key, value, -id, -condition)
oe_dat$question <- ifelse(rownames(oe_dat) %in%grep("taxes", oe_dat$key, fixed = TRUE), "taxes", "jobs")
oe_dat$key <- gsub("taxes_", "", oe_dat$key, fixed = TRUE)
oe_dat$key <- gsub("jobs_", "", oe_dat$key, fixed = TRUE)
oe_dat$key <- gsub("oe", "response", oe_dat$key, fixed = FALSE)
oe_dat <- oe_dat %>%
    spread(., key, value)

# 2. pre-process the text

# create corpus (note that 4 obs do not have response text)
docs <- corpus(oe_dat$response)
# assign document names that id unique responses
docnames(docs) <- paste(oe_dat$id, oe_dat$question, sep = "_")
# additional document meta data (don't want to lose this information). The `_` is to make sure you don't mix these up with features of the same name
docvars(docs, "id_") <- oe_dat$id
docvars(docs, "label_") <- oe_dat$label
docvars(docs, "question_") <- oe_dat$question
docvars(docs, "condition_") <- oe_dat$condition

#   - They do not stem, or remove stopwords or other tokens. We should imagine they have reduced case and removed punctuation, but it is not clear.

# create a document-feature matrix containing n-grams
docs_dfm <- tokens(docs) %>%
    tokens_remove("\\p{P}", valuetype = "regex", padding = FALSE) %>% # punctuation
    dfm() # convert to DFM

# find number of features and top 100 features
nfeat(docs_dfm) # 2,694 features
topfeatures(docs_dfm, 100) 

#   - Note that the original paper "fixes vocabulary" which is intended to address the *finite sample bias* problem explored by Gentzkow, Shapiro, and Taddy (2016, NBER working paper). The idea behind this is that speakers have many phrases/words to choose from relative to the amount of speech we have on record. It could be the case that a speech contains a phrase or word that appears there but is not a substantive signal of party. However, as Gentzkow et al. explain, naive estimators don't understand the substantive signal and therefore would use such terms as though they were credible signals of party label. This could overstate the signal in the classifier; instead, fixing the size of the vocabulary is thought to prevent this. I have specifically eliminated certain terms in other work (i.e. proper nouns which might correlate with labels) and it appears that Gentzkow et al. (2016) use a LASSO to effectively eliminate "weak" terms. Petersen and Spirling "fix" the vocabulary by removing terms which appear in less than 200 speeches, which is 0.0057143 percent of their data. I am not sure we need to concern ourselves here, but in case I only include terms which appear in more than one answer.

# drops features appearing in only one document
docs_dfm <- dfm_trim(docs_dfm, min_docfreq = 2, docfreq_type = "count")
nfeat(docs_dfm) # 1,323 features (~51% reduction)

# 3. select algorithms & apply to data; 10-fold CV
#   - Note that the original paper runs four algorithms over the data for each legislative session to classify party. They indicate that the best performing (highest accuracy in CV) is chosen for each session. They also create inversely proportional weights to balance the classes in each session. For our purposes, we do not have temporally segmented data. We do have very different class frequencies.

# first split the data into training and test sets by randomly pulling a sample of 50% of the data. if we want to weight by label or by question we can do so. we can also change how much of the data we use to train

# first create train and test sets by randomly holding out 50% of data
set.seed(42)
train_ids <- base::sample(docnames(docs_dfm),
    round(nrow(docs_dfm) * 0.5), replace = FALSE)
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

# we have decided to use Naive Bayes, Support Vector Machine(s) instead. this can be done in quanteda

# ensure compatible dimensionality of train, test sets
dfmat_matched <- dfm_match(dfmat_test, featnames(dfmat_train))

# set the seed to get reproducible results
set.seed(42)
# NB model
mod_nb <- textmodel_nb(dfmat_train, docvars(dfmat_train, "label_"))
# set the actual labels vector for evaluation, using the matched test labels
actual_class <- docvars(dfmat_matched, "label_")
# generate predictions of labels based on NB model, using the matched test data
predicted_class <- predict(mod_nb, newdata = dfmat_matched)
# store the label matrix
tab_class <- table(actual_class, predicted_class)
# print the label matrix in the console and look at F1. `caret` is the package I use here, and you need to explicitly set the positive class in order to get sensible results; the mode argument allows for F1 to print
confusionMatrix(tab_class, positive = "positive", mode = "everything")

# SVMs using different weighting schemes; note that this uses the actual class from the NB model (not model dependent)

# unweighted SVM
dfm(dfmat_train) %>%
    textmodel_svm(docvars(dfmat_train, "label_")) %>%
    predict(., newdata = dfmat_matched) %>%
    table(actual_class, .) %>%
    confusionMatrix(., positive = "positive", mode = "everything")

# proportional weight SVM
dfm(dfmat_train) %>%
    dfm_weight(scheme = "prop") %>%
    textmodel_svm(docvars(dfmat_train, "label_")) %>%
    predict(., newdata = dfmat_matched) %>%
    table(actual_class, .) %>%
    confusionMatrix(., positive = "positive", mode = "everything")

# SVM with tf-idf
dfm(dfmat_train) %>%
    dfm_tfidf() %>%
    textmodel_svm(docvars(dfmat_train, "label_")) %>%
    predict(., newdata = dfmat_matched) %>%
    table(actual_class, .) %>%
    confusionMatrix(., positive = "positive", mode = "everything")

# SVM with tf-idf weighted by docfreq
dfm(dfmat_train) %>%
    dfm_tfidf() %>%
    textmodel_svm(docvars(dfmat_train, "label_"), weight = "docfreq") %>%
    predict(., newdata = dfmat_matched) %>%
    table(actual_class, .) %>%
    confusionMatrix(., positive = "positive", mode = "everything")

# 4. accuracy (all true / all obs) where class is determined by a p >=.5
#   - Note that the original authors are using balanced classes, and can get away with simple accuracy as a metric of classification error. However, there are different approaches to measuring classification error that are better for class imbalanced data, such as F1 (harmonic mean of precision, recall).


# 5. Establish ambivalence from accuracy, where low accuracy means high ambivalence.

# We will need to obtain class probabilities rather than bins. This will be done with the predict() function and setting type = "probability". We can then use that class probability to make a measure of "certainty" of language. Note that the probabilities are for the positive label, so we may want to do a "folding" type of thing here where values nearest to 0.5 are most uncertain.

# get the class probabilities for just the test set
nb_preds <- predict(mod_nb, newdata = dfmat_matched, type = "probability")

# create folded measure from the positive pred probs
tmp <- abs(nb_preds[, 2] - .5) %>%
    cbind(., t(sapply(str_split(names(.), "_"), unlist))) %>%
    as_tibble
names(tmp) <- c("folded_ml_x", "id", "question")
tmp$id <- as.numeric(tmp$id)
tmp$folded_ml_x <- as.numeric(tmp$folded_ml_x)

# add to oe data
oe_dat <- oe_dat %>%
    left_join(., tmp)
rm(tmp)

# add to total data
dat$folded_ml_jobs <- oe_dat %>%
    filter(., question == "jobs") %>%
    .[match(dat$id, .$id), "folded_ml_x"] %>%
    unlist

dat$folded_ml_taxes <- oe_dat %>%
    filter(., question == "taxes") %>%
    .[match(dat$id, .$id), "folded_ml_x"] %>%
    unlist

# correlation between closed ended responses and folded ml classifier
cor.test(dat$taxes_pos, dat$folded_ml_taxes)
cor.test(dat$jobs_pos, dat$folded_ml_jobs)

# correlation between folded responses and folded ml classifier
cor.test(dat$folded_taxes, dat$folded_ml_taxes)
cor.test(dat$folded_jobs, dat$folded_ml_jobs)

# we want to understand if the association of the first pair is smaller than the association of the second pair. Since the SECOND pair is not stat. sig. we would say that the relationship of the second pair is NOT stronger (~0.15 > 0). Assuming the same interpretation as before, this cannot support our claim around ambivalence. [CHECK INTERPRETATION!]

# do this another way - compare accuracies between groups

# add the class probabilities
tmp <- nb_preds[, 2] %>%
    cbind(., t(sapply(str_split(names(.), "_"), unlist))) %>%
    as_tibble
names(tmp) <- c("prob_ml_x", "id", "question")
tmp$id <- as.numeric(tmp$id)
tmp$prob_ml_x <- as.numeric(tmp$prob_ml_x)

oe_dat <- oe_dat %>%
    left_join(., tmp)
rm(tmp)

dat$prob_ml_jobs <- oe_dat %>%
    filter(., question == "jobs") %>%
    .[match(dat$id, .$id), "prob_ml_x"] %>%
    unlist

dat$prob_ml_taxes <- oe_dat %>%
    filter(., question == "taxes") %>%
    .[match(dat$id, .$id), "prob_ml_x"] %>%
    unlist

# re-label
dat$label_ml_taxes <- ifelse(dat$prob_ml_taxes >= .5, "positive", "negative")
dat$label_ml_jobs <- ifelse(dat$prob_ml_jobs >= .5, "positive", "negative")

# check confusion matrix on all obs
confusionMatrix(table(dat$taxes_label, dat$label_ml_taxes),
    positive = "positive", mode = "everything")

# now filter to subset and run again
dat %>%
    filter(., exposure == "consistent" & !is.na(label_ml_taxes)) %>%
    select(., taxes_label, label_ml_taxes) %>%
    table(.) %>%
    confusionMatrix(., positive = "positive", mode = "everything")

dat %>%
    filter(., exposure == "inconsistent" & !is.na(label_ml_taxes)) %>%
    select(., taxes_label, label_ml_taxes) %>%
    table(.) %>%
    confusionMatrix(., positive = "positive", mode = "everything")

# for taxes, it looks like there isn't a difference between accuracy (F1) from consistency or not

dat %>%
    filter(., exposure == "consistent" & !is.na(label_ml_jobs)) %>%
    select(., jobs_label, label_ml_jobs) %>%
    table(.) %>%
    confusionMatrix(., positive = "positive", mode = "everything")

dat %>%
    filter(., exposure == "inconsistent" & !is.na(label_ml_jobs)) %>%
    select(., jobs_label, label_ml_jobs) %>%
    table(.) %>%
    confusionMatrix(., positive = "positive", mode = "everything")

# for jobs there is a slight difference, but not sure it is enough
# OVERALL: if we think this is the right way to do this, it suggests again that ambivalence is not driving
