<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*, java.util.regex.Pattern, java.security.MessageDigest"%>
<%@ include file="config.jsp" %>
<%@ include file="data-administrator-expire-code.jsp" %>

<%
request.setCharacterEncoding("UTF-8");

try {
	String userName = request.getParameter("userName").trim().toLowerCase();
	String password = request.getParameter("password");
	String email = request.getParameter("email").trim().toLowerCase();
	String name = request.getParameter("name").trim();
	String referral = request.getParameter("referral").trim();
	String query = "";
	Statement statement = con.createStatement();
	
	if (userName.length() == 0 || password.length() == 0 || email.length() == 0
			|| name.length() == 0 || referral.length() == 0) {
		%>EMPTY FIELDS<%
		return;
	}
	Pattern pattern = Pattern.compile("[\\\"'\\\\\\,\\n\\r\\x00\\?\\[\\]\\{\\}<>]");
	if (pattern.matcher(name).find() || pattern.matcher(name).find() || pattern.matcher(userName).find()
			|| pattern.matcher(password).find() || pattern.matcher(referral).find()) {
		%>ILLEGAL CHARACTERS<%
		return;
	}
	pattern = Pattern.compile("^[a-zA-Z0-9]+@([a-zA-Z0-9]+\\.)+[a-zA-Z0-9]+$");
	if (!pattern.matcher(email).matches()) {
		%>BAD EMAIL<%
		return;
	}
	query = "SELECT COUNT(*) FROM `users` WHERE `username` = \"" + userName + "\";";
	ResultSet result = statement.executeQuery(query);
	result.next();
	if (!result.getString(1).equals("0")) {
		%>DUPLICATE<%
		return;
	}
	query = "SELECT `user` FROM `referral` WHERE `code` = \"" + referral + "\";";
	result = statement.executeQuery(query);
	if (!result.next()) {
		%>BAD CODE<%
		return;
	}
	String hashedString = "";
	MessageDigest md5 = MessageDigest.getInstance("MD5");
	md5.update(password.getBytes("UTF-8"));
	byte[] digested = md5.digest();
	for (int i = 0; i < digested.length; i++) {
		String hex = Integer.toHexString(digested[i] & 0xFF);
		hashedString += "00".substring(hex.length()) + hex;
	}
	query = "INSERT INTO `users` (`username`, `password_hash`, `name`, `email`, `referral`) VALUES (\""
			+ userName + "\", \"" + hashedString + "\", \"" + name + "\", \"" + email
			+ "\", (SELECT `user` FROM `referral` WHERE `code` = \"" + referral + "\"))";
	statement.executeUpdate(query);
	query = "DELETE FROM `referral` WHERE `code` = \"" + referral + "\";";
	statement.executeUpdate(query);
	%>VALID<%
} catch (Exception e) {
	%>ERROR <%=e.getMessage()%><%
}
con.close();
%>