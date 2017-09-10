document.marta_room = 0;
document.marta_result = {};
document.marta_confirm_mark = false;
document.marta_test_xx = 0;
document.marta_test_yy = 0;

document.getElementById("marta_confirm").onclick = function() {document.marta_end_loop()};
document.getElementById("marta_set_by_hand").onclick = function() {document.marta_set_by_hand()};
document.getElementById("marta_show_html").onclick = function() {document.marta_show_html()};
document.getElementById("marta_hide").onclick = function() {document.marta_hide()};
document.getElementById("marta_stop").onclick = function() {document.marta_stop()};

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
  document.marta_click_work(document.elementFromPoint(xx, yy));
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

document.marta_add_field = function(title, what, key, marker) {
    document.marta_room++;
    var objTo = document.getElementById("attr_fields");
    var divtest = document.createElement("div");
    objTo.appendChild(divtest);
    divtest.setAttribute("martaclass", "marta_smthing");
    var headerDiv = document.marta_create_element(divtest, "div", {"martaclass": "marta_smthing", "class": "label", "id": "marta_title"+document.marta_room}, "ATTR");
    var contentDiv = document.marta_create_element(divtest, "div", {"martaclass": "marta_smthing", "martastyle": "field_line", "class": "content", "id": "marta_staff"+document.marta_room}, "");
    var nameField = document.marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martastyle": "name_field", "class": "marta_s_name_field", "type": "text", "disabled": "disabled;", "id": "marta_name"+document.marta_room, "value": ""}, "");
    var valueField = document.marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martastyle": "value_field", "type": "text", "id": "marta_default_value"+document.marta_room, "value": ""}, "");
    var cancelButton = document.marta_create_element(contentDiv, "input", {"martaclass": "marta_smthing", "martaroom": document.marta_room, "martastyle": "cancel_button", "type": "button", "id": "delete_marta_value"+document.marta_room, "value": "Delete"}, "");
    document.getElementById("marta_title"+document.marta_room ).innerHTML = title;
    document.getElementById("marta_name"+document.marta_room ).value = what;
    var field = document.getElementById("marta_default_value"+document.marta_room);
    field.value = key;
    var att = document.createAttribute("marta_object_map");
    att.value = title+";;"+what+";;"+marker;
    field.setAttributeNode(att);
    document.getElementById("delete_marta_value"+document.marta_room).onclick = function(e) {document.marta_delete_line(e)};
    document.getElementById("marta_default_value"+document.marta_room).onchange = function(e) {document.marta_change_field(e)};
};

document.marta_change_field = function(field){
  var data = field.getAttribute("marta_object_map").split(";;");
  if (data[2] == "-1"){
    if (field.value == ""){
      delete document.marta_result[data[0]][data[1]];
    } else {
      document.marta_result[data[0]][data[1]]=field.value;
    };
  }else if (data[2] == "taggy"){
    if (field.value == ""){
      document.marta_result["options"][data[1]] = "*";
    } else {
      document.marta_result["options"][data[1]]=field.value;
    };
  }else {
    if (field.value == ""){
      delete document.marta_result[data[0]][data[1]][parseInt(data[2])];
    } else {
      document.marta_result[data[0]][data[1]][parseInt(data[2])]=field.value;
    };
  };
  document.marta_confirm();
};

document.marta_clean_up = function(){
  var toClear = document.body.querySelectorAll("[martaclass=marta_div],[martaclass=marta_script],[martaclass=marta_style]");
  for (var i = 0; i < toClear.length; i++) {
    toClear[i].parentNode.removeChild(toClear[i]);
  };
  document.marta_room = 0;
};

document.marta_confirm = function(){
  if (document.marta_room != 0){
    document.marta_result["options"]["collection"] = document.getElementById("marta_array").checked;
    document.marta_clean_up();
    for (var what in document.marta_result){
      for (var key in document.marta_result[what]){
        if (document.marta_result[what][key] instanceof Array){
          for (var i = 0; i < document.marta_result[what][key].length; i++) {
            if (document.marta_result[what][key][i] == undefined) {
              document.marta_result[what][key].splice(i, 1);
            i--;
            };
          };
        };
      };
    };
    document.marta_confirm_mark = true;
    return document.marta_result;
  };
};

document.marta_add_data = function() {
  document.marta_result = document.old_marta_Data;
    document.marta_confirm_mark = false;
    document.getElementById("marta_main_title").innerHTML = document.marta_what;
    if (document.old_marta_Data != {}){
      try {
        document.getElementById("marta_array").checked = document.old_marta_Data["options"]["collection"];}
      catch(e){};
      for (var what in document.old_marta_Data){
        if (what != "options"){
          document.marta_add_field("TAG", what, document.old_marta_Data["options"][what], "taggy");
          for (var key in document.old_marta_Data[what]){
              if (/class/.test(key) == true){
                for (var k = 0, length = document.old_marta_Data[what][key].length; k < length; k++){
                  document.marta_add_field(what, key, document.old_marta_Data[what][key][k], k);
                };
              }else
              {
                document.marta_add_field(what, key, document.old_marta_Data[what][key], "-1");
              };
            };
        };
      };
    };
};

document.marta_show_html = function() {
  var area = document.getElementById("marta_s_html_holder");
  area.innerHTML = document.spaninize(document.documentElement.innerHTML);
};

document.marta_touch = function(element) {
  var control = element.textContent.replace(/</g,"&lt;").replace(/>/g,"&gt;");
  var everything = document.getElementsByTagName("*");
  for (var i=0, max=everything.length; i < max; i++) {
    var check = everything[i].outerHTML.replace(/</g,"&lt;").replace(/>/g,"&gt;");
    if (check == control) {
      document.marta_click_work(everything[i]);
    };
  };
};

document.wrap = function(el, wrapper) {
  wrapper.appendChild(el.cloneNode(true));
  el.parentNode.replaceChild(wrapper, el);
};

document.spaninize = function(string) {
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
    document.wrap(everything[i], wrapper);
  };
  var theParent = document.getElementById("marta_s_html_holder");
  theParent.onclick = function(e) {document.pretouch(e)};
  return dummy.innerHTML.replace(/<(?!.?marta_span)([^>]*)>/g,"&lt;$1&gt;").replace(/marta_span/g,"span");
};

document.pretouch = function(e) {
    if (e.target !== e.currentTarget) {
        var clickedItem = e.target;
        document.marta_touch(clickedItem);
    };
};

document.marta_click_work = function(target) {
    var marta_smthing = target.getAttribute("martaclass")=="marta_smthing";
    if(!marta_smthing){
        document.getElementById("attr_fields").innerHTML="";
        document.marta_room = 0;
        document.marta_result = {};
        document.marta_result["options"] = {};
        document.marta_after_click(target,"self");
        if (!!target.parentElement){
          document.marta_after_click(target.parentElement,"pappy");
        };
        if (!!target.parentElement.parentElement){
          document.marta_after_click(target.parentElement.parentElement,"granny");
        };
        document.marta_confirm();
    };
};

document.marta_after_click = function(el, what) {
    document.marta_result[what] = {};
    document.marta_result["options"][what] = el.tagName;
    document.marta_add_field("TAG", what, document.marta_result["options"][what], "taggy");
    for (var att, i = 0, atts = el.attributes, n = atts.length; i < n; i++){
      att = atts[i];
      if(/^[a-zA-Z0-9- _!@#$%^*();:,.?/]*$/.test(att.nodeValue) == true && att.nodeName != "martaclass"){
        if (/class/.test(att.nodeName) == true){
          var values=att.nodeValue.split(" ");
          document.marta_result[what][att.nodeName]=[];
          for (var val, j = 0, vals = values, l = vals.length; j < l; j++){
            val = vals[j];
            document.marta_result[what][att.nodeName][j]=val;
          };
        } else {
          document.marta_result[what][att.nodeName]=att.nodeValue;
        };
      };
    };
    if (what == "self"){
      try{
        document.marta_result[what]["retrieved_by_marta_text"]=el.firstChild.nodeValue;
      }catch(e){};
    };
    for (var key in document.marta_result[what]){
      if (/class/.test(key) == true){
        for (var k = 0, length = document.marta_result[what][key].length; k < length; k++){
          document.marta_add_field(what, key, document.marta_result[what][key][k], k);
        };
      }else
      {
        document.marta_add_field(what, key, document.marta_result[what][key], "-1");
      };
    };
};

document.marta_delete_line = function(theEvent) {
    var line = theEvent.target.getAttribute("martaroom");
    var title = document.getElementById("marta_title"+line);
    var staff = document.getElementById("marta_staff"+line);
    var field = document.getElementById("marta_default_value"+line);
    field.value = "";
    document.marta_change_field(field);
    staff.parentNode.removeChild(staff);
    title.parentNode.removeChild(title);
};

document.marta_set_by_hand = function(){
    var toClear = document.querySelector("[martaclass=marta_div]");
    toClear.parentNode.removeChild(toClear);
    document.marta_confirm_mark = true;
    document.marta_result = "3";
};

document.marta_end_loop = function(){
    if (document.marta_room != 0){
      document.marta_clean_up();
      document.marta_confirm_mark = true;
      document.marta_result = "1";
    }
};

document.marta_hide = function() {
  var toHide = document.querySelector("[martaclass=marta_div]");
  if (toHide.getAttribute("martastyle")=="hidden"){
    toHide.setAttribute("martastyle", "none");
  } else{
    toHide.setAttribute("martastyle", "hidden");
  };
}
