# ecdf.R 
#################################################
# Description: This function takes a dataframe 
# with two columns (time, value). The first as.Date,
# in ISO-8601 format, in reverse chronological order, 
# and the second as a vector of numerical values.
# Example: 2019-08-06,1.73
#
# It then takes the remaining time, makes a vector of the log of the 
# quotient between current price divided by the price that was equal 
# to the remaining time left before the question for all the data 
# available. It then calculates a log mean and standard deviation 
# to create a standard distribution, which is then used to randomly 
# choose values for the Monte Carlo simulation. These randomly chosen 
# values are then returned to normal values using exponent and 
# multiplied by the current price by the number of simulations
# required in the script.

ecdf <- function(df,
                  closing_date, # for question
                  bins) { # bins=c(100,Inf)
                          # only two values, one is Inf
  
  # Set todays_date
  todays_date <- Sys.Date()
  
  # Set standard hands to a 100,000
  # hands=1000000
  hands=1
  
  # Format for probability functions
  source("./functions/probform.R")
  df <- probform(df)
  
  # Run the remaining_time function
  source("./functions/remaining_time.R")
  remaining_time <- remaining_time(df,
                                   closing_date)
  
  # Replaces negative values with zero
  df$value <- replace(df$value, df$value < 0,0) 
  
  # Filter out days with value of "."
  df <- filter(df, value != ".") 
  df %>% is.na()
  df %>% is.null()
  
  # Setting most recent value, assuming decreasing order
  current_value <- as.numeric(df[1,2])
  
  # Get the length of df$value and shorten it by a day
  deck_size <- length(df$value) - 1
  
  # Create a dataframe
  deck <- NULL
  
  # Iterate through each value and subtract the difference 
  # from the next row, or period to create hand.
  for (i in 1:deck_size) {
    # Avoiding dividing by zero and negatives
    # since log normal needs positive values 
    if (df$value[i+1] <= 0) {
      deck[i+remaining_time] <- 1
    } else {
      # Logarithmic prices are always in a standard distribution
      deck[i] <- log(df$value[i] / df$value[i+1])
    }
  }
  
  # View(deck)
  
  deck[!is.finite(deck)] <- 0
  deck[is.na(deck)] <- 0
  
  # Calculate standard deviation (sig) and mean of hand (mu)
  sig <- sd(deck)
  mu <- mean(deck)
  
  # Create data frame, create a randomly generated vector of hands
  # and then multiple the vector for each period remaining.
  prob_calc <- as.data.frame(NULL)
  mean_prob_calc <- NULL
  
  prob_calc <- current_value * exp(rnorm(hands, mean = mu, sd = sig))
  mean_prob_calc[1] <- mean(prob_calc)
  for (i in 2:remaining_time) {
    prob_calc <- prob_calc * exp(rnorm(hands, mean = mu, sd = sig))
    mean_prob_calc[i] <- mean(prob_calc)
  }
  
  ecdf_dist <- (ecdf(mean_prob_calc)) # for testing
  ecdf_dist(0.0)
  return(plot(ecdf_dist))

}
