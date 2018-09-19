--/--------------------------------------------------------
--Optimized and debugged by jiten (5/20/2005)
--/--------------------------------------------------------
--Chat History On Entry 1.02 LUA 5
--By Mutor The Ugly     4/14/04

--Based on a script by Tezlo     1/17/04
--Send chat history to PM on entry
--
-- +Converted to LUA 5 2/22/05
--/--------------------------------------------------------
cFile = "cHistory.dat"
mHistory = 20  -- maximum lines of chat to cache
sBot = "[Historian]"
BadChars = {".","?","!","+","-",}   --disallow command prefixes
cHistory = {}

Main = function ()
	if loadfile(cFile) then dofile(cFile) end frmHub:RegBot(sBot)
end

OnExit = function()
	if next(cHistory) then local hFile = io.open(cFile,"w+") Serialize(cHistory,"cHistory",hFile); hFile:close() end
end

NewUserConnected = function(user)
	local str = "\r\n\t<----------------------------------------------------------------------[ Last ( "..table.getn(cHistory).." ) chat messages ]----------->"
	for i = 1, table.getn(cHistory) do str = str.."\r\n\t"..cHistory[i] end
	str = str.."\r\n\t<--------------------------------------------------------------------------[ End of chat history ]--------------->"
	user:SendPM(sBot,str)
end

OpConnected = NewUserConnected

ChatArrival = function(user, data)
	local s,e,pre = string.find(data, "^%b<> (.)") local when = os.date("[%H:%M] ") local chat = string.sub(data, 1, -2)
	for k,v in BadChars do if pre == v then return end end -- disallow command input to cached chat
	table.insert(cHistory,when..chat) if table.getn(cHistory) > mHistory then table.remove(cHistory, 1) end OnExit()
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