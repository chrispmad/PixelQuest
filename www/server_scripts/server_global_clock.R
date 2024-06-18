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