###############################################################################
# UI Access for Dashboard
#
# Author: Vivek Katial
# Created 2019-01-30 20:32:15
###############################################################################

ui = shiny::htmlTemplate(
  # Index Page
  "www/index.html",
  
  # City Selector
  city_selector = selectInput(
    "city", 
    label = "Select City", 
    choices = d_clean$city %>% 
      unique(),
    selected = "Auckland"
    ),
  
  # Year Selector
  year_selector = selectInput(
    "year", 
    label = "Select Year", 
    choices = d_clean$year %>% 
      unique(),
    selected = 2018
    ),
  
  # Leaflet map
  leaflet_map = leafletOutput(outputId = "leaflet_map") %>% 
    withSpinner(color="#0dc5c1")
  )