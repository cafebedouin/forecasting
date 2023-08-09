monte <- function(df, 
                  closing_date, 
                  bins) {
  todays_date <- as.Date(Sys.Date())
  hands <- 1e6
  
  source("./functions/probform.R")
  df <- probform(df)
  
  source("./functions/remaining_time.R")
  remaining_time <- remaining_time(df, closing_date)
  
  df$value <- replace(df$value, df$value < 0, 0)
  df <- filter(df, value != ".")
  
  current_value <- as.numeric(df[1, 2])
  deck_size <- length(df$value) - 1
  deck <- numeric(deck_size)
  
  for (i in 1:deck_size) {
    if (df$value[i+1] <= 0) {
      deck[i + remaining_time] <- 1
    } else {
      deck[i] <- log(df$value[i] / df$value[i+1])
    }
  }
  
  deck[!is.finite(deck)] <- 0
  
  sig <- sd(deck)
  mu <- mean(deck)
  
  set.seed(42)  # Set a seed for reproducibility
  prob_calc <- matrix(exp(rnorm(hands * remaining_time, mean = mu, sd = sig)), nrow = remaining_time)
  prob_calc <- apply(prob_calc, 2, cumprod)
  prob_calc <- prob_calc * current_value
  
  source("./functions/sortbins.R")
  bins <- sortbins(bins, prob_calc)
  
  return(bins)
}