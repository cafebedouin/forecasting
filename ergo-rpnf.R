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
ergo <- function(closing_date="2024-01-01",
                 bins=c(0.5,1,1.5,2,2.5,3,Inf),
                 prob_type="monte-full",
                 filename="ergo") {
  
  setwd("D:/forecasting")
  library(dplyr)
  library(rpnf)
  
  # Preventing scientific notation in graphs
  options(scipen=999)
  
  #################################################
  # Import, organize and output csv data
  df <- read.csv(paste0("./data/", filename, ".csv"), 
                        skip=0, header=TRUE)
  
  df$date <- as.Date(df$timeOpen)
  df <- df %>% arrange(date)
  
  pnfdata <- pnfprocessor(
    high=df$high,
    low=df$low,
    date=df$date,
    boxsize=getLogBoxsize(percent=3),
    # boxsize=1L,
    log=TRUE)
  
  pnfdata$ATR <- pnfdata$high - pnfdata$low
  
  pnfdata <- filter(pnfdata, date >= "2021-04-01")
  pnfdata <- filter(pnfdata, date <= "2021-08-31")
  
  # Show the object obtained
  # str(pnfdata)
  # Show the data obtained
  # pnfdata
  # Create a TXT based plot with X and O's
  # pnfplottxt(pnfdata,boxsize=getLogBoxsize(percent=1),log=TRUE)
  # Create a more graphical plot
  # pnfplot(pnfdata, reversal = 3, boxsize=2L, log=TRUE) 
  pnfplot(pnfdata, reversal = 3, boxsize=getLogBoxsize(percent=3), log=FALSE)
  # pnfplot(pnfdata,main="P&F Plot DOW (log)")
  
}



