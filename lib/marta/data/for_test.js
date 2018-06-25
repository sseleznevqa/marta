document.marta_add_data = function(){
  document.getElementById("title").innerHTML = document.marta_what;
  document.getElementById(document.old_marta_Data).innerHTML = document.old_marta_Data;
};
document.marta_result = "";
document.marta_confirm_mark = false;

document.marta_connect = function() {
  var event = new CustomEvent('marta_send', {'detail':{ 'port': document.martaPort, 'mark': document.marta_confirm_mark }});
  this.dispatchEvent(event);
};

setTimeout(function() { document.marta_result = "Done"; document.marta_connect(); }, 1000);
setTimeout(function() { document.marta_confirm_mark = true; document.marta_connect(); }, 2000);
