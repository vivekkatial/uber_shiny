###############################################################################
# Animated Maps in R
#
# Author: Vivek Katial
# Created 2019-03-01 22:03:45
###############################################################################


# Setup and Libraries -----------------------------------------------------

library(shiny)
library(leaflet)
library(tidyverse)
library(xts)


# Creds -------------------------------------------------------------------

map_key <- read_file(".credentials/googlemaps") %>% str_replace_all("\n", "")

# Import RDS file containing route information
d_routes <- readRDS("data/uber_routes.rds") %>% 
  select(city, request_time, start_coord, end_coord, route) %>% 
  filter(lubridate::year(request_time) > 2017) %>% 
  mutate(a = 1:n())

d_routes

# Shiny App ---------------------------------------------------------------

ui <- fluidPage(
  sliderInput(
    "time", 
    "date",
    min(d_routes$request_time) %>% as.Date(), 
    max(d_routes$request_time) %>% as.Date(),
    value = max(d_routes$request_time) %>% as.Date(),
    step=14,
    animate=T
  ),
  leafletOutput("mymap")
)

server <- function(input, output, session) {
  points <- reactive({
    d_routes %>% 
      filter(city == "Auckland") %>% 
      filter(request_time <= input$time)
  })
  
  output$mymap <- renderLeaflet({
    # Base map
    map <- leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>% 
      # blanking bg
      leaflet.extras::setMapWidgetStyle(map = .,list(background= "white")) %>% 
      addPolylines(
        data = points() %>% unnest(route),
        lat = ~lat,
        lng = ~lon,
        weight = 1,
        opacity = 1
      )
  })
}

