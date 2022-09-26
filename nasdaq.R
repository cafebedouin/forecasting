# nasdaq.R 
#################################################
# Description: Pulls NASDAQ data by ticker and 
# from the NASDAQ website, allows you to limit the 
# data set, then provides a probability base line
# against <=5 bins or 4 price points using current
# price and walk through the outcomes in set.
#
# https://www.nasdaq.com/api/v1/historical/TSLA/stocks/2016-01-01/2021-04-06
#
# https://finance.yahoo.com/quote/' + ticker + '/history
#
# Replace defaults in function to desired, or 
# call the function from console
nasdaq <- function(ticker="CCL", 
                   begin_date="2015-01-01", # For analysis, not question
                   closing_date="2022-03-01", 
                   bins,
                   prob_type="monte-full") {
  
  #################################################
  # Preliminaries
  
  # Preventing scientific notation in graphs
  options(scipen=999)
  
  # Set todays_date
  todays_date <- Sys.Date()
  
  #################################################
  # Load libraries. If library X is not installed
  # you can install it with this command at the R prompt:
  # install.packages('X')
  library(data.table)
  library(dplyr)

  #################################################
  # Import, organize and output csv data
  
  # Create url to access data
  nurl = paste0("https://www.nasdaq.com/api/v1/historical/",
               ticker, "/stocks/", begin_date, "/", todays_date)

  
  # Live import
  df <- read.csv(nurl, skip=0, header=TRUE)
  View(df)
  
  # Downloaded
  # df <- read.csv(paste0("/home/cafebedouin/Downloads/HistoricalQuotes-", ticker, "-", todays_date, ".csv"), 
  #                   skip=0, header=TRUE)
  
  # View(df)

  # Selects date and closing value
  df = df[, -c(3:6)]
  
  # Names the columns
  colnames(df) <- c("date", "value")
  
  # Translates the NASDAQ date into one R likes
  df$date <- as.Date(df$date, "%m/%d/%Y")
  
  # Removes the dollar signs from values
  df$value <- as.numeric(gsub("[\\$,]", "", df$value))
  
  # Making sure data types are in the correct format
  df$date <- as.Date(df$date)
  df$value <- as.vector(df$value)
  
  # View(df)
  
  # Removes data after a certain point for back-testing
  # df <- filter(df, date < "2020-04-09")
  
  #################################################
  # Call the probability functions by type,
  # check README or probfun.R for details.
  source("./functions/probfun.R")
  return(probfun(df, 
                 closing_date, 
                 bins, 
                 prob_type))
} 
