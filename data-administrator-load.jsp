<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%@ include file="data-administrator-secure.jsp" %><%// This has the config file included%>

<%
request.setCharacterEncoding("UTF-8");

ResultSet rs = null;
String country = null;

try {
	String table = request.getParameter("table");
	country = request.getParameter("country");
	Statement st = con.createStatement();
	if (table.equals("ead")) {
		rs = st.executeQuery("SELECT datasource, recdate, totalcount, positive, net, appappdis, source, (SELECT `username` FROM `users` WHERE `id`=`user`), timestamp FROM ead WHERE country=\"" + country + "\" ORDER BY recdate;");
		%>
		{"cols": ["Series", "Date", "N", "% Positive", "% Net", "%App/(%App+%Dis)", "Source", "User", "Time Stamp"],
		"rows": [
		<%
		boolean first = true;
		while (rs.next()) {
			if (!first) {%>,<%;}
			first = false;
			%>
				["<%=rs.getString(1)%>", "<%=rs.getString(2)%>","<%=rs.getString(3)%>", "<%=rs.getString(4)%>", "<%=rs.getString(5)%>", "<%=rs.getString(6)%>", "<%=rs.getString(7)%>", "<%=rs.getString(8)%>", "<%=rs.getString(9)%>"]
			<%
		}
		%>
		]}
		<%
	} else if (table.equals("series_information")) {
		String sql = "SELECT series, description, question_type, question_wording, (SELECT `username` FROM `users` WHERE `id`=`user`), timestamp FROM series_information WHERE country=\"" + country + "\";";
		rs = st.executeQuery(sql);
		%>
		{"cols": ["Series", "Description", "Question Type", "Question Wording", "User", "Time Stamp"],
		"rows": [
		<%
		boolean first = true;
		while (rs.next()) {
			if (!first) {%>,<%;}
			first = false;
			%>
				["<%=rs.getString(1)%>", "<%=rs.getString(2)%>","<%=rs.getString(3)%>", "<%=rs.getString(4)%>", "<%=rs.getString(5)%>", "<%=rs.getString(6)%>"]
			<%
		}
		%>
		]}
		<%
	}

} catch (Exception e) {
	e.printStackTrace();
}
con.close();
%>