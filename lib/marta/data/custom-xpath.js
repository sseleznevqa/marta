var marta_result = {};
var marta_confirm_mark = false;
var marta_temp_els =[];

function marta_add_data() {
    marta_confirm_mark = false;
    document.getElementById("marta_main_title").innerHTML = "XPATH for " + marta_what + " = ?";
};

function marta_look() {
  try {
    for (var i=0; i<marta_temp_els.snapshotLength; i++) {
      marta_temp_els.snapshotItem(i).removeAttribute("martaclass");
    };
    var t=0;
    var value = document.getElementById("marta_user_xpath").value;
    var result = document.evaluate(value, document.body, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
    marta_temp_els = result;
    for (var i=0; i<result.snapshotLength; i++) {
      var marta_smthing = ((result.snapshotItem(i).getAttribute("martaclass")=="marta_smthing")||(result.snapshotItem(i).getAttribute("martaclass")=="marta_div"));
      if(!marta_smthing) {
        result.snapshotItem(i).setAttribute("martaclass","foundbymarta");
        t = t+1;
      };
    };
    document.getElementById("marta_xpath_label").innerHTML = "Found " + t + " elements";
  } catch(e) {
    document.getElementById("marta_xpath_label").innerHTML = "Ooops! Are you sure? Maybe Xpath is wrong?";
  };
};

function marta_confirm(){
    for (var i=0; i<marta_temp_els.snapshotLength; i++) {
      marta_temp_els.snapshotItem(i).removeAttribute("martaclass");
    };
    marta_result["collection"] = document.getElementById("marta_array").checked;
    marta_result["xpath"] = document.getElementById("marta_user_xpath").value;
    var toClear = document.querySelector("[martaclass=marta_smthing]");
    toClear.parentNode.removeChild(toClear);
    marta_confirm_mark = true;
};

function marta_try_again(){
    for (var i=0; i<marta_temp_els.snapshotLength; i++) {
      marta_temp_els.snapshotItem(i).removeAttribute("martaclass");
    };
    var toClear = document.querySelector("[martaclass=marta_div]");
    toClear.parentNode.removeChild(toClear);
    marta_confirm_mark = true;
    marta_result = "2";
};

function marta_hide() {
  var toHide = document.querySelector("[martaclass=marta_div]");
  if (toHide.getAttribute("martastyle")=="hidden"){
    toHide.setAttribute("martastyle", "none");
  } else{
    toHide.setAttribute("martastyle", "hidden");
  };
}
