<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%@ include file="data-administrator-secure.jsp" %><%// This has the config file included%>

<%
request.setCharacterEncoding("UTF-8");

try {
	String table = request.getParameter("table");
	Statement st = con.createStatement();
	String query = "";
	if (table.equals("ead")) {
		String country = request.getParameter("country");
		String source = request.getParameter("datasource");
		String recdate = request.getParameter("recdate");
		query = "DELETE FROM `ead` "
				+ " WHERE `datasource`='" + source + "' and`recdate`='"
				+ recdate + "' and`country`='" + country + "';";
	} else if (table.equals("series_information")) {
		String country = request.getParameter("country");
		String series = request.getParameter("series");
		query = "DELETE FROM `series_information` "
				+ " WHERE `country`=\"" + country + "\" and `series`=\""
				+ series + "\";";
	}
	st.executeUpdate(query);
	%>SUCCESS<%
} catch (Exception e) {
	%>ERROR<%
}
con.close();
%>