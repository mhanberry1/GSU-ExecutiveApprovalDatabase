function autoload(){
	var url_temp1 = "autoload.jsp?time="+new Date().getTime();
	ajaxGeneric(url_temp1,function()
			{
		if (xmlhttp.readyState==4 && xmlhttp.status==200)
		{
			document.getElementById("country").innerHTML= xmlhttp.responseText;		
		}
			});


}

function basechecks(){
	if(document.getElementById("countries").value != "selcountry"){
	var radios = document.getElementsByName('sel');
	
	for (var i = 0, length = radios.length; i < length; i++) {
	  
	        // do whatever you want with the checked radio
	        radios[i].disabled = false;
	     
	}
	
	document.getElementById("chart").disabled = false;
	document.getElementById("mulcalc").disabled = false;
	}
	else{
		
		document.getElementById("chart").disabled = true;
		document.getElementById("multi").disabled = true;
		var radios = document.getElementsByName('sel');
		
		for (var i = 0, length = radios.length; i < length; i++) {
		  
		        // do whatever you want with the checked radio
		        radios[i].disabled = true;
		        
		}
		
		document.getElementById("from").disabled = true;
		document.getElementById("to").disabled = true;
		document.getElementById("datasource").disabled = true;
		document.getElementById("selinit").disabled = true;
		document.getElementById("mulcalc").disabled = true;	
	}
	
}

function datacalc()
{
	var init = document.getElementById("chart");
	var check = init.options[init.selectedIndex].value;
	var countid = document.getElementById("countries");
	var selcount = countid.options[countid.selectedIndex].value;
	if(!(check == "calmeth")){
		if(!(selcount == "selcountry")){

			var url_temp1 = "datacalc.jsp?check="+check+"&selcount="+selcount+"&time="+new Date().getTime();	
			ajaxGeneric(url_temp1,function(){

				if (xmlhttp.readyState==4 && xmlhttp.status==200)
				{

					if(check == "datachart"){
						document.getElementById("calc").innerHTML= '<select id="mulcalc" onchange = "dataorder()"> <option value="positive">Positive : Total Positive Rating</option><option value="net">Net : (Positive - Negative) Rating</option><option value="appappdis">AppApp+Dis : 100 * Positive/(Positive + Negative) Rating</option></select>';
					}
					else{
						document.getElementById("calc").innerHTML= '<select id="mulcalc" multiple="multiple" onchange = "dataorder()"> <option value="positive">Positive : Total Positive Rating</option><option value="net">Net : (Positive - Negative) Rating</option><option value="appappdis">AppApp+Dis : 100 * Positive/(Positive + Negative) Rating</option></select>';
					}

					document.getElementById("datasource").innerHTML=xmlhttp.responseText;

				}
			});

		}
	}

}

function timeperiod(){

var init = document.getElementById("chart");
var check = init.options[init.selectedIndex].value;
var coun = document.getElementById("countries");
var country = coun.options[coun.selectedIndex].value;
var multi;
var mulcalc;
var mulcalc1 = null;
var multi1 = null;
if(check == "calchart"){
multi = document.getElementById("multi");
multi1=multi.options[multi.selectedIndex].value;
mulcalc = document.getElementById("mulcalc");

 for (var i = 0; i < mulcalc.length; i++) {
        if (mulcalc.options[i].selected) {
        	if(i==0){
        		
        	mulcalc1 = mulcalc.options[i].value;
        	}
        	else{
                        if(mulcalc1 != null){
        		mulcalc1 = mulcalc1 + "," + mulcalc.options[i].value;
                    }
                    else{
                        mulcalc1 = mulcalc.options[i].value;
                        
                    }
        	}
        }
        }
    }

if(check == "datachart"){
	mulcalc= document.getElementById("mulcalc");
	mulcalc1=mulcalc.options[mulcalc.selectedIndex].value;
   	multi = document.getElementById("multi");
	
	 for (var i = 0; i < multi.length; i++) {
	        if (multi.options[i].selected) {
	        	if(i==0){      	        		
	        		multi1 = multi.options[i].value;
	        		
	        	}
	        	else{
                                if(multi1 !=null){
	        		multi1 = multi1 + "," + multi.options[i].value;
                            }
                            else{
                                multi1 = multi.options[i].value;
                            }
	        	}
	        }
	        }
	}



var url_temp1 = "timeperiod.jsp?check="+check+"&muldata="+multi1+"&mulcalc="+mulcalc1+"&country="+country+"&time="+new Date().getTime();

ajaxGeneric(url_temp1,function(){

	if (xmlhttp.readyState==4 && xmlhttp.status==200)
	{
	document.getElementById("timedummy").innerHTML=xmlhttp.responseText;

	}
});
	var date1;
	var month1;
	var date2;
	var month2;
	
	date1 = parseInt(document.getElementById("date1").value,10);
	month1 = parseInt(document.getElementById("month1").value,10);
	date2 = parseInt(document.getElementById("date2").value,10);
	month2 = parseInt(document.getElementById("month2").value,10);
	

	var initdate = "From:<select id = \"selfyr\" onchange=\"timechange()\">";
	for(var j = date2;j<=date1;j++){
	initdate = initdate + "<option value=\""+j+"\">"+j+"</option>";
	}
	initdate = initdate + "</select>";
	document.getElementById("fromyear").innerHTML = initdate;
	var initmonth = "<select id = \"selfmn\">";
	for(var k = month2;k<=12;k++){
	initmonth = initmonth + "<option value=\""+k+"\">"+k+"</option>";
	}    	
	
	initmonth = initmonth + "</select>";
	document.getElementById("frommonth").innerHTML = initmonth;
	var findate = "To:<select id = \"seltyr\" onchange=\"timechange()\">";    	
	for(var l = date1;l>=date2;l--){
		findate = findate + "<option value=\""+l+"\">"+l+"</option>";
		}    	
		findate = findate + "</select>";
		document.getElementById("toyear").innerHTML = findate;
    	var finmonth = "<select id = \"seltmn\">";
		for(var m = month1;m>=1;m--){
		finmonth = finmonth + "<option value=\""+m+"\">"+m+"</option>";
		}    	
		
		finmonth = finmonth + "</select>";
		document.getElementById("tomonth").innerHTML = finmonth;
}

function timechange(){
	
	var toyear;
	var fromyear;
	var tomonth;
	var frommonth;
	toyear = document.getElementById("date1").value;
	fromyear = document.getElementById("date2").value;
	tomonth = parseInt(document.getElementById("month1").value,10);
	frommonth = parseInt(document.getElementById("month2").value,10);
	selfromyr= document.getElementById("selfyr");
	selfromyr1=selfromyr.options[selfromyr.selectedIndex].value;
	seltoyr= document.getElementById("seltyr");
	seltoyr1=seltoyr.options[seltoyr.selectedIndex].value;
	if(fromyear < parseInt(selfromyr1)){
		
		var finmonth = "<select id = \"selfmn\">";
		for(var m = 1;m<=12;m++){
		finmonth = finmonth + "<option value=\""+m+"\">"+m+"</option>";
		}    	
		
		finmonth = finmonth + "</select>";
		document.getElementById("frommonth").innerHTML = finmonth;		
	}
	else{
		var initmonth = "<select id = \"selfmn\">";
		for(var k = frommonth;k<=12;k++){
			initmonth = initmonth + "<option value=\""+k+"\">"+k+"</option>";
			}    	
			
			initmonth = initmonth + "</select>";
			document.getElementById("frommonth").innerHTML = initmonth;
		
	}
	
	if(toyear > parseInt(seltoyr1)){
		
		
		var initmonth = "<select id = \"seltmn\">";
		for(var k = 1;k<=12;k++){
		initmonth = initmonth + "<option value=\""+k+"\">"+k+"</option>";
		}    	
		
		initmonth = initmonth + "</select>";
		document.getElementById("tomonth").innerHTML = initmonth;
		
	}
	else{
		
		var finmonth = "<select id = \"seltmn\">";
		for(var m = tomonth;m>=1;m--){
		finmonth = finmonth + "<option value=\""+m+"\">"+m+"</option>";
		}    	
		
		finmonth = finmonth + "</select>";
		document.getElementById("tomonth").innerHTML = finmonth;
		
	}

}

function GenerateChart(){
	
	
	var init = document.getElementById("chart");
	var check = init.options[init.selectedIndex].value;
	var coun = document.getElementById("countries");
	var country = coun.options[coun.selectedIndex].value;
	var multi;
	var mulcalc;
	var mulcalc1;
	var multi1;
	if(check == "calchart"){
	multi = document.getElementById("multi");
	multi1="'"+multi.options[multi.selectedIndex].value+"'";
	mulcalc = document.getElementById("mulcalc");
	 for (var i = 0; i < mulcalc.length; i++) {
	        if (mulcalc.options[i].selected) {
	        	if(i==0){
	
	        	mulcalc1 = mulcalc.options[i].value;
	        	}
	        	else{
                            if(mulcalc1 != null){
	        		mulcalc1 = mulcalc1 + "," + mulcalc.options[i].value;
                        }
                        else{
                            mulcalc1 = mulcalc.options[i].value;
                            
                        }
	        	}
	        }
	        }
	    }

	if(check == "datachart"){
		mulcalc= document.getElementById("mulcalc");
		mulcalc1=mulcalc.options[mulcalc.selectedIndex].value;
	   	multi = document.getElementById("multi");
    	
    	 for (var i = 0; i < multi.length; i++) {
    	        if (multi.options[i].selected) {
   	        	if(i==0){      	        		
    	        		multi1 = "'"+multi.options[i].value+"'";
    	        	}
    	        	else{
                                    if(multi1 !=null){
    	        		multi1 = multi1 + "," + "'"+multi.options[i].value+"'";
                                }
                                else{
                                    multi1 = "'"+multi.options[i].value+"'";
                                }
    	        	}
    	        }
    	        }
    	}
	
	var fromyear = document.getElementById("selfyr");
	var fromyear1 = fromyear.options[fromyear.selectedIndex].value;
	var frommonth = document.getElementById("selfmn");
	frommonth = frommonth.options[frommonth.selectedIndex].value;
	var fromdate = fromyear1 + "-" + frommonth + "-01";
	var toyear = document.getElementById("seltyr");
	toyear = toyear.options[toyear.selectedIndex].value;
	var tomonth = document.getElementById("seltmn");
	tomonth = tomonth.options[tomonth.selectedIndex].value;
	var lastday =  new Date(toyear, tomonth, 0).getDate();
	var todate = toyear + "-" + tomonth + "-" + lastday;
	var url_temp1 = "dbresults.jsp?check="+check+"&multi="+multi1+"&mulcalc="+mulcalc1+"&from="+fromdate+"&to="+todate+"&country="+country+"&time="+new Date().getTime();    	
	
	
	ajaxGeneric(url_temp1,function()
	{

	if (xmlhttp.readyState==4 && xmlhttp.status==200)
	{
		document.getElementById("results").innerHTML=xmlhttp.responseText;
	}
	});


}

function Generategraph(){
	GenerateChart();
	var d3var;
	d3var = document.getElementById("d3var").value;
	
	
	window.location.href = "multiseries_multisource.html?d3var="+d3var+"&time="+new Date().getTime();
}

function ajaxGeneric(url, func){

	if (window.XMLHttpRequest)
	{
		// code for IE7+, Firefox, Chrome, Opera, Safari
		xmlhttp=new XMLHttpRequest();    	

	}
	else
	{
		// code for IE6, IE5
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
	}


	xmlhttp.onreadystatechange= func;
	xmlhttp.open("GET",url,false);
	xmlhttp.send(null);
}