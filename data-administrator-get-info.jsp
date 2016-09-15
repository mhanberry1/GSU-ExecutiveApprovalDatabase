<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%@ include file="data-administrator-secure.jsp" %><%// This has the config file included%>

<%
request.setCharacterEncoding("UTF-8");

if (request.getParameter("userName") != null) {
	userName = request.getParameter("userName");
}
try {
	Statement statement = con.createStatement();
	String sql = "SELECT username, name, email, (SELECT userName FROM `users` AS `otherUsers` WHERE `otherUsers`.`id` = `users`.`referral`) FROM `users` WHERE `username` = \"" + userName + "\";";
	ResultSet result = statement.executeQuery(sql);
	result.next();
	%><%=result.getString(1)%>|<%=result.getString(2)%>|<%=result.getString(3)%>|<%=result.getString(4)%><%
} catch (Exception e) {
	valid = false;
}
%>