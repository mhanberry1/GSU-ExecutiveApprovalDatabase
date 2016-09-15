<%@page import="java.awt.geom.CubicCurve2D"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*, javax.sql.*, java.io.*, javax.naming.*,javax.servlet.ServletContext"%>

<%
	Connection con = null;
	String check = null;
	String from = null;
	String to = null;
	String mulcalc = null;
	String multi = null;
	File file = null;
	FileWriter fw = null;
	BufferedWriter writer = null;
	String filename = null;
	String [] mulcalcsplit = null;
	String [] mulcalcarray=null;
	mulcalcarray = new String[5];
	String d3var = null;
	String country = null;
	//System.out.println(new File(".").getAbsolutePath());
%>

<table border="1">
	<thead>
		<tr>
			<%
				try {
					
					Class.forName("com.mysql.jdbc.Driver").newInstance();
					con = DriverManager.getConnection(
							"jdbc:mysql://localhost:3306/ngatla1", "ngatla1", "1db23");
					check = request.getParameter("check");
					from = request.getParameter("from");
					to = request.getParameter("to");
					mulcalc = request.getParameter("mulcalc");
					multi = request.getParameter("multi");
					country = request.getParameter("country");
							
					
					if (check.equalsIgnoreCase("calchart")) {
						if (mulcalc.contains(",")) {
							mulcalcsplit = mulcalc.split(",");
							d3var = multi.substring(1, multi.length()-1);
						}
						else {
							
							
							d3var = mulcalc;
						}

					}

					if (check.equalsIgnoreCase("datachart")) {
						if (multi.contains(",")) {
							
							d3var = mulcalc;
						
						}

						else {
							
							d3var = mulcalc;
						}

					}
					
				filename = "/charts-ui/alldata.csv";
				String absoluteDiskPath = getServletContext().getRealPath(filename);
				file = new File(absoluteDiskPath);
				System.out.println(file);				
				Boolean del = file.delete();
					if (!file.exists())
						file.createNewFile();
					fw = new FileWriter(file);
					writer = new BufferedWriter(fw);
			
				}

				catch (Exception e)
				{
					System.out.print(e);
					e.printStackTrace();
				}
				ResultSet rsdata = null;
				ResultSet aResultset1 = null;
				try
				{
					Statement a = con.createStatement();
					int actColmns = 6;
					String dispQuery = "select datasource,recdate," + mulcalc
							+ " from ead where recdate between '" + from
							+ "' and '" + to + "' and datasource IN (" + multi
							+ ") and country like '%"+country+"%'";
					writer.write("datasource,date,value");
					aResultset1 = a.executeQuery(dispQuery);
					ResultSetMetaData rsmd = aResultset1.getMetaData();
					int columnsNumber = rsmd.getColumnCount();
					String name = rsmd.getColumnName(1);
					if (actColmns != 0 || dispQuery != null) {
						for (int i = 1; i <= columnsNumber; i++)
						{
							String tabHeader = rsmd.getColumnName(i);
							
			%>
			<th><%=tabHeader%></th>
			<%
				}
					}

					writer.newLine();
			%>
		</tr>
	</thead>
	<tbody>
		<%
				
			rsdata = a.executeQuery("select datasource,recdate," + mulcalc
						+ " from ead where recdate between '" + from
						+ "' and '" + to + "' and datasource IN (" + multi
						+ ") and country like '%"+country+"%'");
						
				while (rsdata.next()) {
		%><tr>
			<%
				for (int i = 1; i <= columnsNumber; i++)
						{
							String values = rsdata.getString(i);
							//System.out.println(rsdata.getString(i));
							if(i==2){
								
								String [] dateparts = values.split("-");
								mulcalcarray[i-1] =dateparts[1] + "/" + dateparts[2] + "/" + dateparts[0];
								
							}else{
							mulcalcarray[i-1] = values;
							}
							if (i != columnsNumber) {
								if (i==2) {
									
									//System.out.println(values);
									String[] parts = values.split("-");
									values = parts[1] + "/" + parts[2] + "/"
											+ parts[0];
								}
								if(!(check.equalsIgnoreCase("calchart") && mulcalc.contains(","))){
								writer.write(values + ",");
								}
							}

							else {
								if (i==2) {
									String[] parts = values.split("-");
									values = parts[2] + "/" + parts[1] + "/"
											+ parts[0];
								}
								if(!(check.equalsIgnoreCase("calchart") && mulcalc.contains(","))){
								writer.write(values);
								}
							}
							
			%>

			<td><%=values%></td>
			<%
				}
			
			if((check.equalsIgnoreCase("calchart") && mulcalc.contains(","))){
				for(int k = 0;  k<mulcalcsplit.length; k++){
					
					writer.write(mulcalcsplit[k]+","+mulcalcarray[1]+","+mulcalcarray[k+2]);
					writer.newLine();		
				}
			
				}
			if(!(check.equalsIgnoreCase("calchart") && mulcalc.contains(","))){
						writer.newLine();
			}
			%>
		</tr>
		<%
			}
			}

			catch (SQLException e) {
				e.printStackTrace();
			}
			aResultset1.close();
			rsdata.close();
			con.close();
			writer.flush();
			writer.close();
			fw.close();
		%>
	</tbody>
</table>
<input type="hidden" id="d3var" value='<%=d3var%>'>