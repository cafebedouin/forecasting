# probplot.R
#################################################
# Description: Standard plot to check data 
# distributions and appropriate functions

probplot <- function(df) {
  
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
  
  # Plot 
  probplot <- ggplot() + 
    geom_line(data = df, aes(x = date, y = value)) +
    bbc_style() +
    labs(title=paste0("Standard Plot of Data")) +
    scale_x_date()
  print(probplot)
}