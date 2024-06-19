# Global clock; recalculates every 100 ms.
# Keeps track of things like player movement and monster movement.
observe({
  invalidateLater(100, session)
  
  if(game_over()){
    end_game()
  }
  # Remove a unit of time from the jump, if the player has jumped
  isolate(
    if(player_jump() > 0){
      player_jump(player_jump() - 1)
    }
  )
  
  if(!is.null(goldcoins())){
    
    # if(player_points() == 100) browser()
    
    if(nrow(goldcoins()[goldcoins()$id == 1,]) == 1){
      coin_one = sf::st_coordinates(goldcoins()[goldcoins()$id == 1,])
    } else {
      coin_one = NULL
    }
    if(nrow(goldcoins()[goldcoins()$id == 2,]) == 1){
      coin_two = sf::st_coordinates(goldcoins()[goldcoins()$id == 2,])
    } else {
      coin_two = NULL
    }
    
    # See if the player has bumped coin one.
    if(!is.null(coin_one)){
      if(abs(char_lng()) - abs(coin_one[,1]) <= (2 * rpsize()) & abs(char_lat()) - abs(coin_one[,2]) <= (2 * rpsize())){
        player_points(player_points() + 100)
        goldcoins(goldcoins() |> dplyr::filter(id != 1))
      }
    }
    # See if player has bumped into coin two.
    if(!is.null(coin_two)){
      if(abs(char_lng()) - abs(coin_two[,1]) <= (2 * rpsize()) & abs(char_lat()) - abs(coin_two[,2]) <= (2 * rpsize())){
        player_points(player_points() + 100)
        goldcoins(goldcoins() |> dplyr::filter(id != 2))
      }
    }
  }
    
  # Listen for arrow keys - move player coordinates for each keystroke.
  isolate(
    if(pending_move() != 'none'){
      
      current_elev = find_current_elev(current_map(), char_lat(), char_lng())
      # player_current_el(current_elev)
      
      if(pending_move() == 'left'){
        
        new_lng = char_lng() - rpsize()
        
        pot_char_sf = make_pot_char_sf(char_lat(), new_lng)
        
        new_elev = terra::extract(current_map(), terra::vect(pot_char_sf))[,2]
        
        # Acceptable new elevation - it's within 1 level of difference!
        if(new_elev <= current_elev + floor(player_jump()/2) & new_elev >= current_elev - 1){
          char_lng(new_lng)
        }
      }
      if(pending_move() == 'right'){
        new_lng = char_lng() + rpsize()
        
        pot_char_sf = make_pot_char_sf(char_lat(), new_lng)
        
        new_elev = terra::extract(current_map(), terra::vect(pot_char_sf))[,2]
        
        # Acceptable new elevation - it's within 1 level of difference!
        if(new_elev <= current_elev + floor(player_jump()/2) & new_elev >= current_elev - 1){
          char_lng(new_lng)
        }
      }
      if(pending_move() == 'up'){
        new_lat = char_lat() + rpsize()
        
        pot_char_sf = pot_char_sf = make_pot_char_sf(new_lat, char_lng())
        
        new_elev = terra::extract(current_map(), terra::vect(pot_char_sf))[,2]
        # Acceptable new elevation - it's within 1 level of difference!
        if(new_elev <= current_elev + floor(player_jump()/2) & new_elev >= current_elev - 1){
          char_lat(new_lat)
        }
      }
      if(pending_move() == 'down'){
        new_lat = char_lat() - rpsize()
        
        pot_char_sf = pot_char_sf = make_pot_char_sf(new_lat, char_lng())
        
        new_elev = terra::extract(current_map(), terra::vect(pot_char_sf))[,2]
        
        # Acceptable new elevation - it's within 1 level of difference!
        if(new_elev <= current_elev + floor(player_jump()/2) & new_elev >= current_elev - 1){
          char_lat(new_lat)
        }
      }
      pending_move('none')
    }
  )
})

observe({
  invalidateLater(1000, session)
  isolate({
    req(run_plots())
    req(!is.null(monster_one()))
    
    # for(i in 1:number_monsters()){
  
    monster_coords = monster_one() |>
      sf::st_coordinates()

    monster_x = monster_coords[,1]
    monster_y = monster_coords[,2]

    player_x = char_lng()
    player_y = char_lat()

    # Is monster closer than 10 or fewer map cells to the player?
    if(abs(player_x) - abs(monster_x) <= (10 * rpsize()) & abs(player_y) - abs(monster_y) <= (10 * rpsize())){

      # Find 1 rpsize closer to the player in both dimensions.
      if(monster_x > player_x){
        new_monster_x = monster_x - rpsize()
      } else {
        new_monster_x = monster_x + rpsize()
      }

      if(monster_y > player_y){
        new_monster_y = monster_y - rpsize()
      } else {
        new_monster_y = monster_y + rpsize()
      }
    } else {
      # Nope! The monster is farther away. Random movement!
      new_monster_x = monster_x + sample(c(1,-1),1) * rpsize()
      new_monster_y = monster_y + sample(c(1,-1),1) * rpsize()
    }

    # new monster position
    new_monster_position = sf::st_as_sf(data.frame(new_monster_y,new_monster_x), coords = c('new_monster_x','new_monster_y'),crs = 4326)

    # browser()
    monster_one(new_monster_position)

  })
  # }


})