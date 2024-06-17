function PlayMusic() {
  var play=document.getElementById("music");
  play.play();
}

function StopMusic() {
  var play=document.getElementById("music");
  play.pause();
}
    
$(document).ready(function(){

    harp = document.getElementById('harp');

    music_is_playing = false;
    harp_clicked = false;

    setInterval(function() {
      if(music_is_playing == false & harp_clicked == false){
        PlayMusic();
        music_is_playing = true;
      }
    }, 1000);

    // Click effects
    harp.addEventListener('click', function() {
        if(!music_is_playing){
            PlayMusic();
            music_is_playing = true;
        } else {
            StopMusic();
            music_is_playing = false;
            harp_clicked = true;
        }
    });
})