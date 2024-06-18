# Continue an adventure
observeEvent(input$load_adv, {
  shinyjs::hide(id = 'opening_screen_id')
  
  prof = load_profile()
  
  start_game_engine(prof)
})