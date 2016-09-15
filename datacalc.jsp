<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*"%>
<%
	Connection con = null;
	String check = null;
	String selcount = null;

	try {
		selcount = request.getParameter("selcount");
		selcount = selcount.trim();
		check = request.getParameter("check");
		System.out.println(check);

		Class.forName("com.mysql.jdbc.Driver").newInstance();
	con= DriverManager.getConnection("jdbc:mysql://localhost:3306/ngatla1", "ngatla1","1db23");
	} catch (Exception e) {
		e.printStackTrace();
	}

	ResultSet rs = null;

	try {
		Statement st = con.createStatement();
		rs = st.executeQuery("select distinct Datasource from ead where country LIKE '%"+ selcount + "%' and positive != 0.0 order by positive desc");
		//System.out.println("select distinct Datasource from ead where country LIKE '%"+ selcount + "%' and positive != 0.0 order by appappdis desc");
		if (check.equalsIgnoreCase("datachart")) {
%>
<select id="multi" multiple="multiple" onchange = "timeperiod();">
	<%
		while (rs.next()) {
					String dsval = rs.getString(1);
	%>
	<option><%=dsval%></option>

	<%
		}
	%>
</select>
<%
	} else {
%>
<select id="multi" onchange = "timeperiod();">
<option>Select Data Source</option>
	<%
		while (rs.next()) {
					String dsval = rs.getString(1);
	%>
	<option><%=dsval%></option>
	<%
		}
	%>
</select>
<%
	}

	} catch (SQLException e) {
		e.printStackTrace();
	}
%>
<%
	rs.close();
	con.close();
%>