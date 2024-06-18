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