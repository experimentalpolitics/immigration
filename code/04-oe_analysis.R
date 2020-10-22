# =================================================================== #
# Project: Sources of Misperception
# Author: Nick
# Date: 10/19/2020
# Summary: Explore/analyze OE responses using different methods.
# =================================================================== #

cd("~/Dropbox/github-local//experimentalpolitics/immigration")

# packages
library(here)
library(readr)
library(tidyverse)
library(quanteda)
quanteda_options(threads = RcppParallel::defaultNumThreads()) # max threads for parallel processing

# prep the data for LIWC program
dat <- read_csv(here("data/immigration_20191219_clean.csv"))

# write out
dat %>%
    select(., id, taxes_oe) %>%
    write_csv(., "data/taxes_oe.csv")

dat %>%
    select(., id, jobs_oe) %>%
    write_csv(., "data/jobs_oe.csv")

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

# "Bag-of-words" vector space model of text data.

# isolate the relevant data; can be rejoined later
oe_dat <- dat %>%
    select(., id, condition, taxes_pos, taxes_oe, jobs_pos, jobs_oe)

# 1. dichotomize data (label)
oe_dat$taxes_label <- ifelse(oe_dat$taxes_pos >= .5, "positive", "negative")
oe_dat$jobs_label <- ifelse(oe_dat$jobs_pos >= .5, "positive", "negative")

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
# additional document meta data (don't want to lose this information)
docvars(docs, "id_") <- oe_dat$id
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
# 	- Note that the original paper runs four algorithms over the data for each legislative session to classify party. They indicate that the best performing (highest accuracy in CV) is chosen for each session. They also create inversely proportional weights to balance the classes in each session. For our purposes, we do not have temporally segmented data. It remains to be seen if we have very different class frequencies. 
# 	- It is not clear to me that we need to use these four; in fact, the advice from the authors is to use Naive Bayes or some other fast, scalable option (and then to check with a few different alternatives).
# 4. accuracy (all true / all obs) where class is determined by a p >=.5
# 	- Note that the original authors are using balanced classes, and can get away with simple accuracy as a metric of classification error. However, there are different approaches to measuring classification error that are better for class imbalanced data, such as F1 (harmonic mean of precision, recall).
# 5. Establish ambivalence from overall accuracy, where low accuracy means high ambivalence.
