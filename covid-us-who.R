# covid-us-who.R
# cafebedouin@gmail.com, 2020
#################################################
# Description:
# Script parses cvs file and provides a graph 
# with selectable yearly trend lines for 
# comparison, also includes analysis options at 
# bottom for predicting a particular day or 
# searching by cases.

# Clear memory
rm(list=ls())
gc()

covid <- function(country = "",
                  start_date = "2021-04-21",
                  end_date = "2021-09-30",
                  end_value = "600") {
  
  #################################################
  # Preliminaries
  
  # Preventing scientific notation in graphs
  options(scipen=999)
  
  # Set todays_date
  todays_date <- Sys.Date()
  start_date <- as.Date(start_date, origin='1970-01-01')
  end_date <- as.Date(end_date, origin='1970-01-01')
  
  #################################################
  # Load libraries. If library X is not installed
  # you can install it with this command at the R prompt:
  # install.packages('X')
  library(data.table)
  library(lubridate)
  library(dplyr)
  library(plyr)
  library(tidyverse)
  library(ggplot2)
  library(bbplot)
  
  #################################################
  # Import, organize and output csv data

  # Download data for testing script 
  df <- read.csv(paste0("https://covid19.who.int/WHO-COVID-19-global-data.csv"), 
               na.strings = "", fileEncoding = "UTF-8-BOM",
                 skip=0, header=TRUE)

  # Live import, switch to testing line when modifying script
  # View(head(df))


  # 5/6 new/cum cases, 7/8 new/cum deaths
  df <- df[ -c(3,4,6,8) ] 
  
  # Add column names
  colnames(df)[1] <- "date"
  colnames(df)[2] <- "country"
  colnames(df)[3] <- "cases"
  colnames(df)[4] <- "deaths"
  
  # Set datatypes  
  df$date <- as.Date(df$date, origin="1970-01-01")
  df$country <- as.character(df$country)
  df$cases <- as.numeric(df$cases) 
  df$deaths <- as.numeric(df$deaths) 
  
  # Puts into date decreasing order
  df <- df[rev(order(as.Date(df$date), na.last = NA)),]
  last_data_date <- as.Date(head(df$date, n=1))
  
  # Limit by data of interest
  df <- filter(df, country == "US")
  df <- filter(df, date >= "2021-04-01")
  
  # drop country 
  df <- df[ -c(2) ] 

  # Create dataframe
  us_median <- NULL
  
  # Gets the 7 day median for each us row
  for (i in 7:length(df$deaths)) {
    us_median[i] <- as.numeric(median(df$deaths[i:(i-7)]))
  }
  
  # Populates first 6 rows with 0
  us_median[is.na(us_median)] <- 0
  
  # Replaces original numbers with median
  df$deaths <- us_median
  
  write.csv(df, file=paste0("./output/covid-us-median-table-", todays_date, ".csv")) 

  # Adds last date with projection
  # df_proj <- NULL 
  # df_proj$date <- as.Date('2021-09-30')
  # df_proj$deaths <- as.numeric('13000') 
  # df <- rbind(df, df_proj)

  # Limits dates
  df <- filter(df, date >= "2020-03-01")
  
  # Adjust cases
  df$cases <- df$cases * 0.012
  
  # Create dataframe
  us_cases <- NULL
  
  # Gets the 7 day median for each us row
  for (i in 7:length(df$cases)) {
    us_cases[i] <- as.numeric(median(df$cases[i:(i-7)]))
  }
  
  # Replaces original numbers with median cases
  df$cases <- us_cases
  
  # Trim most recent data
  df <- df[-c(1:6),]
  
  # Plot 
  plot <- ggplot() + 
    geom_line(data = df, aes(x = date, y = deaths)) +
    geom_line(data = df, aes(x = date+21, y = cases), colour = "blue") +
    geom_vline(xintercept=start_date, linetype="F1", colour="black") +
    geom_text(aes(x=start_date, label="April 21, 2021", y=1000, angle=90), size=8) +
    geom_vline(xintercept=as.numeric(as.Date(last_data_date-6)), linetype=4, colour="black") +
    geom_text(aes(x=last_data_date-6, label="Most Recent Date With Data - 6 Days", y=700, angle=45), size=8) +
    geom_vline(xintercept=as.numeric(as.Date(end_date)), linetype="F1", colour="black") +
    geom_text(aes(x=end_date, label="September 30, 2021", y=1000, angle=90), size=8) +
    geom_hline(yintercept=1700, color="red") +
    # geom_hline(yintercept=1000, color="yellow") +
    # geom_hline(yintercept=1300, color="green") +
    bbc_style() +
    labs(title=paste0("Seven Day Median U.S. Deaths, ", todays_date)) +
    scale_x_date()
  
  plot
  
  finalise_plot(plot_name = plot,
                source = "Source: WHO",
                save_filepath = paste0("./output/covid-us-who-7day-median-deaths-",
                                       todays_date, ".png"),
                width_pixels = 1500,
                height_pixels =500,
                logo_image_path = paste0("./branding/logo.png"))
  
}
  