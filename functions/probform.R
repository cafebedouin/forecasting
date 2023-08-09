probform <- function(df) {
  library(dplyr)
  library(tidyr)
  
  # Make a copy of the input dataframe to avoid overwriting it
  input_df <- df
  
  # Rename columns
  colnames(df) <- c("date", "value")
  
  # Convert date column to Date format
  df$date <- as.Date(df$date)
  df$value <- as.character(df$value) # for converting factors
  df$value <- as.numeric(df$value) 
  
  # Replace . with N/A
  gsub("[.]", NA, df$value)

  # Fills N/A in rows with previous value
  df <- df %>% fill(value, .direction = 'up')
  
  # Order the dataframe in decreasing order of dates
  df <- df %>% arrange(desc(date))
  
  # Standard plotting of data to check it
  source("./functions/probplot.R")
  probplot(df)
  
  View(df) # for testing
  
  return(df)
}
