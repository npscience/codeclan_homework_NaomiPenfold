ui <- fluidPage(
  theme = bs_theme(bootswatch = "simplex"),
  
  # ABOVE TABS ----
  titlePanel(tags$h3("Videogame industry landscape")),
  
  # select developer(s) and genre(s)
  fluidRow(
    column(width = 6,
           # select developer(s)
           checkboxGroupInput(inputId = "multi_developer_input",
                              label = tags$b("Which game developer(s)?"),
                              choices = developers_list,
                              selected = developers_list,
                              inline = TRUE)
    ),
    column(width = 6,
           # select genre(s)
           checkboxGroupInput(inputId = "genre",
                              label = tags$b("Which genre(s)?"),
                              choices = genres_list,
                              selected = genres_list,
                              inline = TRUE)
    )
  ),
  
  # select year range
  fluidRow(column(width = 8,
                  sliderInput(inputId = "year_range",
                              label = tags$b("Which year?"),
                              min = min(game_sales_filtered$year_of_release),
                              max = max(game_sales_filtered$year_of_release),
                              value = c(1996,2016),
                              step = 1,
                              ticks = FALSE,
                              round = TRUE,
                              sep = ""
                  )
  ),
  
  column(width = 4,
         HTML("<br>"),
         actionButton(inputId = "submit",
                      label = "Submit choices"),
  )
  ),
  
  tabsetPanel(
    
    # Tab 1: Developer performance ----
    
    tabPanel(tags$b("Developer performance"),
             HTML("<br>"),
             fluidRow(
               column(width = 6,
                      plotOutput("devs_years_sales")
               ),
               column(width = 6,
                      plotOutput("user_v_critic_scores")
               )
             )
    ),
    
    # Tab 2: genre performance ----
    
    tabPanel(tags$b("Genre performance"),
             HTML("<br>"),
             fluidRow(
               column(width = 4,
                      plotOutput("num_games_released")
               ),
               column(width = 8,
                      plotOutput("genre_performance")
               )
             )
    ),
    
    # Tab 3: see the data ----
    tabPanel("Data for all games in this period",
             sidebarLayout(
               sidebarPanel(
                 textInput(inputId = "game_text_search",
                           label = "Search for game:",
                           value = "",
                           placeholder = "Try Mario or FIFA"),
                 
                 actionButton(inputId = "name_search",
                              label = "Search")
               ),
               mainPanel(
                 DT::dataTableOutput("games_table_output")
               )
             )
    )
  )
)