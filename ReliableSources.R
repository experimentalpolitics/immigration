## ----setup, include=FALSE---------------------------------------------------------------------------
knitr::opts_chunk$set(echo = FALSE, warning=FALSE, message=FALSE)

## Load packages
library(tidyverse)
library(broom)
library(sandwich)
library(ggplot2)
library(stargazer)
library(lmtest)
library(car)

### Custom functions
se <- function(x, na.rm = T){
  sd(x, na.rm = na.rm)/sqrt(length(na.omit(x)))
}
cilo <- function(x, na.rm = T){
  mean(x, na.rm = na.rm) - qnorm(.975) * se(x, na.rm)
}
cihi <- function(x, na.rm = T){
  mean(x, na.rm = na.rm) + qnorm(.975) * se(x, na.rm)
}

## Load data
df <- read_csv("../data/immigration_20191219_clean.csv") %>%
  mutate(condition = factor(condition, levels = c("control", "assigned", "choice")),
         lazy_diff = lazy_whites - lazy_hispanics)


## ----m1, fig.height=2, fig.width=7, fig.cap="\\label{fig:m1}Treatment effects of forced exposure and free choice condition. Coefficients are based on linear regression models controlling for pre-treatment covariates. Full model results included in the appendix."----
m1 <- list(employ_correct = lm(employ_correct ~ condition
                               + lazy_hispanics + problem_immigration
                               + age + male + usborn + white + college
                               , data = df),
           sales_correct = lm(sales_correct ~ condition
                              + lazy_hispanics + problem_immigration
                              + age + male + usborn + white + college
                              , data = df),
           jobs_pos = lm(jobs_pos ~ condition
                         + lazy_hispanics + problem_immigration
                         + age + male + usborn + white + college
                         , data = df),
           taxes_pos = lm(taxes_pos ~ condition
                          + lazy_hispanics + problem_immigration
                          + age + male + usborn + white + college
                          , data = df),
           immig_increased = lm(immig_increased ~ condition
                                + lazy_hispanics + problem_immigration
                                + age + male + usborn + white + college
                                , data = df))

m1robust <- m1 %>%
  map(~coeftest(., vcov. = vcovHC(.)))

m1robust %>%
  map_dfr(tidy, .id = "dv") %>%
  bind_cols(map_dfr(m1robust, confint_tidy)) %>%
  filter(term %in% c("conditionassigned", "conditionchoice")) %>%
  mutate(group = recode_factor(dv, 
                               `employ_correct` = "Belief",
                               `sales_correct` = "Belief",
                               `jobs_pos` = "Interpretation",
                               `taxes_pos` = "Interpretation",
                               `immig_increased` = "Opinion",
                               .ordered = TRUE),
         outcome = recode_factor(dv, 
                                 `employ_correct` = "Employment correct",
                                 `sales_correct` = "Sales correct",
                                 `jobs_pos` = "Immigrants create jobs",
                                 `taxes_pos` = "Immigrants pay taxes",
                                 `immig_increased` = "Immigration should be increased",
                                 .ordered = TRUE),
         Condition = recode_factor(term,
                                   `conditionassigned` = "Forced\nExposure",
                                   `conditionchoice` = "Free\nChoice")) %>%
  ggplot(aes(y = estimate, ymin = conf.low, ymax = conf.high, x = outcome,
             shape = Condition, col = Condition)) + 
  geom_hline(yintercept = 0, col = "grey") +
  geom_point(position=position_dodge(width=0.4)) +
  geom_errorbar(width=0, position=position_dodge(width=0.4)) +
  theme_bw(base_size = 8) + 
  labs(x = NULL, y = "Coefficient", 
       col = "Experimental\nCondition",
       shape = "Experimental\nCondition") +
  facet_wrap(~group, scales = "free_x", ncol = 3) +
  scale_colour_brewer(palette = "Set1")


## ----m2, fig.height=2, fig.width=7, fig.cap="\\label{fig:m2}Treatment effects within forced exposure condition, conditional on media preference. Coefficients are based on linear regression models controlling for pre-treatment covariates. Full model results included in the appendix."----
df_nochoice <- df %>%
  filter(condition != "choice") %>% # exclude free choice arm of experiment
  mutate(exposure = 
           as.numeric(((tv_fox-tv_msnbc>0) & (tweet=="msnbc"))
                      |((tv_fox-tv_msnbc<0) & (tweet=="fox")))
         + 2*as.numeric(((tv_fox-tv_msnbc==0) & (tweet=="msnbc"))
                        |((tv_fox-tv_msnbc==0) & (tweet=="fox")))
         + 3*as.numeric(((tv_fox-tv_msnbc>0) & (tweet=="fox"))
                        |((tv_fox-tv_msnbc<0) & (tweet=="msnbc"))),
         exposure = factor(exposure, labels = c("control","inconsistent","neutral","consistent")))

m2 <- list(employ_correct = lm(employ_correct ~ exposure
                               + lazy_hispanics + problem_immigration
                               + age + male + usborn + white + college
                               , data = df_nochoice),
           sales_correct = lm(sales_correct ~ exposure
                              + lazy_hispanics + problem_immigration
                              + age + male + usborn + white + college
                              , data = df_nochoice),
           jobs_pos = lm(jobs_pos ~ exposure
                         + lazy_hispanics + problem_immigration
                         + age + male + usborn + white + college
                         , data = df_nochoice),
           taxes_pos = lm(taxes_pos ~ exposure
                          + lazy_hispanics + problem_immigration
                          + age + male + usborn + white + college
                          , data = df_nochoice),
           immig_increased = lm(immig_increased ~ exposure
                                + lazy_hispanics + problem_immigration
                                + age + male + usborn + white + college
                                , data = df_nochoice))

m2robust <- m2 %>%
  map(~coeftest(., vcov. = vcovHC(.)))

m2robust %>%
  map_dfr(tidy, .id = "dv") %>%
  bind_cols(map_dfr(m2robust, confint_tidy)) %>%
  filter(term %in% c("exposureinconsistent", "exposureneutral", "exposureconsistent")) %>%
  mutate(group = recode_factor(dv, 
                               `employ_correct` = "Belief",
                               `sales_correct` = "Belief",
                               `jobs_pos` = "Interpretation",
                               `taxes_pos` = "Interpretation",
                               `immig_increased` = "Opinion",
                               .ordered = TRUE),
         outcome = recode_factor(dv, 
                                 `employ_correct` = "Employment correct",
                                 `sales_correct` = "Sales correct",
                                 `jobs_pos` = "Immigrants create jobs",
                                 `taxes_pos` = "Immigrants pay taxes",
                                 `immig_increased` = "Immigration should be increased",
                                 .ordered = TRUE),
         Exposure = recode_factor(term,
                                  `exposureinconsistent` = "Inonsistent",
                                  `exposureneutral` = "Neutral",
                                  `exposureconsistent` = "Consistent")) %>%
  ggplot(aes(y = estimate, ymin = conf.low, ymax = conf.high, x = outcome,
             shape = Exposure, col = Exposure)) + 
  geom_hline(yintercept = 0, col = "grey") +
  geom_point(position=position_dodge(width=0.4)) +
  geom_errorbar(width=0, position=position_dodge(width=0.4)) +
  theme_bw(base_size = 8) + 
  labs(x = NULL, y = "Coefficient", 
       col = "Forced\nExposure",
       shape = "Forced\nExposure") +
  facet_wrap(~group, scales = "free_x", ncol = 3) +
  scale_colour_brewer(palette = "Set1")


## ----m3, fig.height=2, fig.width=7, fig.cap="\\label{fig:m3}ACTE Estimates comparing exposure to Fox vs. MSNBC"----
df_assigned <- df %>%
  filter(condition == "assigned") %>%
  mutate(prefer = 
           as.numeric(tv_fox-tv_msnbc<0)
         + 2*as.numeric(tv_fox-tv_msnbc==0)
         + 3*as.numeric(tv_fox-tv_msnbc>0),
         prefer = factor(prefer, labels = c("msnbc","neutral","fox"))) %>%
  split(.$prefer)

extractDiff <- function(formula, data){
  tmp <- t.test(as.formula(formula), data=data)
  tibble(comparison = tmp$data.name,
         diff = diff(rev(tmp$estimate)),
         cilo = tmp$conf.int[1],
         cihi = tmp$conf.int[2])
}

m3 <- bind_rows(
  map_dfr(df_assigned, ~extractDiff(employ_correct~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(sales_correct~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(jobs_pos~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(taxes_pos~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(immig_increased~tweet, .), .id = "prefer")
) %>% 
  mutate(Preference = recode_factor(prefer,
                                    `fox` = "Fox",
                                    `neutral` = "Neither",
                                    `msnbc` = "MSNBC",
                                    .ordered = TRUE),
         comparison = gsub(" by tweet", "", comparison),
         group = recode_factor(comparison, 
                               `employ_correct` = "Belief",
                               `sales_correct` = "Belief",
                               `jobs_pos` = "Interpretation",
                               `taxes_pos` = "Interpretation",
                               `immig_increased` = "Opinion",
                               .ordered = TRUE),
         outcome = recode_factor(comparison, 
                                 `employ_correct` = "Employment correct",
                                 `sales_correct` = "Sales correct",
                                 `jobs_pos` = "Immigrants create jobs",
                                 `taxes_pos` = "Immigrants pay taxes",
                                 `immig_increased` = "Immigration should be increased",
                                 .ordered = TRUE))

ggplot(m3, aes(y = diff, ymin = cilo, ymax = cihi, x = outcome,
             shape = Preference, col = Preference)) + 
  geom_hline(yintercept = 0, col = "grey") +
  geom_point(position=position_dodge(width=0.4)) +
  geom_errorbar(width=0, position=position_dodge(width=0.4)) +
  theme_bw(base_size = 8) + 
  labs(x = NULL, y = "Treatment effect of reading\nFox rather than MSNBC",
       col = "Media\nPreference",
       shape = "Media\nPreference") +
  facet_wrap(~group, scales = "free_x", ncol=3) +
  scale_colour_brewer(palette = "Set1")


## ----m4, fig.height=2.7, fig.width=7, fig.cap="\\label{fig:m4}ACTE Estimates comparing exposure to Fox vs. MSNBC"----
m4 <- bind_rows(
  map_dfr(df_assigned, ~extractDiff(wp_accurate~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(wp_fair~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(wp_skewed~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(wp_bad~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(wp_hostile~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(wp_american~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(actions_seek~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(actions_discuss~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(actions_forward~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(actions_post~tweet, .), .id = "prefer")
) %>% 
  mutate(Preference = recode_factor(prefer,
                                    `fox` = "Fox",
                                    `neutral` = "Neither",
                                    `msnbc` = "MSNBC",
                                    .ordered = TRUE),
         comparison = gsub(" by tweet", "", comparison),
         group = recode_factor(comparison, 
                               `wp_accurate` = "Article evaluation",
                               `wp_fair` = "Article evaluation",
                               `wp_skewed` = "Article evaluation",
                               `wp_bad` = "Article evaluation",
                               `wp_hostile` = "Article evaluation",
                               `wp_american` = "Article evaluation",
                               `actions_seek` = "Subsequent engagement",
                               `actions_discuss` = "Subsequent engagement",
                               `actions_forward` = "Subsequent engagement",
                               `actions_post` = "Subsequent engagement",
                               .ordered = TRUE),
         outcome = recode_factor(comparison, 
                                 `wp_accurate` = "Accurate",
                                 `wp_fair` = "Fair",
                                 `wp_skewed` = "Skewed",
                                 `wp_bad` = "Bad",
                                 `wp_hostile` = "Hostile",
                                 `wp_american` = "American",
                                 `actions_seek` = "Seek more infos",
                                 `actions_discuss` = "Discuss with friends",
                                 `actions_forward` = "Forward via email",
                                 `actions_post` = "Post on social media",
                                 .ordered = TRUE))

ggplot(m4, aes(y = diff, ymin = cilo, ymax = cihi, x = outcome,
             shape = Preference, col = Preference)) + 
  geom_hline(yintercept = 0, col = "grey") +
  geom_point(position=position_dodge(width=0.4)) +
  geom_errorbar(width=0, position=position_dodge(width=0.4)) +
  theme_bw(base_size = 8) + 
  labs(x = NULL, y = "Treatment effect of reading\nFox rather than MSNBC",
       col = "Media\nPreference",
       shape = "Media\nPreference") +
  facet_wrap(~group, scales = "free_x", ncol=3) +
  scale_colour_brewer(palette = "Set1") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


## ----table, results='asis'--------------------------------------------------------------------------
stargazer(m1, 
          dep.var.caption = "",
          dep.var.labels = c("Employment", "Sales", "Jobs",
                             "Taxes", "Immigration"), 
          covariate.labels = c("Assigned", "Choice", "Racial Prejudice", "Immigration Problem", 
                               "Age", "Male", "Born in US", "White", "College", "Constant"),
          column.labels = c("Belief", "Interpretation", "Opinion"),
          column.separate = c(2,2,1),
          column.sep.width = "0pt", 
          title = "Main Treatment Effects", 
          table.placement = "h",
          header = FALSE,
          keep.stat = c("n", "rsq"))


## ----table2, results='asis'-------------------------------------------------------------------------
stargazer(m2, 
          dep.var.caption = "",
          dep.var.labels = c("Employment", "Sales", "Jobs",
                             "Taxes", "Immigration"), 
          covariate.labels = c("Inconsistent", "Neutral", "Consistent", 
                               "Racial Prejudice", "Immigration Problem", 
                               "Age", "Male", "Born in US", "White", "College", "Constant"),
          column.labels = c("Belief", "Interpretation", "Opinion"),
          column.separate = c(2,2,1),
          column.sep.width = "0pt", 
          title = "Main Treatment Effects", 
          table.placement = "h",
          header = FALSE,
          keep.stat = c("n", "rsq"))

