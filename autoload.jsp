<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%
	Connection con = null;
		Set<String> temp = new HashSet<String>();
	try{
	Class.forName("com.mysql.jdbc.Driver").newInstance();
	con= DriverManager.getConnection("jdbc:mysql://localhost:3306/ngatla1", "ngatla1","1db23");
	}
	catch(Exception e)
	{
		e.printStackTrace();
	}

	ResultSet rs = null;
	try
	{
		Statement st=con.createStatement();
		
		rs = st.executeQuery("select distinct country from ead order by country");
		String country = null;
		%>
<select id="countries" onchange = "basechecks();">
	<option value="selcountry">Select Country</option>
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
	}	
	catch (SQLException e) {
    e.printStackTrace();
	}
		 rs.close();
		 con.close();
		%>