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