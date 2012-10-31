/*
Mapchen v0.1
by: Thomas Greiner
Artistic License/GPL
code.google.com/p/mapchen-heatmap
www.greinr.com
*/

var xmlHttp;

function sendData(param) {
	var script_path = document.getElementById("mapchen").src.replace("heatmap.js","");
	var path = location.pathname;
	var pagename = path.substring(0,path.length);
	if(pagename == "") pagename = "(index)";
	var pagefile = path.substring(path.lastIndexOf("/")+1,path.length);
    var url=((pagefile=="")?script_path+"heat.asp":script_path+"heat.asp?file="+pagename.replace(/\//g,"((_))").replace(/\./g,"((p))").replace(/\?/g,"((q))").replace(/#/g,"((hash))").replace(/=/g,"((eq))")+"&"+param);
	//console.log(pagefile);
	//console.log(pagename);
	//console.log(url);
    xmlHttp=GetXmlHttpObject()
    xmlHttp.open("GET", url , true)
    xmlHttp.send(null)
}

function GetXmlHttpObject(handler) {
    var objXmlHttp=null
    if (navigator.userAgent.indexOf("MSIE")>=0) {
        var strName="Msxml2.XMLHTTP"
        if (navigator.appVersion.indexOf("MSIE 5.5")>=0) {
            strName="Microsoft.XMLHTTP"
        } try {
            objXmlHttp=new ActiveXObject(strName)
            objXmlHttp.onreadystatechange=handler
            return objXmlHttp
        }
        catch(e) {
            //Error. Scripting for ActiveX might be disabled
            return
        }
    }
    if (navigator.userAgent.indexOf("Mozilla")>=0) {
        objXmlHttp=new XMLHttpRequest()
        objXmlHttp.onload=handler
        objXmlHttp.onerror=handler
        return objXmlHttp
    }
}

start = 0;
timeOnSite = 0;
date = new Date();
visitor = "_"+date.getDate()+(date.getMonth()+1)+date.getYear()+date.getHours()+date.getMinutes()+date.getSeconds()+"_";
res = window.innerWidth+"x"+window.innerHeight;

//e.type
// - mousemove
// - click
function record(e) {
	if(e.type == "mousemove") {
		window.timeOnSite = timeOnSite+1;
		if(timeOnSite%50==0) {
			x = (document.all) ? window.event.x + document.body.scrollLeft : e.pageX;
			y = (document.all) ? window.event.y + document.body.scrollTop  : e.pageY;
			date = new Date();
			if(date.getMonth()+1<10) nullM = "0"; else nullM = "";
			if(date.getDate()<10) nullD = "0"; else nullD = "";
			if(date.getHours()<10) nullH = "0"; else nullH = "";
			if(date.getMinutes()<10) nullMin = "0"; else nullMin = "";
			if(date.getSeconds()<10) nullS = "0"; else nullS = "";
			time = (date.getYear()+1900)+"-"+nullM+(date.getMonth()+1)+"-"+nullD+date.getDate()+" "+nullH+date.getHours()+":"+nullMin+date.getMinutes()+":"+nullS+date.getSeconds();
			//document.documentElement.innerHTML += time+": "+e.type+"["+res+"] "+x+":"+y+"<br>";
			sendData("type="+e.type+"&visitor="+visitor+"&res="+res+"&xIn="+x+"&yIn="+y+"&time="+time);
		}
	} else {
		x = (document.all) ? window.event.x + document.body.scrollLeft : e.pageX;
		y = (document.all) ? window.event.y + document.body.scrollTop  : e.pageY;
		date = new Date();
		if(date.getYear()-100<10) year = "0"+(date.getYear()-100); else year = date.getYear()-100;
		if(date.getMonth()+1<10) month = "0"+(date.getMonth()+1); else month = date.getMonth()+1;
		//document.documentElement.innerHTML += time+": "+e.type+"["+res+"] "+x+":"+y+"<br>";
		sendData("type="+e.type+"&visitor="+visitor+"&res="+res+"&xIn="+x+"&yIn="+y+"&time="+year+month);
	}
}

document.onmousemove = record;
document.onclick = record;