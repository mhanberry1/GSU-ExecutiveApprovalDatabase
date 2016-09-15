var SAVE_MESSAGE_COLOR = "#00FF2E", ERROR_MESSAGE_COLOR = "#FF002D";
var columns, rows, sortColumn = 1, sortType = 1, currentCountry, rowChecked, messageAlpha = 0;
var currentUser;

setInterval(function() {
	if (messageAlpha > 0) {
		messageAlpha -= .02;
	}
	if (messageAlpha < 0) messageAlpha = 0;
	document.getElementById("messageText").style.opacity = messageAlpha;
}, 50);


function autoload() {
	getUserInformation();
    var url_temp1 = "autoload-google-charts.jsp?time=" + new Date().getTime() + "&table=ead";
    ajaxGeneric(url_temp1, function() {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            document.getElementById("country").innerHTML = xmlhttp.responseText;
        }
    });
	tableResize();
	document.getElementById("rowInsert").onkeydown = function(e) {
		if (e.keycode == 9 || e.which == 9) {
			e.preventDefault();
			this.value = this.value.substring(0, this.selectionStart) + "\t" + this.value.substring(this.selectionStart);
		}
	};
}

function countryChanged() {
	var countryElement = document.getElementById("countries");
	if (countryElement.selectedIndex > 0) {
		currentCountry = countryElement.options[countryElement.selectedIndex].value;
		ajaxGeneric("data-administrator-load.jsp?table=ead&country=" + currentCountry, function() {
			if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
				checkAjaxResponse(xmlhttp.responseText);
				var json = JSON.parse(xmlhttp.responseText);
				columns = json["cols"];
				rows = json["rows"];
				sortData();
				rowChecked = new Array(rows.length);
				for (var i = 0; i < rowChecked.length; i++) {
					rowChecked[i] = false;
				}
				refreshTable();
			}
		});
	}
}

function refreshTable() {
	var table = document.getElementById("dataTable");
	var tableHeader = document.getElementById("dataTableHeader");
	var tableHtml = "<thead><t><td><input type='checkbox' id='checkBoxRowAll' onclick='selectAll()'></td>";
	for (var i = 0; i < columns.length; i++) { // Populate columns
		var sortingArrow = "";
		if (i == sortColumn) {
			if (sortType == 1) {
				sortingArrow = " ▲";
			} else {
				sortingArrow = " ▼";
			}
		}
		tableHtml += "<th><input readonly='readonly' class='tableLabel' onclick='sortRows(" + i + ")' value='"
				+ columns[i] + sortingArrow + "' tabIndex='-1'/></th>";
	}
	tableHtml += "</tr></thead>";
	tableHeader.innerHTML = tableHtml;
	tableHtml = "";
	for (var i = 0; i < rows.length; i++) { // Populate rows
		tableHtml += "<tr><td><input type='checkbox' id='checkBoxRow" + i + "' onclick='selectRow(this)'></td>";
		for (var j = 0; j < columns.length; j++) {
			var valueToInput = rows[i][j] == "null" ? "" : rows[i][j];
			if (j < 7) {
				tableHtml += "<td><input class='input' value='" + valueToInput
						+ "' onchange='inputChange(this, " + i + ", " + j + ")'></input></td>";
			} else {
				if (j == 7) {
					tableHtml += "<td><input readonly='readonly' class='input clickable' onclick='redirect(this)' value='" + valueToInput
							+ "' /></td>";
				} else {
					tableHtml += "<td><input readonly='readonly' class='input' value='" + valueToInput
							+ "' /></td>";
				}
			}
		}
		tableHtml += "</tr>";
	}
	table.innerHTML = tableHtml;
	tableResize();
}

function redirect(inputElement) {
	window.open("data-administrator-user.html?" + inputElement.value, "_blank");
}

function selectAll() {
	var selectAllCheckBox = document.getElementById("checkBoxRowAll");
	for (var i = 0; i < rowChecked.length; i++) {
		rowChecked[i] = selectAllCheckBox.checked;
	}
	refreshCheckBoxes();
}

function selectRow(e) {
	var rowNumber = e.id.substring("checkBoxRow".length);
	rowChecked[rowNumber] = e.checked;
	refreshCheckBoxes();
}

function refreshCheckBoxes() {
	var selectAllCheckBox = document.getElementById("checkBoxRowAll");
	selectAllCheckBox.checked = true;
	for (var i = 0; i < rowChecked.length; i++) {
		document.getElementById("checkBoxRow" + i).checked = rowChecked[i];
		if (!rowChecked[i]) {
			selectAllCheckBox.checked = false;
		}
	}
}

function sortRows(columnIndex) {
	if (sortColumn == columnIndex) {
		sortType = -sortType;
	} else {
		sortType = 1;
	}
	sortColumn = columnIndex;
	sortData();
	refreshTable();
}

function sortData() {
	rows.sort(function(a, b) {
		if (isNaN(a[sortColumn]) && a[sortColumn] != "null") {
			return a[sortColumn].localeCompare(b[sortColumn]) * sortType;	
		}
		var tempA = a[sortColumn] == "null" ? -10000000000 : a[sortColumn];
		var tempB = b[sortColumn] == "null" ? -10000000000 : b[sortColumn];
		return (tempA - tempB) * sortType;
	});
}

function inputChange(input, row, column) {
	var inputValue = input.value == "" ? "null" : input.value;
	var returnFunction = function() {
		if (xmlhttp.readyState == 0) {
			showCornerMessage("Error! Change was not saved.", ERROR_MESSAGE_COLOR);
		}
		if (xmlhttp.readyState == 4){
			if (xmlhttp.status == 200) {
				checkAjaxResponse(xmlhttp.responseText);
				var newValue = xmlhttp.responseText.replace(/\r|\n/g, "");
				if (newValue != "ERROR") {
					input.value = newValue == "null" ? "" : newValue;
					rows[row][column] = newValue;
					showCornerMessage("Saved", SAVE_MESSAGE_COLOR);
				} else {
					showCornerMessage("Error! Change was not saved.", ERROR_MESSAGE_COLOR);
				}
			} else {
				showCornerMessage("Error! Change was not saved.", ERROR_MESSAGE_COLOR);
			}
		}
	};
	var arguments = "table=ead&country=" + currentCountry + "&datasource=" + rows[row][0] + "&recdate=" + rows[row][1]
			+ "&column=" + column + "&value=" + inputValue;
	ajaxPost("data-administrator-save.jsp", returnFunction, arguments);
}

function deleteSelected() {
	var numOfSelections = 0;
	var toDelete = [];
	for (var i = 0; i < rowChecked.length; i++) {
		if (rowChecked[i]) {
			numOfSelections++;
			toDelete.push(i);
		}
		
	}
	if (numOfSelections > 0) {
		if (confirm("Are you sure you want to delete these " + numOfSelections + " rows?")) {
			var deleteMessage = function() {
				if (xmlhttp.readyState == 4){
					if (xmlhttp.status == 200) {
						checkAjaxResponse(xmlhttp.responseText);
						var returnValue = xmlhttp.responseText.replace(/\r|\n/g, "");
						if (returnValue == "SUCCESS") {
							showCornerMessage("Successfully deleted rows.", SAVE_MESSAGE_COLOR);
						} else {
							showCornerMessage("Error! Could not delete rows.", ERROR_MESSAGE_COLOR);
						}
					} else {
						showCornerMessage("Error! Could not delete rows.", ERROR_MESSAGE_COLOR);
					}
				}
			};
			for (var i = toDelete.length - 1; i >= 0; i--) {
				var index = toDelete[i];
				var arguments = "table=ead&country=" + currentCountry + "&datasource=" + rows[index][0] + "&recdate=" + rows[index][1];
				ajaxPost("data-administrator-delete.jsp", deleteMessage, arguments);
				rows.splice(index, 1);
			}
			refreshTable();
		}
	}
}

function insertData() {
	var arguments = "table=ead&defaultCountry=" + currentCountry + "&data=" + document.getElementById("rowInsert").value;
	var returnFunction = function() {
		if (xmlhttp.readyState == 4){
			if (xmlhttp.status == 200) {
				checkAjaxResponse(xmlhttp.responseText);
				var returnValue = xmlhttp.responseText.replace(/\r|\n/g, "");
				if (!returnValue.startsWith("ERROR")) {
					showCornerMessage(returnValue + " inserted", SAVE_MESSAGE_COLOR);
					countryChanged();
					document.getElementById("rowInsert").value = "";
				} else {
					showCornerMessage("Error! Could not insert data.", ERROR_MESSAGE_COLOR);
				}
			} else {
				showCornerMessage("Error! Could not insert data.", ERROR_MESSAGE_COLOR);
			}
		}
	};
	ajaxPost("data-administrator-insert.jsp", returnFunction, arguments);
	window.scrollTo(0, 0);
}

function getUserInformation() {
	ajaxGeneric("data-administrator-get-info.jsp", function() {
		if (xmlhttp.readyState == 4 && xmlhttp.status == 200){
			var response = trimResponse(xmlhttp.responseText);
			checkAjaxResponse(response);
			var args = response.split("|");
			currentUser = args[0];
			document.getElementById("userName").innerText = args[0];
		}
	});
}

function tableResize() {
	var tableContainer = document.getElementById("divTableContainer");
	var bodyTop = document.body.getBoundingClientRect().top;
	var containerTop = tableContainer.getBoundingClientRect().top - bodyTop;
	tableContainer.style.height = window.innerHeight - containerTop + "px";
	document.getElementById("divTableContainerInner").style.height = (tableContainer.offsetHeight - 110) + "px";
	document.getElementById("dataTableHeader").style.width = document.getElementById("dataTable").offsetWidth + "px";
}

function showCornerMessage(text, color) {
	var messageText = document.getElementById("messageText");
	messageText.innerText = text;
	messageText.style.color = color;
	messageAlpha = 1;
}