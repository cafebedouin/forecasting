# covid-ww-owid-100s.R
#################################################
# Description:
# Script parses cvs file and provides a graph 
# with selectable yearly trend lines for 
# comparison, also includes analysis options at 
# bottom for predicting a particular day or 
# searching by cases.

todays_date <- Sys.Date()

#Preventing scientific notation in graphs
options(scipen=999)

#################################################
# Load libraries. If library X is not installed
# you can install it with this command at the R prompt:
# install.packages('X')
library(data.table)
library(dplyr)
library(ggplot2)
library(bbplot)
library(readr)

# Use for testing so I'm not downloading 30Mb every test
# df <- read.csv(paste0("~/Downloads/owid-covid-data.csv"), 
#               na.strings = "", fileEncoding = "UTF-8-BOM",
#               skip=0, header=TRUE)

# Use when the script is working correctly
df <- read.csv(paste0("https://covid.ourworldindata.org/data/owid-covid-data.csv"), 
               na.strings = "", fileEncoding = "UTF-8-BOM",
               skip=0, header=TRUE)

# Drop everything but location, date, vaccines per 100, and population
df <- df[ -c(1,2,5:40,42:46,48:62) ] 

# Rename the columns
colnames(df) <- c("location", "date", "value", "population")

# Limits to locations with more than 200000
df <- df[df$population > 200000, ]

# Drop population
df <- df[ -c(4) ] 

# Fixes the data structures so subsetting works
df$location <- as.character(df$location)
df$date <- as.character(df$date) # for converting factors
df$date <- as.Date(df$date)
df$value <- as.character(df$value) # for converting factors
df$value <- as.numeric(df$value) 

# Clips off dates prior to 2021
df <- df[df$date >= "2021-01-01", ]

# Puts into date decreasing order
df <- df[(order(as.Date(df$date), na.last = NA)),]

# Puts into alphabetical order by country
df <- df[(order(as.character(df$location), na.last = NA)),]

# Reshape the table into grid
df <- reshape(df, direction="wide", idvar="date", timevar="location")

# Fix column names after reshaping
names(df) <- gsub("value.", "", names(df))

# Remove supranational columns
setDT(df)[ , c("Africa", "Asia", "Europe",
                  "European Union", "Oceania", "World") := NULL] 

# count columns that are above 100
df$total <- rowSums(df > 100, na.rm = TRUE)

# Creating a cvs file of df
write.csv(df, file=paste0("./output/100-locations-", todays_date, ".csv")) 

# Put df in a data.frame, subset date and total
df <-as.data.frame(df)
df <- df[ -c(2:sum(ncol(df)-1)) ]

# Remove last row, which has incomplete data
df <- head(df,-1)

# Adds last date with projection
df_proj <- NULL 
df_proj$date <- as.Date("2022-02-01",  origin="1970-01-01")
df_proj$total <- as.numeric(100) 
df <- rbind(df, df_proj)

# plots it
plot <- ggplot() + 
  geom_line(data = df, aes(x = date, y = total)) +
  geom_vline(xintercept=as.numeric(as.Date(todays_date)), linetype=4, colour="black") +
  geom_text(aes(x=todays_date-1, label="Yesterday", y=20, angle=90), size=8) +
  geom_vline(xintercept=as.numeric(as.Date("2022-02-01", origin="1970-01-01")), linetype=4, colour="black") +
  geom_text(aes(x=as.Date("2022-02-01", origin="1970-01-01")-5, label="2022-02-01", y=20, angle=90), size=8) +
  bbc_style() +
  labs(title=paste0("100 Locations Projection, ", todays_date)) +
  scale_x_date()

# displays plot for initial check
plot

# saves plot to a file
finalise_plot(plot_name = plot,
              source = "Source: OWID",
              save_filepath = paste0("./output/100-locations-", todays_date, ".png"),
              width_pixels = 1500,
              height_pixels =500,
              logo_image_path = paste0("./branding/logo.png"))
              

