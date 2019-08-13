##
##  Created by Nicholas R. Davis (nicholas@democracyobserver.org)
##  on 2019-04-23 14:16:52. Intended for Github distribution.
##  Modified by Patrick Kraft (kraftp@uwm.edu)
##  on 2019-07-08 16:58:26.
##
##########################################################
##  experimentalpolitics/immigration/declaredesign-code ##
##########################################################

#cd("/Users/nrdavis/Dropbox/political.science/DIRECTORY_HERE")

###################   LOAD  ##############################

library(DeclareDesign)

####################  CODE  ##############################


## Implement our design (basic ATEs)

N <- 500

## simplified 3-arm design

outcome_means <- c(0, .2, .4)
sd_i <- 1

population <- declare_population(
  N = N, u = rnorm(N, sd = sd_i))

potential_outcomes <- declare_potential_outcomes(
  formula = Y ~ outcome_means[1] * (Z == "1") + 
    outcome_means[2] * (Z == "2") + 
    outcome_means[3] * (Z == "3") + u, 
  conditions = c("1", "2", "3"), 
  assignment_variables = Z)

estimand <- declare_estimands(
  ate_Y_2_1 = mean(Y_Z_2 - Y_Z_1), 
  ate_Y_3_1 = mean(Y_Z_3 - Y_Z_1), 
  ate_Y_3_2 = mean(Y_Z_3 - Y_Z_2))

assignment <- declare_assignment(
  num_arms = 3, 
  conditions = c("1", "2", "3"), 
  assignment_variable = Z)

reveal_Y <- declare_reveal(
  assignment_variables = Z)

estimator <- declare_estimator(
  handler = function(data) {
    estimates <- rbind.data.frame(
      ate_Y_2_1 = difference_in_means(formula = Y ~ Z, data = data, condition1 = "1", condition2 = "2"), 
      ate_Y_3_1 = difference_in_means(formula = Y ~ Z, data = data, condition1 = "1", condition2 = "3"),
      ate_Y_3_2 = difference_in_means(formula = Y ~ Z, data = data, condition1 = "2", condition2 = "3"))
    names(estimates)[names(estimates) == "N"] <- "N_DIM"
    estimates$estimator_label <- c("DIM (Z_2 - Z_1)", "DIM (Z_3 - Z_1)", "DIM (Z_3 - Z_2)")
    estimates$estimand_label <- rownames(estimates)
    estimates$estimate <- estimates$coefficients
    estimates$term <- NULL
    return(estimates)
  })

multi_arm_design <- population + potential_outcomes + assignment + reveal_Y + estimand + estimator

diagnosis <- diagnose_design(multi_arm_design)
diagnosis <- diagnose_design(multi_arm_design, diagnosands = declare_diagnosands(select = c("power", "bias")))
diagnosis

draw_data(multi_arm_design) # one draw of simulated data
draw_estimates(multi_arm_design) # this draws once and gives the estimate
