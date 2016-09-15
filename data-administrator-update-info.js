function getUserInformation() {
	// Get viewing user information
	ajaxGeneric("data-administrator-get-info.jsp", function () {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
			var response = trimResponse(xmlhttp.responseText);
			checkAjaxResponse(response);
			var arg = response.split("|");
			document.getElementById("userName").innerText = arg[0];
			document.getElementById("name").value = arg[1];
			document.getElementById("email").value = arg[2];
		}
	});
}
function save() {
	var messageElement = document.getElementById("message");
	messageElement.innerText = "";
	var arguments = "";
	var oldPassword = document.getElementById("oldPassword").value;
	var newPassword = document.getElementById("newPassword").value;
	var confirmPassword = document.getElementById("confirmPassword").value;
	var email = document.getElementById("email").value.trim();
	var name = document.getElementById("name").value.trim();
	if (!checkInput(oldPassword) || !checkInput(newPassword) || !checkInput(email)
			|| !checkInput(name)){
		messageElement.innerText = "One or more inputs contains illegal charactors.";
		return;
	}
	if (oldPassword != "") { // If there's something entered in the password field
		if (newPassword != "" || confirmPassword != "") {
			if (newPassword == confirmPassword) {
				arguments = "oldPassword=" + oldPassword + "&newPassword=" + newPassword + "&";
			} else {
				messageElement.innerText = "New password and confirmation don't match.";
				return;
			}
		} else {
			messageElement.innerText = "Please fill in both New Password and Confirm Password fields.";
			return;
		}
	} else {
		if (newPassword != "" || confirmPassword != "") {
			messageElement.innerText = "Please leave all the password fields empty.";
			return;
		}
	}
	
	// Check email
	if (!email.match(/^[a-zA-Z0-9]+@([a-zA-Z0-9]+\.)+[a-zA-Z0-9]+$/g)) {
		messageElement.innerText = "Email is invalid.";
		return;
	}
	if (email == "" || name == "") {
		messageElement.innerText = "Please fill in both Email and Full name.";
		return;
	}
	arguments += "email=" + email + "&name=" + name;
	
	var returnFunction = function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200){
			checkAjaxResponse(xmlhttp.responseText);
			var returnValue = trimResponse(xmlhttp.responseText);
			if (returnValue == "VALID") {
				window.location.href = "data-administrator-user.html";
			} else if (returnValue == "WRONG OLD PASSWORD") {
				messageElement.innerText = "Old password is wrong.";
			} else if (returnValue == "BAD EMAIL") {
				messageElement.innerText = "Email is invalid.";
			} else if (returnValue == "EMPTY FIELDS") {
				messageElement.innerText = "Please fill in all fields.";
			} else if (returnValue == "ILLEGAL CHARACTERS") {
				messageElement.innerText = "One or more inputs contains illegal charactors.";
			} else if (returnValue.startsWith("ERROR")) {
				messageElement.innerText = "Can't save new information. An error occurred.";
			}
		}
	};
	ajaxPost("data-administrator-update-info.jsp", returnFunction, arguments);
}
function checkInput(input) {
	if (input.length > 200) return false;
	if (input.match(/.*[\"'\\\,\n\r\0\?\[\]\{\}<>].*/g)) return false;
	return true;
}

