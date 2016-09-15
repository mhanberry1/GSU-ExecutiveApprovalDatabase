<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%@ include file="data-administrator-secure.jsp" %><%// This has the config file included%>
<%
request.setCharacterEncoding("UTF-8");
ResultSet rs = null;
String[] columnsMain = {"datasource", "recdate", "totalcount", "positive", "net", "appappdis", "source"};
String[] columnsSeriesInfo = {"series", "description", "question_type", "question_wording"};
try {
	if (request.getParameter("value").contains("\"")) {
		response.sendError(500);
		return;
	}
	Statement st = con.createStatement();
	String table = request.getParameter("table");
	String country = request.getParameter("country");
	if (table.equals("ead")) {
		String columnName = columnsMain[Integer.parseInt(request.getParameter("column"))];
		String value = request.getParameter("value").equals("null") ? "NULL" : "\"" + request.getParameter("value") + "\"";
		String source = request.getParameter("datasource");
		String recdate = request.getParameter("recdate");
		String query = "UPDATE `ead` SET `" + columnName + "`=" + value + ", user=(SELECT `id` FROM `users` WHERE `username`=\"" + userName
			+ "\") WHERE `datasource`=\"" + source + "\" and`recdate`=\""
			+ recdate + "\" and`country`=\"" + country + "\";";
			st.executeUpdate(query);
		if (columnName.equals("datasource")) {
			source = value.substring(1, value.length() - 1);;
		}
		if (columnName.equals("recdate")) {
			recdate = value.substring(1, value.length() - 1);
		}
		query = "SELECT `" + columnName + "` FROM `ead` WHERE `datasource`=\"" + source + "\" and`recdate`=\""
				+ recdate + "\" and`country`=\"" + country + "\";";
		rs = st.executeQuery(query);
		rs.next();
		%><%=rs.getString(1)%><%// Bounce what is inserted into the database back to synchronize front end.
	} else if (table.equals("series_information")) {
		String columnName = columnsSeriesInfo[Integer.parseInt(request.getParameter("column"))];
		String value = request.getParameter("value").equals("null") ? "NULL" : "\"" + request.getParameter("value") + "\"";
		String series = request.getParameter("series");
		String query = "UPDATE `series_information` SET `" + columnName + "`=" + value + ", user=(SELECT `id` FROM `users` WHERE `username`=\"" + userName
			+ "\") WHERE `series`=\"" + series + "\" and`country`=\"" + country + "\";";
			st.executeUpdate(query);
		if (columnName.equals("series")) {
			series = value.substring(1, value.length() - 1);;
		}
		query = "SELECT `" + columnName + "` FROM `series_information` WHERE `series`=\"" + series + "\" and`country`=\"" + country + "\";";
		rs = st.executeQuery(query);
		rs.next();
		%><%=rs.getString(1)%><%// Bounce what is inserted into the database back to synchronize front end.
	}
	
} catch (Exception e) {
	%>ERROR<%
}
con.close();
%>