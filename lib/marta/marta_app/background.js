chrome.runtime.onMessage.addListener(
  function(request, sender, sendResponse) {
    chrome.windows.create( {'url': 'dialog.html?port='+request.port,
                            'type': 'popup',
                            'width': 800,
                            'height': 600}, function(window) {});
    sendResponse({farewell: "dialog requested"});

  });
