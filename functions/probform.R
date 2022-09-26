# probform.R 
#################################################
# Description: Calculates formats for probability functions

probform <- function(df) {
  library(dplyr)
  
  # Changing column name to required values
  colnames(df) <- c("date", "value")
  
  # Clips off time and imports value as number
  df$date <- as.Date(df$date)
  df$value <- as.character(df$value) # for converting factors
  df$value <- as.numeric(df$value) 
  
  # Filter out days with value of "."
  df <- filter(df, value != ".") 
  df %>% is.na()
  df %>% is.null()
  
  # Removes NAs if they appear in values column
  # df[!is.na(df[, 2]), ]
  
  # Puts into date decreasing order
  df <- df[rev(order(as.Date(df$date), na.last = NA)),]
  
  # Standard plotting of data to check it
  source("./functions/probplot.R")
  probplot(df)
  
  # View(df) # for testing
  
  return(df)
}