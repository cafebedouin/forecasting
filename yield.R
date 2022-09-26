# yield.R 
#################################################
# Description: This script is for scraping yield data
# from the Treasury website limiting to the yield of
# interest then doing a either a Monte Carlo or historical
# simulation data to project probabilities for future 
# Treasury yields on some arbitrary date.

#Clear memory and set string option for reading in data:
rm(list=ls())
gc()

#################################################
# Function
yield <- function(closing_date,
                  begin_year, # > than this year, for analysis
                  bins,
                  prob_type,
                  # If you want a graph, indicate and add info

    # Script does analysis for only one Treasury Yield at a time.                    
    # Yield Codes:  Y1M = 1 Month Yield, Y2M = 2 Month Yield Y3M, Y6M, 
    # Y1Y = 1 Year Yield, Y2Y, Y3Y, Y5Y, Y7Y, Y10Y, Y20Y, Y30Y                       
                  treasury_code="Y30Y") {

  #################################################
  # Libraries
  #
  # Load libraries. If library X is not installed
  # you can install it with this command at the R prompt:
  # install.packages('X') 
  library(xml2)
  library(lubridate)
  library(dplyr)
    
  #################################################
  # Import & Parse Treasury Data
  # Point to time series data file and import it.
  # Last 4 digits are year, retrieves years > than start_date
  yurl = paste0("http://data.treasury.gov/feed.svc/DailyTreasuryYieldCurveRateData?",
                "$filter=year(NEW_DATE)%20gt%20",
                begin_year) 

  # Script testing with downloaded file
  # xmlobj <- read_xml("~/Downloads/DailyTreasuryYieldCurveRateData")

  # Live script
  xmlobj <- read_xml(yurl)
  
  df <- data.frame( 
    id   = xml_find_all(xmlobj, ".//d:Id" ) %>% xml_attr( "id" ),
    date = xml_find_all(xmlobj, ".//d:NEW_DATE" ) %>% xml_text(),
    Y1M = xml_find_all(xmlobj, ".//d:BC_1MONTH" ) %>% xml_text(),
    Y2M = xml_find_all(xmlobj, ".//d:BC_2MONTH" ) %>% xml_text(),
    Y3M = xml_find_all(xmlobj, ".//d:BC_3MONTH" ) %>% xml_text(),
    Y6M = xml_find_all(xmlobj, ".//d:BC_6MONTH" ) %>% xml_text(),
    Y1Y = xml_find_all(xmlobj, ".//d:BC_1YEAR" ) %>% xml_text(),
    Y2Y = xml_find_all(xmlobj, ".//d:BC_2YEAR" ) %>% xml_text(),
    Y3Y = xml_find_all(xmlobj, ".//d:BC_3YEAR" ) %>% xml_text(),
    Y5Y = xml_find_all(xmlobj, ".//d:BC_5YEAR" ) %>% xml_text(),
    Y7Y = xml_find_all(xmlobj, ".//d:BC_7YEAR" ) %>% xml_text(),
    Y10Y = xml_find_all(xmlobj, ".//d:BC_10YEAR" ) %>% xml_text(),
    Y20Y = xml_find_all(xmlobj, ".//d:BC_20YEAR" ) %>% xml_text(),
    Y30Y = xml_find_all(xmlobj, ".//d:BC_30YEAR" ) %>% xml_text(),
    Y30D = xml_find_all(xmlobj, ".//d:BC_30YEARDISPLAY" ) %>% xml_text(),
    stringsAsFactors = FALSE )

  df <- df[,c("date", treasury_code)]
  
  # Changing column name to reuse time-series script
  colnames(df) <- c("date", "value")
  
  # Changes date to date and imports value as number
  df$date <- as.Date(df$date)
  df$value <- as.numeric(df$value) 
  
  # Puts into date decreasing order
  df <- df[rev(order(as.Date(df$date), na.last = NA)),]

  # View(df) # testing
  
  # Putting into vectors format
  df$value <- as.vector(df$value) 
  
  #################################################
  # Call the probability functions by type,
  # check README or probfun.R for details.
  source("./functions/probfun.R")
  return(probfun(df, 
                 closing_date, 
                 bins, 
                 prob_type))
}  
