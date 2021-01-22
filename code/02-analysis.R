library(tidyverse)
library(broom)
library(sandwich)
library(stargazer)
library(lmtest)
library(car)
library(here)


## ----data, cache = TRUE---------------------------------------------------------------------------------
## Load data
df <- read_csv(here("data/immigration_20191219_clean.csv")) %>%
  mutate(condition = factor(condition, levels = c("control", "assigned", "choice")),
         wp_balanced = 1-wp_skewed,
         wp_good = 1-wp_bad,
         wp_friendly = 1-wp_hostile,
         prefer = (tv_fox-tv_msnbc==0) + 2*(tv_fox-tv_msnbc>0),
         prefer = factor(prefer, labels = c("msnbc","neutral","fox")),
         exposure = ((prefer=="fox" & tweet=="msnbc")|(prefer=="msnbc" & tweet=="fox")) + 
           2*(prefer=="neutral" & tweet!="control") + 3*(prefer==tweet),
         exposure = factor(exposure, labels = c("control","inconsistent","neutral","consistent")))


## ----model-1, cache = TRUE------------------------------------------------------------------------------
## model 1: forced exposure vs. free choice
m1 <- list(employ_correct = lm(employ_correct ~ condition
                               + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                               + age + male + usborn + white + college
                               , data = df),
           sales_correct = lm(sales_correct ~ condition
                              + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                              + age + male + usborn + white + college
                              , data = df),
           jobs_pos = lm(jobs_pos ~ condition
                         + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                         + age + male + usborn + white + college
                         , data = df),
           taxes_pos = lm(taxes_pos ~ condition
                          + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                          + age + male + usborn + white + college
                          , data = df),
           immig_increased = lm(immig_increased ~ condition
                                + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                                + age + male + usborn + white + college
                                , data = df))

m1robust <- m1 %>%
  map(~coeftest(., vcov. = vcovHC(.)))
  
p1 <- m1robust %>%
  map_dfr(tidy, .id = "dv") %>%
  bind_cols(map_dfr(m1robust, confint_tidy)) %>%
  rename(cilo95 = conf.low, cihi95 = conf.high) %>%
  bind_cols(map_dfr(m1robust, confint_tidy, conf.level = 0.9)) %>%
  rename(cilo90 = conf.low, cihi90 = conf.high) %>%
  filter(term %in% c("conditionassigned", "conditionchoice")) %>%
  mutate(group = recode_factor(dv, 
                               `employ_correct` = "Belief",
                               `sales_correct` = "Belief",
                               `jobs_pos` = "Interpretation",
                               `taxes_pos` = "Interpretation",
                               `immig_increased` = "Opinion",
                               .ordered = TRUE),
         outcome = recode_factor(dv, 
                                 `employ_correct` = "Employment\ncorrect",
                                 `sales_correct` = "Sales\ncorrect",
                                 `jobs_pos` = "Immigrants\ncreate jobs",
                                 `taxes_pos` = "Immigrants\npay taxes",
                                 `immig_increased` = "Immigration should\nbe increased",
                                 .ordered = TRUE),
         Condition = recode_factor(term,
                                   `conditionassigned` = "Forced\nexposure",
                                   `conditionchoice` = "Free\nchoice")) %>%
  ggplot(aes(y = estimate, x = outcome,
             shape = Condition, col = Condition)) + 
  geom_hline(yintercept = 0, col = "grey") +
  geom_point(size = 3, position=position_dodge(width=0.4)) +
  geom_linerange(aes(ymin = cilo95, ymax = cihi95), size=.75, position=position_dodge(width=0.4)) +
  geom_linerange(aes(ymin = cilo90, ymax = cihi90), size=1.5, position=position_dodge(width=0.4)) +
  theme_light(base_size = 10) + 
  labs(x = NULL, y = "Coefficient", 
       col = "Experimental\ncondition",
       shape = "Experimental\ncondition") +
  facet_wrap(~group, scales = "free_x", ncol = 3) +
  scale_color_brewer(palette = "Paired")


## ----model-2, cache = TRUE------------------------------------------------------------------------------
## model 2: inconsistent vs. consistent forced exposure
df_nochoice <- df %>%
  filter(condition != "choice")

m2 <- list(employ_correct = lm(employ_correct ~ exposure
                               + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                               + age + male + usborn + white + college
                               , data = df_nochoice),
           sales_correct = lm(sales_correct ~ exposure
                              + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                              + age + male + usborn + white + college
                              , data = df_nochoice),
           jobs_pos = lm(jobs_pos ~ exposure
                         + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                         + age + male + usborn + white + college
                         , data = df_nochoice),
           taxes_pos = lm(taxes_pos ~ exposure
                          + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                          + age + male + usborn + white + college
                          , data = df_nochoice),
           immig_increased = lm(immig_increased ~ exposure
                                + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                                + age + male + usborn + white + college
                                , data = df_nochoice))

m2robust <- m2 %>%
  map(~coeftest(., vcov. = vcovHC(.)))

m2df <- m2robust %>%
  map_dfr(tidy, .id = "dv") %>%
  bind_cols(map_dfr(m2robust, confint_tidy)) %>%
  rename(cilo95 = conf.low, cihi95 = conf.high) %>%
  bind_cols(map_dfr(m2robust, confint_tidy, conf.level = 0.9)) %>%
  rename(cilo90 = conf.low, cihi90 = conf.high) %>%
  filter(term %in% c("exposureinconsistent", "exposureneutral", "exposureconsistent")) %>%
  mutate(group = recode_factor(dv, 
                               `employ_correct` = "Belief",
                               `sales_correct` = "Belief",
                               `jobs_pos` = "Interpretation",
                               `taxes_pos` = "Interpretation",
                               `immig_increased` = "Opinion",
                               .ordered = TRUE),
         outcome = recode_factor(dv, 
                                 `employ_correct` = "Employment\ncorrect",
                                 `sales_correct` = "Sales\ncorrect",
                                 `jobs_pos` = "Immigrants\ncreate jobs",
                                 `taxes_pos` = "Immigrants\npay taxes",
                                 `immig_increased` = "Immigration should\nbe increased",
                                 .ordered = TRUE),
         Exposure = recode_factor(term,
                                  `exposureinconsistent` = "Inconsistent",
                                  `exposureneutral` = "Neutral",
                                  `exposureconsistent` = "Consistent"),
         condition = "Forced exposure")


## ----model-3, cache = TRUE------------------------------------------------------------------------------
## model 3: forced exposure vs. free choice while holding consistency constant
df_noforce <- df %>%
  filter(condition != "force")

m3 <- list(employ_correct = lm(employ_correct ~ exposure
                               + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                               + age + male + usborn + white + college
                               , data = df_noforce),
           sales_correct = lm(sales_correct ~ exposure
                              + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                              + age + male + usborn + white + college
                              , data = df_noforce),
           jobs_pos = lm(jobs_pos ~ exposure
                         + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                         + age + male + usborn + white + college
                         , data = df_noforce),
           taxes_pos = lm(taxes_pos ~ exposure
                          + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                          + age + male + usborn + white + college
                          , data = df_noforce),
           immig_increased = lm(immig_increased ~ exposure
                                + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                                + age + male + usborn + white + college
                                , data = df_noforce))

m3robust <- m3 %>%
  map(~coeftest(., vcov. = vcovHC(.)))

m3df <- m3robust %>%
  map_dfr(tidy, .id = "dv") %>%
  bind_cols(map_dfr(m3robust, confint_tidy)) %>%
  rename(cilo95 = conf.low, cihi95 = conf.high) %>%
  bind_cols(map_dfr(m3robust, confint_tidy, conf.level = 0.9)) %>%
  rename(cilo90 = conf.low, cihi90 = conf.high) %>%
  filter(term %in% c("exposureinconsistent", "exposureneutral", "exposureconsistent")) %>%
  mutate(group = recode_factor(dv, 
                               `employ_correct` = "Belief",
                               `sales_correct` = "Belief",
                               `jobs_pos` = "Interpretation",
                               `taxes_pos` = "Interpretation",
                               `immig_increased` = "Opinion",
                               .ordered = TRUE),
         outcome = recode_factor(dv, 
                                 `employ_correct` = "Employment\ncorrect",
                                 `sales_correct` = "Sales\ncorrect",
                                 `jobs_pos` = "Immigrants\ncreate jobs",
                                 `taxes_pos` = "Immigrants\npay taxes",
                                 `immig_increased` = "Immigration should\nbe increased",
                                 .ordered = TRUE),
         Exposure = recode_factor(term,
                                  `exposureinconsistent` = "Inconsistent",
                                  `exposureneutral` = "Neutral",
                                  `exposureconsistent` = "Consistent"),
         condition = "Free choice")

p2 <- bind_rows(m2df, m3df) %>%
  ggplot(aes(y = estimate, x = outcome,
             shape = Exposure, col = Exposure)) + 
  geom_hline(yintercept = 0, col = "grey") +
  geom_point(size = 3, position=position_dodge(width=0.4)) +
  geom_linerange(aes(ymin = cilo95, ymax = cihi95), size=.75, position=position_dodge(width=0.4)) +
  geom_linerange(aes(ymin = cilo90, ymax = cihi90), size=1.5, position=position_dodge(width=0.4)) +
  theme_light(base_size = 10) + 
  labs(x = NULL, y = "Coefficient", 
       col = "Media\nexposure",
       shape = "Media\nexposure") +
  facet_grid(condition~group, scales = "free_x") +
  scale_color_brewer(palette = "Dark2")


## ----model-4, cache = TRUE------------------------------------------------------------------------------
## model 4: forced exposure vs. free choice (holding inconsistent exposure)
df_consistent <- df %>%
  filter(exposure == "inconsistent")

m4 <- list(employ_correct = lm(employ_correct ~ condition
                               + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                               + age + male + usborn + white + college
                               , data = df_consistent),
           sales_correct = lm(sales_correct ~ condition
                              + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                              + age + male + usborn + white + college
                              , data = df_consistent),
           jobs_pos = lm(jobs_pos ~ condition
                         + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                         + age + male + usborn + white + college
                         , data = df_consistent),
           taxes_pos = lm(taxes_pos ~ condition
                          + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                          + age + male + usborn + white + college
                          , data = df_consistent),
           immig_increased = lm(immig_increased ~ condition
                                + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                                + age + male + usborn + white + college
                                , data = df_consistent))

m4robust <- m4 %>%
  map(~coeftest(., vcov. = vcovHC(.)))

p4 <- m4robust %>%
  map_dfr(tidy, .id = "dv") %>%
  bind_cols(map_dfr(m4robust, confint_tidy)) %>%
  rename(cilo95 = conf.low, cihi95 = conf.high) %>%
  bind_cols(map_dfr(m4robust, confint_tidy, conf.level = 0.9)) %>%
  rename(cilo90 = conf.low, cihi90 = conf.high) %>%
  filter(term %in% c("conditionassigned", "conditionchoice")) %>%
  mutate(group = recode_factor(dv, 
                               `employ_correct` = "Belief",
                               `sales_correct` = "Belief",
                               `jobs_pos` = "Interpretation",
                               `taxes_pos` = "Interpretation",
                               `immig_increased` = "Opinion",
                               .ordered = TRUE),
         outcome = recode_factor(dv, 
                                 `employ_correct` = "Employment\ncorrect",
                                 `sales_correct` = "Sales\ncorrect",
                                 `jobs_pos` = "Immigrants\ncreate jobs",
                                 `taxes_pos` = "Immigrants\npay taxes",
                                 `immig_increased` = "Immigration should\nbe increased",
                                 .ordered = TRUE),
         Condition = recode_factor(term,
                                   `conditionassigned` = "Forced\nexposure",
                                   `conditionchoice` = "Free\nchoice")) %>%
  ggplot(aes(y = estimate, x = outcome)) + 
  geom_hline(yintercept = 0, col = "grey") +
  geom_point(size = 3, position=position_dodge(width=0.4)) +
  geom_linerange(aes(ymin = cilo95, ymax = cihi95), size=.75, position=position_dodge(width=0.4)) +
  geom_linerange(aes(ymin = cilo90, ymax = cihi90), size=1.5, position=position_dodge(width=0.4)) +
  theme_light(base_size = 10) + 
  labs(x = NULL, y = "Effect of free choice\nvs. forced exposure condition") +
  facet_wrap(~group, scales = "free_x", ncol = 3)
