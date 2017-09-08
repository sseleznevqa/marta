var marta_room = 0;
var marta_result = {};
var marta_confirm_mark = false;

var clickListener = function(e) {marta_magic_click(e); clickListener = function() {}};
document.addEventListener("click", clickListener, true);
document.getElementById("marta_confirm").onclick = function() {marta_end_loop()};
document.getElementById("marta_set_by_hand").onclick = function() {marta_set_by_hand()};
document.getElementById("marta_show_html").onclick = function() {marta_show_html()};
document.getElementById("marta_hide").onclick = function() {marta_hide()};

if (!document.getElementById("marta_magic_div")){
  marta_create_element(document.body, "div", {"martaclass": "marta_smthing","id":"marta_magic_div", "martastyle": "at_large"}, "");
} else {
  document.getElementById("marta_magic_div").setAttribute("martastyle", "at_large");
};

function marta_magic_click(e) {
  var xx = e.clientX;
  var yy = e.clientY;
  document.getElementById("marta_magic_div").setAttribute("martastyle", "off");
  marta_click_work(document.elementFromPoint(xx, yy));
  document.getElementById("marta_magic_div").setAttribute("martastyle", "at_large");
};

function sleep(ms) {
  ms += new Date().getTime();
  while (new Date() < ms){};
};

function marta_create_element(dom, tag, attrs, inner) {
  var element = document.createElement(tag);
  dom.appendChild(element);
  for (var key in attrs) {
    element.setAttribute(key, attrs[key])
  };
  element.innerHTML = inner;
  return element;
};

function marta_add_field(title, what, key, marker) {
    marta_room++;
    var objTo = document.getElementById("attr_fields");
    var divtest = document.createElement("div");
    objTo.appendChild(divtest);
    divtest.setAttribute("martaclass", "marta_smthing");
    var headerDiv = marta_create_element(divtest, "div", {"martaclass": "marta_smthing", "class": "label", "id": "marta_title"+marta_room}, "ATTR");
    var contentDiv = marta_create_element(divtest, "div", {"martaclass": "marta_smthing", "martastyle": "field_line", "class": "content", "id": "marta_staff"+marta_room}, "");
    var nameField = marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martastyle": "name_field", "class": "marta_s_name_field", "type": "text", "disabled": "disabled;", "id": "marta_name"+marta_room, "value": ""}, "");
    var valueField = marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martastyle": "value_field", "type": "text", "id": "marta_default_value"+marta_room, "value": ""}, "");
    var cancelButton = marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martaroom": marta_room, "martastyle": "cancel_button", "type": "button", "id": "delete_marta_value"+marta_room, "value": "Delete"}, "");
    document.getElementById("marta_title"+marta_room ).innerHTML = title;
    document.getElementById("marta_name"+marta_room ).value = what;
    var field = document.getElementById("marta_default_value"+marta_room);
    field.value = key;
    var att = document.createAttribute("marta_object_map");
    att.value = title+";;"+what+";;"+marker;
    field.setAttributeNode(att);
    document.getElementById("delete_marta_value"+marta_room).onclick = function(e) {marta_delete_line(e)};
    document.getElementById("marta_default_value"+marta_room).onchange = function(e) {marta_change_field(e)};
};

function marta_change_field(field){
  var data = field.getAttribute("marta_object_map").split(";;");
  if (data[2] == "-1"){
    if (field.value == ""){
      delete marta_result[data[0]][data[1]];
    } else {
      marta_result[data[0]][data[1]]=field.value;
    };
  }else if (data[2] == "taggy"){
    if (field.value == ""){
      marta_result["options"][data[1]] = "*";
    } else {
      marta_result["options"][data[1]]=field.value;
    };
  }else {
    if (field.value == ""){
      delete marta_result[data[0]][data[1]][parseInt(data[2])];
    } else {
      marta_result[data[0]][data[1]][parseInt(data[2])]=field.value;
    };
  };
  marta_confirm();
};

function marta_clean_up(){
  var toClear = document.body.querySelectorAll("[martaclass=marta_div],[martaclass=marta_script],[martaclass=marta_style]");
  for (var i = 0; i < toClear.length; i++) {
    toClear[i].parentNode.removeChild(toClear[i]);
  };
  marta_room = 0;
};

function marta_confirm(){
  if (marta_room != 0){
    marta_result["options"]["collection"] = document.getElementById("marta_array").checked;
    marta_clean_up();
    for (var what in marta_result){
      for (var key in marta_result[what]){
        if (marta_result[what][key] instanceof Array){
          for (var i = 0; i < marta_result[what][key].length; i++) {
            if (marta_result[what][key][i] == undefined) {
              marta_result[what][key].splice(i, 1);
            i--;
            };
          };
        };
      };
    };
    marta_confirm_mark = true;
    return marta_result;
  };
};

function marta_add_data() {
  marta_result = old_marta_Data;
    marta_confirm_mark = false;
    document.getElementById("marta_main_title").innerHTML = marta_what;
    if (old_marta_Data != {}){
      try {
        document.getElementById("marta_array").checked = old_marta_Data["options"]["collection"];}
      catch(e){};
      for (var what in old_marta_Data){
        if (what != "options"){
          marta_add_field("TAG", what, old_marta_Data["options"][what], "taggy");
          for (var key in old_marta_Data[what]){
              if (/class/.test(key) == true){
                for (var k = 0, length = old_marta_Data[what][key].length; k < length; k++){
                  marta_add_field(what, key, old_marta_Data[what][key][k], k);
                };
              }else
              {
                marta_add_field(what, key, old_marta_Data[what][key], "-1");
              };
            };
        };
      };
    };
};

function marta_show_html() {
  var area = document.getElementById("marta_s_html_holder");
  area.innerHTML = spaninize(document.documentElement.innerHTML);
};

function marta_touch(element) {
  var control = element.textContent.replace(/</g,"&lt;").replace(/>/g,"&gt;");
  var everything = document.getElementsByTagName("*");
  for (var i=0, max=everything.length; i < max; i++) {
    var check = everything[i].outerHTML.replace(/</g,"&lt;").replace(/>/g,"&gt;");
    if (check == control) {
      everything[i].click();
    };
  };
};

function wrap(el, wrapper) {
  wrapper.appendChild(el.cloneNode(true));
  el.parentNode.replaceChild(wrapper, el);
};

function spaninize(string) {
  var dummy = document.createElement( "marta_span" );
  dummy.innerHTML = string;
  ignore = dummy.querySelectorAll("[martaclass=marta_div],[martaclass=marta_script],[martaclass=marta_style]");
  for (var i = 0; i < ignore.length; i++) {
    ignore[i].parentNode.removeChild(ignore[i]);
  };
  dummy.setAttribute("martaclass", "marta_smthng");
  var counter = {};
  var everything = dummy.getElementsByTagName("*");
  for (var i=0, max=everything.length; i < 2*max; i=i+2) {
    if (counter[everything[i].tagName] == null) {
      counter[everything[i].tagName] = 0;
    } else {
      counter[everything[i].tagName] = counter[everything[i].tagName] + 1;
    };
    var wrapper = document.createElement( "marta_span" );
    wrapper.setAttribute("martaclass","marta_smthing");
    wrap(everything[i], wrapper);
  };
  var theParent = document.getElementById("marta_s_html_holder");
  theParent.onclick = function(e) {pretouch(e)};
  return dummy.innerHTML.replace(/<(?!.?marta_span)([^>]*)>/g,"&lt;$1&gt;").replace(/marta_span/g,"span");
};

function pretouch(e) {
    if (e.target !== e.currentTarget) {
        var clickedItem = e.target;
        marta_touch(clickedItem);
    };
};

function marta_click_work(target) {
    var marta_smthing = target.getAttribute("martaclass")=="marta_smthing";
    if(!marta_smthing){
        document.getElementById("attr_fields").innerHTML="";
        marta_room = 0;
        marta_result = {};
        marta_result["options"] = {};
        marta_after_click(target,"self");
        if (!!target.parentElement){
          marta_after_click(target.parentElement,"pappy");
        };
        if (!!target.parentElement.parentElement){
          marta_after_click(target.parentElement.parentElement,"granny");
        };
        marta_confirm();
    };
};

function marta_after_click(el, what) {
    marta_result[what] = {};
    marta_result["options"][what] = el.tagName;
    marta_add_field("TAG", what, marta_result["options"][what], "taggy");
    for (var att, i = 0, atts = el.attributes, n = atts.length; i < n; i++){
      att = atts[i];
      if(/^[a-zA-Z0-9- _!@#$%^*();:,.?/]*$/.test(att.nodeValue) == true && att.nodeName != "martaclass"){
        if (/class/.test(att.nodeName) == true){
          var values=att.nodeValue.split(" ");
          marta_result[what][att.nodeName]=[];
          for (var val, j = 0, vals = values, l = vals.length; j < l; j++){
            val = vals[j];
            marta_result[what][att.nodeName][j]=val;
          };
        } else {
          marta_result[what][att.nodeName]=att.nodeValue;
        };
      };
    };
    if (what == "self"){
      try{
        marta_result[what]["retrieved_by_marta_text"]=el.firstChild.nodeValue;
      }catch(e){};
    };
    for (var key in marta_result[what]){
      if (/class/.test(key) == true){
        for (var k = 0, length = marta_result[what][key].length; k < length; k++){
          marta_add_field(what, key, marta_result[what][key][k], k);
        };
      }else
      {
        marta_add_field(what, key, marta_result[what][key], "-1");
      };
    };
};

function marta_delete_line(theEvent) {
    var line = theEvent.target.getAttribute("martaroom");
    var title = document.getElementById("marta_title"+line);
    var staff = document.getElementById("marta_staff"+line);
    var field = document.getElementById("marta_default_value"+line);
    field.value = "";
    marta_change_field(field);
    staff.parentNode.removeChild(staff);
    title.parentNode.removeChild(title);
};

function marta_set_by_hand(){
    var toClear = document.querySelector("[martaclass=marta_div]");
    toClear.parentNode.removeChild(toClear);
    marta_confirm_mark = true;
    marta_result = "3";
};

function marta_end_loop(){
    if (marta_room != 0){
      marta_clean_up();
      marta_confirm_mark = true;
      marta_result = "1";
    }
};

function marta_hide() {
  var toHide = document.querySelector("[martaclass=marta_div]");
  if (toHide.getAttribute("martastyle")=="hidden"){
    toHide.setAttribute("martastyle", "none");
  } else{
    toHide.setAttribute("martastyle", "hidden");
  };
}
