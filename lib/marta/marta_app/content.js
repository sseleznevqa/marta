var port = 6260;

async function port_set(value){
  await chrome.storage.sync.set({port: value}, function() {
          console.log('Value is set to ' + value);
        });
};

async function port_get(){
  await chrome.storage.sync.get(['port'], function(result) {
          port = result.port;
          console.log('The port currently is ' + port);
        });
};

document.addEventListener("marta_send", async function(e) {
  console.log("User is saying smthing to Marta");
  if (typeof e.detail.port !== "undefined"){
    await port_set(e.detail.port)
    await port_get();
  };
  //console.log(port);
  //console.log(e.detail.port);
  console.log("Marta is acting back. With port = " + port);
  marta_real_send(e.detail.mark, port);
});

function marta_real_send(answer, the_port) {
  if (answer == true) {
    console.log("Marta js is calling Marta ruby");
    document.xmlHttp = new XMLHttpRequest();
    var martaUrl = "http://localhost:" + the_port + "/dialog/got_answer";
    document.xmlHttp.open( "GET", martaUrl, false );
    document.xmlHttp.send( null );
  };
  return port;
};

async function refreshData()
{ console.log("Marta is checking is she on the page");

    if (((typeof document.getElementById("marta_s_everything") == undefined) || (document.getElementById("marta_s_everything") == null)) && (window == top)){
      console.log("Marta is lost. Asking ruby Marta to do something with the port = " + port);
      document.xmlHttp = new XMLHttpRequest();
      var martaUrl = "http://localhost:" + port + "/dialog/not_answer";
      try {document.xmlHttp.open( "GET", martaUrl, false );
      document.xmlHttp.send( null );
        } catch {
      console.log("Cannot connect with port = " + port);
      }
    } else {
    };
}

setInterval(async function(){await port_get(); await refreshData()},1000);
