server <- function(input, output, session) {
  
  # global filter by user inputs ----
  
  # selecting genre(s), developer(s) and year range gives user option to explore perforamnce metrics for subsets of the games industry 
  games_data_input <- eventReactive(
    eventExpr = input$submit, {
      game_sales_filtered %>% 
        filter(developer %in% input$multi_developer_input) %>% 
        filter(genre %in% input$genre) %>% 
        filter(year_of_release >= input$year_range[1] &
                 year_of_release <= input$year_range[2])
    })
  
  # outputs for tab 1: Developer performance ----

  # show plot for total sales by developer(s) for year range
  # this plot quickly shows which developers have released the most games
  output$devs_years_sales <- renderPlot({
    games_data_input() %>% 
      group_by(developer) %>% 
      summarise(total_sales = sum(sales, na.rm = TRUE)) %>% 
      ggplot() +
      aes(y = reorder(developer, total_sales), x = total_sales, fill = developer) +
      geom_col(show.legend = FALSE) +
      #scale_fill_manual(values = developer_colour_scheme) +
      scale_fill_brewer(palette = "Set1") +
      labs(x = "\nTotal sales", y = "Developer", title = "Total sales across year range") +
      theme_simplex()
  })
  
  # show plot for user v critic scores by developer(s) for year range
  # with trend line and ordered by highest critic score first (top-left)
  # This plot shows the user and critics' reception to games produced by each developer
  # the more points in the top-right, the better received they were
  # trendline gradient also indicates whether critics and users agree (if so, x~y)
  output$user_v_critic_scores <- renderPlot({
    games_data_input() %>% 
      ggplot() +
      aes(x = critic_score, y = user_score, colour = developer) +
      geom_point(size = 0.5, show.legend = FALSE) +
      geom_smooth(method = lm, se = FALSE, size = 1, show.legend = FALSE) +
      scale_colour_brewer(palette = "Set1") +
      labs(x = "\nCritic score", y = "User score\n", colour = "Developer",
           title = "Game performance by user/critic") +
      facet_wrap(~ reorder(developer, -critic_score), ncol = 3) +
      theme_simplex()
  })
  
  # outputs for tab 2: Market trends by genre ----
  
  # plot number of games released by year by genre
  # this shows which genres of games have been released when
  # and with all genres selected, we see action and sports dominate throughout
  output$num_games_released <- renderPlot({
    games_data_input() %>% 
      group_by(genre, year_of_release) %>% 
      summarise(num_games = n()) %>% 
      ggplot() +
      aes(x = year_of_release, y = num_games, fill = factor(genre)) +
      geom_col(position = "stack", show.legend = FALSE) +
      scale_fill_manual(values = genre_colour_scheme) +
      labs(y = "Number of games released\n", x = "\nYear", fill = "Genre",
           title = "Game releases by genre") +
      theme_simplex()
  })
  
  # make summary stats for genre
  # this is a more complex plot for looking at overall performance by genre
  # when using averages of critic and user score and sales across the genre,
  # there doesn't seem to be a pattern between reception and sales
  # however - it would be useful to drill down into individual games
  # (as done in developer tab)
  output$genre_performance <- renderPlot({
    games_data_input() %>% 
      group_by(genre) %>% 
      summarise(across(.cols = c(sales, user_score, critic_score),
                        .fns = ~ mean(.x, na.rm=TRUE))) %>% 
      ggplot() +
      geom_point(aes(x = critic_score, y = user_score, size = sales, colour = genre)) +
      #geom_text(aes(label = genre), vjust = 0.3, hjust = -0.2, size = 2, show.legend = FALSE) +
      scale_colour_manual(values = genre_colour_scheme) +
      labs(x = "\nAverage critic score", y = "Average user score\n", colour = "Genre", 
           size = "Average sales", title = "Average performance by genre") +
      theme_simplex() +
      theme(legend.position = "left")
  })
  
  
  # outputs for tab 3: See the data ----
  
  # filter for game name as per text input
  game_text_input <- eventReactive(
    eventExpr = input$name_search, {
      games_data_input() %>% 
        filter(str_detect(name, input$game_text_search))
    })
  
  # show searchable data table for selected developer(s) and year released
  output$games_table_output <- DT::renderDataTable({
    game_text_input() %>% 
      select(name,genre,platform,developer,year_of_release,sales,critic_score,user_score) %>% 
      arrange(name)
  })
}