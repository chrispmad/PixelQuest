$(document).ready(function(){
   var keys = {
     left: false,
     up: false,
     right: false,
     down: false,
     spacebar: false,
     escape: false
   };

  function updateKeyState() {
    Shiny.setInputValue('keys', keys, {priority: 'event'});
  }

   $(document).on('keydown', function(event){
     var key = event.which;
     if(key === 37){
       keys.left = true;
     } else if(key === 38){
       keys.up = true;
     } else if(key === 39){
       keys.right = true;
     } else if(key === 40){
       keys.down = true;
     } else if(key === 32){
       keys.spacebar = true;
     } else if(key === 27){
        keys.escape = true;
     }
   });

   $(document).on('keyup', function(event){
     var key = event.which;
     if(key === 37){
       keys.left = false;
     } else if(key === 38){
       keys.up = false;
     } else if(key === 39){
       keys.right = false;
     } else if(key === 40){
       keys.down = false;
     } else if(key === 32){
       keys.spacebar = false;
     } else if(key === 27){
        keys.escape = false;
     }
   });
   
   setInterval(function() {
     updateKeyState();
   }, 100);
});