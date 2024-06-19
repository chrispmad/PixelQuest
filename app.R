source('ui.R')

server <- function(input, output, session) {

  current_wd = getwd()
  if(!stringr::str_detect(current_wd, 'www$')) setwd(paste0(current_wd,'/www'))
  
  # Adjust working directory, load in map files, ready server.
  source('server_scripts/server_initialize_server.R', local = TRUE)$value
  
  # Have a little timer somewhere so the user can see how long it took them to finish?
  source('server_scripts/server_timer.R', local = TRUE)$value
  
  # Set up reactives
  source('server_scripts/server_set_up_reactives.R', local = TRUE)$value
  
  # Start a new adventure!
  source('server_scripts/server_start_new_adventure.R', local = TRUE)$value
  
  # Continue an adventure
  source('server_scripts/server_continue_adventure.R', local = TRUE)$value
    
  # Measure current map
  source('server_scripts/server_measure_current_map.R', local = TRUE)$value
  
  # React to key presses
  source('server_scripts/server_key_reactions.R', local = TRUE)$value
  
  # Set up monsters
  source('server_scripts/server_make_monsters.R', local = TRUE)$value
  
  source('server_scripts/server_button_reactions.R', local = TRUE)$value
  
  # Global clock; recalculates every 100 ms.
  source('server_scripts/server_global_clock.R', local = TRUE)$value
  
  # Map making logic
  source('server_scripts/server_map_making_logic.R', local = TRUE)$value
}

shinyApp(ui, server)
