# ergo.R 
#################################################
# Description: Pulls data from the FRED website on 
# currencies, precious metals, unemployment, etc.
# allows you to limit the data set, set the 
# frequency interval, then provides 
# a probability base line against <=5 bins or 
# 4 price points using current price and walk 
# through the outcomes in set.

# To download Ergo historical data:
# https://coinmarketcap.com/currencies/ergo/historical-data/

# Replace defaults in function to desired, or 
# call the function from console
ergo <- function(closing_date="2024-08-25",
                 bins=c(0.5,1,1.5,2,Inf),
                 prob_type="monte-full",
                 filename="ergo") {
  
  setwd("D:/forecasting")
  
  #################################################
  # Import, organize and output csv data
  df <- read.csv(paste0("./data/", filename, ".csv"), 
                        skip=0, header=TRUE)
  
  # Remove unwanted columns, if it hasn't been done already.
  df <- df[ -c(1,3,4,5,6,7,9,10) ]
    
  # Names the columns
  colnames(df) <- c("date", "value")

  source("./functions/probfun.R")
  return(probfun(df, 
                 closing_date, 
                 bins, 
                 prob_type))
}
