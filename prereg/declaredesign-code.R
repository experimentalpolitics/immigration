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

design <- # create experimental design object
  declare_population(N = 100, u = rnorm(N)) + # describes population by giving a 
  declare_potential_outcomes(Y ~ rbinom(n = N, size = 1, prob = 0.5 + 0.05 * Z)) + # identifies the outcome values; here they 
  declare_estimand(ATE = 0.05) + # declare estimand; here it is Average Treatment Effect, the difference between treated, untreated outcomes
  declare_assignment(m = 50) + # here each sampled unit is assigned independently, p = 0.5
  declare_estimator(Y ~ Z) # assumes ATE from estimand

diagnosis <- diagnose_design(design, diagnosands = declare_diagnosands(select = c("power", "bias"))) # assign object which has properties to diagnose
diagnosis

draw_estimates(design) # this draws once and gives the estimate



## Implement our design

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



#### Old attempt to implement 2x2 + 1 design


# treatment effects
mean_A0B0 <- .1
mean_A0B1 <- .2
mean_A1B0 <- .3
mean_A1B1 <- .5

# all control = 1 have the same mean = 0
mean_C1 <- 0

# weights (?)
weight_A <- 0
weight_B <- 0

## variation
sd_i <- 1
outcome_sds <- rep(0,5)

## declare population
population <- declare_population(N, u = rnorm(N, sd = sd_i))

## declare potential outcomes
potential_outcomes <- declare_potential_outcomes(Y_A_0_B_0 = mean_A0B0 + u + rnorm(N, sd = outcome_sds[1]),
                                                 Y_A_0_B_1 = mean_A0B1 + u + rnorm(N, sd = outcome_sds[2]),
                                                 Y_A_1_B_0 = mean_A1B0 + u + rnorm(N, sd = outcome_sds[3]),
                                                 Y_A_1_B_1 = mean_A1B1 + u + rnorm(N, sd = outcome_sds[4]),
                                                 Y_C_1 = mean_C1 + u + rnorm(N, sd = outcome_sds[5]))

# potential_outcomes <- declare_potential_outcomes(
#   formula = Y ~ .2 * Z1 + .1 * Z2 + .05 * Z1 * Z2 + rnorm(N, sd = sd_i),
#   conditions = list(Z1 = 0:1, Z2 = 0:2)
# )


## declare estimands
estimand_A1 <- declare_estimand(ate_A1 = weight_B * mean(Y_A_1_B_1 - Y_C_1) + 
                                 (1 - weight_B) * mean(Y_A_1_B_0 - Y_C_1))
estimand_A0 <- declare_estimand(ate_A0 = weight_B * mean(Y_A_0_B_1 - Y_C_1) + 
                                 (1 - weight_B) * mean(Y_A_0_B_0 - Y_C_1))
estimand_A <- declare_estimand(ate_A = weight_B * mean(Y_A_0_B_1 - Y_C_1) + 
                                  (1 - weight_B) * mean(Y_A_0_B_0 - Y_C_1))
estimand_3 <- declare_estimand(ate_B = weight_A * mean(Y_A_1_B_1 - Y_C_1) + 
                                 (1 - weight_B) * mean(Y_A_0_B_1 - Y_C_1))
estimand_4 <- declare_estimand(ate_B = weight_A * mean(Y_A_1_B_1 - Y_C_1) + 
                                 (1 - weight_B) * mean(Y_A_0_B_1 - Y_C_1))

estimand_2 <- declare_estimand(ate_B = mean(Y_A_1_B_1 - Y_A_1_B_0) + mean(Y_A_0_B_1 - Y_A_0_B_0))
estimand_3 <- declare_estimand(interaction = mean((Y_A_1_B_1 - 
                                                     Y_A_1_B_0) - (Y_A_0_B_1 - Y_A_0_B_0)))

## declare assignment
tmp <- declare_population(N = 10) + 
  declare_assignment(conditions = 1:5) + 
  declare_step(fabricate, 
               A = as.numeric(Z %in% 3:4), 
               B = as.numeric(Z %in% 4:5),
               C = as.numeric(Z == 1))
draw_data(tmp)

assign <- declare_assignment(conditions = 1:5)

treat <- declare_step(fabricate, T1 = as.numeric(Z %in% 2:3), T2 = as.numeric(Z %in% 4:5))

assign_A <- declare_assignment(prob = prob_A, assignment_variable = A)
assign_B <- declare_assignment(prob = prob_B, assignment_variable = B, 
                               blocks = A)
reveal_Y <- declare_reveal(Y_variables = Y, assignment_variables = c(A, 
                                                                     B))
estimator_1 <- declare_estimator(Y ~ A + B, model = lm_robust, 
                                 term = c("A", "B"), estimand = c("ate_A", "ate_B"), label = "No_Interaction")
estimator_2 <- declare_estimator(Y ~ A + B + A:B, model = lm_robust, 
                                 term = "A:B", estimand = "interaction", label = "Interaction")
two_by_two_design <- population + potential_outcomes + estimand_1 + 
  estimand_2 + estimand_3 + assign_A + assign_B + reveal_Y + 
  estimator_1 + estimator_2