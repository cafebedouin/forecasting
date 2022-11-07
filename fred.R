# fred.R 
#################################################
# Description: Pulls data from the FRED website, 
# caches it, formats data and generates a 
# probability baseline against any arbitrary 
# number of bins for historical and monte carlo 
# simulated data.
# 
# Example usage:
#
# source("fred.R")
# fred(code="JTSJOL", 
#      begin_date="2000-12-01", 
#      closing_date="2023-07-01", 
#      bins=c(6000, 7000, 8000, 9000, 10000, 11000, Inf), 
#      prob_type="monte-full") 

# Replace defaults in function to desired, or 
# call the function from another script or console
fred <- function(code, # FRED, e.g., SP500 is S&P 500 in FRED
                 begin_date, # for data set
                 closing_date, # for forecast
                 bins, # bins=c(6000, 7000, 8000, 9000, 10000, 11000, Inf), 
                 prob_type) { # defined functions: historical, monte-full, etc.
  
  # Set todays_date
  todays_date <- Sys.Date()
  
  # Set date for ten years ago, FRED often has a 10 year limit
  ten_years <- todays_date - 3652
  
  #################################################
  # Add libraries, install with install.packages('X')
  library(data.table)
  library(dplyr)
  
  #################################################
  # Import and cache data
  cached_file = paste0("./data/", code, "-", todays_date, ".csv")
  
  if (file.exists(cached_file)) {
    
    # Read in previously run data
    df <- read.csv(cached_file, skip=0, header=TRUE)
    
    # Drop the numbered column
    df <- df[ -c(1) ]
    
  } else {
  
  # Create live url to access data
  nurl = paste0("https://fred.stlouisfed.org/graph/fredgraph.csv?",
                "&id=",
                code, "&cosd=",
                begin_date, "&coed=",
                todays_date, 
                "mark_type=none&mw=3&lw=2&ost=-99999&",
                "oet=99999&mma=0&fml=a&fq=Daily&fam=avg",
                "&fgst=lin&fgsnd=",
                ten_years, "&line_index=1",
                "&transformation=lin&vintage_date=",
                todays_date, "&revision_date=",
                todays_date, "&nd=",
                begin_date)
  
  # Live import
  df <- read.csv(nurl, skip=0, header=TRUE)
  
  # Cache data
  write.csv(df, file=paste0("./data/", code, "-", todays_date, ".csv")) 

  }

  # Visually check columns, data types and data
  glimpse(df)

  #################################################
  # Call the probability functions by type
  
  source("./functions/probfun.R")
  return(probfun(df, 
                 closing_date, 
                 bins, 
                 prob_type))
} 
