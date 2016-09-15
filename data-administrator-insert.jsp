<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="java.util.*"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,java.util.*"%>
<%@ include file="data-administrator-secure.jsp" %><%// This has the config file included%>

<%
request.setCharacterEncoding("UTF-8");
String query = "";
try {
	Statement st = con.createStatement();
	String defaultCountry = request.getParameter("defaultCountry");
	String table = request.getParameter("table");
	String data = request.getParameter("data").replace("\r", "").replace("\"", "");
	String[] rows = data.split("\n");
	int rowsAdded = 0;
	for (int i = 0; i < rows.length; i++) {
		String cell[] = rows[i].split("\t");
		String temp[] = cell;
		String country = "";
		if (table.equals("ead")){
			country = "\"" + (cell.length < 8 ? defaultCountry : cell[7]) + "\"";
			if (cell.length < 8 && request.getParameter("defaultCountry").equals("undefined")) {
				response.sendError(500);
				return;
			}
			cell = new String[7];
		}
		else if (table.equals("series_information")){
			country = "\"" + (cell.length < 5 ? defaultCountry : cell[4]) + "\"";
			if (cell.length < 5 && request.getParameter("defaultCountry").equals("undefined")) {
				response.sendError(500);
				return;
			}
			cell = new String[4];
		}
		for (int j = 0; j < cell.length; j++) {
			if (j < temp.length) {
				cell[j] = temp[j];
			} else {
				cell[j] = "";
			}
		}
		for (int j = 0; j < cell.length; j++) {
			if (cell[j].equals("")) cell[j] = "NULL";
			else cell[j] = "\"" + cell[j] + "\"";
		}
		if (table.equals("ead")) {
			if (cell.length < 3) continue;
			query = "REPLACE INTO `ead` (`datasource`, `recdate`, `totalcount`, `positive`, `net`, `appappdis`, `source`, `country`, `user`) VALUES ("
					+ cell[0] + ", " + cell[1] + ", " + cell[2] + ", " + cell[3] + ", " + cell[4] + ", " + cell[5] + ", " + cell[6] + ", "
					+ country + ", (SELECT `id` FROM `users` WHERE `username` = \"" + userName + "\"));";
		} else if (table.equals("series_information")) {
			query = "REPLACE INTO `series_information` (`series`, `description`, `question_type`, `question_wording`, `country`, `user`) VALUES ("
					+ cell[0] + ", " + cell[1] + ", " + cell[2] + ", " + cell[3] + ", "
					+ country + ", (SELECT `id` FROM `users` WHERE `username` = \"" + userName + "\"));";
		}
		st.executeUpdate(query);
		rowsAdded++;
	}
	%><%=rowsAdded%>/<%=rows.length%><%
} catch (Exception e) {
	%>ERROR <%=query%> <%=e.getMessage()%><%
}
con.close();
%>