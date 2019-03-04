###############################################################################
# R Script to extract route's for all uber trips completed
#
# Author: Vivek Katial
# Created 2019-03-04 21:07:06
###############################################################################


# Import Dependencies and Source Relevant Scripts -----------------------------------------------------

library(googleway)
source("utils/setup.R")



# Read in data ------------------------------------------------------------

# Import RDS file containing route information
d_routes <- readRDS("data/uber_routes.rds")

# Prep Data ---------------------------------------------------------------

d_directions <- d_clean %>% 
  filter(
    !is.na(begin_trip_lat),
    !is.na(dropoff_lat),
    !(trip_or_order_status %in% c("DRIVER_CANCELED", "CANCELED", "UNFULFILLED"))
    ) %>% 
  mutate(
    start_coord = map2(begin_trip_lat, begin_trip_lng, function(lat, lng) c(lat, lng)),
    end_coord = map2(dropoff_lat, dropoff_lng, function(lat, lng) c(lat, lng))
  )


# Extract Routes for all Trips --------------------------------------------

# WARNING: This will use your Google Maps API request (make sure your df is not too large!!)
# Comment out below code when making new request

# d_routes <- d_directions %>% 
#   mutate(route = map2(start_coord, end_coord, extract_route))



# Function Call Google Maps API to Extract Route Data ------------------------------

#' @param start_coord This is a vector of the lat and lng coords at the start location
#' @param end_coord This is a vector of the lat and lng coords at the end location
#' @param map_key This is your Google Maps API key (KEEP CONFIDENTIAL)
#' 
#' @return data.frame containing the lat and lng coords of the respective route
extract_route <- function(start_coord, end_coord, map_key = MAP_KEY){
  
  # Extract Google Map object
  gmap_obj <- google_directions(
    origin = start_coord,
    destination = end_coord,
    key = MAP_KEY,
    mode = "driving"
  )
  
  # Extract polyline from the google maps object
  route <- gmap_obj$routes$overview_polyline$points %>% 
    # decode polyline into lat and lng
    decode_pl()
  
}



map <- leaflet() %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addPolylines(
    data = d_route %>% as.data.frame(), 
    lat = ~lat, 
    lng = ~lon
  )
