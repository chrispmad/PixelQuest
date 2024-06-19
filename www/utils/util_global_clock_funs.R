make_pot_char_sf = function(lat, lng){
  pot_char_sf = sf::st_as_sf(
    data.frame(
      lat = lat,
      lng = lng
    ), 
    coords = c('lng','lat'),
    crs = 4326
  )
}

find_current_elev = function(current_map, lat, lng){
  terra::extract(
    current_map,
    terra::vect(data.frame(lat = lat,
                           lng = lng),
                geom = c("lng","lat"))
  )[,2]
}

end_game = function(){
  
  # Pause map
  pause_game()
  
  # Create alert window notifying the user that the game is over
  shiny::showModal(
    shiny::modalDialog(
    title = 'Game Over...',
    actionButton('restart_adv','Restart?')
    )
  )
  
  
}

get_random_position = function(current_map,map_ext,rpsize,map_ncol,map_nrow){
  random_col = sample(c(1:map_ncol), size = 1)
  random_row = sample(c(1:map_nrow), size = 1)

  lng = map_ext[1] + rpsize * random_col
  lat = map_ext[3] + rpsize * random_row
  
  sf::st_as_sf(data.frame(lat,lng), coords = c('lng','lat'), crs = 4326)
}

make_goldcoin = function(id,lat,lng){
  data.frame(id,lat,lng) |> 
    sf::st_as_sf(coords = c('lng','lat'),
                 crs = 4326)
}
