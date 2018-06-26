document.marta_result = {};
document.marta_confirm_mark = false;

document.getElementById("marta_try_again").onclick = function() {document.marta_try_again()};
document.getElementById("marta_confirm").onclick = function() {document.marta_confirm()};
document.getElementById("marta_set_by_hand").onclick = function() {document.marta_set_by_hand()};
document.getElementById("marta_hide").onclick = function() {document.marta_hide()};

document.marta_confirm = function(){
    var toClear = document.querySelector("[martaclass=marta_smthing]");
    toClear.parentNode.removeChild(toClear);
    document.marta_confirm_mark = true;
    document.marta_result = "4";
    document.marta_connect();
};

document.marta_click_work = function(e){};

document.marta_try_again = function(){
    var toClear = document.querySelector("[martaclass=marta_div]");
    toClear.parentNode.removeChild(toClear);
    document.marta_confirm_mark = true;
    document.marta_result = "2";
    document.marta_connect();
};

document.marta_set_by_hand = function(){
    var toClear = document.querySelector("[martaclass=marta_div]");
    toClear.parentNode.removeChild(toClear);
    document.marta_confirm_mark = true;
    document.marta_result = "3";
    document.marta_connect();
};

document.marta_add_data = function() {
    document.marta_confirm_mark = false;
    document.getElementById("marta_main_title").innerHTML = document.old_marta_Data + " elements found for " + document.marta_what;
};

document.marta_hide = function() {
  var toHide = document.querySelector("[martaclass=marta_div]");
  if (toHide.getAttribute("martastyle")=="hidden"){
    toHide.setAttribute("martastyle", "none");
  } else{
    toHide.setAttribute("martastyle", "hidden");
  };
};

document.marta_connect = function() {
  var event = new CustomEvent('marta_send', {'detail':{ 'port': document.martaPort, 'mark': document.marta_confirm_mark }});
  this.dispatchEvent(event);
};
