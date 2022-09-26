# monte-full.R 
#################################################
# Description: This function takes a dataframe 
# with two columns (time, value). The first as.Date,
# in ISO-8601 format, in reverse chronological order, 
# and the second as a vector of numerical values.
# Example: 2019-08-06,1.73
#
# It calls a formatting function, gets 
# the remaining time based on closing date and
# intervals of the data, creates a deck of daily
# percent changes, calculates a log mean and 
# standard deviation, randomly generates a
# vector with X hands and does that multiplied by
# the remaining time, sorts those into pre-defined
# probability bins and returns a new dataframe.

monte <- function(df,
                  closing_date, # for question
                  bins) { # bins=c(100,Inf)
                          # only two values, one is Inf
  
  # Set todays_date
  todays_date <- Sys.Date()
  
  # Set standard hands to a 1,000,000
  hands=1000000
  # hands=10
  
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
  # from the next row, or period to create deck.
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
  prob_calc <- current_value * exp(rnorm(hands, mean = mu, sd = sig))
  for (i in 2:remaining_time) {
    prob_calc <- prob_calc * exp(rnorm(hands, mean = mu, sd = sig))
  }
  
  # View(prob_calc) # for testing
  
  # Sort probabilities into bins
  source("./functions/sortbins.R")
  bins <- sortbins(bins,
                   prob_calc)
  
  # print(bins)
  return(bins)
}