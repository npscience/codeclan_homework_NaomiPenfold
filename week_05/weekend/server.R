server <- function(input, output, session) {
  
  game_sales_year_devs_input <- eventReactive(
    eventExpr = input$update, {
      game_sales_mid_devs %>% 
        # add year range filter
        filter(year_of_release >= input$year_range[1] &
                 year_of_release <= input$year_range[2]) %>%
        # add multi-select developer input
        filter(developer %in% input$multi_developer_input) 
    })
  
  game_sales_year_devs_table_filter <- eventReactive(
    eventExpr = input$reveal, {
      game_sales_year_devs_input() %>% 
        filter(genre %in% input$genre) %>% 
        filter(platform %in% input$platform)
    })
  
  # outputs for tab 1: Games released ----
  
  # plot number of games released by year for each developer in grid
  output$num_games_released <- renderPlot({
    game_sales_year_devs_input() %>% 
      group_by(developer, year_of_release) %>% 
      summarise(num_games = n()) %>% 
      ungroup() %>% 
      ggplot() +
      aes(x = year_of_release, y = num_games, fill = developer) +
      geom_col(show.legend = FALSE) +
      scale_fill_manual(values = developer_colour_scheme) +
      labs(y = "Number of games released\n", x = "\nYear", fill = "Developer") +
      facet_wrap(~ developer, ncol = 4) +
      theme(strip.text.x = element_text(size = 16, face = "bold"),
            axis.text = element_text(size = 12),
            axis.title = element_text(size = 20)
      )
  })
  
  # outputs for tab 2: Developer market performance ----
  
  # show plot for total sales by developer(s) for year range
  output$devs_years_sales <- renderPlot({
    game_sales_year_devs_input() %>% 
      ggplot() +
      aes(y = developer, x = sales, fill = developer) +
      geom_col(show.legend = FALSE) +
      scale_fill_manual(values = developer_colour_scheme) +
      labs(x = "Sales", y = "Developer")
  })
  
  # show plot for user v critic scores by developer(s) for year range
  output$user_v_critic_scores <- renderPlot({
    game_sales_year_devs_input() %>% 
      ggplot() +
      aes(x = critic_score, y = user_score, colour = developer) +
      geom_point(size = 2) +
      geom_smooth(method = lm, se = FALSE, size = 1) +
      scale_colour_manual(values = developer_colour_scheme) +
      labs(x = "Critic score", y = "User score", colour = "Developer") +
      theme(legend.position = "bottom")
  })
  
  # outputs for tab 3: see the data
  
  # show searchable data table for selected developer(s) and year released
  output$multidev_games_table_output <- DT::renderDataTable({
    game_sales_year_devs_table_filter() %>% 
      select(name,genre, platform,rating,developer,year_of_release) %>% 
      arrange(desc(year_of_release), developer)
  })
  
}