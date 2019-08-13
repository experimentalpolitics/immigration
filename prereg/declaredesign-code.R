##
##  Created by Nicholas R. Davis (nicholas@democracyobserver.org)
##  on 2019-04-23 14:16:52. Intended for Github distribution.
##  Modified by Patrick Kraft (kraftp@uwm.edu)
##  on 2019-07-08 16:58:26.
##
##########################################################
##  experimentalpolitics/immigration/declaredesign-code ##
##########################################################

# no need to check working directory; code creates no output

###################   LOAD  ##############################

library(DeclareDesign)

####################  CODE  ##############################



### simplified 3-arm design (ATE w/o differentiating sources)

N <- 550
outcome_means <- c(0, .1, .3)
sd_i <- 1

population <- declare_population(
  N = N, u = rnorm(N, sd = sd_i))

potential_outcomes <- declare_potential_outcomes(
  formula = Y ~ outcome_means[1] * (Z == "0") + 
    outcome_means[2] * (Z == "1") + 
    outcome_means[3] * (Z == "2") + u, 
  conditions = c("0", "1", "2"), 
  assignment_variables = Z)

estimand <- declare_estimands(
  ate_Y_1_0 = mean(Y_Z_1 - Y_Z_0), 
  ate_Y_2_0 = mean(Y_Z_2 - Y_Z_0), 
  ate_Y_2_1 = mean(Y_Z_2 - Y_Z_1))

assignment <- declare_assignment(
  num_arms = 3, 
  conditions = c("0", "1", "2"), 
  assignment_variable = Z)

reveal_Y <- declare_reveal(
  assignment_variables = Z)

estimator <- declare_estimator(
  handler = function(data) {
    estimates <- rbind.data.frame(
      ate_Y_1_0 = difference_in_means(formula = Y ~ Z, data = data, condition1 = "0", condition2 = "1"), 
      ate_Y_2_0 = difference_in_means(formula = Y ~ Z, data = data, condition1 = "0", condition2 = "2"),
      ate_Y_2_1 = difference_in_means(formula = Y ~ Z, data = data, condition1 = "1", condition2 = "2"))
    names(estimates)[names(estimates) == "N"] <- "N_DIM"
    estimates$estimator_label <- c("DIM (Z_1 - Z_0)", "DIM (Z_2 - Z_0)", "DID (Z_2 - Z_1)")
    estimates$estimand_label <- rownames(estimates)
    estimates$estimate <- estimates$coefficients
    estimates$term <- NULL
    return(estimates)
  })

multi_arm_design <- population + potential_outcomes + assignment + reveal_Y + estimand + estimator

# single draw of simulated data
head(draw_data(multi_arm_design))

# display estimates for single draw
draw_estimates(multi_arm_design)

# diagnose design based on 500 simulations
diagnosis <- diagnose_design(multi_arm_design, diagnosands = declare_diagnosands(
  select = c("power", "bias","mean_estimate")))
diagnosis



### conditional effects depending on media preference (ACTE following Knox)
# Q: take into account participants who are indifferent?
# Q: add control condition (no exposure at all)?
# Q: S should not be randomly assigned?

Nforced <- round(N/3)
Sfox_Afox <- .2 # note: S = preferred treatment, A = actual treatment
Sfox_Amsnbc <- .0
Smsnbc_Afox <- .3
Smsnbc_Amsnbc <- .4
sd_i <- 1

population <- declare_population(
  N = Nforced, u = rnorm(Nforced, sd = sd_i))

potential_outcomes <- declare_potential_outcomes(
  formula = Y ~ 0 + 
    Sfox_Afox * (Z == "1") + 
    Sfox_Amsnbc * (Z == "2") + 
    Smsnbc_Afox * (Z == "3") + 
    Smsnbc_Amsnbc * (Z == "4") + u, 
  conditions = c("1", "2", "3","4"), 
  assignment_variables = Z)

estimand <- declare_estimands(
  acte_Y_fox = mean(Y_Z_1 - Y_Z_2), 
  acte_Y_msnbc = mean(Y_Z_4 - Y_Z_3))

assignment <- declare_assignment(
  num_arms = 4, 
  conditions = c("1", "2", "3", "4"), 
  assignment_variable = Z)

reveal_Y <- declare_reveal(
  assignment_variables = Z)

estimator <- declare_estimator(
  handler = function(data) {
    estimates <- rbind.data.frame(
      acte_Y_fox = difference_in_means(formula = Y ~ Z, data = data, condition1 = "2", condition2 = "1"), 
      acte_Y_msnbc = difference_in_means(formula = Y ~ Z, data = data, condition1 = "3", condition2 = "4"))
    names(estimates)[names(estimates) == "N"] <- "N_DIM"
    estimates$estimator_label <- c("DIM (Z_1 - Z_2)", "DIM (Z_4 - Z_3)")
    estimates$estimand_label <- rownames(estimates)
    estimates$estimate <- estimates$coefficients
    estimates$term <- NULL
    return(estimates)
  })

multi_arm_design <- population + potential_outcomes + assignment + reveal_Y + estimand + estimator

# single draw of simulated data
head(draw_data(multi_arm_design))

# display estimates for isngle draw
draw_estimates(multi_arm_design)

# diagnose design based on 500 simulations
diagnosis <- diagnose_design(multi_arm_design, diagnosands = declare_diagnosands(
  select = c("power", "bias","mean_estimate")))
diagnosis
