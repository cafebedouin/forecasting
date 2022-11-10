# probfun.R 
#################################################
# Description: Intermediate function call that 
# calls all probabilistic functions available, which 
# generate probability tables for the forecast period by:
#
# 1. historical: straight historical probability table
#    generation using same period as forecast interval
# 2. monte-lazy: creates a standard distribution
#    curve for forecast interval, randomly selects
#    from the curve to generate probability table
# 3. monte-full: creates a randomly selected vector 
#    for each data point interval in the data table, 
#    then multiplies the vectors over the remaining time 
#    in the forecast period.
# 4. monte-threshold: same as monte-full, except counts
#    the results of each data period to determine if 
#    the number has surpassed a threshold. 
# 5. probands: generates probability bands based on the
#    standard distribution of the data, pointing to 
#    numerical values which is created using percent bins. 
# 6. standist: like probands, generates probability by 
#    projecting the mean and standard deviation based on 
#    historical values, and then generates probablisatic 
#    percentages for forecasting specific numerical ranges.

probfun <- function(df,
                    closing_date,
                    bins,
                    prob_type) {
  
  if (prob_type == "historical") {
    source("./functions/historical.R")
    result <- return(historical(df, closing_date, bins)) }
  
  if (prob_type == "monte-lazy") {
    source("./functions/monte-lazy.R")
    result <- return(monte(df, closing_date, bins)) }
  
  if (prob_type == "monte-full") {
    source("./functions/monte-full.R")
    result <- return(monte(df, closing_date, bins)) }
  
  if (prob_type == "monte-threshold") {
    source("./functions/monte-threshold.R")
    result <- return(monte(df, closing_date, bins)) }

  if (prob_type == "probands") {
    source("./functions/probands.R")
    result <- return(probands(df, closing_date, bins)) }
  
  if (prob_type == "standist") {
    source("./functions/standist.R")
    result <- return(standist(df, closing_date, bins)) }
  
  if (prob_type == "ecdf") {
    source("./functions/ecdf.R")
    result <- return(ecdf(df, closing_date, bins)) }
  
}