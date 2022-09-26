# cvs-tech-startup.R 
#################################################
# Description: Pulls data from the FRED website on 
# currencies, precious metals, unemployment, etc.
# allows you to limit the data set, set the 
# frequency interval, then provides 
# a probability base line against <=5 bins or 
# 4 price points using current price and walk 
# through the outcomes in set.


# Replace defaults in function to desired, or 
# call the function from console
csv <- function(begin_date="1986-01-01", # For analysis, not question
                closing_date="2022-07-01",
                outlier=NULL,
                bins=c(0.1,0.5,0.9),
                probability_type="probands") {
  
  #################################################
  # Preliminaries
  
  # Preventing scientific notation in graphs
  options(scipen=999)
  
  # Set todays_date
  todays_date <- Sys.Date()
  
  # Set date for ten years ago
  ten_years <- todays_date - 3652
  
  #################################################
  # Load libraries. If library X is not installed
  # you can install it with this command at the R prompt:
  # install.packages('X')
  library(data.table)
  library(dplyr)
  
  #################################################
  # Import, organize and output csv data
  df <- read.csv(paste0("~/Documents/programming/R/forecasting/data/tech-startup.csv"), 
                        skip=0, header=TRUE)
  
  # Remove unwanted columns, if it hasn't been done already.
  # df <- df[ -c(1,4,5,6) ]
  
  View(df)
  
  # Names the columns
  colnames(df) <- c("date", "value")
  
  # Filter out days with value of "."
  df <- filter(df, value != ".") 
  df %>% is.na()
  
  # Making sure data types are in the correct format
  df$date <- as.Date(df$date)
  df$value <- as.character(df$value) # for converting factors
  df$value <- as.numeric(df$value)
  
  # Reverse dates 
  df <- df[rev(order(df$date)),] 

  # Visually check columns, data types and data
  glimpse(df)
  
  # Writes csv file
  write.csv(df, file=paste0("./output/csv-", 
                            todays_date,
                            ".csv")) 

  #################################################
  # Call desired forecasting functions
  if (probability_type == "simple") {
    source("./functions/simple_probability.R")
    return(simple_probability(df, closing_date, bins)) }
  
  # Simple walk through historical percentages to generate probabilities
  if (probability_type == "simple_percent") {
    source("./functions/simple_probability_percent.R")
    return(simple_probability(df, closing_date, bins)) }
  
  # Simple Monte Carlo using historical period changes 
  # and number of hands to generate probabilities
  if (probability_type == "monte") {
    source("./functions/monte.R")
    return(monte(df, closing_date, hands=10000, bins)) }
  
  # Returns number at probability bands based on  
  # normal distribution curve
  if (probability_type == "probands") {
    source("./functions/probands.R")
    return(probands(df, closing_date, outlier, bins)) }
  
} 
