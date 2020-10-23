# Demographic Tables

## Load Data

setwd("C:/Users/19204/OneDrive/Desktop")
imm <- read.csv("immigration_2019_clean.csv")

install.packages("qwraps2")
library(qwraps2)

# Full Sample Demographics

## Create Variables

age <- imm$age
sex <- na.omit(imm$male)
race <- imm$race
educ <- imm$educ
income <- imm$income

mean_sd(imm$age, denote_sd = "paren")
sex <- na.omit(imm$male)
educ <- imm$educ

## Create Table

full_sample <-
  list("Age" =
         list("Minimum"       = ~ min(age),
              "Maximum"       = ~ max(age),
              "Mean (Standard Deviation)" = ~ qwraps2::mean_sd(age)),
       "Sex" =
         list("Male"      = ~ n_perc(sex == 1),
              "Female"    = ~ n_perc(sex == 0)),
       "Race" = 
         list("White"     = ~ n_perc(race == "Caucasian/White (non-Hispanic)"),
              "Asian/Pacific Islander"     = ~ n_perc(race == "Asian/Pacific Islanders"), 
              "Black"     = ~ n_perc(race == "Black or African-American (non-Hispanic)"),
              "Hispanic"  = ~ n_perc(race == "Hispanic or Latino"),
              "Middle Eastern" = ~ n_perc(race == "Middle Eastern"),
              "Native American" = ~ n_perc(race == "Native American or Aleut"),
              "Other" = ~ n_perc(race == "Other")),
       "Highest Education Level" = 
         list("Post-Graduate Degree"   = ~ n_perc(educ == "Completed post-graduate or professional school, with degree"),
              "4-year Degree"     = ~ n_perc(educ == "Graduated 4-year college"),
              "2-year Degree"     = ~ n_perc(educ == "Graduated 2-year college"),
              "Some College"      = ~ n_perc(educ == "Some college but no college degree"),
              "High School"       = ~ n_perc(educ == "Graduated high school or GED"),
              "Less than High School"  = ~ n_perc(educ == "Less than a high school diploma")),
       "Income Level" =
         list("$120,000 +"      = ~ n_perc(inc == "1.0000000"),
              "$119,999 - $100,000"   = ~ n_perc(inc == "0.8333333"),
              "$99,999 - $80,000"     = ~ n_perc(inc == "0.6666667"),
              "$79,999 - $60,000"     = ~ n_perc(inc == "0.5"),
              "$59,999 - $40,000"     = ~ n_perc(inc == "0.3333333"),
              "$39,999 - $20,000"     = ~ n_perc(inc == "0.1666667"),
              "< $20,000"       = ~ n_perc(inc == "0"))
       
  )

# Treatment Sample 

## Create Variables

imm_treat <- subset(imm, tweet == "fox" | tweet == "msnbc")

age_treat <- imm_treat$age
sex_treat <- na.omit(imm_treat$male)
race_treat <- imm_treat$race
educ_treat <- imm_treat$educ
income_treat <- imm_treat$income

full_sample <-
  list("Age" =
         list("Minimum"       = ~ min(age_treat),
              "Maximum"       = ~ max(age_treat),
              "Mean (Standard Deviation)" = ~ qwraps2::mean_sd(age_treat)),
       "Sex" =
         list("Male"      = ~ n_perc(sex_treat == 1),
              "Female"    = ~ n_perc(sex_treat == 0)),
       "Race" = 
         list("White"     = ~ n_perc(race_treat == "Caucasian/White (non-Hispanic)"),
              "Asian/Pacific Islander"     = ~ n_perc(race_treat == "Asian/Pacific Islanders"), 
              "Black"     = ~ n_perc(race_treat == "Black or African-American (non-Hispanic)"),
              "Hispanic"  = ~ n_perc(race_treat == "Hispanic or Latino"),
              "Middle Eastern" = ~ n_perc(race_treat == "Middle Eastern"),
              "Native American" = ~ n_perc(race_treat == "Native American or Aleut"),
              "Other" = ~ n_perc(race_treat == "Other")),
       "Highest Education Level" = 
         list("Post-Graduate Degree"   = ~ n_perc(educ_treat == "Completed post-graduate or professional school, with degree"),
              "4-year Degree"     = ~ n_perc(educ_treat == "Graduated 4-year college"),
              "2-year Degree"     = ~ n_perc(educ_treat == "Graduated 2-year college"),
              "Some College"      = ~ n_perc(educ_treat == "Some college but no college degree"),
              "High School"       = ~ n_perc(educ_treat == "Graduated high school or GED"),
              "Less than High School"  = ~ n_perc(educ_treat == "Less than a high school diploma")),
       "Income Level" =
         list("$120,000 +"      = ~ n_perc(income_treat == "1.0000000"),
              "$119,999 - $100,000"   = ~ n_perc(income_treat == "0.8333333"),
              "$99,999 - $80,000"     = ~ n_perc(income_treat == "0.6666667"),
              "$79,999 - $60,000"     = ~ n_perc(income_treat == "0.5"),
              "$59,999 - $40,000"     = ~ n_perc(income_treat == "0.3333333"),
              "$39,999 - $20,000"     = ~ n_perc(income_treat == "0.1666667"),
              "< $20,000"       = ~ n_perc(income_treat == "0"))
       
  )
