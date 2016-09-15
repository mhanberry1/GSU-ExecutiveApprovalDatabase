var viewOnlyMode = false;
function getUserInformation() {
	// Get current user information
	ajaxGeneric("data-administrator-get-info.jsp", function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200){
			var response = xmlhttp.responseText.replace(/\n|\r/g, "");
			checkAjaxResponse(response);
			var args = response.split("|");
			currentUser = args[0];
			document.getElementById("myUserName").innerText = args[0];
		}
	});
	
	// Get viewing user information
	var userNameArgument = window.location.search;
	if (userNameArgument != "") {
		userNameArgument = "userName=" + userNameArgument.substring(1);
		viewOnlyMode = true;
	}
	ajaxPost("data-administrator-get-info.jsp", function () {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			var response = trimResponse(xmlhttp.responseText);
			checkAjaxResponse(response);
			var arg = response.split("|");
			document.getElementById("userName").innerText = arg[0];
			document.getElementById("name").innerText = arg[1];
			document.getElementById("email").innerText = arg[2];
			document.getElementById("referral").innerText = arg[3];
			document.getElementById("referral").href = "data-administrator-user.html?" + arg[3];
			if (viewOnlyMode) {
				document.getElementById("nonInfoRow").style.display = "none";
			}
		}
	}, userNameArgument);
}
