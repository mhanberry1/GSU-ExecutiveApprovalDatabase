<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>

<%
try {
	Statement statement = con.createStatement();
	String query = "DELETE FROM `referral` WHERE `timestamp` < (NOW() - INTERVAL 3 DAY);";
	statement.executeUpdate(query);
} catch (Exception e) {
}
%>