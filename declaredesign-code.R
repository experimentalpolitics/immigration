##
##  Created by Nicholas R. Davis (nicholas@democracyobserver.org)
##  on 2019-04-23 14:16:52. Intended for Github distribution.
##
##########################################################
##  experimentalpolitics/immigration/declaredesign-code ##
##########################################################

cd("/Users/nrdavis/Dropbox/political.science/DIRECTORY_HERE")

###################   LOAD  ##############################

require(DeclareDesign)

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