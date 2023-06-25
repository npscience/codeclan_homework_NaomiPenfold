library(shiny)
library(tidyverse)
library(bslib)

game_sales <- CodeClanData::game_sales #%>% 
#mutate(year = as.integer(year_of_release), .before = year_of_release)

# set up input lists
developers_list <- unique(game_sales$developer)


ui <- fluidPage(
  #theme = bs_theme(bootswatch = "cyborg"),
  
  titlePanel(tags$h1("Videogame market landscape by game developer(s)")),
  
  fluidRow(
    # input selector
    column(width = 4,
           sliderInput(inputId = "year_range",
                       label = "Which year?",
                       min = min(game_sales$year_of_release),
                       max = max(game_sales$year_of_release),
                       value = c(2010,2016),
                       step = 1,
                       round = TRUE,
                       sep = ""
           )
    ),
    
    column(width = 8,
           checkboxGroupInput(inputId = "multi_developer_input",
                              label = "Which game developer(s)?",
                              choices = developers_list,
                              selected = c("Namco", "Capcom", 
                                           "Traveller's Tales",
                                           "Neversoft Entertainment", 
                                           "Vicarious Visions", 
                                           "Konami", "Visual Concepts", 
                                           "Maxis", "Yuke's", "Midway",
                                           "TT Games", "Omega Force", "Codemasters"),
                              inline = TRUE
           )
    )
    
  ),
  
  tabsetPanel(
    
    tabPanel("Games released by developer(s)",
             
             plotOutput("num_games_released"),
             
             HTML("<br>"),
             
             DT::dataTableOutput("multidev_games_table_output")
             
    ),
    
    fluidRow(
      column(width = 6,
             plotOutput("sales")
      ),
      
      column(width = 6,
             plotOutput("user_v_critic_scores")
      )
    )
    
  ),
  
  tabPanel("By developer",
           
           fluidRow(
             radioButtons(inputId = "handed_input",
                          label = "Handedness",
                          choices = c("L", "R"),
                          inline = TRUE)
           ),
           
           fluidRow(
             plotOutput("plotA")
           )
           
           
  ),
  
  tabPanel("See the data",
           
           fluidRow(
             radioButtons(inputId = "other_input",
                          label = "Handedness",
                          choices = c("A", "B"),
                          inline = TRUE)
           ),
           
           fluidRow(
             plotOutput("plotB")
           )  
  )
  
)

server <- function(input, output, session) {
  
  # game_sales_year_dev_input <- eventReactive(
  #   eventExpr = {
  #   game_sales %>% 
  #     # add year range filter
  #     filter(year_of_release %in% input$year_range) %>%
  #     # add multi-select developer input
  #     filter(developer %in% input$multi_developer_input) 
  # })
  
  output$num_games_released <- renderPlot({
    # game_sales_year_dev_input %>% 
    game_sales %>% 
      # add year range filter
      filter(year_of_release >= input$year_range[1] & 
               year_of_release <= input$year_range[2]) %>%
      # add multi-select developer input
      filter(developer %in% input$multi_developer_input) %>% 
      group_by(developer, year_of_release) %>% 
      summarise(num_games = n()) %>% 
      ungroup() %>% 
      ggplot() +
      aes(x = year_of_release, y = num_games, fill = developer) +
      geom_col(show.legend = FALSE) +
      scale_fill_manual(values = developer_colour_scheme) +
      labs(y = "Number of games released\n", x = "Year", fill = "Developer") +
      facet_wrap(~ developer, ncol = 4) +
      theme_minimal()
  })
  
  output$multidev_games_table_output <- DT::renderDataTable({
    game_sales %>% 
      # add year range filter
      filter(year_of_release >= input$year_range[1] & 
               year_of_release <= input$year_range[2]) %>%
      # add multi-select developer input
      filter(developer %in% input$multi_developer_input) %>% 
      select(name,developer,year_of_release) %>% 
      arrange(desc(year_of_release), developer, name)
  })
  
}

shinyApp(ui, server)