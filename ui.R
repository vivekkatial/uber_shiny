###############################################################################
# UI Access for Dashboard
#
# Author: Vivek Katial
# Created 2019-01-30 20:32:15
###############################################################################

ui = shiny::htmlTemplate(
  # Index Page
  "www/index.html",
  
  # Number of trips
  number_of_trips = textOutput(
    "num_trips",
    inline = T
  ),
  
  # Expensive Trip
  expensive_trip = textOutput(
    "most_expensive_trip_text",
    inline = T
    ),
  
  longest_trip_time = textOutput(
    "longest_trip_time_text",
    inline = T
  ),
  
  longest_trip_distance = textOutput(
    "longest_trip_distance_text",
    inline = T
  ),
  
  # City Selector
  city_selector = selectInput(
    "city", 
    label = "Select City", 
    choices = d_clean$city %>% 
      unique(),
    selected = "Auckland"
    ),
  
  
  # Selector for Time
  time_selector = sliderInput(
    "time", 
    "Date",
    min(d_routes$request_time) %>% as.Date(), 
    max(d_routes$request_time) %>% as.Date(),
    value = max(d_routes$request_time) %>% as.Date(),
    step = 14,
    animate = TRUE
  ),
  
  # Leaflet map
  leaflet_map = leafletOutput(outputId = "map") %>% 
    withSpinner(color="#0dc5c1")
  )