###############################################################################
# Cleaning Data Scripts
#
# Author: Vivek Katial
# Created 2019-01-30 21:50:24
###############################################################################


# Import File ------------------------------------------------------------

d_uber <- read_csv("data/trips_data.csv") %>% 
  janitor::clean_names()


# Clean File --------------------------------------------------------------

d_clean <- d_uber %>% 
  mutate(
    request_time = as.POSIXct(request_time),
    begin_trip_time = as.POSIXct(begin_trip_time),
    dropoff_time = as.POSIXct(dropoff_time),
    year = year(request_time),
    month = month(request_time, label = T),
    day = day(request_time),
    request_date = as.Date(request_time),
    begin_trip_date = as.Date(begin_trip_time),
    dropoff_date = as.Date(dropoff_time)
    )
# Code to find and write out currency rates -------------------------------

d_currency_rates <- read_csv("data/currency_rate.csv")


# Make Route Data Available -----------------------------------------------

d_routes <- readRDS("data/uber_routes.rds") %>% 
  select(city, request_time, start_coord, end_coord, route) %>% 
  mutate(trip = paste("Trip", 1:n())) %>% 
  filter(request_time > as_datetime("2016-01-01"))



