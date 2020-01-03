# =================================================================== #
# Project: Sources of Misperception
# Author: Patrick
# Date: 12/19/2019
# Summary: prepare raw qualtrics dataset for subsequent analyses
# =================================================================== #


### Packages
library(here)
library(readr)
library(tidyverse)


### Load raw data
raw <- read_csv(here("data/Immigration_December 19, 2019_02.00.csv"), skip = 3, 
                col_names = here("data/Immigration_December 19, 2019_02.00.csv") %>%
                  read_lines(n_max = 1) %>%
                  strsplit(",") %>%
                  unlist)

num <- read_csv(here("data/Immigration_December 19, 2019_05.20.csv"), skip = 3, 
                col_names = here("data/Immigration_December 19, 2019_05.20.csv") %>%
                  read_lines(n_max = 1) %>%
                  strsplit(",") %>%
                  unlist)


### Clean/recode complete set of variables
dat <- num %>% 
  transmute(
    ranid = `Random ID`,
    id = row_number(),
    duration = `Duration (in seconds)`,
    date = RecordedDate,
    condition = condition,
    smedia_yt = (7 - smedia_1)/6,  ## 0 = never, 1 = several times a day
    smedia_fb = (7 - smedia_2)/6,
    smedia_ig = (7 - smedia_3)/6,
    smedia_tw = (7 - smedia_4)/6,
    smedia_tb = (7 - smedia_5)/6,
    tv_fox = (7 - tv_1)/6,  ## 0 = never, 1 = several times a day
    tv_msnbc = (7 - tv_2)/6,
    tv_cnn = (7 - tv_3)/6,
    tv_mbc = (7 - tv_4)/6,
    tv_cbs = (7 - tv_5)/6,
    print_nyt = (7 - print_1)/6,  ## 0 = never, 1 = several times a day
    print_wapo = (7 - print_2)/6,
    print_wsj = (7 - print_3)/6,
    print_ust = (7 - print_4)/6,
    print_nyp = (7 - print_5)/6,
    unint_farmers = (st_job_1 - 1)/6,  ## 0 = intelligent, 1 = unintelligent
    unint_teachers = (st_job_2 - 1)/6,
    unint_lawyers = (st_job_3 - 1)/6,
    unint_politicians = (st_job_4 - 1)/6,
    lazy_whites = (st_race_1 - 1)/6,  ## 0 = hard-working, 1 = lazy
    lazy_blacks = (st_race_2 - 1)/6,
    lazy_hispanics = (st_race_3 - 1)/6,
    lazy_asians = (st_race_4 - 1)/6,
    selfish_silent = (st_age_1 - 1)/6,  ## 0 = generous, 1 = selfish
    selfish_boomers = (st_age_2 - 1)/6,
    selfish_genx = (st_age_3 - 1)/6,
    selfish_millenials = (st_age_4 - 1)/6,
    polint = (5 - polint)/4,  ## 0 = never, 1 = always
    problem_economy = (problem_1 - 1)/4,  ## 0 = least important, 1 = most important
    problem_terrorism = (problem_3 - 1)/4,
    problem_immigration = (problem_6 - 1)/4,
    problem_healthcare = (problem_7 - 1)/4,
    problem_environment = (problem_9 - 1)/4,
    ideol_con = (ideol - 1)/6,  ## 0 = very liberal, 1 = very conservative
    pid_rep = (recode(pid, `1`=6, `2`=2, `3`=4, `4`=4) +  ## 0 = democrat, 1 = republican
                 recode(pid_lean, `1`=1, `2`=-1, `3`=0, .missing=0) +
                 recode(pid_rep, `1`=1, `2`=0, .missing=0) +
                 recode(pid_dem, `1`=-1, `2`=0, .missing=0) - 1)/6,
    tweet = factor(recode(choice, `1`=2, `2`=1, .missing=0) +
                     recode(assigned, `fox`=2, `msnbc`=1, .missing=0),
                   labels = c("control","msnbc","fox")),
    tweet_click = as.numeric(`time_tweet_Click Count` > 0),
    tweet_time = `time_tweet_Page Submit`,
    story_time = `time_story_Page Submit`,
    source = raw$source,
    source_correct = ((source == "Fox News" & tweet == "fox") |
                        (source == "MSNBC" & tweet == "msnbc")),
    about = raw$about,
    about_correct = (about == "Immigrant-owned businesses"),
    att_check = (source_correct & about_correct),
    actions_discuss = (4 - actions_1)/3,  ## 0 = not likely, 1 = very likely
    actions_forward = (4 - actions_2)/3,
    actions_post = (4 - actions_3)/3,
    actions_seek = (4 - actions_4)/3,
    wp_fair = (5 - word_pairs_1)/4,  ## 0 = unfair, 1 = fair
    wp_hostile = (5 - word_pairs_2)/4,  ## 0 = friendly, 1 = hostile
    wp_bad = (5 - word_pairs_3)/4,  ## 0 = good, 1 = bad
    wp_skewed = (5 - word_pairs_4)/4,  ## 0 = balanced, 1 = skewed
    wp_american = (5 - word_pairs_5)/4,  ## 0 = un-american, 1 = american
    wp_accurate = (5 - word_pairs_6)/4,  ## 0 = inaccurate, 1 = accurate
    employ = (employ - 1)/4,  ## 0 = less than 500,000, 1 = more than 10 million
    employ_correct = (raw$employ == "5 million - 10 million"),
    sales = (sales - 1)/4,  ## 0 = less than $500 billion, 1 = more than $2 trillion
    sales_correct = (raw$sales == "$1 trillion - $1.5 trillion"),
    immig_increased = (5 - immig)/4,  ## 0 = decreased a lot, 1 = increased a lot
    taxes_pos = taxes_1/10,  ## 0 = take more out, 1 = put in more
    taxes_oe = taxes_oe,
    jobs_pos = jobs_1/10,  ## 0 = take jobs, 1 = create jobs
    jobs_oe = jobs_oe,
    tv_trust_fox = (5 - tv_trust_1)/4,  ## 0 = never, 1 = always
    tv_trust_msnbc = (5 - tv_trust_2)/4,
    tv_trust_cnn = (5 - tv_trust_3)/4,
    tv_trust_nbc = (5 - tv_trust_4)/4,
    tv_trust_cbs = (5 - tv_trust_5)/4,
    print_trust_nyt = (5 - print_trust_1)/4,  ## 0 = never, 1 = always
    print_trust_wapo = (5 - print_trust_2)/4,
    print_trust_wsj = (5 - print_trust_3)/4,
    print_trust_ust = (5 - print_trust_4)/4,
    print_trust_nyp = (5 - print_trust_5)/4,
    age = age,
    male = recode(gender, `1`=0, `2`=1, `3`=NA_real_),
    usborn = 2 - usborn,
    usborn_year = usborn_year,
    zip = zip,
    zip_time = (zip_time - 1)/3,  ## 0 = 1-3 years, 1 = more than 5 years
    race = raw$race,
    white = race == "Caucasian/White (non-Hispanic)",
    educ = raw$educ,
    college = num$educ > 4,
    income = (income - 1)/6,  ## 0 = less than $20,000, 1 = $120,000 or more
    marital = raw$marital,
    church = (church - 1)/8,  ## 0 = never, 1 = more than once per week
    comments = comments) %>%
  filter(!is.na(ranid)) %>%
  select(-ranid)

## Check labelled vs. numeric data
table(raw$church, num$church, useNA = "always")
table(dat$employ, dat$employ_correct, useNA = "always")


### Save dataset
write_csv(dat, here("data/immigration_20191219_clean.csv"))




