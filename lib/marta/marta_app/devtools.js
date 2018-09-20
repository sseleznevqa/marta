
setInterval(function(){
    chrome.devtools.inspectedWindow.eval("getSelected($0)", { useContentScriptContext: true });
}, 100);
