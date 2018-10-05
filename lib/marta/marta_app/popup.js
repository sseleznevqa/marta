let port = '6269';
async function get_value(name) {
  let x = await new Promise((resolve, reject) => chrome.storage.sync.get([name], resolve));
  return x[name];
};
async function get_port() {
  port = await get_value('port');
};

get_port().then(function(){
  chrome.runtime.sendMessage({port: port}, function(response) {console.log(response.farewell)});
  //window.close();
});
