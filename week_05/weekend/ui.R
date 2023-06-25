ui <- fluidPage(
  #theme = bs_theme(bootswatch = "cyborg"),
  
  titlePanel(tags$h1("Videogame market landscape by game developer(s)")),
  
  fluidRow(
    column(width = 4,
           # select year range
           sliderInput(inputId = "year_range",
                       label = "Which year?",
                       min = min(game_sales_mid_devs$year_of_release),
                       max = max(game_sales_mid_devs$year_of_release),
                       value = c(2010,2016),
                       step = 1,
                       round = TRUE,
                       sep = ""
           )
    ),
    
    column(width = 8,
           # multi-select checkboxes for developers
           checkboxGroupInput(inputId = "multi_developer_input",
                              label = "Which game developer(s)?",
                              choices = developers_list,
                              # select all but the biggest producers
                              # Ubisoft and EA
                              selected = developers_list,
                              inline = TRUE
           )
    )
    
  ),
  
  actionButton(inputId = "update",
               label = "Show / Update results"),
  
  tabsetPanel(
    
    tabPanel(tags$b("Games released"),
             
             plotOutput("num_games_released"),
             
    ),
    
    
    tabPanel(tags$b("Developer market performance"),
             
             fluidRow(
               column(width = 6,
                      plotOutput("devs_years_sales")
               ),
               
               column(width = 6,
                      plotOutput("user_v_critic_scores")
               )
               
             )
             
    ),
    
    tabPanel("See the data",
             
             fluidRow(
               column(width = 6,
                      checkboxGroupInput(inputId = "genre",
                                  label = "Genre",
                                  choices = genres_list,
                                  selected = genres_list,
                                  inline = TRUE)
               ),
               
               column(width = 6,
                      checkboxGroupInput(inputId = "platform",
                                  label = "Platform:",
                                  choices = platforms_list,
                                  selected = platforms_list,
                                  inline = TRUE)
               )
             ),
             
             fluidRow(
               actionButton(inputId = "reveal",
                            label = "Reveal the games"),
             ),
             
             fluidRow(
               HTML("<br>"),
               tags$i("The games:"),
               HTML("<br><br>"),
               
               DT::dataTableOutput("multidev_games_table_output")
             )
    )
    
  )
)