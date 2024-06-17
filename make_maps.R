library(tidyverse)
library(elevatr)
library(terra)
library(leaflet)
library(sf)

# Find some cool jungles from the Sierra Nevada de Santa Marta, Colombia

santa_marta = data.frame(
  x = c(-74.31715, -73.19105),
  y = c(11.37998, 10.43605)
) |> 
  st_as_sf(coords = c('x','y'), crs = 4326) |> 
  st_bbox() |> 
  st_as_sfc() |> 
  st_as_sf()
  
sm_el = terra::rast(elevatr::get_elev_raster(locations = santa_marta, z = 7))

sm_el = sm_el |> 
  terra::crop(santa_marta) |> 
  terra::mask(santa_marta)

terra::plot(sm_el)

# Simplify the elevation into bins
sm_el_s = sm_el
sm_el_s[] <- cut(sm_el[], 12, labels = F)
sm_el_s

terra::plot(sm_el_s)

# Make into polygons for borders and stuff.
names(sm_el_s) <- 'santa_marta_elev'

sm_el_p = terra::as.polygons(sm_el_s)

ggplot() + 
  tidyterra::geom_spatvector(data = sm_el_p, aes(fill = santa_marta_elev))

sf::write_sf(st_as_sf(sm_el_p),'www/data/maps/santa_marta_polys.gpkg')
terra::writeRaster(sm_el_s, 'www/data/maps/santa_marta_raster.tif')
