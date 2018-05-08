chrome.runtime.onMessage.addListener(function(message, sender, sendResponse) {
  document.xmlHttp = new XMLHttpRequest();
  if (message["confirm_mark"] == true) {
    var martaUrl = "http://localhost:" + message["port"] + "/dialog/got_answer";
  } else if (message["confirm_mark"] == false){
    var martaUrl = "http://localhost:" + message["port"] + "/dialog/not_answer";
  } else {
    var martaUrl = "http://localhost:" + message["port"] + "/dialog/lost";
  }
  document.xmlHttp.open( "GET", martaUrl, true );
  document.xmlHttp.send( null );
});
