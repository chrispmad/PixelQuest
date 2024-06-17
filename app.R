library(shiny)
library(bslib)
library(shinyjs)
library(ggplot2)
library(tidyterra)

harp_btn = tags$audio(id = 'music', 
                      src = 'https://patrickdearteaga.com/audio/Flutes%20for%20Misha.ogg?_=19',
                      type = 'audio/mp3')

opening_screen = div(
  id = 'opening_screen_id',
  div(
  h5("WELCOME ADVENTURER!"),
  br(),
  br(),
  actionButton('start_adv',
               'NEW ADVENTURE'),
  actionButton('load_adv',
               'CONTINUE ADVENTURE'),
  class = 'opening-screen-text'),
  class = 'opening-screen'
)

gui_overlay = div(
  div(id = 'harp', class = 'harp'),
  class = 'gui-overlay'
)

gui = div(
  # div(
  #   plotOutput('map_plot', width = '100%', height = '100%'),
  #   class = 'map-plot-frame'
  # ),
  # div(
  #   plotOutput('char_pos_plot', width = '100%', height = '100%'),
  #   class = 'char-plot-frame'
  # ),
  div(
    leafletOutput('leaf_map', width = '100%', height = '100%'),
    class = 'map-plot-frame'
  ),
  class = 'gui-frame'
)

# Map specific keyboard keys to do certain things.
map_keys_js <- paste(
  "$(document).on('keydown', function(event){",
  "  var key = event.which;",
  "  if(key === 37){",
  "    Shiny.setInputValue('key_left', true, {priority: 'event'});",
  "  } else if(key === 38){",
  "    Shiny.setInputValue('key_up', true, {priority: 'event'});",
  "  } else if(key === 39){",
  "    Shiny.setInputValue('key_right', true, {priority: 'event'});",
  "  } else if(key === 40){",
  "    Shiny.setInputValue('key_down', true, {priority: 'event'});",
  "  }",
  "});"
)

ui <- page_fluid(
  tags$head(tags$script(HTML(map_keys_js))),
  shiny::includeCSS('www/data/css/gui.css'),
  shiny::includeScript('add_music_to_app.js'),
  useShinyjs(),
  gui,
  gui_overlay,
  opening_screen,
  harp_btn
)

server <- function(input, output, session) {
  
  print(getwd())
  
  current_wd = getwd()
  if(!stringr::str_detect(current_wd, 'www$')) setwd(paste0(current_wd,'/www'))
  
  print(getwd())
  
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
  
  # Establish reactives for character position on map.
  run_plots = reactiveVal(FALSE)
  current_map = reactiveVal(NA)
  char_lat = reactiveVal(NA)
  char_lng = reactiveVal(NA)
  char_x = reactiveVal(NA)
  char_y = reactiveVal(NA)
  
  observeEvent(input$key_esc, {
    # The following function is not yet written
    pause_game()
    run_plots(FALSE)
    create_menu_window()
  })
  
  # Start a new adventure!
  observeEvent(input$start_adv, {
    shinyjs::hide(id = 'opening_screen_id')
    
    # The following functions need to be written, still.
    run_plots(TRUE)
    current_map(terra::rast('data/maps/santa_marta.tif'))
    
    # Starting coords / indices for Santa Marta level
    char_lat(11.22376)
    char_lng(-74.17845)
    
    char_x(25)
    char_y(30)
    
    # run_start_text()
    # 
    # prof = new_profile()
    # 
    # start_game_engine(prof)
  })
  
  # Continue an adventure
  observeEvent(input$load_adv, {
    shinyjs::hide(id = 'opening_screen_id')
    
    prof = load_profile()
    
    start_game_engine(prof)
  })
  
  # Find the dimension of each raster pixel for the current map.
  rpsize = reactive(terra::res(current_map())[1])
  map_ext = reactive(terra::ext(current_map()))
  map_ncol = reactive(terra::ncol(current_map()))
  map_nrow = reactive(terra::nrow(current_map()))
  
  # Listen for arrow keys - move player coordinates for each keystroke.
  observeEvent(input$key_left, {
    new_lng = char_lng() - rpsize()
    char_lng(new_lng)
    # char_x(char_x() - 1)
    # if(char_x() < 1) char_x(1)
  })
  
  observeEvent(input$key_up, {
    new_lat = char_lat() + rpsize()
    char_lat(new_lat)
    # char_y(char_y() + 1)
    # if(char_y() >= map_nrow()) char_x(map_nrow())
  })
  
  observeEvent(input$key_down, {
    new_lat = char_lat() - rpsize()
    char_lat(new_lat)
    # char_y(char_y() - 1)
    # if(char_y() < 1) char_y(1)
  })
  
  observeEvent(input$key_right, {
    new_lng = char_lng() + rpsize()
    char_lng(new_lng)
    # char_x(char_x() + 1)
    # if(char_x() < map_ncol()) char_x(map_ncol())
  })
  
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
  
  # char_r = reactive({
  #   char_r = sm
  #   char_r[] <- 0
  #   char_r[char_x(),char_y()] <- 1
  #   return(char_r)
  # })
  
  # output$map_plot = renderPlot({
  #   req(run_plots())
  #   ggplot() + 
  #     tidyterra::geom_spatraster(data = current_map()) + 
  #     ggthemes::theme_map()
  # })
  
  # output$char_pos_plot = renderPlot({
  #   req(run_plots())
  #   
  #   # sf vector way
  #   # ggplot() + 
  #   #   geom_sf(data = char_sf(), fill = 'black', col = 'red') + 
  #   #   theme_void() +
  #   #   coord_sf(xlim = map_ext()[c(1,2)],
  #   #            ylim = map_ext()[c(3,4)]) +
  #   #   theme(
  #   #     panel.background = element_rect(fill = "transparent", colour = NA),
  #   #     plot.background = element_rect(fill = "transparent", colour = NA),
  #   #     panel.grid.major = element_blank(),
  #   #     panel.grid.minor = element_blank(),
  #   #     panel.border = element_blank()
  #   #   )
  #   
  #   # terra rast way
  #   ggplot() + 
  #     tidyterra::geom_spatraster(data = char_r()) + 
  #     theme_void()
  #   
  # }, bg = "transparent")
  
  terrain_colours = terrain.colors(max(terra::values(sm)))
  terrain_colours[1] <- 'darkblue'
  
  # Let's try it with leaflet and leaflet proxy?
  output$leaf_map = renderLeaflet({
    req(run_plots())
    req(!is.na(current_map()))
    
    leaflet() |> 
      leaflet::addRasterImage(x = current_map(),
                              colors = terrain_colours)
  })
  
  observe({
    req(run_plots())
    leafletProxy('leaf_map') |> 
      clearGroup('player-icon') |> 
      addPolygons(data = char_sf(),
                  group = 'player-icon')
  })
}

shinyApp(ui, server)
