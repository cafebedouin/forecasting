source("fred.R")
fred(code="CBBTCUSD", 
      begin_date="2000-12-01", 
      closing_date="2023-12-31", 
      bins=c(8000, 16000, 24000, 32000, Inf), 
#      prob_type="monte-full")
      prob_type="historical")

source("fred.R")
fred(code="DGS10", 
     begin_date="1962-02-01", 
     closing_date="2024-12-31", 
     bins=c(0.75, 2, 3.5, 5, Inf), 
#     prob_type="monte-full")
     prob_type="historical")

source("fred.R")
fred(code="DGS5", 
     begin_date="1962-02-01", 
     closing_date="2024-12-31", 
     bins=c(0.75, 2, 3.5, 5, Inf), 
     prob_type="monte-full")
#prob_type="historical")

source("fred.R")
fred(code="CBBTCUSD", 
     begin_date="2000-12-01", 
     closing_date="2023-12-31", 
     bins=c(0.05,0.95), 
     prob_type="probands")

source("fred.R")
fred(code="FEDFUNDS", 
     begin_date="1954-12-01", 
     closing_date="2025-12-31", 
     bins=c(0.5,2,3.5,5,Inf), 
     prob_type="monte-full")
#     prob_type="historical")
