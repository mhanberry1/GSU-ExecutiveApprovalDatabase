function register() {
	var messageElement = document.getElementById("message");
	messageElement.innerText = "";
	var arguments = "";
	var userName = document.getElementById("userName").value.trim();
	var password = document.getElementById("password").value;
	var confirmPassword = document.getElementById("confirm").value;
	var email = document.getElementById("email").value.trim();
	var name = document.getElementById("name").value.trim();
	var referral = document.getElementById("referral").value.trim();
	
	if (!checkInput(password) || !checkInput(confirmPassword) || !checkInput(email)
			|| !checkInput(name) || !checkInput(userName) || !checkInput(referral)
			|| userName.indexOf(" ") >= 0 || email.indexOf(" ") >= 0){
		messageElement.innerText = "One or more inputs contains illegal charactors.";
		return;
	}
	
	if (userName == "" || password == "" || confirmPassword == "" || email == "" || name == "" || referral == "") {
		messageElement.innerText = "Please fill in all fields.";
		return;
	}
	
	if (password != confirmPassword) {
		messageElement.innerText = "Password and confirmation don't match.";
		return;
	}
	
	// Check email
	if (!email.match(/^[a-zA-Z0-9]+@([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+$/g)) {
		messageElement.innerText = "Email is invalid.";
		return;
	}
	
	arguments = "userName=" + userName + "&password=" + password + "&email=" + email
			+ "&name=" + name + "&referral=" + referral;
	
	var returnFunction = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200){
			checkAjaxResponse(xmlhttp.responseText);
			var returnValue = trimResponse(xmlhttp.responseText);
			if (returnValue == "VALID") {
				window.location.href = "data-administrator-login.html";
			} else if (returnValue == "DUPLICATE") {
				messageElement.innerText = "This user name is already taken.";
			} else if (returnValue == "BAD EMAIL") {
				messageElement.innerText = "Email is invalid.";
			} else if (returnValue == "EMPTY FIELDS") {
				messageElement.innerText = "Please fill in all fields.";
			} else if (returnValue == "ILLEGAL CHARACTERS") {
				messageElement.innerText = "One or more inputs contains illegal charactors.";
			} else if (returnValue == "BAD CODE") {
				messageElement.innerText = "Bad referral code.";
			} else if (returnValue.startsWith("ERROR")) {
				messageElement.innerText = "Cannot register. An error occurred.";
			}
		}
	};
	ajaxPost("data-administrator-register.jsp", returnFunction, arguments);
}
function checkInput(input) {
	if (input.length > 200) return false;
	if (input.match(/.*[\"'\\\,\n\r\0\?\[\]\{\}<>].*/g)) return false;
	return true;
}

