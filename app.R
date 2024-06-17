library(shiny)
library(bslib)
library(shinyjs)
library(ggplot2)
library(tidyterra)
library(leaflet)

harp_btn = tags$audio(id = 'music',
                      src = 'https://patrickdearteaga.com/audio/Flutes%20for%20Misha.ogg?_=19',
                      type = 'audio/mp3')
jump_sound = tags$audio(id = 'jump_audio',
                        src = 'https://cdn.freesound.org/previews/350/350901_5450487-lq.mp3',
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
  harp_btn,
  div(textOutput('timer'), class = 'timer'),
  class = 'gui-overlay'
)

gui = div(
  div(
    leafletOutput('leaf_map', width = '100%', height = '100%'),
    class = 'map-plot-frame'
  ),
  class = 'gui-frame'
)

ui <- page_fluid(
  shiny::includeCSS('www/data/css/gui.css'),
  shiny::includeScript('track_keyboard_keys.js'),
  shiny::includeScript('add_music_to_app.js'),
  useShinyjs(),
  jump_sound,
  gui,
  gui_overlay,
  opening_screen
)

server <- function(input, output, session) {

  current_wd = getwd()
  if(!stringr::str_detect(current_wd, 'www$')) setwd(paste0(current_wd,'/www'))

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
  
  observe({
    req(input$keys$escape)
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
  
  # Continue an adventure
  observeEvent(input$load_adv, {
    shinyjs::hide(id = 'opening_screen_id')
    
    prof = load_profile()
    
    start_game_engine(prof)
  })
  
  # Have a little timer somewhere so the user can see how long it took them to finish?
    start_time = Sys.time()
    current_time = reactiveVal(Sys.time())
    observe({
      invalidateLater(1000, session)
      current_time(Sys.time())
    })
    time_elapsed = reactive({
      floor(current_time() - start_time)
    })
    output$timer = renderText(time_elapsed())
    
  # Find the dimension of each raster pixel for the current map.
  rpsize = reactive(terra::res(current_map())[1])
  map_ext = reactive(terra::ext(current_map()))
  map_ncol = reactive(terra::ncol(current_map()))
  map_nrow = reactive(terra::nrow(current_map()))
  pending_move = reactiveVal('none')
  player_current_el = reactiveVal(0)
  player_jump = reactiveVal(0)
  
  observe({
    req(input$keys$spacebar)
    if(player_jump() == 0){
      # Give 5 'units' of global clock time (i.e. 500 ms) for jump
      player_jump(player_jump() + 5)
      shinyjs::runjs("document.getElementById('jump_audio').play();")
    }
  })
  
  # Set up monsters
  
  keys <- reactive({
    input$keys
  })
  
  observe({
    req(input$keys$left)
    pending_move('left')
  })
  observe({
    req(input$keys$right)
    print('right detected at ')
    print(Sys.time())
    pending_move('right')
  })
  observe({
    req(input$keys$up)
    pending_move('up')
  })
  observe({
    req(input$keys$down)
    pending_move('down')
  })
  
  # Global clock; recalculates every 100 ms.
  # Keeps track of things like player movement and monster movement.
  observe({
    invalidateLater(100, session)

    # Remove a unit of time from the jump
    isolate(
      if(player_jump() > 0){
        player_jump(player_jump() - 1)
      }
    )
    
    # Listen for arrow keys - move player coordinates for each keystroke.
    isolate(
      if(pending_move() != 'none'){
        if(pending_move() == 'left'){
          new_lng = char_lng() - rpsize()
          pot_char_sf = sf::st_as_sf(
            data.frame(
              lat = char_lat(),
              lng = new_lng
            ), 
            coords = c('lng','lat'),
            crs = 4326
          )
          new_elev = terra::extract(current_map(), terra::vect(pot_char_sf))[,2]
          # Acceptable new elevation - it's within 1 level of difference!
          if(new_elev <= player_current_el() + 1 + floor(player_jump()/2) & new_elev >= player_current_el() - 1){
            char_lng(new_lng)
          }
        }
        if(pending_move() == 'right'){
          new_lng = char_lng() + rpsize()
          pot_char_sf = sf::st_as_sf(
            data.frame(
              lat = char_lat(),
              lng = new_lng
            ), 
            coords = c('lng','lat'),
            crs = 4326
          )
          new_elev = terra::extract(current_map(), terra::vect(pot_char_sf))[,2]
          # Acceptable new elevation - it's within 1 level of difference!
          if(new_elev <= player_current_el() + 1 + floor(player_jump()/2) & new_elev >= player_current_el() - 1){
            char_lng(new_lng)
          }
        }
        if(pending_move() == 'up'){
          new_lat = char_lat() + rpsize()
          pot_char_sf = sf::st_as_sf(
            data.frame(
              lat = new_lat,
              lng = char_lng()
            ), 
            coords = c('lng','lat'),
            crs = 4326
          )
          new_elev = terra::extract(current_map(), terra::vect(pot_char_sf))[,2]
          # Acceptable new elevation - it's within 1 level of difference!
          if(new_elev <= player_current_el() + 1 + floor(player_jump()/2) & new_elev >= player_current_el() - 1){
            char_lat(new_lat)
          }
        }
        if(pending_move() == 'down'){
          new_lat = char_lat() - rpsize()
          pot_char_sf = sf::st_as_sf(
            data.frame(
              lat = new_lat,
              lng = char_lng()
            ), 
            coords = c('lng','lat'),
            crs = 4326
          )
          new_elev = terra::extract(current_map(), terra::vect(pot_char_sf))[,2]
          # Acceptable new elevation - it's within 1 level of difference!
          if(new_elev <= player_current_el() + 1 + floor(player_jump()/2) & new_elev >= player_current_el() - 1){
            char_lat(new_lat)
          }
        }
        pending_move('none')
      }
    )
    
    # Measure new elevation of player
    isolate(
      if(!is.na(char_lat()) & !is.na(char_lng())){
        player_current_el(
          terra::extract(current_map(),
                         terra::vect(data.frame(lat = char_lat(),
                                                lng = char_lng()),
                                     geom = c("lng","lat"))
          )[,2]
        )
        print(player_current_el())
      }
    )
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
  # terrain_colours = reactiveVal()
  # 
  # observe({
  #   req(run_plots())
  #   terrain_colours(terrain.colors(max(terra::values(current_map()))))
  #   terrain_colours(c('darkblue',terrain_colours()[-1]))
  # })
  
  # Let's try it with leaflet and leaflet proxy?
  output$leaf_map = renderLeaflet({
    req(run_plots())
    req(!is.na(current_map()))
    
    terrain_colours = terrain.colors(max(terra::values(current_map())))
    terrain_colours[1] <- 'darkblue'
    
    leaflet() |> 
      leaflet::addRasterImage(x = current_map(),
                              colors = terrain_colours()
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
}

shinyApp(ui, server)
