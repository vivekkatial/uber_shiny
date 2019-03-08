###############################################################################
# Defining Server Logic behind App to explore UBER data
#
# Author: Vivek Katial
# Created 2019-01-30 20:32:44
###############################################################################

server <- function(input, output) {
  
  # Basic Numbers Page --------------------------------------------------------------
  
  # Number of trips text in UI
  output$num_trips <- renderText({
    d_clean %>% 
      filter(trip_or_order_status == "COMPLETED") %>% 
      nrow()
  })
  
  # Number of kilometers
  n_distance <- reactive({
    d_clean %>% 
      pull(distance_miles) %>% 
      sum() * 1.6
  })
  
  # Number of kilometers in UI
  output$num_distance <- renderText({
    d_clean %>% 
      pull(distance_miles) %>% 
      sum(na.rm = T) * 1.6
  })
  
  output$longest_trip_distance_text <- renderText({
    d_clean %>% 
      pull(distance_miles) %>% 
      max(na.rm = T) * 1.6
  })
  
  # Number of hours spent calculation
  d_duration <- reactive({
    d_clean %>% 
      mutate(duration = dropoff_time - begin_trip_time) %>% 
      select(duration) %>% 
      filter(duration > 0) %>% 
      pull(duration) 
  })
  
  # Number of hours in UI
  output$num_hours <- renderText({
    d_duration() %>% 
      sum() %>% 
      as.numeric()/3600 %>% 
      round(., 1)
  })
  
  # Longest trip time
  output$longest_trip_time_text <- renderText({
    d_duration() %>% 
      max(na.rm = T) %>% 
      as.numeric()/60 %>% 
      round(., 1)
  })
  
  # Calculation for number of USD spent
  n_dollars_spent <- reactive({
    d_clean %>% 
      left_join(d_currency_rates, by = "fare_currency") %>% 
      mutate(usd_spent = fare_amount * rate) %>% 
      select(usd_spent) %>% 
      pull(usd_spent) %>% 
      sum(na.rm = T) %>% 
      round()
  })
  
  # Number of USD spent
  output$num_dollars_spent <- renderText({
    n_dollars_spent()
  })
  
  most_expensive_trip <- reactive({
    d_clean %>% 
      left_join(d_currency_rates, by = "fare_currency") %>% 
      mutate(usd_spent = fare_amount * rate) %>% 
      filter(usd_spent == max(usd_spent, na.rm = T))
  })
  
  output$most_expensive_trip_text <- renderText({
    most_expensive_trip() %>% 
      pull(usd_spent)
  })
  

  
  
  


  # Create Map Plot ---------------------------------------------------------

  
  points_full <- reactive({
    # Clean trip data
    d_show <- d_routes %>% 
      filter(city == input$city)
    
    # Check if any trips present otherwise return NULL
    if (nrow(d_show) > 0) {
      
      # store in DF
      d_show <- d_show %>% unnest(route)
      
      # Convert to SP obj
      split_data = lapply(
        unique(d_show$trip), 
        function(x) {
          df = as.matrix(d_show[d_show$trip == x, c("lon", "lat")])
          lns = Lines(Line(df), ID = x)
          return(lns)
        }
      )
      
      # Convert to SP lines so it can be plotted
      data_lines = SpatialLines(split_data)
      
    } else {
      NULL
    }
    
  })
  
  points <- reactive({
    
    # Clean trip data
    d_show <- d_routes %>% 
      filter(city == input$city) %>% 
      filter(request_time <= (input$time))
    
    # Check if any trips present otherwise return NULL
    if (nrow(d_show) > 0) {
      
      # store in DF
      d_show <- d_show %>% unnest(route)
      
      # Convert to SP obj
      split_data = lapply(
        unique(d_show$trip), 
        function(x) {
          df = as.matrix(d_show[d_show$trip == x, c("lon", "lat")])
          lns = Lines(Line(df), ID = x)
          return(lns)
        }
      )
      
      # Convert to SP lines so it can be plotted
      data_lines = SpatialLines(split_data)
      
    } else {
      NULL
    }
    
  })
  
  output$map <- renderLeaflet({
    # Base map
    leaflet(points_full()) %>%
      addProviderTiles(providers$CartoDB.DarkMatterNoLabels)
    
  })
  
  observe({
    req(!is.null(points()))
    # create the map
    leafletProxy("map", data = points()) %>% 
      clearShapes() %>% 
      addPolylines(weight = 1, color = "violet") %>% 
      fitBounds(
        points_full()@bbox[1], 
        points_full()@bbox[2], 
        points_full()@bbox[3], 
        points_full()@bbox[4]
      )
  })
  

}
