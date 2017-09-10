document.marta_room = 0;
document.marta_result = {};
document.marta_confirm_mark = false;

document.getElementById("marta_confirm").onclick = function() {document.marta_confirm()};
document.getElementById("marta_more_fields").onclick = function() {document.marta_add_field()};
document.getElementById("marta_hide").onclick = function() {document.marta_hide()};

document.marta_create_element = function(dom, tag, attrs, inner) {
  var element = document.createElement(tag);
  dom.appendChild(element);
  for (var key in attrs) {
    element.setAttribute(key, attrs[key])
  };
  element.innerHTML = inner;
  return element;
};

document.marta_add_field = function() {
    document.marta_room++;
    var objTo = document.getElementById("vars_fileds");
    var divtest = document.createElement("div");
    objTo.appendChild(divtest);
    var contentDiv = document.marta_create_element(divtest, "div", {"martaclass": "marta_smthing", "martastyle": "field_line", "class": "content", "id": "marta_staff"+document.marta_room}, "");
    var nameField = document.marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martastyle": "name_field", "class": "marta_s_name_field", "type": "text", "id": "marta_name"+document.marta_room, "value": ""}, "");
    var valueField = document.marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martastyle": "value_field", "type": "text", "id": "marta_default_value"+document.marta_room, "value": ""}, "");
    var cancelButton = document.marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martaroom": document.marta_room, "martastyle": "cancel_button", "type": "button", "id": "delete_marta_value"+document.marta_room, "value": "Delete"}, "");
    document.getElementById("delete_marta_value"+document.marta_room).onclick = function(e) {document.marta_delete_line(e)};
};

document.marta_confirm = function(){
        for(i=1; i<=document.marta_room; i++){
            if (!!document.getElementById("marta_name"+i) && (document.getElementById("marta_name"+i).value != "")) {
              document.marta_result[document.getElementById("marta_name"+i).value] = document.getElementById("marta_default_value"+i).value;
            };
        };
        var toClear = document.querySelector("[martaclass=marta_div]");
        toClear.parentNode.removeChild(toClear);
        document.marta_confirm_mark = true;
        return document.marta_result;};

document.marta_add_data = function() {
    document.getElementById("marta_main_title").innerHTML = "You are defining " + document.marta_what;
    for (var key in document.old_marta_Data){
        document.marta_add_field();
        document.getElementById("marta_name"+document.marta_room ).value = key;
        document.getElementById("marta_default_value"+document.marta_room ).value = document.old_marta_Data[key];
    };
};

document.marta_delete_line = function(theEvent) {
    var line = theEvent.target.getAttribute("martaroom");
    var staff = document.getElementById("marta_staff"+line);
    title.parentNode.removeChild(title);
    staff.parentNode.removeChild(staff);
};

document.marta_hide = function() {
  var toHide = document.querySelector("[martaclass=marta_div]");
  if (toHide.getAttribute("martastyle")=="hidden"){
    toHide.setAttribute("martastyle", "none");
  } else{
    toHide.setAttribute("martastyle", "hidden");
  };
}
