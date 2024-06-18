# Read arrow key presses and set to pending_move reactiveVal
observe({
  req(input$keys$left)
  pending_move('left')
})
observe({
  req(input$keys$right)
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

# React to spacebar to make character jump
observe({
  req(input$keys$spacebar)
  if(player_jump() == 0){
    # Give 5 'units' of global clock time (i.e. 500 ms) for jump
    player_jump(player_jump() + 5)
    shinyjs::runjs("document.getElementById('jump_audio').play();")
  }
})

# React to escape key - bring up pause menu
observe({
  req(input$keys$escape)
  # The following function is not yet written
  pause_game()
  run_plots(FALSE)
  create_menu_window()
})