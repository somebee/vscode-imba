

function activate(ext){
	return console.log("activated!!!",ext);
}; exports.activate = activate;

function deactivate(){
	return console.log("deactivated");
}; exports.deactivate = deactivate;
