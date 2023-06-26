library(shiny)
library(tidyverse)
library(bslib)

# load game_sales data
game_sales <- CodeClanData::game_sales

# filter game sales to exclude developers with total sales < 50 (units)
# to constrain options available to user, look at more prominent developers only
developers_totsales_50 <- game_sales %>% 
  group_by(developer) %>% 
  summarise(total_sales = sum(sales, na.rm = TRUE)) %>% 
  filter(total_sales > 50) %>% 
  pull(developer)

game_sales_filtered <- game_sales %>% 
  filter(developer %in% developers_totsales_50)

# set up input lists
developers_list <- sort(unique(game_sales_filtered$developer))
genres_list <- sort(unique(game_sales_filtered$genre))
#platforms_list <- sort(unique(game_sales_filtered$platform))
#ratings_list <- sort(unique(game_sales_filtered$rating))

# set up colorblind-friendly colour scheme for 12 genres
colours_n_genre <- Polychrome::createPalette(N = length(unique(game_sales_filtered$genre)), seedcolors = c("#ff0000", "#00ff00", "#0000ff"), target = c("normal", "protanope", "deuteranope", "tritanope"))
genre_colour_scheme <- setNames(colours_n_genre, genres_list)

# use brewer Set 1 for developers (darker colours)

# make a theme for all plots
theme_simplex <- function() {
  theme_minimal() +
    theme(
      # add border 1)
      panel.border = element_rect(colour = "white", fill = NA),
      
      # color background 2)
      panel.background = element_rect(fill = "white"),
      
      # modify grid 3)
      panel.grid.major.x = element_line(colour = "grey80", linetype = 3, size = 0.5),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.y =  element_line(colour = "grey80", linetype = 3, size = 0.5),
      panel.grid.minor.y = element_blank(),
      
      # modify texts
      plot.title = element_text(colour = "firebrick3", face = "bold", family = "Arial", size = 20),
      legend.title = element_text(family = "Arial", size = 16),
      legend.text = element_text(family = "Arial", size = 12),
      axis.title = element_text(face = "bold", family = "Arial", size = 16),
      axis.text = element_text(family = "Arial", size = 14),
      strip.text.x = element_text(size = 12, face = "bold")
    )
}
