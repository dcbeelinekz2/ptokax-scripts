--[[ 

	TopHubbers 2.01-2.02 DB Converter by jiten (11/11/2006)

	Requested by: speedX

	DESCRIPTION:

	This converter will keep the oldest repeated entry in the DB and delete the others.

	STEPS:

	1. Place your old tOnliners.tbl under your scripts' folder;
	2. Run this script and the new file "tOnliners(new).tbl" will appear in the same folder;
	3. Backup your old DB (just in case) and rename the new one to the default format: tOnliners.tbl
	4. And that's it!

]]--

-- File to convert
fConvert = "tOnliners.tbl"
-- Output file
fConverted = "tOnliners(new).tbl"

Main = function()
	if loadfile(fConvert) then dofile(fConvert) end; local tConvert, tRemove = tOnline, {}
	for i, v in pairs(tConvert) do
		tRemove[string.lower(i)] = (tRemove[string.lower(i)] or {})
		table.insert(tRemove[string.lower(i)], v.Julian); table.sort(tRemove[string.lower(i)])
		while #tRemove[string.lower(i)] > 1 do
			table.remove(tRemove[string.lower(i)], #tRemove[string.lower(i)])
		end
	end
	for i, v in pairs(tConvert) do
		if tRemove[string.lower(i)] then
			if tRemove[string.lower(i)][1] < v.Julian then tConvert[i] = nil end
		end
	end
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