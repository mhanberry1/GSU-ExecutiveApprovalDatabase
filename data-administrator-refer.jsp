<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%@ include file="data-administrator-secure.jsp" %><%// This has the config file included%>
<%@ include file="data-administrator-expire-code.jsp" %>
<%
String referralCode = "";
try {
	Statement statement = con.createStatement();
	String sql = "";
	while (true) {
		for (int i = 1; i <= 16; i++) {
			// Generates random text with random uppercase and lowercase
			if (Math.random() > .5) {
				referralCode += (char) (('z' - 'a') * Math.random() + 'a' - (int) (Math.random() * 2 - 0.001) * ('a' - 'A'));
			} else {
				referralCode += (int) (Math.random() * 10 - .001);
			}
		}
		sql = "SELECT COUNT(*) FROM `referral` WHERE `code`=\"" + referralCode + "\";";
		ResultSet result = statement.executeQuery(sql);
		result.next();
		if (result.getString(1).equals("0")) {
			break;
		}
	}
	sql = "INSERT INTO `referral` (`user`, `code`) VALUES ((SELECT `id` FROM `users` WHERE `username`=\"" + userName + "\"), \"" + referralCode + "\");";
	statement.executeUpdate(sql);
} catch(Exception e) {
	%>ERROR <%=e.getMessage()%><%
	return;
}
%>
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <title>Exective Approval</title>
	<link href='https://fonts.googleapis.com/css?family=Montserrat' rel='stylesheet' type='text/css'>
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.2/jquery.min.js"></script>
	<link href='login-register.css' rel='stylesheet' type='text/css'>
    <style>
    </style>
</head>
<body>
	<h2 id="banner">Executive Approval Database Administrator - Referral</h2>
	<div id="smallContainer">
		<p>Give this code to the person you wish to be a part of the project.</p>
		<span class="bigText"><%=referralCode%></span>
		<br/>
		<span class="message">(This code will expire in 3 days)</span>
		<br/>
		<br/>
		<a href="data-administrator-user.html">Back</a>
	</div>
</body>
</html>