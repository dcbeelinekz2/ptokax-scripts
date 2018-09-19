--[[ 

	Entry 1.2 and older .tbl file converting tool
	
	Just run the script and the new file "Entry.tbl" appear in your main scripts' folder

]]--

tConvert = {}
Entry = {}

Main = function()
	dofile("rssfeed.tbl")
	for i,v in ipairs(rssfeed) do
		tConvert[v[1]] = { sHost = v[2]..v[3], sDesc = v[4], Cache = {}, Queue = {} }
	end
	SaveToFile("tRSS.tbl",tConvert,"RSS")
end

Serialize = function(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in tTable do
		if (type(value) ~= "function") then
			local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
			if(type(value) == "table") then
				Serialize(value,sKey,hFile,sTab.."\t");
			else
				local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
				hFile:write(sTab.."\t"..sKey.." = "..sValue);
			end
			hFile:write(",\n");
		end
	end
	hFile:write(sTab.."}");
end

SaveToFile = function(file,table,tablename)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end