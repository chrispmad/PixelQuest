# Find the dimension of each raster pixel for the current map.
rpsize = reactive(terra::res(current_map())[1])
map_ext = reactive(terra::ext(current_map()))
map_ncol = reactive(terra::ncol(current_map()))
map_nrow = reactive(terra::nrow(current_map()))