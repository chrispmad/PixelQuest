# Start a new adventure!
observeEvent(input$start_adv, {
  shinyjs::hide(id = 'opening_screen_id')
  
  # The following functions need to be written, still.
  run_plots(TRUE)
  current_map(terra::rast('data/maps/santa_marta.tif'))
  
  # Starting coords / indices for Santa Marta level
  char_lat(11.22376)
  char_lng(-74.17845)
  
  player_current_el(
    terra::extract(current_map(),
                   terra::vect(data.frame(lat = char_lat(),
                                          lng = char_lng()),
                               geom = c("lng","lat"))
    )[,2]
  )
  
  char_x(25)
  char_y(30)
  
  # run_start_text()
  # 
  # prof = new_profile()
  # 
  # start_game_engine(prof)
})