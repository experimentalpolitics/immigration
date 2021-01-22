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

# Prepare taxes OEs file for LIWC if it doesn't exist already
if (!"LIWC2015 Results (taxes_oe).csv" %in% dir(here("data/"))) {
    dat %>%
        select(id, taxes_oe) %>%
        write_csv("data/taxes_oe.csv")
    stop("LIWC2015 Results (taxes_oe).csv is missing, code will not run")
} else {
    dat <- read_csv(here("data/LIWC2015 Results (taxes_oe).csv")) %>%
        rename(id = `Source (A)`, tentat_taxes = tentat, certain_taxes = certain) %>%
        select(id, tentat_taxes, certain_taxes) %>%
        right_join(dat)
}

# Prepare jobs OEs file for LIWC if it doesn't exist already
if (!"LIWC2015 Results (jobs_oe).csv" %in% dir(here("data/"))) {
    dat %>%
        select(id, jobs_oe) %>%
        write_csv("data/jobs_oe.csv")
    stop("LIWC2015 Results (jobs_oe).csv is missing, code will not run")
} else {
    dat <- read_csv(here("data/LIWC2015 Results (jobs_oe).csv")) %>%
        rename(id = `Source (A)`, tentat_jobs = tentat, certain_jobs = certain) %>%
        select(id, tentat_jobs, certain_jobs) %>%
        right_join(dat)
}


# LIWC analysis -----------------------------------------------------------

# correlation between closed ended responses and tentativeness
cor.test(dat$taxes_pos, dat$tentat_taxes)
cor.test(dat$jobs_pos, dat$tentat_jobs)
cor.test(dat$taxes_pos, dat$certain_taxes)
cor.test(dat$jobs_pos, dat$certain_jobs)

# correlation between folded responses and tentativeness
cor.test(dat$folded_taxes, dat$tentat_taxes)
cor.test(dat$folded_jobs, dat$tentat_jobs)
cor.test(dat$folded_taxes, dat$certain_taxes)
cor.test(dat$folded_jobs, dat$certain_jobs)

# we want to understand if the association of the first pair is smaller than 
# the association of the second pair. Since the first pair is not stat. sig. 
# we would say that the relationship of the second pair is indeed stronger 
# (0 < ~0.15). The sign of the second correlation is negative, meaning more 
# "extreme" answers are less tentative. Certainty is not correlated with either.

# This first step indicates that tentativeness is a reasonable measure of ambivalence 
# because the correlation is stronger with the folded (extremity) indicator 
# than the positional indicator. We then want to test whether there is a 
# difference in the measure of ambivalence between choice treated which select 
# consistent and those which select inconsistent media.

t.test(tentat_taxes ~ condition, 
       data = filter(dat, exposure == "inconsistent"))

t.test(tentat_jobs ~ condition, 
       data = filter(dat, exposure == "inconsistent"))

# No stat. sig. difference in tentativeness between forced and voluntary 
# inconsistent exposure -> makes ambivalence unlikely as an explanation

p5 <- dat %>%
    filter(exposure == "inconsistent") %>%
    select(condition, tentat_jobs, tentat_taxes) %>%
    pivot_longer(-condition) %>% 
    group_by(condition, name) %>% 
    summarize(mean = mean(value, na.rm = T),
              sd = sd(value, na.rm = T),
              n = n(),
              se = sd/sqrt(n),
              cilo95 = mean - 1.96 * se,
              cihi95 = mean + 1.96 * se,
              cilo90 = mean - 1.64 * se,
              cihi90 = mean + 1.64 * se) %>%
    mutate(condition = recode_factor(condition,
                                     `assigned` = "Forced exposure",
                                     `choice` = "Free choice"),
           name = recode_factor(name,
                                `tentat_jobs` = "Immigrants create jobs",
                                `tentat_taxes` = "Immigrants pay taxes")) %>% 
    ggplot(aes(x = condition, y = mean, fill = condition)) +
    geom_col() + 
    geom_linerange(aes(ymin = cilo95, ymax = cihi95), size=.75, position=position_dodge(width=0.4)) +
    geom_linerange(aes(ymin = cilo90, ymax = cihi90), size=1.5, position=position_dodge(width=0.4)) +
    theme_light(base_size = 10) + 
    facet_wrap(~name) +
    theme(legend.position = "none") +
    labs(y = "Tentative words (%)",
         x = NULL) +
    scale_fill_brewer(palette = "Paired")
