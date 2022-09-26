# probands.R 
#################################################
# Description: Takes a two column data frame
# with columns date (chronological), value and 
# generates a projected mean increase for the 
# forecast period, adds that increase to last 
# value for the series, uses that projected mean 
# with standard deviation to generate a number based
# on probability percent, assuming a standard distribution.
#
# Example: If you had a time series and wanted to know,
# based on the data, where there was 10% and 90% chance of
# it being some two values on X date.

probands <- function(df, 
                     closing_date,
                     bins) {  # bins=c(0.10, 0.90)

  # Prevent scientific notation
  options(scipen=999)
  
  # Format for probability functions
  source("./functions/probform.R")
  df <- probform(df)
  
  # Run the remaining_time function,
  # which calculates the time to closing_date
  source("./functions/remaining_time.R")
  remaining_time <- remaining_time(df,
                                   closing_date)
  
  # Checking output of remaining_time
  # View(remaining_time)
  
  # If values are percentages, 
  # change to whole number for multiplication.
  if (mean(df$value) < 1) {
    df$value <- df$value * 100
  }
  
  # Create a data frame
  percentages <- NULL
  View(df)
  
  # Creates a dataframe of change in value that matches forecast period
  for (i in 1:(length(df$value) - remaining_time)) {
    # Assumes newest at bottom
    percentages[i] <- log(df$value[i] / df$value[i+remaining_time])
  }
  
  # Check percentages output
  View(percentages)
  
  # Current value
  current_value <- head(df$value, n=1)
  
  # Check output of current value
  # View(current_value)

  # Adjusted to mean for similar periods over data available
  projected_mu <- current_value * exp(mean(percentages))
  
  # Check projected_mu
  View(projected_mu)
  
  # Using standard deviation of percentages multiplying
  # against projected mean and then subtracting projected mean.
  # You could use historical standard deviation, but I think
  # it gives probability ranges that are too narrow.
  # projected_sig <- sum(projected_mu * exp(sd(percentages))) - projected_mu  

  # Historical, a more conservative choice than above
  projected_sig <- exp(sd(percentages))
  
  # Check projected-sig output
  View(projected_sig)
  
  # Turns atomic vector bins into dataframe
  bins <- as.data.frame(bins)
  
  # Skipping first bin, calculate probability of left of bin 
  # minus the probability of everything before previous bin
  for (i in 1:length(bins$bins)) {
    bins$probs[i] <- qnorm(bins$bins[i], projected_mu, projected_sig)
  }
  
  # Rounds results
  bins$probs <- round(bins$probs, digits = 3)
  
  # Prints mean and standard deviation to console
  cat(paste0("Projected mean: ", projected_mu, "\n",
             "Projected standard deviation: ", projected_sig, "\n"))
  
  # Returns a dataframe of results
  return(bins)
}