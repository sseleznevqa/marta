var marta_room = 0;
var marta_result = {};
var marta_confirm_mark = false;

function marta_add_field() {
    marta_room++;
    var objTo = document.getElementById("vars_fileds");
    var divtest = document.createElement("div");
    divtest.innerHTML = "<div class=label id=marta_title"+marta_room+">Var " + marta_room +":</div><div class=content id=marta_staff"+marta_room+"><span>Name: <input type=text martaclass=marta_smthing class=marta_s_name_field id=marta_name"+marta_room+" value=></span><span>Default value: <input martaclass=marta_smthing type=text id=marta_default_value"+marta_room+" value=></span><input martaclass=marta_smthing type=button onclick=marta_delete_line("+marta_room+") value=Delete id=delete_marta_value"+marta_room+"</div>";

    objTo.appendChild(divtest);
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

function marta_delete_line(line) {
    var title = document.getElementById("marta_title"+line);
    var staff = document.getElementById("marta_staff"+line);
    title.parentNode.removeChild(title);
    staff.parentNode.removeChild(staff);
    };

function marta_down() {
  var toDown = document.querySelector("[martaclass=marta_div]");
  toDown.setAttribute("martastyle", "down");
}
