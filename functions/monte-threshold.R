# monte-threshold.R 
#################################################
# Description: This function takes a dataframe 
# with two columns (time, value). The first as.Date,
# in ISO-8601 format, in reverse chronological order, 
# and the second as a vector of numerical values.
# Example: 2019-08-06,1.73

monte <- function(df,
                  closing_date, # for question
                  bins) { # bins=c(100,Inf)
                          # only two values, one is Inf
  
  # Set todays_date
  todays_date <- Sys.Date()
  
  # Set standard hands to a million
  sims=1000000
  # sims=10
  
  # Format for probability functions
  source("./functions/probform.R")
  df <- probform(df)
  
  # Run the remaining_time function
  source("./functions/remaining_time.R")
  remaining_time <- remaining_time(df,
                                   closing_date)
  
  # Replaces negative values with zero
  df$value <- replace(df$value, df$value < 0,0) 
  
  # Setting most recent value, assuming decreasing order
  current_value <- as.numeric(df[1,2])
  
  # Get the length of df$value and shorten it by 1
  periods <- length(df$value) - 1
  
  # Create a dataframe
  deck <- NULL
  
  # Iterate through each value and subtract the difference 
  # from the next row, or period to create hand.
  for (i in 1:periods) {
    # Avoiding dividing by zero  
    if (df$value[i+1] == 0) {
      deck[i] <- 0
    } else {
      # Logarithmic prices are always in a standard distribution
      deck[i] <- log(df$value[i] / df$value[i+1])
    }
  }
  
  View(deck)
  deck[!is.finite(deck)] <- 0
  deck[is.na(deck)] <- 0
  
  # Calculate standard deviation (sig) and mean of deck (mu)
  sig <- sd(deck)
  mu <- mean(deck)
  
  # Create data frame
  prob_calc <- NULL
  counter <- 0
  
  # Creates a standard distribution and random samples it 
  # remaining times to create a hand, or simulation. Multiplies 
  # previous intervals results with next sample. Filters results
  # by threshold by remaining days. Repeats for all remaining days.
  prob_calc <- NULL
  for (i in 1:remaining_time) {
      if (i == 1) {
        prob_calc <- current_value * exp(rnorm(sims, mean = mu, sd = sig))
      } else {
        prob_calc <- prob_calc * exp(rnorm(counter, mean = mu, sd = sig))
      }
    
      # Change the > or < sign, filter results depending
      # on whether current_value is above or below the threshold.
      if (current_value < bins[1]) {
        prob_calc <- prob_calc[prob_calc < bins[1]]
      } else {
        prob_calc <- prob_calc[prob_calc > bins[1]]
      }
      counter <- length(prob_calc)
    }
  
  # Check counter
  # View(counter)
  # View(prob_calc)
  
  # Create data from with two bins, calculate
  # the probabilities for them
  result <- NULL
  result <- as.data.frame(bins)
  
  # Puts the results in a df
  result$probs[1] <- sum(1 - (counter / sims))
  result$probs[2] <- counter / sims

  return(result)
}
