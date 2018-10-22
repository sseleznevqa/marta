// A little bite of esoteric here :)
document.time = null;
let port = window.location.href.split('dialog.html?port=')[1];
//let iframe = document.getElementById('marta_dialog_container');
setInterval(function(){

  const Http = new XMLHttpRequest();
  const url='http://127.0.0.1:'+ port + '/updated';
  Http.open("GET", url);
  Http.send();
  Http.onreadystatechange = function(){
    let iframe = document.getElementById('marta_dialog_container');
    if ((this.readyState == 4) && (this.status == 200) && (Http.responseText != document.time)) {
      iframe.src = 'http://127.0.0.1:'+ port + '/welcome';
      document.time = Http.responseText;
      //console.log(time);
    }
  }
}, 1000);
//Question can dialog access chrome sync storage?
//If we can not we can still send it from context.js
