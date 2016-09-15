<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%@ include file="config.jsp" %>

<%
String userName = (String) session.getAttribute("userName");
String passwordHash = (String) session.getAttribute("passwordHash");
boolean valid = true;
if (userName != null && passwordHash != null) {
	try {
		Statement statement = con.createStatement();
		String sql = "SELECT COUNT(*) FROM users WHERE `username` = \"" + userName + "\" AND `password_hash` = \"" + passwordHash + "\";";
		ResultSet result = statement.executeQuery(sql);
		result.next();
		if (result.getString(1).equals("0")) {
			valid = false;
		} else {
			valid = true;
		}
	} catch (Exception e) {
		valid = false;
	}
} else {
	valid = false;
}
if (!valid) {
	session.setAttribute("userName", null);
	session.setAttribute("passwordHash", null);
	%>NOT LOGGED IN<%
	return;
}
%>