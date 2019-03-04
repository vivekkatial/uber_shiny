###############################################################################
# Script to download data from uber api
#
# Author: Vivek Katial
# Created 2019-02-25 23:37:27
###############################################################################

# Uber Auth ---------------------------------------------------------------

UBER_AUTH_KEY <- read_file(file = ".credentials/uber-app") %>% 
  str_replace("\n", "")


# Request trips -----------------------------------------------------------

# Send trip request
r_trips <- GET(
  url = "https://api.uber.com/v1.2/history",
  add_headers(
    "Authorization" = sprintf("Bearer %s", UBER_AUTH_KEY),
    "Accept-Language" = "en_US",
    "Content-Type" = "application/json"
  ),
  query = list(limit = 50)
)

# Clean requested data
d_uber <- content(r_trips, type = "text", encoding = "UTF-8") %>% 
  jsonlite::fromJSON() %>% 
  magrittr::extract("history") %>%
  as.data.frame() %>% 
  jsonlite::flatten() %>% 
  tbl_df() %>% 
  mutate(
    start_time = as.POSIXct(history.start_time, origin = "1970-01-01"),
    end_time = as.POSIXct(history.end_time, origin = "1970-01-01"),
    request_time = as.POSIXct(history.request_time, origin = "1970-01-01")
  ) %>% 
  select(-history.start_time, -history.end_time, -history.request_time, -history.product_id)


# Request Trips meta-info -------------------------------------------------

test_id <- d_uber %>% slice(1) %>% pull(history.request_id)

r_single_trip <- GET(
  url = sprintf("https://api.uber.com/v1.2/requests/%s", test_id),
  add_headers(
    "Authorization" = sprintf("Bearer %s", UBER_AUTH_KEY),
    "Accept-Language" = "en_US",
    "Content-Type" = "application/json"
  )
) 

content(r_single_trip, type = "text", encoding = "UTF-8")
