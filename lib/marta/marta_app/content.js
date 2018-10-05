
async function set_value(name, value){
  let temp = {};
  temp[name] = value;
  await chrome.storage.sync.set(temp, function() {});
};

function getSelected(value){
  document.getElementById('marta_show_html').setAttribute('tag', value.tagName);
  const x = document.getElementsByTagName(value.tagName);
  const index = Array.prototype.indexOf.call(x, value);
  document.getElementById('marta_show_html').setAttribute('index', index);
};

async function get_value(name) {
  let x = await new Promise((resolve, reject) => chrome.storage.sync.get([name], resolve));
  return x[name];
};

document.addEventListener("marta_send", async function(e) {
  await set_value(e.detail.varname, e.detail.varvalue);
});

async function marta_real_send(answer, the_port) {
  if (answer == true) {
    document.xmlHttp = new XMLHttpRequest();
    const port = await get_value('port');
    const martaUrl = "http://localhost:" + port + "/dialog/got_answer";
    document.xmlHttp.open( "GET", martaUrl, false );
    document.xmlHttp.send( null );
  };
  return port;
};

async function refreshData()
{
  if (!document.getElementById("marta_magic_div")){
    marta_create_element(document.body, "div", {"martaclass": "marta_smthing","id":"marta_magic_div", "martastyle": get_value('magic_div')}, "");
  } else {
    document.getElementById("marta_magic_div").setAttribute("martastyle", get_value('magic_div'));
  };
  document.getElementById('marta_magic_div').onclick = function(e) {marta_magic_click(e)};
};

// BRAVE NEW WORLD STARTS HERE

// Notes
// We will send answer to server via marta_real_send
// format of the answer will include answer, tag and index of the element
// So server should eat parameters
// From dialog server will get request with answer only
// answer is a string saying what was clicked: (element, watch\nowatch, xpath, confirm, collection mark etc.)
// For page we should send variables of the fields
// Marta server will pass data by invoking custom event marta_send
// First of all Marta should set port that must be passed to dialog html somehow
// Marta magic div should not work at the server dialog page. Most probably we will ignore that div thru css
// We should add content css for all the pages but we will overwrite  it with !important on the marta dialog iframe

// So in ruby we should overwrite dialog (a little to use new answers)
// Injector. Now it will only invoke marta_send
// Server it should now take data and include it to servlet. Also server should return answer from content js or\and form
// The most strange story with collection mark and exclude option. I need to think about it again.
function marta_magic_click(e) {
  if (document.marta_test_xx == 0) {var xx = e.clientX} else {var xx = document.marta_test_xx};
  if (document.marta_test_yy == 0) {var yy = e.clientY} else {var yy = document.marta_test_yy};
  document.getElementById("marta_magic_div").setAttribute("martastyle", "off");
  let is_shift = e.shiftKey||document.marta_shift;
  document.marta_result = {"element": document.elementFromPoint(xx, yy), "collection": document.getElementById("marta_array").checked, "exclude": is_shift};
  document.marta_confirm();//100% fail here
  document.getElementById("marta_magic_div").setAttribute("martastyle", "at_large");
};

function marta_create_element(dom, tag, attrs, inner) {
  const element = document.createElement(tag);
  dom.appendChild(element);
  for (var key in attrs) {
    element.setAttribute(key, attrs[key])
  };
  element.innerHTML = inner;
  return element;
};

function marta_stop() {
  if (document.getElementById("marta_magic_div").getAttribute("martastyle") == "off"){
    document.getElementById("marta_magic_div").setAttribute("martastyle", "at_large");
  } else {
    document.getElementById("marta_magic_div").setAttribute("martastyle", "off");
  }
};

set_value('port','6260'); // Default port
// Waiting for a 0.5 second Marta ruby request to set the correct port

let port = '6260';
setTimeout(async function(){port = await get_value('port')},500);
setTimeout(function() {
  if (!document.getElementById("marta_main_dialog_form")) {
    chrome.runtime.sendMessage({port: port}, function(response) {console.log(response.farewell)})
  }
}, 600);
setInterval(async function(){ await refreshData()},1000);
