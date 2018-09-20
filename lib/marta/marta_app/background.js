win = null;

chrome.runtime.onMessage.addListener(
  function(request, sender, sendResponse) {
    if (win == null){
      chrome.windows.create({'url': 'dialog.html',
                             'type': 'popup',
                             'width': 800,
                             'height': 600}, function(window) { win = window});
    };
    if (request.greeting == "hello")
      sendResponse({farewell: win});
  });

  function init() {

    var options = {
      frame: 'chrome',
      minWidth: 400,
      minHeight: 400,
      width: 700,
      height: 700
    };

    chrome.app.window.create('dialog.html', options);
  }

  //chrome.app.runtime.onLaunched.addListener(init);

  //chrome.app.runtime.onLaunched.addListener(init);
