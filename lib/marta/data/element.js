document.marta_result = {};
document.marta_confirm_mark = false;
document.marta_test_xx = 0;
document.marta_test_yy = 0;
document.marta_shift = false;

document.getElementById("marta_confirm").onclick = function() {document.marta_end_loop()};
document.getElementById("marta_set_by_hand").onclick = function() {document.marta_set_by_hand()};
document.getElementById("marta_show_html").onclick = function(e) {document.marta_show_html(e)};
document.getElementById("marta_hide").onclick = function() {document.marta_hide()};
document.getElementById("marta_stop").onclick = function() {document.marta_stop()};
document.getElementById("marta_array").onclick = function() {document.marta_array_switch()};

document.marta_array_switch = function(){
  if (document.getElementById("marta_array").checked) {
    document.getElementById("marta_hint").innerHTML = "<p>You are selecting a collection. Select two elements of a kind</p><p>And marta will automatically find all the similar elements</p><p>If Marta found too many elements exclude the wrong element by click on it with Shift</p><p>Note: Marta will return Watir::HTMLElementCollection</p>";
  } else {
    document.getElementById("marta_hint").innerHTML = "<p>You are selecting a single element.</p><p>Remember Marta will perform .to_subtype for it automatically</p>";
  };
};

document.marta_stop = function() {
  if (document.getElementById("marta_magic_div").getAttribute("martastyle") == "off"){
    document.getElementById("marta_magic_div").setAttribute("martastyle", "at_large");
    document.getElementById("marta_stop").value = String.fromCharCode(55357)+String.fromCharCode(56385);
    document.getElementById("marta_hint").innerHTML = "<p>Marta is watching you</p><p>Please click <b>the correct element</b> only!</p>";
  } else {
    document.getElementById("marta_stop").value = "--";
    document.getElementById("marta_magic_div").setAttribute("martastyle", "off");
    document.getElementById("marta_hint").innerHTML = "<p>Go ahead! Marta is not watching.</p><p>All your actions <b>will not</b> be counted as an element definition</p><p>It will lasts until page will not be refreshed (or new opened).</p><p>Or until you will not switch it off</p>";
  }
};

document.marta_magic_click = function(e) {
  if (document.marta_test_xx == 0) {var xx = e.clientX} else {var xx = document.marta_test_xx};
  if (document.marta_test_yy == 0) {var yy = e.clientY} else {var yy = document.marta_test_yy};
  document.getElementById("marta_magic_div").setAttribute("martastyle", "off");
  let is_shift = e.shiftKey||document.marta_shift;
  document.marta_result = {"element": document.elementFromPoint(xx, yy), "collection": document.getElementById("marta_array").checked, "exclude": is_shift};
  document.marta_confirm();
  document.getElementById("marta_magic_div").setAttribute("martastyle", "at_large");
};

document.marta_create_element = function(dom, tag, attrs, inner) {
  var element = document.createElement(tag);
  dom.appendChild(element);
  for (var key in attrs) {
    element.setAttribute(key, attrs[key])
  };
  element.innerHTML = inner;
  return element;
};

if (!document.getElementById("marta_magic_div")){
  document.marta_create_element(document.body, "div", {"martaclass": "marta_smthing","id":"marta_magic_div", "martastyle": "at_large"}, "");
} else {
  document.getElementById("marta_magic_div").setAttribute("martastyle", "at_large");
};
document.getElementById('marta_magic_div').onclick = function(e) {document.marta_magic_click(e)};

document.marta_clean_up = function(){
  var toClear = document.body.querySelectorAll("[martaclass=marta_div],[martaclass=marta_script],[martaclass=marta_style]");
  for (var i = 0; i < toClear.length; i++) {
    toClear[i].parentNode.removeChild(toClear[i]);
  };
};

document.marta_confirm = function(){
  document.marta_clean_up();
  document.marta_confirm_mark = true;
  document.marta_connect();
  return document.marta_result;
};

document.marta_show_html = function(e) {
  console.log(e.target.getAttribute('tag'));
  console.log(e.target.getAttribute('index'));
  document.pretouch(document.getElementsByTagName(e.target.getAttribute('tag')).item(e.target.getAttribute('index')),e.shiftKey);
};

document.marta_touch = function(element, shift) {
      document.marta_result = {"element": element, "collection": document.getElementById("marta_array").checked, "exclude": shift};
      document.marta_confirm();
};

document.pretouch = function(element, shift) {
        document.marta_touch(element, shift);
};

document.marta_set_by_hand = function(){
    var toClear = document.querySelector("[martaclass=marta_div]");
    toClear.parentNode.removeChild(toClear);
    document.marta_confirm_mark = true;
    document.marta_result = "3";
    document.marta_connect();
};

document.marta_end_loop = function(){
    if (document.marta_room != 0){
      document.marta_clean_up();
      document.marta_confirm_mark = true;
      document.marta_result = "1";
      document.marta_connect();
    }
};

document.marta_hide = function() {
  var toHide = document.querySelector("[martaclass=marta_div]");
  if (toHide.getAttribute("martastyle")=="hidden"){
    toHide.setAttribute("martastyle", "none");
  } else{
    toHide.setAttribute("martastyle", "hidden");
  };
};

document.marta_add_data = function() {
    document.marta_result = document.old_marta_Data;
    document.marta_confirm_mark = false;
    document.getElementById("marta_main_title").innerHTML = document.marta_what;
    try {
      document.getElementById("marta_array").checked = document.old_marta_Data["options"]["collection"];}
    catch(e){};
};

document.marta_connect = function() {
  var event = new CustomEvent('marta_send', {'detail':{ 'port': document.martaPort, 'mark': document.marta_confirm_mark }});
  this.dispatchEvent(event);
};
