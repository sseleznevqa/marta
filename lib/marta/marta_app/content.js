document.addEventListener("marta_send", function(data) {
    chrome.runtime.sendMessage({"confirm_mark" : document.marta_confirm_mark, "port" :  document.martaPort});
});
setTimeout(function() {
  if (typeof document.marta_confirm_mark == "undefined") {
    document.marta_confirm_mark = null;
    event.initEvent("marta_send");
  }
}, 1000);
