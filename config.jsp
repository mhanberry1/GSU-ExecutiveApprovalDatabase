<%
Connection con = null;
try{
	Class.forName("com.mysql.jdbc.Driver").newInstance();
	con = DriverManager.getConnection("jdbc:mysql://localhost:3306/execapp", "root", "root");
} catch(Exception e) {
	e.printStackTrace();
}
%>