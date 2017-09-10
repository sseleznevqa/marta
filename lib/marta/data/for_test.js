document.marta_add_data = function(){
  document.getElementById("title").innerHTML = document.marta_what;
  document.getElementById(document.old_marta_Data).innerHTML = document.old_marta_Data;
};
document.marta_result = "";
document.marta_confirm_mark = false;
setTimeout(function() { document.marta_result = "Done" }, 1000);
setTimeout(function() { document.marta_confirm_mark = true }, 2000);
