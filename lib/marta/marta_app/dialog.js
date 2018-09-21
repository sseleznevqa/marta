// A little bite of esoteric here :)
let port = window.location.href.split('dialog.html?port=')[1];
setInterval(function(){
  let iframe = document.getElementById('marta_dialog_container');
  iframe.src = 'http://127.0.0.1:'+ port + '/welcome';
}, 1000);
//Question can dialog access chrome sync storage?
//If we can not we can still send it from context.js
