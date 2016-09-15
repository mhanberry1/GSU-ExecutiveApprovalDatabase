<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%@ include file="config.jsp" %>
<%
	ResultSet rs = null;
	try {
		HashMap<String, HashMap<String, String[]>> seriesTable = new HashMap<String, HashMap<String, String[]>>();
		Statement st=con.createStatement();
		rs = st.executeQuery("SELECT `country`, `series`, `description`, `question_type`, `question_wording` FROM `series_information`;");
		while(rs.next()){
			String country = rs.getString(1);
			String series = rs.getString(2);
			HashMap<String, String[]> innerTable = null;
			if (seriesTable.get(country) != null) {
				innerTable = seriesTable.get(country);
			} else {
				innerTable = new HashMap<String, String[]>();
				seriesTable.put(country, innerTable);
			}
			String[] columns = new String[3];
			columns[0] = rs.getString(3);
			columns[1] = rs.getString(4);
			columns[2] = rs.getString(5);
			innerTable.put(series, columns);
		}
		boolean first = true;
		%>{<%
		for (String country: seriesTable.keySet()) {
			if (!first) %>,<%
			first = false;
			%>"<%=country%>":{<%
			HashMap<String, String[]> innerTable = seriesTable.get(country);
			boolean firstSeries = true;
			for (String series: innerTable.keySet()){
				if (!firstSeries) %>,<%
				firstSeries = false;
				String[] attributes = innerTable.get(series);
				%>"<%=series%>":{"description": "<%=attributes[0].replace("\"", "\\\"")%>", "questionType": "<%=attributes[1].replace("\"", "\\\"")%>", "questionWording": "<%=attributes[2].replace("\"", "\\\"")%>"}<%
			}
			%>}<%
		}
		%>}<%
	} catch (SQLException e) {
		e.printStackTrace();
	}
	rs.close();
	con.close();
%>