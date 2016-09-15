<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*, java.util.regex.Pattern, java.security.MessageDigest"%>
<%@ include file="data-administrator-secure.jsp" %><%// This has the config file included%>
<%
request.setCharacterEncoding("UTF-8");

try {
	Statement st = con.createStatement();
	String oldPassword = request.getParameter("oldPassword");
	String newPassword = request.getParameter("newPassword");
	String email = request.getParameter("email").trim();
	String name = request.getParameter("name").trim();
	String query = "UPDATE `users` SET ";
	Pattern pattern = Pattern.compile("[\\\"'\\\\\\,\\n\\r\\x00\\?\\[\\]\\{\\}<>]");
	if (pattern.matcher(name).find() || pattern.matcher(name).find()) {
		%>ILLEGAL CHARACTERS<%
		return;
	}
	pattern = Pattern.compile("^[a-zA-Z0-9]+@([a-zA-Z0-9]+\\.)+[a-zA-Z0-9]+$");
	if (!pattern.matcher(email).matches()) {
		%>BAD EMAIL<%
		return;
	}
	MessageDigest md5 = MessageDigest.getInstance("MD5");
	byte[] digested;
	String hashedString;
	if (oldPassword != null) {
		if (newPassword.equals("")) {
			%>EMPTY FIELDS<%
			return;
		}
		md5.update(oldPassword.getBytes("UTF-8"));
		digested = md5.digest();
		hashedString = "";
		for (int i = 0; i < digested.length; i++) {
			String hex = Integer.toHexString(digested[i] & 0xFF);
			hashedString += "00".substring(hex.length()) + hex;
		}
		if (!hashedString.equals(passwordHash)) {
			%>WRONG OLD PASSWORD<%
			return;
		}
		
		md5.update(newPassword.getBytes("UTF-8"));
		digested = md5.digest();
		hashedString = "";
		for (int i = 0; i < digested.length; i++) {
			String hex = Integer.toHexString(digested[i] & 0xFF);
			hashedString += "00".substring(hex.length()) + hex;
		}
		query += "`password_hash` = \"" + hashedString + "\", ";
		session.setAttribute("passwordHash", hashedString);
	}
	if (email.length() == 0 || name.length() == 0) {
		%>EMPTY FIELDS<%
		return;
	}
	query += "`email` = \"" + email + "\", `name` = \"" + name + "\" WHERE `username`=\"" + userName + "\";";
	st.executeUpdate(query);
	%>VALID<%
} catch (Exception e) {
	%>ERROR <%=e.getMessage()%><%
}
con.close();
%>