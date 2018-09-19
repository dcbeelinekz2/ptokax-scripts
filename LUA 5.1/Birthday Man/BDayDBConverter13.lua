--[[ 

	Birthday Man 4.01-04 to 4.05 DB Converter by jiten (6/19/2006)

	Requested by: TïMê†råVêlléR

	Changelog:

	- Fixed: Birthday is counted from midnight (6/19/2006)

	1. Place your old tBirthday.tbl under your scripts' folder;
	2. Run this script and the new file "tBirthday(new).tbl" will appear in the same folder;
	3. Backup your old DB (just in case) and rename the new one to the default format.
	4. And that's it!

]]--

tConvert = {}

Main = function()
	local tmp; dofile("tBirthday.tbl")
	for i,v in pairs(tBirthday) do
		local T = os.date("!*t", v.iJulian)
		local tTable = { day = T.day, month = T.month, year = T.year, hour = 0, min = 0, sec = 0 }
		tConvert[i] = { sNick = v.sNick, iJulian = os.time(tTable), iAdjust = v.iAdjust}
	end
	local hFile = io.open("tBirthday(new).tbl","w+") Serialize(tConvert, "tBirthday", hFile); hFile:close() 
end

Serialize = function(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in pairs(tTable) do
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