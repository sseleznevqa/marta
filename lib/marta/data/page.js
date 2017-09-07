var marta_room = 0;
var marta_result = {};
var marta_confirm_mark = false;

document.getElementById("marta_confirm").onclick = function() {marta_confirm()};
document.getElementById("marta_more_fields").onclick = function() {marta_add_field()};
document.getElementById("marta_hide").onclick = function() {marta_hide()};

function marta_create_element(dom, tag, attrs, inner) {
  var element = document.createElement(tag);
  dom.appendChild(element);
  for (var key in attrs) {
    element.setAttribute(key, attrs[key])
  };
  element.innerHTML = inner;
  return element;
};

function marta_add_field() {
    marta_room++;
    var objTo = document.getElementById("vars_fileds");
    var divtest = document.createElement("div");
    objTo.appendChild(divtest);
    var contentDiv = marta_create_element(divtest, "div", {"martaclass": "marta_smthing", "martastyle": "field_line", "class": "content", "id": "marta_staff"+marta_room}, "");
    var nameField = marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martastyle": "name_field", "class": "marta_s_name_field", "type": "text", "id": "marta_name"+marta_room, "value": ""}, "");
    var valueField = marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martastyle": "value_field", "type": "text", "id": "marta_default_value"+marta_room, "value": ""}, "");
    var cancelButton = marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martaroom": marta_room, "martastyle": "cancel_button", "type": "button", "id": "delete_marta_value"+marta_room, "value": "Delete"}, "");
    document.getElementById("delete_marta_value"+marta_room).onclick = function(e) {marta_delete_line(e)};
};

function marta_confirm(){
        for(i=1; i<=marta_room; i++){
            if (!!document.getElementById("marta_name"+i) && (document.getElementById("marta_name"+i).value != "")) {
              marta_result[document.getElementById("marta_name"+i).value] = document.getElementById("marta_default_value"+i).value;
            };
        };
        var toClear = document.querySelector("[martaclass=marta_div]");
        toClear.parentNode.removeChild(toClear);
        marta_confirm_mark = true;
        return marta_result;};

function marta_add_data() {
    document.getElementById("marta_main_title").innerHTML = "You are defining " + marta_what;
    for (var key in old_marta_Data){
        marta_add_field();
        document.getElementById("marta_name"+marta_room ).value = key;
        document.getElementById("marta_default_value"+marta_room ).value = old_marta_Data[key];
    };
};

function marta_delete_line(theEvent) {
    var line = theEvent.target.getAttribute("martaroom");
    var staff = document.getElementById("marta_staff"+line);
    title.parentNode.removeChild(title);
    staff.parentNode.removeChild(staff);
};

function marta_hide() {
  var toHide = document.querySelector("[martaclass=marta_div]");
  if (toHide.getAttribute("martastyle")=="hidden"){
    toHide.setAttribute("martastyle", "none");
  } else{
    toHide.setAttribute("martastyle", "hidden");
  };
}
