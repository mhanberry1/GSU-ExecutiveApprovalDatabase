<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%@ include file="config.jsp" %>

<%
request.setCharacterEncoding("UTF-8");

ResultSet rs = null;
String country = null;

try {
	country = request.getParameter("country");
	Statement st=con.createStatement();
	rs = st.executeQuery("SELECT datasource, recdate, positive, net, appappdis FROM ead WHERE country=\"" + country + "\" ORDER BY recdate;");
%>
{
	"cols": [
		{"id":"", "label":"Source", "pattern":"", "type":"string"},
		{"id":"", "label":"Date", "pattern":"", "type":"date"},
		{"id":"", "label":"%Positive", "pattern":"", "type":"number"},
		{"id":"", "label":"%Net", "pattern":"", "type":"number"},
		{"id":"", "label":"%App/%App + %Dis", "pattern":"", "type":"number"}
	],
	"rows": [
<%
	boolean first = true;
	while (rs.next()) {
		if (!first) {%>,<%;}
		first = false;
%>
		{"c":[{"v":"<%=rs.getString(1)%>", "f":null},
			{"v":"Date(<%=rs.getString(2).substring(0, 4)%>, <%=rs.getString(2).substring(5, 7)%>, <%=rs.getString(2).substring(8)%>)", "f":null},
			{"v":<%=rs.getString(3)%>, "f":null},
			{"v":<%=rs.getString(4)%>, "f":null},
			{"v":<%=rs.getString(5)%>, "f":null}
			]
		}
<%
	}
%>
	]
}
<%
} catch (Exception e) {
	e.printStackTrace();
}
con.close();
%>