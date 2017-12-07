document.marta_result = {};
document.marta_confirm_mark = false;
document.marta_temp_els =[];

document.getElementById("marta_try_again").onclick = function() {document.marta_try_again()};
document.getElementById("marta_confirm").onclick = function() {document.marta_confirm()};
document.getElementById("marta_user_xpath").onchange = function() {document.marta_look()};
document.getElementById("marta_hide").onclick = function() {document.marta_hide()};

document.marta_add_data = function() {
    document.marta_confirm_mark = false;
    document.getElementById("marta_main_title").innerHTML = "XPATH for " + document.marta_what + " = ?";
};

document.marta_look = function() {
  try {
    for (var i=0; i<document.marta_temp_els.snapshotLength; i++) {
      document.marta_temp_els.snapshotItem(i).removeAttribute("martaclass");
    };
    var t=0;
    var value = document.getElementById("marta_user_xpath").value;
    var result = document.evaluate(value, document.body, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
    document.marta_temp_els = result;
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

document.marta_confirm = function(){
    for (var i=0; i<document.marta_temp_els.snapshotLength; i++) {
      document.marta_temp_els.snapshotItem(i).removeAttribute("martaclass");
    };
    document.marta_result["collection"] = document.getElementById("marta_array").checked;
    document.marta_result["xpath"] = document.getElementById("marta_user_xpath").value;
    var toClear = document.querySelector("[martaclass=marta_smthing]");
    toClear.parentNode.removeChild(toClear);
    document.marta_confirm_mark = true;
};

document.marta_try_again = function(){
    for (var i=0; i<document.marta_temp_els.snapshotLength; i++) {
      document.marta_temp_els.snapshotItem(i).removeAttribute("martaclass");
    };
    var toClear = document.querySelector("[martaclass=marta_div]");
    toClear.parentNode.removeChild(toClear);
    document.marta_confirm_mark = true;
    document.marta_result = "2";
};

document.marta_hide = function() {
  var toHide = document.querySelector("[martaclass=marta_div]");
  if (toHide.getAttribute("martastyle")=="hidden"){
    toHide.setAttribute("martastyle", "none");
  } else{
    toHide.setAttribute("martastyle", "hidden");
  };
};

while (true) {
  var document.xmlHttp = new XMLHttpRequest();
  if (document.marta_confirm_mark) {
    document.martaUrl = "http://localhost:" + document.martaPort + "/dialog/got_answer"
  } else {
    document.martaUrl = "http://localhost:" + document.martaPort + "/dialog/not_answer"
  };
  document.xmlHttp.open( "GET", document.martaUrl, false );
  document.xmlHttp.send( null );
}
