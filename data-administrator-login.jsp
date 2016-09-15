<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*, java.util.*,java.security.MessageDigest"%>
<%
request.setCharacterEncoding("UTF-8");
session.setAttribute("userName", request.getParameter("userName"));
String password = request.getParameter("passwordHash");
String hashedString = "";
try {
	MessageDigest md5 = MessageDigest.getInstance("MD5");
	md5.update(password.getBytes("UTF-8"));
	byte[] digested = md5.digest();
	
	for (int i = 0; i < digested.length; i++) {
		String hex = Integer.toHexString(digested[i] & 0xFF);
		hashedString += "00".substring(hex.length()) + hex;
	}
} catch (Exception e) {
	%><%=e.getMessage()%><%
} finally {
	
}
password = hashedString;
session.setAttribute("passwordHash", password);
%>
<%@ include file="data-administrator-secure.jsp" %><%// This has the config file included%>