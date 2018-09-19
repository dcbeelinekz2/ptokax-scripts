--[[ 

	Birthday Man 3.x - 4.x DB Converter by jiten (4/13/2006)

	Requested by: TïMê†råVêlléR
	
	1. Place your old birthdays.tbl under your scripts' folder;
	2. Run this script and the new file "tBirthday.tbl" will appear in the same folder;
	3. And that's it!

]]--

tConvert = {}

Main = function()
	local tmp; dofile("birthdays.tbl")
	for i,v in pairs(tBirthdays) do
		if v[3] < 1970 then tmp = 1970 - v[3]; v[3] = 1970 else tmp = 0 end
		local tTable = { day = v[1], month = v[2], year = v[3] }
		tConvert[i] = { iJulian = os.time(tTable), iAdjust = tmp }
	end
	local hFile = io.open("tBirthday.tbl","w+") Serialize(tConvert,"tBirthday",hFile); hFile:close() 
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