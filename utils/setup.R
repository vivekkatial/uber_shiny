###############################################################################
# Setup information in UBER app
#
# Author: Vivek Katial
# Created 2019-02-23 15:04:55

###############################################################################

# Key to OpenExhcange Rates
key <- read_file(file = ".credentials/openexchangerates") %>% 
  str_replace("\n", "")

# Key to Google maps
MAP_KEY <- read_file(file = ".credentials/googlemaps") %>% 
  str_replace("\n", "")
