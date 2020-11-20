# Balance Checks 

## Load Data -

setwd("C:/Users/19204/OneDrive/Desktop/Lab Work")
imm <- read.csv("immigration_2019_clean.csv")

##View(imm)

## Packages -

install.packages("cobalt")
library(cobalt)
install.packages("MatchIt")
library(MatchIt)
install.packages("WeightIt")
library(WeightIt)

# Age Balance Check (Distributional Balance)

age <- subset(imm, select = c(age))
age_W.out <- weightit(treatment ~ age, data = imm,
                      method = "ps", estimand = "ATT")
bal.tab(age_W.out)
bal_plot_age <- bal.plot(age_W.out, var.name = "age")

# Sex Balance Check

sex <- subset(imm, select = c(male))
sex_W.out <- weightit(treatment ~ sex, data = imm,
                      method = "ps", estimand = "ATT")
bal.tab(sex_W.out)
bal_plot_sex <- bal.plot(sex_W.out, var.name = "male")

# College Balance Check

college <- subset(imm, select = c(college))
college_W.out <- weightit(treatment ~ college, data = imm,
                          method = "ps", estimand = "ATT")
bal.tab(college_W.out)
bal_plot_college <- bal.plot(college_W.out, var.name = "college")

# PID Balance Check

PID <- subset(imm, select = c(pid_rep))
PID_W.out <- weightit(treatment ~ pid_rep, data = imm,
                      method = "ps", estimand = "ATT")
bal.tab(PID_W.out)
bal_plot_PID <- bal.plot(PID_W.out, var.name = "pid_rep")

# Ideology Balance Check

ideo <- subset(imm, select = c(ideol_con))
ideo_W.out <- weightit(treatment ~ ideol_con, data = imm,
                       method = "ps", estimand = "ATT")
bal.tab(ideo_W.out)
bal_plot_ideo <- bal.plot(ideo_W.out, var.name = "ideol_con")

# Graphs

bal_plot_age
bal_plot_sex
bal_plot_college
bal_plot_PID
bal_plot_ideo

# Love Plot Attempt

(W1 <- weightit(treatment ~ age + college + pid_rep + sex + ideol_con, data = imm,
                method = "ps", estimand = "ATT",
                link = "probit"))
bal.tab(W1, var.name = "test")
love.plot(W1, thresholds = c(cor = .1), abs = TRUE,
          var.order = "unadjusted", line = TRUE)
love_test <- love.plot(W1, binary = "std", thresholds = c(m = .1))
