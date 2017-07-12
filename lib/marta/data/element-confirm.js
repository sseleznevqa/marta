var marta_result = {};
var marta_confirm_mark = false;

function marta_confirm(){
    var toClear = document.querySelector("[martaclass=marta_smthing]");
    toClear.parentNode.removeChild(toClear);
    marta_confirm_mark = true;
    marta_result = "4";
};

function marta_click_work(e){};

function marta_try_again(){
    var toClear = document.querySelector("[martaclass=marta_div]");
    toClear.parentNode.removeChild(toClear);
    marta_confirm_mark = true;
    marta_result = "2";
};

function marta_set_by_hand(){
    var toClear = document.querySelector("[martaclass=marta_div]");
    toClear.parentNode.removeChild(toClear);
    marta_confirm_mark = true;
    marta_result = "3";
};

function marta_add_data() {
    marta_confirm_mark = false;
    document.getElementById("marta_main_title").innerHTML = old_marta_Data + " elements found for " + marta_what;
};

function marta_hide() {
  var toHide = document.querySelector("[martaclass=marta_div]");
  if (toHide.getAttribute("martastyle")=="hidden"){
    toHide.setAttribute("martastyle", "none");
  } else{
    toHide.setAttribute("martastyle", "hidden");
  };
}
