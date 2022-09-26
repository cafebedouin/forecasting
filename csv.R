# cvs.R 
#################################################
# Description: Pulls data from the FRED website on 
# currencies, precious metals, unemployment, etc.
# allows you to limit the data set, set the 
# frequency interval, then provides 
# a probability base line against <=5 bins or 
# 4 price points using current price and walk 
# through the outcomes in set.

# To get stock data, use the following forms:
# https://www.nasdaq.com/api/v1/historical/TSLA/stocks/2016-01-01/2021-04-06
# https://finance.yahoo.com/quote/' + ticker + '/history

# Replace defaults in function to desired, or 
# call the function from console
csv <- function(closing_date="2022-02-28",
                bins=c(200,Inf),
                prob_type="monte-threshold",
                filename="SI") {
  
  library(dplyr)
  
  # Preventing scientific notation in graphs
  options(scipen=999)
  
  #################################################
  # Import, organize and output csv data
  df <- read.csv(paste0("~/Documents/programming/R/forecasting/data/", filename, ".csv"), 
                        skip=0, header=TRUE)
  
  View(df)

  # Remove unwanted columns, if it hasn't been done already.
  # df <- df[ -c(1) ]
  
  # Remove unwanted columns, if it hasn't been done already.
  # df <- df[ -c(1,4,5,6) ]
  
  # Names the columns
  colnames(df) <- c("date", "value")

  # Visually check columns, data types and data
  glimpse(df)

  #################################################
  # Call the probability functions by type,
  # check README or probfun.R for details.
  source("./functions/probfun.R")
  return(probfun(df, 
                 closing_date, 
                 bins, 
                 prob_type))
} 
