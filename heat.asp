<!--
Mapchen v0.1
by: Thomas Greiner
Artistic License/GPL
code.google.com/p/mapchen-heatmap
www.greinr.com
-->

<!-- #include file="config.asp" -->
<%
file = request("file")
dbname = request("time")
'blacklist check
dim blacklist
dim iprx
blacklist = split(IP_BLACKLIST,";")
ipfound = false
for each ip in blacklist
	set iprx = new regexp
	iprx.pattern = ip
	if iprx.test(request.servervariables("REMOTE_ADDR")) then ipfound = true
next

if not ipfound then
	if request("type") = "mousemove" then
		dbname = right(left(dbname,4),2) & right(left(dbname,7),2)
	end if
	dir = server.mappath(DB_FOLDER_PATH & file)
	all = server.mappath(DB_FOLDER_PATH & file & "/" & dbname & ".mdb")
	'directory exists?
	set FSO = createobject("scripting.filesystemobject")
	if not FSO.folderexists(dir) then
		FSO.createfolder dir
	end if
	'database exists?
	if not FSO.fileexists(all) then
		Set cat = CreateObject("ADOX.Catalog")
		cat.create "Provider=Microsoft.Jet.OLEDB.4.0;" & "Data Source=" & all
		set conn=server.createobject("adodb.connection")
		conn.open "DRIVER={Microsoft Access Driver (*.mdb)}; DBQ=" & all
		conn.execute "CREATE TABLE mousemove(id counter CONSTRAINT PK PRIMARY KEY, visitor memo, usertime datetime, x smallint, y smallint, res memo)"
		conn.execute "CREATE TABLE click(id counter CONSTRAINT PK PRIMARY KEY, visitor memo, x smallint, y smallint, res memo)"
	else
		set conn=server.createobject("adodb.connection")
		conn.open "DRIVER={Microsoft Access Driver (*.mdb)}; DBQ=" & all
	end if
	if request("type") = "mousemove" then
		timefield = ",usertime"
		timeval = ",'"&request("time")&"'"
	else
		timefield = ""
		timeval = ""
	end if
	sql = "INSERT INTO "&request("type")&"(visitor"&timefield&",x,y,res) VALUES ('"&request("visitor")&"'"&timeval&",'"&request("xIn")&"','"&request("yIn")&"','"&request("res")&"')"
	conn.execute sql
	conn.close
end if
%>