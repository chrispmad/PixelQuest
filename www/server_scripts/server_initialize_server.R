# Load map(s). Maybe just the one the char is on.
p_map_files = list.files('/data/maps/', pattern = '.gpkg') |> 
  lapply(sf::read_sf)

r_map_files = list.files('/data/maps/', pattern = '.tif', full.names = T) |> 
  lapply(terra::rast)

names(r_map_files) = list.files('/data/maps/', pattern = '.tif')

# Make sure our opening screen is visible to start.
shinyjs::show(id = 'opening_screen_id',
              anim = TRUE, animType = 'fade',
              time = 4)