<!--
Mapchen v0.1
by: Thomas Greiner
Artistic License/GPL
code.google.com/p/mapchen-heatmap
www.greinr.com
-->

<iframe src="<%= replace(replace(replace(replace(replace(request("file"),"((_))","/",1,-1),"((q))","?",1,-1),"((eq))","=",1,-1),"((p))",".",1,-1),"((hash))","#",1,-1) %>" width="100%" height="100%" frameborder="0" style="position:absolute;left:0px;top:0px;"></iframe>

<canvas id="canvas" style="position:absolute;left:0px;top:0px;z-index:1;">
	Unable to display graph.
</canvas>

<!-- #include file="config.asp" -->
<%
'build paths
file = replace(replace(replace(replace(replace(request("file"),"((_))","/",1,-1),"((q))","?",1,-1),"((eq))","=",1,-1),"((p))",".",1,-1),"((hash))","#",1,-1)
timestamp = request("month")&".mdb"
all = DB_FOLDER_PATH & request("file") & "/" & timestamp

'connect to database
set conn=server.createobject("adodb.connection")
DSNtemp="DRIVER={Microsoft Access Driver (*.mdb)}; "
DSNtemp=DSNtemp & "DBQ=" & server.mappath(all)
conn.Open DSNtemp
Set rs = Server.CreateObject("ADODB.Recordset")
sql = "SELECT * FROM "&request("type")
rs.open sql, conn,3 ,1, 1
%>

<script type="application/javascript">
function draw() {
	var canvas = document.getElementById("canvas");
	canvas.width = window.innerWidth;
	canvas.height = window.innerHeight;
	if(canvas.getContext) {
		var ctx = canvas.getContext("2d");
		<%
		rs.movefirst
		i = 0
		totalWidth = 0
		totalHeight = 0
		minWidth = 1000000
		minHeight = 1000000
		while not rs.eof and not rs.bof
			resX = left(rs("res"),instr(rs("res"),"x")-1)*1
			resY = right(rs("res"),len(rs("res"))-instr(rs("res"),"x"))*1
			x = rs("x")
			y = rs("y")
			xRel = rs("x")/resX*10000
			yRel = rs("y")/resY*10000
			totalWidth = totalWidth+resX
			totalHeight = totalHeight+resY
			if resX < minWidth then minWidth = resX
			if resY < minHeight then minHeight = resY
		%>
			x = <%=x%>;
			y = <%=y%>;
			<% select case request("method") %>
				<% case "0" %>
					resX = <%=resX%>;
					xRel = <%=xRel%>;
					yRel = <%=yRel%>;
					ctx.fillStyle = "rgba(255, 0, 0, <% if request("type")="click" then %>0.3<% else %>0.1<% end if %>)"; //ctx.fillStyle = "rgba(0, 0, 255, 0.3)";
					if(x>213 && x<resX-213) {
						//ctx.fillStyle = "rgba(255, 0, 0, 0.3)";
						x = xRel/10000*window.innerWidth;
					}
					if(<%=x%>>=resX-213) {
						//ctx.fillStyle = "rgba(0, 0, 255, 0.3)";
						x = window.innerWidth-(resX-x);
					}
					ctx.fillRect(x,y,5,5);
					/* x,y Bar */
					//ctx.fillStyle = "rgba(255, 0, 255, <% if request("type")="click" then %>0.1<% else %>0.05<% end if %>)";
					//ctx.fillRect(x,window.innerHeight-10,5,10);
					//ctx.fillRect(window.innerWidth-10,y,10,5);
				<% case "1" %>
					resX = <%=resX%>;
					xRel = <%=xRel%>;
					if(x>213 && x<resX-213)  x = xRel/10000*window.innerWidth;
					if(<%=x%>>=resX-213) x = window.innerWidth-(resX-x);
					ctx.fillStyle = "rgba(255, 255, 0, <% if request("type")="click" then %>0.1<% else %>0.05<% end if %>)";
					ctx.fillRect(x,0,5,window.innerHeight);
					ctx.fillRect(0,y,window.innerWidth,5);
			<% end select %>
			<%
			i = i+1
			rs.movenext
		wend
		%>
		avgWidth = <%=totalWidth/i%>
		avgHeight = <%=totalHeight/i%>
		ctx.fillStyle = "rgba(0, 255, 0, 0.5)";
		ctx.fillRect(avgWidth, 0, 2, avgHeight+2);
		ctx.fillRect(0, avgHeight, avgWidth+2, 2);
		ctx.fillRect(<%=minWidth%>, 0, 2, <%=minHeight%>+2);
		ctx.fillRect(0, <%=minHeight%>, <%=minWidth%>+2, 2);
	}
}
draw();
</script>

<%
rs.close
conn.close
%>