library(shiny)
library(bslib)
library(shinyjs)
library(ggplot2)
library(tidyterra)
library(leaflet)

source('www/utils/util_global_clock_funs.R')

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