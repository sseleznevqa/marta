var marta_room = 0;
var marta_result = {};
var marta_confirm_mark = false;
var marta_waits_iframe = "IFRAME";

function sleep(ms) {
  ms += new Date().getTime();
  while (new Date() < ms){};
};

var marta_monitor = setInterval(function(){
    var elem = document.activeElement;
    if(elem && elem.tagName == marta_waits_iframe){
        marta_waits_iframe = "Nope, she is not";
        marta_click_work(elem, true);
    } else {
        marta_waits_iframe = "IFRAME";
    };
}, 100);

function marta_add_field(title, what, key, marker) {
    marta_room++;
    var objTo = document.getElementById("attr_fields");
    var divtest = document.createElement("div");
    var att = document.createAttribute("martaclass");
    att.value = "marta_smthing";
    divtest.setAttributeNode(att);
    divtest.innerHTML = "<div martaclass=marta_smthing class=label id=marta_title"+marta_room+">ATTR</div><div martaclass=marta_smthing class=content id=marta_staff"+marta_room+"><span martaclass=marta_smthing>ATTR: <input martaclass=marta_smthing class=marta_s_name_field type=text disabled=disabled; id=marta_name"+marta_room+" value=></span><span martaclass=marta_smthing> = <input onchange=marta_change_field(this); martaclass=marta_smthing type=text id=marta_default_value"+marta_room+" value=></span><input martaclass=marta_smthing type=button onclick=marta_delete_line("+marta_room+") value=Delete id=delete_marta_value"+marta_room+"</div>";
    objTo.appendChild(divtest);
    document.getElementById("marta_title"+marta_room ).innerHTML = title;
    document.getElementById("marta_name"+marta_room ).value = what;
    var field = document.getElementById("marta_default_value"+marta_room);
    field.value = key;
    var att = document.createAttribute("marta_object_map");
    att.value = title+";;"+what+";;"+marker;
    field.setAttributeNode(att);
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
};

function marta_confirm(){
  if (marta_room != 0){
    marta_result["options"]["collection"] = document.getElementById("marta_array").checked;
    var toClear = document.querySelector("[martaclass=marta_div]");
    toClear.parentNode.removeChild(toClear);
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
    document.getElementById("marta_main_title").innerHTML = "You are defining " + marta_what;
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

function marta_click_work(e, iframe=false) {
  if (iframe == false){
    e = e || window.event;
    var target = e.target || e.srcElement;
  } else {
    target = e;
  };
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
        if (!!target.parentElement){
          marta_after_click(target.parentElement.parentElement,"granny");
        };
        if(!marta_confirm_mark){
          e.stopPropagation();
          e.preventDefault();
        };
    };
};

document.addEventListener("click", function(e) {marta_click_work(e)} , true);

function marta_after_click(el, what) {
    marta_result[what] = {};
    marta_result["options"][what] = el.tagName;
    marta_add_field("TAG", what, marta_result["options"][what], "taggy");
    for (var att, i = 0, atts = el.attributes, n = atts.length; i < n; i++){
      att = atts[i];
      if(/^[a-zA-Z0-9- _!@#$%^*();:,.?/]*$/.test(att.nodeValue) == true){
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

function marta_delete_line(line) {
    var title = document.getElementById("marta_title"+line);
    var staff = document.getElementById("marta_staff"+line);
    var field = document.getElementById("marta_default_value"+line);
    field.value = "";
    marta_change_field(field);
    title.parentNode.removeChild(title);
    staff.parentNode.removeChild(staff);
  };
