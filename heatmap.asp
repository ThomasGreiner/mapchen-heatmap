<%
'Mapchen v0.1
'by: Thomas Greiner
'Artistic License/GPL
'code.google.com/p/mapchen-heatmap
'www.greinr.com
%>
<!-- #include file="config.asp" -->
<%
if request("file") <> "" then

	Function kc_fsoFiles(theFolder, Exclude)
		Dim rsFSO, objFSO, objFolder, File
		Const adInteger = 3
		Const adDate = 7
		Const adVarChar = 200
		Set rsFSO = Server.CreateObject("ADODB.Recordset")
		Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
		Set objFolder = objFSO.GetFolder(theFolder)
		Set objFSO = Nothing

		With rsFSO.Fields
			.Append "Name", adVarChar, 200
			.Append "Type", adVarChar, 200
			.Append "DateCreated", adDate
			.Append "DateLastAccessed", adDate
			.Append "DateLastModified", adDate
			.Append "Size", adInteger
			.Append "TotalFileCount", adInteger
		End With
		rsFSO.Open()

		For Each File In objFolder.Files
			'hide any file that begins with the character to exclude
			If (Left(File.Name, 1)) <> Exclude Then 
				rsFSO.AddNew
				rsFSO("Name") = File.Name
				rsFSO("Type") = File.Type
				rsFSO("DateCreated") = File.DateCreated
				rsFSO("DateLastAccessed") = File.DateLastAccessed
				rsFSO("DateLastModified") = File.DateLastModified
				rsFSO("Size") = File.Size
				rsFSO.Update
			End If
		Next

		Set objFolder = Nothing
		rsFSO.MoveFirst()
		Set kc_fsoFiles = rsFSO
	End Function

	Dim strFolder : strFolder = Server.MapPath("\") & DB_FOLDER_PATH & request("file") & "/"
	Dim rsFile
	Set rsFile = kc_fsoFiles(strFolder, "_")
	rsFile.sort = "Name DESC"
	
	i = true
	while not rsFile.eof and not rsFile.bof
		if i = true then
			i = false
		else
			response.write ","
		end if
		response.write replace(rsFile("Name"),".mdb","")
		rsFile.movenext
	wend

else

	Whichfolder=server.mappath("\") & DB_FOLDER_PATH
	Dim fs, f, f1, fc 
	Set fs = CreateObject("Scripting.FileSystemObject") 
	Set f = fs.GetFolder(Whichfolder) 
	Set fc = f.subfolders
	%>

	<div style="height:40px;font-weight:bold;font-size:12px;font-family:Arial">
		file: 
		<select id="fileSelect" onchange="XHRsend(this.value)">
			<%
			for each f1 in fc
				%>
				<option value="<%=f1.name%>"><%=replace(replace(replace(replace(replace(f1.name,"((_))","/",1,-1),"((q))","?",1,-1),"((eq))","=",1,-1),"((p))",".",1,-1),"((hash))","#",1,-1)%></option>
				<%
			next
			%>
		</select>
		month: 
		<select id="monthSelect" onchange="refresh()"></select>
		method: 
		<select id="methodSelect" onchange="refresh()">
			<option value="0">points</option>
			<option value="1">grid</option>
		</select>
		type: 
		<select id="typeSelect" onchange="refresh()">
			<option value="click">clicks</option>
			<option value="mousemove">mouse move</option>
		</select>
	</div>
	<iframe src="" style="width:100%;position:absolute;left:0px;top:40px" frameborder="0"></iframe>
	<script type="text/javascript">
		function refresh() {
			file = document.getElementById("fileSelect").value;
			month = document.getElementById("monthSelect").value;
			method = document.getElementById("methodSelect").value;
			type = document.getElementById("typeSelect").value;
			path = location.pathname;
			url = path.replace(path.substring(path.lastIndexOf("/")+1,path.length),"canvas.asp")+"?file="+file+"&month="+month+"&method="+method+"&type="+type;
			document.getElementsByTagName("iframe")[0].src = url;
		}
		
		function XHRsend(file) {
			var xhr = new XMLHttpRequest();
			xhr.open("GET",location.pathname+"?file="+file, true);
			xhr.send();
			xhr.onreadystatechange = function() {
				if(xhr.readyState == 4) {
					var resp = xhr.responseText;
					var array = resp.split(",");
					var monthSelect = document.getElementById("monthSelect");
					monthSelect.innerHTML = "";
					for(i=0;i<array.length;i++) {
						month = array[i];
						var opt = document.createElement("option");
						opt.value = month;
						opt.innerHTML = month.substr(0,2)+"/"+month.substr(2,2);
						monthSelect.appendChild(opt);
					}
					refresh();
				}
			}
		}
		var iframe = document.getElementsByTagName("iframe")[0];
		if(window.innerHeight)
			iframe.style.height = window.innerHeight-40;
		else
			iframe.style.height = "100%";
		//set default page
		XHRsend(document.getElementById("fileSelect").value);
	</script>
<% end if %>