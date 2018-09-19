--[[ 

	Top Hubbers 1.1x to 1.21 DB Converter by jiten (8/17/2006)

	Requested by: -SkA-

	Changelog:

	1. Place your old tOnliners.tbl under your scripts' folder;
	2. Run this script and the new file "tOnliners(new).tbl" will appear in the same folder;
	3. Backup your old DB (just in case) and rename the new one to the default format.
	4. And that's it!

]]--

-- File to convert
fConvert = "tOnliners.tbl"
-- Output file
fConverted = "tOnliners(new).tbl"

tConvert = {}

Main = function()
	if loadfile(fConvert) then dofile(fConvert) end; tConvert = tOnline
	for i, v in pairs(tOnline) do tConvert[i].Julian = os.time(os.date("!*t")) end
	local hFile = io.open(fConverted, "w+") Serialize(tConvert, "tOnline", hFile); hFile:close() 
end

Serialize = function(tTable, sTableName, hFile, sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key, value in pairs(tTable) do
		if (type(value) ~= "function") then
			local sKey = (type(key) == "string") and string.format("[%q]", key) or string.format("[%d]", key);
			if(type(value) == "table") then
				Serialize(value, sKey, hFile, sTab.."\t");
			else
				local sValue = (type(value) == "string") and string.format("%q", value) or tostring(value);
				hFile:write(sTab.."\t"..sKey.." = "..sValue);
			end
			hFile:write(",\n");
		end
	end
	hFile:write(sTab.."}");
end