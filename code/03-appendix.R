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

## ----model-5x, cache = TRUE-----------------------------------------------------------------------------
## model 5x
df_assigned <- df %>%
  filter(condition == "assigned") %>%
  split(.$prefer)

extractDiff <- function(formula, data){
  tmp <- t.test(as.formula(formula), data=data)
  tibble(comparison = tmp$data.name,
         diff = diff(rev(tmp$estimate)),
         cilo = tmp$conf.int[1],
         cihi = tmp$conf.int[2])
}


m5 <- bind_rows(
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

p5 <- ggplot(m5, aes(y = diff, ymin = cilo, ymax = cihi, x = outcome,
               shape = Preference, col = Preference)) + 
  geom_hline(yintercept = 0, col = "grey") +
  geom_point(position=position_dodge(width=0.4)) +
  geom_errorbar(width=0, position=position_dodge(width=0.4)) +
  theme_light(base_size = 8) + 
  labs(x = NULL, y = "Treatment effect of reading\nFox rather than MSNBC",
       col = "Media\npreference",
       shape = "Media\npreference") +
  facet_wrap(~group, scales = "free_x", ncol=3) +
  scale_colour_manual(values = c("darkred","darkgreen","darkblue"))


## ----model-6x, cache = TRUE-----------------------------------------------------------------------------
## model 6x
m6 <- bind_rows(
  map_dfr(df_assigned, ~extractDiff(wp_accurate~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(wp_fair~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(wp_balanced~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(wp_good~tweet, .), .id = "prefer"),
  map_dfr(df_assigned, ~extractDiff(wp_friendly~tweet, .), .id = "prefer"),
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
                               `wp_balanced` = "Article evaluation",
                               `wp_accurate` = "Article evaluation",
                               `wp_fair` = "Article evaluation",
                               `wp_good` = "Article evaluation",
                               `wp_friendly` = "Article evaluation",
                               `wp_american` = "Article evaluation",
                               `actions_seek` = "Subsequent engagement",
                               `actions_discuss` = "Subsequent engagement",
                               `actions_forward` = "Subsequent engagement",
                               `actions_post` = "Subsequent engagement",
                               .ordered = TRUE),
         outcome = recode_factor(comparison, 
                                 `wp_balanced` = "Balanced",
                                 `wp_accurate` = "Accurate",
                                 `wp_fair` = "Fair",
                                 `wp_good` = "Good",
                                 `wp_friendly` = "Friendly",
                                 `wp_american` = "American",
                                 `actions_seek` = "Seek more info",
                                 `actions_discuss` = "Discuss with friends",
                                 `actions_forward` = "Forward via email",
                                 `actions_post` = "Post on social media",
                                 .ordered = TRUE))

p6 <- ggplot(m6, aes(y = diff, ymin = cilo, ymax = cihi, x = outcome,
             shape = Preference, col = Preference)) + 
  geom_hline(yintercept = 0, col = "grey") +
  geom_point(position=position_dodge(width=0.4)) +
  geom_errorbar(width=0, position=position_dodge(width=0.4)) +
  theme_light(base_size = 8) + 
  labs(x = NULL, y = "Treatment effect of reading\nFox rather than MSNBC",
       col = "Media\npreference",
       shape = "Media\npreference") +
  facet_wrap(~group, scales = "free_x", ncol=3) +
  scale_colour_manual(values = c("darkred","darkgreen","darkblue")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

## -------------------------------------------------------------------------------------------------------
m7 <- list(wp_balanced = lm(wp_balanced ~ condition
                            + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                            + age + male + usborn + white + college
                            , data = df),
           wp_accurate = lm(wp_accurate ~ condition
                            + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                            + age + male + usborn + white + college
                            , data = df),
           wp_fair = lm(wp_fair ~ condition
                        + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                        + age + male + usborn + white + college
                        , data = df),
           wp_good = lm(wp_good ~ condition
                        + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                        + age + male + usborn + white + college
                        , data = df),
           wp_friendly = lm(wp_friendly ~ condition
                            + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                            + age + male + usborn + white + college
                            , data = df),
           wp_american = lm(wp_american ~ condition
                            + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                            + age + male + usborn + white + college
                            , data = df),
           actions_seek = lm(actions_seek ~ condition
                             + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                             + age + male + usborn + white + college
                             , data = df),
           actions_discuss = lm(actions_discuss ~ condition
                                + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                                + age + male + usborn + white + college
                                , data = df),
           actions_forward = lm(actions_forward ~ condition
                                + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                                + age + male + usborn + white + college
                                , data = df),
           actions_post = lm(actions_post ~ condition
                             + lazy_hispanics + problem_immigration + ideol_con + pid_rep
                             + age + male + usborn + white + college
                             , data = df)) %>%
  map(~coeftest(., vcov. = vcovHC(.)))