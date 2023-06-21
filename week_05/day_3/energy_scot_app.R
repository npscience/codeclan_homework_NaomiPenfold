# load libraries
library(shiny)
library(tidyverse)
library(bslib)
library(CodeClanData)

# read in data from CodeClanData
energy_scot <- CodeClanData::energy_scotland

all_sectors <- energy_scot %>% 
  distinct(Sector) %>% 
  pull()

# set up ui
ui <- fluidPage(
  theme = bs_theme(bootswatch = "lux"),
  
  titlePanel(tags$h1("Scottish energy production by sector")),
  
  HTML("<br>"),
  
  fluidRow(
    column(width = 8, offset = 2,
           tags$h2("Compare energy production between sectors"),
           tags$i("Select two sectors from the dropdown list to compare production over time")),
  ),
  
  HTML("<br>"),
  
  fluidRow(
    column(width = 4, offset = 2,
           selectInput("sector1",
                       "Sector 1:",
                       choices = all_sectors,
                       selected = "Renewables")),
    
    column(width = 4,
           selectInput("sector2",
                       "Sector 2:",
                       choices = all_sectors,
                       selected = "Coal"))
  ),
  
  fluidRow(
    column(width = 4, offset = 2,
           plotOutput("prod_sector1")),
    
    column(width = 4,
           plotOutput("prod_sector2"))
  ),
  
  fluidRow(
    column(width = 8, offset = 2,
           HTML("<br>"),
           tags$h2("Energy production from all sectors"),
           plotOutput("all_years_composition"))
  )
)

# set up server
server <- function(input,output){
  
  output$all_years_composition <- renderPlot({
    energy_scot %>% 
      ggplot() +
      aes(x = Year, y = EnergyProd, fill = Sector) +
      geom_col(position = "stack") +
      labs(x = "\nYear", y = "Energy production\n", fill = "Sector") +
      scale_fill_brewer(palette = "Dark2") +
      scale_x_continuous(breaks = c(2004,2006,2008,2010,2012,2014,2016,2018)) + 
      scale_y_continuous(limits = c(0,60000), labels = scales::comma) +
      theme_minimal()
  })
  
  output$prod_sector1 <- renderPlot({
    energy_scot %>%
      filter(Sector == input$sector1) %>% 
      ggplot() +
      aes(x = Year, y = EnergyProd, colour = Sector) +
      geom_line(show.legend = FALSE, size = 1.5) +
      geom_point(show.legend = FALSE, size = 3) +
      labs(x = "\nYear", y = "Energy production\n") +
      scale_colour_manual(values = c(
        "Renewables" = "#1b9e77",
        "Pumped hydro" = "#d95f02",
        "Nuclear" = "#7570b3",
        "Coal" = "#e7298a",
        "Oil" = "#66a61e",
        "Gas" = "#e6ab02"
      )) +
      scale_x_continuous(breaks = c(2004,2008,2012,2016,2020)) +
      scale_y_continuous(limits = c(0,30000), labels = scales::comma) +
      theme_minimal()
  })
  
  output$prod_sector2 <- renderPlot({
    energy_scot %>%
      filter(Sector == input$sector2) %>% 
      ggplot() +
      aes(x = Year, y = EnergyProd, colour = Sector) +
      geom_line(show.legend = FALSE, size = 1.5) +
      geom_point(show.legend = FALSE, size = 3) +
      labs(x = "\nYear", y = "Energy production\n") +
      scale_colour_manual(values = c(
        "Renewables" = "#1b9e77",
        "Pumped hydro" = "#d95f02",
        "Nuclear" = "#7570b3",
        "Coal" = "#e7298a",
        "Oil" = "#66a61e",
        "Gas" = "#e6ab02"
      )) +
      scale_x_continuous(breaks = c(2004,2008,2012,2016,2020)) +
      scale_y_continuous(limits = c(0,30000), labels = scales::comma) +
      theme_minimal()
  })
}

# set up app
shinyApp(ui = ui, server = server)
