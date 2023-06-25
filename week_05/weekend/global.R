library(shiny)
library(tidyverse)
library(bslib)

# load filtered game sales data to look at more recent mid-market developers only
# where games released since 2010 between 10 and 50
# to constrain data options the user has to play with
game_sales_mid_devs <- CodeClanData::game_sales %>% 
  # filter for games released since 2010
  filter(year_of_release >= 2010) %>% 
  # remove higher & lower productive developers
  filter(!(developer %in% c("EA", "Ubisoft", "Neversoft Entertainment", "Maxis", "Vicarious Visions")))
  
# set up input lists
developers_list <- sort(unique(game_sales_mid_devs$developer))
genres_list <- sort(unique(game_sales_mid_devs$genre))
platforms_list <- sort(unique(game_sales_mid_devs$platform))
ratings_list <- sort(unique(game_sales_mid_devs$rating))

# set up colour scheme for developers
colours_ndev <- Polychrome::createPalette(N = length(unique(developers_list)), seedcolors = c("#ff0000", "#00ff00", "#0000ff"), target = c("normal", "protanope", "deuteranope", "tritanope"))

# make colour scheme vector matching developer name to colour in palette
developer_colour_scheme <- setNames(colours_ndev, developers_list)