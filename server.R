###############################################################################
# Defining Server Logic behind App to explore UBER data
#
# Author: Vivek Katial
# Created 2019-01-30 20:32:44
###############################################################################

server <- function(input, output) {
  
  # Basic Numbers Page --------------------------------------------------------------
  
  # Number of trips
  n_trips <- reactive({
    d_clean %>% 
      filter(trip_or_order_status == "COMPLETED") %>% 
      nrow()
  })
  
  # Number of trips text in UI
  output$num_trips <- renderText({
    n_trips()
  })
  
  # Number of kilometers
  n_distance <- reactive({
    d_clean %>% 
      pull(distance_miles) %>% 
      sum() * 1.6
  })
  
  # Number of kilometers in UI
  output$num_distance <- renderText({
    n_distance()
  })
  
  # Number of hours spent calculation
  n_hours <- reactive({
    d_clean %>% 
      mutate(duration = dropoff_time - begin_trip_time) %>% 
      select(duration) %>% 
      filter(duration > 0) %>% 
      pull(duration) %>% 
      sum() %>% 
      as.numeric()/3600 %>% 
      round(., 1)
  })
  
  # Number of hours in UI
  output$num_hours <- renderText({
    n_hours()
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
  

  # Message for numbers page ------------------------------------------------

  # Find date for last date in data
  data_message <- reactive({
    
    # Find the date for which data was pulled
    latest_date <- d_clean %>% 
      arrange(dropoff_date) %>% 
      slice(n()) %>% 
      pull(dropoff_date)
    
    # Find the currency rate
    date_of_rate <- d_currency_rates %>% 
      pull(rates_date) %>% 
      first()
    
    # Construct message
    message <- sprintf(
      "This data is based on the Uber extract on %s with the currency rate based on %s",
      latest_date,
      date_of_rate
      )
    
    message
  })
  
  output$data_message <- renderText(
    data_message()
  )
  
  

# Plots -------------------------------------------------------------------
  

  # Reactive to create map data ---------------------------------------------
  d_map <- reactive({
    d_clean %>% 
      filter(city == input$city) %>% 
      filter(year == as.numeric(input$year)) %>% 
      remove_missing()
  })
  

  # Create Map Plot ---------------------------------------------------------
  output$leaflet_map <- renderLeaflet({
      d_map()
      leaflet() %>% 
      addProviderTiles(providers$CartoDB.Positron) %>% 
      addCircleMarkers(
        lat = d_map()$begin_trip_lat, 
        lng = d_map()$begin_trip_lng,
        radius = 2,
        color = "blue",
        popup = paste("<b>Start Address:</b>\n", d_map()$begin_trip_address)
      ) %>% 
      addCircleMarkers(
        lat = d_map()$dropoff_lat,
        lng = d_map()$dropoff_lng,
        radius = 2,
        color = "red",
        popup = paste("<b>Drop off Address:</b>\n", d_map()$dropoff_address)
      ) %>% 
      addPolylines(
        lat = c(d_map()$begin_trip_lat, d_map()$dropoff_lat),
        lng = c(d_map()$begin_trip_lng, d_map()$dropoff_lng),
        weight = 0.5,
        color = "black"
      )
  })

}
