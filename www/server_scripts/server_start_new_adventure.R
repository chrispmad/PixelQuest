start_new_adventure = function(){
  # The following functions need to be written, still.
  run_plots(TRUE)
  
  current_map(terra::rast('data/maps/santa_marta_raster.tif'))
  
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
  
  timer_running(TRUE)
  
  number_monsters(1)
  
  monster_one(make_monster(current_map(),map_ext(),rpsize(),map_ncol(),map_nrow()))
  
  # monster_one(sf::st_as_sf(data.frame(lat = char_lat() + 0.005, lng = char_lng() + 0.005),
  #                      coords = c('lng','lat'),
  #                      crs = 4326))
  # monster_two(make_monster(current_map(),map_ext(),rpsize(),map_ncol(),map_nrow()))
  # monster_three(make_monster(current_map(),map_ext(),rpsize(),map_ncol(),map_nrow()))
  
  coin_coords = data.frame(id = c(1,2),
                           lat = c(11.13,10.55),
                           lng = c(-74.05,-73.55)) |> 
    dplyr::group_by(id) |> 
    dplyr::group_split()
  
  coins = purrr::map(coin_coords, ~ {
    make_goldcoin(.x$id, .x$lat, .x$lng)
    }) |> 
    dplyr::bind_rows()
  
  goldcoins(coins)
  # run_start_text()
  # 
  # prof = new_profile()
  # 
  # start_game_engine(prof)
}

# Start a new adventure!
observeEvent(input$start_adv, {
  
  shinyjs::hide(id = 'opening_screen_id')
  
  start_new_adventure()
  
})