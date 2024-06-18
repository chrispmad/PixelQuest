# Map making logic
# Convert coords of player to an sf box for the plot.
char_sf = reactive({
  sf::st_as_sf(
    data.frame(
      lat = c(char_lat()+rpsize()/2, char_lat()-rpsize()/2),
      lng = c(char_lng()+rpsize()/2, char_lng()-rpsize()/2)
    ), 
    coords = c("lng","lat"), 
    crs = 4326
  ) |> 
    # Then make it a square by finding the bounding box.
    sf::st_bbox() |> sf::st_as_sfc() |> sf::st_as_sf()
})

# The following version of char_sf is to show a jumping animation
char_sf_vis = reactive({
  sf::st_as_sf(
    data.frame(
      lat = c(char_lat()+rpsize()/2 + (floor(player_jump()/2))*rpsize(), char_lat()-rpsize()/2 + (floor(player_jump()/2))*rpsize()),
      lng = c(char_lng()+rpsize()/2, char_lng()-rpsize()/2)
    ), 
    coords = c("lng","lat"), 
    crs = 4326
  ) |> 
    # Then make it a square by finding the bounding box.
    sf::st_bbox() |> sf::st_as_sfc() |> sf::st_as_sf()
})

# Let's try it with leaflet and leaflet proxy?
output$leaf_map = renderLeaflet({
  req(run_plots())
  req(!is.na(current_map()))
  
  terrain_colours = terrain.colors(max(terra::values(current_map())))
  terrain_colours[1] <- 'darkblue'
  
  leaflet() |> 
    leaflet::addRasterImage(x = current_map(),
                            colors = terrain_colours
    )
})

observe({
  req(run_plots())
  leafletProxy('leaf_map') |> 
    clearGroup('player-icon') |> 
    addPolygons(data = char_sf(),
                fillColor = 'black',
                color = 'black',
                group = 'player-icon') |> 
    addPolygons(data = char_sf_vis(),
                fillColor = 'purple',
                color = 'purple',
                group = 'player-icon')
})