# Map making logic
# Convert coords of player to an sf box for the plot.
char_sf = reactive({
  req(!is.na(current_map()))
  res = sf::st_as_sf(
    data.frame(
      lat = c(char_lat()+rpsize()/2, char_lat()-rpsize()/2),
      lng = c(char_lng()+rpsize()/2, char_lng()-rpsize()/2)
    ), 
    coords = c("lng","lat"), 
    crs = 4326
  ) |> 
    # Then make it a square by finding the bounding box.
    sf::st_bbox() |> sf::st_as_sfc() |> sf::st_as_sf()
  res |> 
    dplyr::rename(geometry = x)
})

# The following version of char_sf is to show a jumping animation
char_sf_vis = reactive({
  req(!is.na(current_map()))
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

monsters_sf = reactive({
  req(!is.null(monster_one()))
  dplyr::bind_rows(
    monster_one()#,
    # monster_two()#,
    # monster_three()
  ) |> 
    sf::st_buffer(dist = 1000)
})

# Make coin markers
coin_markers = leaflet::makeIcon(
  #iconUrl = "http://127.0.0.1:40473/graphics/75a5fba1-530d-45f0-957f-3e413a741fa5.png"
  iconUrl = "data/entities/spinning-coin.gif",
  iconWidth = 100,
  iconHeight = 100,
  iconAnchorX = 50,
  iconAnchorY = 50
)

# Let's try it with leaflet and leaflet proxy?
output$leaf_map = renderLeaflet({
  req(run_plots())
  req(!is.na(current_map()))
  
  terrain_colours = terrain.colors(max(terra::values(current_map())))
  terrain_colours[1] <- 'darkblue'
  
  l = leaflet() |> 
    leaflet::addRasterImage(x = current_map(),
                            colors = terrain_colours
    )
  
  if(nrow(goldcoins()) > 0){
    l = l |> 
      clearGroup('coins') |> 
      addMarkers(icon = coin_markers,
                 data = goldcoins(),
                 group = 'coins')
  } else {
    l = l |> 
      clearGroup('coins')
  }
})

observe({
  req(run_plots())
  req(!pause_game())
  req(!is.na(current_map()))
  
  leafletProxy('leaf_map') |> 
    clearGroup('player-icon') |> 
    clearGroup('monster-icons') |>
    addPolygons(data = char_sf(),
                fillColor = 'black',
                color = 'black',
                group = 'player-icon') |> 
    addPolygons(data = char_sf_vis(),
                fillColor = 'purple',
                color = 'purple',
                group = 'player-icon') |> 
      addPolygons(data = monsters_sf(),
                  fillColor = 'red',
                  color = 'orange',
                  opacity = 1,
                  fillOpacity = 0.8,
                  group = 'monster-icons')
  
})