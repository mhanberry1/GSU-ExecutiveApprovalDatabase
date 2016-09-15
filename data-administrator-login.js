function login() {
	var userName = document.getElementById("userName").value.toLowerCase().trim();
	var password = document.getElementById("password").value;
	if (userName != "" && password != "") {
		function validate() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				var response = trimResponse(xmlhttp.responseText);
				if (response == "") {
					window.location.href = "data-administrator.html";
				} else {
					document.getElementById("message").innerText = "User name or password is incorrect.";
				}
			}
		}
		ajaxPost("data-administrator-login.jsp", validate, "userName=" + userName + "&passwordHash=" + password);
	} else {
		document.getElementById("message").innerText = "Please enter both user name and password.";
	}
}