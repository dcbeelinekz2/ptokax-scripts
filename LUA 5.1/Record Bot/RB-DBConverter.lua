--[[ 

	RecordBot 1.5a to 1.6 DB Converter by jiten (11/8/2006)

	Requested by: speedX

	CHANGELOG:

	1. Place your old tRecord.tbl under your scripts' folder;
	2. Run this script and the new file "tRecord(new).tbl" will appear in the same folder;
	3. Backup your old DB (just in case) and rename the new one to the default format: tRecord.tbl
	4. And that's it!

]]--

-- File to convert
fConvert = "tRecord.tbl"
-- Output file
fConverted = "tRecord(new).tbl"

tConvert = {}

Main = function()
	if loadfile(fConvert) then dofile(fConvert) end; tConvert = Record.tDB
	local hFile = io.open(fConverted, "w+") Serialize(tConvert, "tRecord", hFile); hFile:close() 
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