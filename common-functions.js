function ajaxPost(url, func, arguments) {
    if (window.XMLHttpRequest) {
        // code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp = new XMLHttpRequest();
    } else {
        // code for IE6, IE5
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }

    xmlhttp.onreadystatechange = func;
    xmlhttp.open("POST", url, true);
	xmlhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xmlhttp.send(arguments);
}

function ajaxGeneric(url, func) {
    if (window.XMLHttpRequest) {
        // code for IE7+, Firefox, Chrome, Opera, Safari
        xmlhttp = new XMLHttpRequest();

    } else {
        // code for IE6, IE5
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
	
    xmlhttp.onreadystatechange = func;
    xmlhttp.open("GET", url, false);
    xmlhttp.send();
}
function checkAjaxResponse(response) {
	if (response != null && trimResponse(response) == "NOT LOGGED IN") {
		window.location.href = "data-administrator-login.html";
	}
}
function trimResponse(response) {
	return response.replace(/\n|\r/g, "").trim();
}