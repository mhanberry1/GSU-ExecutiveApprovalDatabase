<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%@ include file="config.jsp" %>
<%
	Set<String> temp = new HashSet<String>();
	ResultSet rs = null;
	try {
		String table = request.getParameter("table");
		Statement st=con.createStatement();
		
		rs = st.executeQuery("select distinct country from ead order by country");
		if (table != null && table.equals("series_information")) {
			rs = st.executeQuery("select distinct country from series_information order by country");
		}
		String country = null;
%>
<select id="countries" onchange = "countryChanged();">
	<option value="selcountry" selected disabled>Select Country</option>
	<%
		while(rs.next()){
			country = rs.getString(1);
			if(temp.add(country.trim())){
	%>
		<option><%=country%></option>
	<% 
			}
		}
  	%>
</select>
<% 
	} catch (SQLException e) {
		e.printStackTrace();
	}
	rs.close();
	con.close();
%>