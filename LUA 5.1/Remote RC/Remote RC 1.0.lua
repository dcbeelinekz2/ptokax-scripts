--[[

	Remote UserCommands 1.0 - LUA 5.0/5.1 by jiten (8/6/2006)

	Requested by: Juelz

	DESCRIPTION:
	¯¯¯¯¯¯¯¯¯¯¯¯
	- Remotely enable/disable custom user commands

]]--

sBot = frmHub:GetHubBotName()
tRC = {}; fRC = "tRC.tbl"

Main = function()
	if loadfile(fRC) then dofile(fRC) end
end

ChatArrival = function(user, data)
	local _,_, cmd = string.find(data, "^%b<>%s+%!(%S+).*|$")
	if cmd and tCommands[cmd] then return tCommands[cmd](user, data), 1 end
end

tCommands = {
	clicker = function(user, data)
		if user.bRegistered then
			local _,_, arg = string.find(data, "^%b<>%s+%S+%s+(%S+)|$")
			if arg then
				if string.lower(arg) == "on" then
					if tRC[user.sName] then
						user:SendData(sBot, "*** Error: You have already enabled your personal User Commands.")
					else
						tRC[user.sName] = 1; SaveToFile(fRC, tRC, "tRC"); SendRC(user)
						user:SendData(sBot, "*** Your personal User Commands have been enabled!")
					end
				elseif string.lower(arg) == "off" then
					if tRC[user.sName] then
						tRC[user.sName] = nil; SaveToFile(fRC, tRC, "tRC")
						user:SendData("$UserCommand 255 3")
						user:SendData(sBot, "*** Your personal User Commands have been disabled!")
					else
						user:SendData(sBot, "*** Error: You haven't enabled your personal User Commands!")
					end
				else
					user:SendData(sBot, "*** Syntax Error: Type !clicker <on/off>")
				end
			else
				user:SendData(sBot, "*** Syntax Error: Type !clicker <on/off>")
			end
		else
			user:SendData(sBot, "*** Error: Register yourself to enable your User Commands!")
		end
	end,
	viewclicker = function(user)
		if next(tRC) then
			local tmp  = "\r\n\r\n\tRightClick-Enabled Users:\r\n\t"..string.rep("-", 45).."\r\n" 
			for i,v in pairs(tRC) do
				tmp = tmp.."\t•  "..i.."\r\n" 
			end 
			user:SendData(sBot, tmp)
		else
			user:SendData(sBot, "*** Error: There are no RightClick-Enabled Users!")
		end
	end,
}

SendRC = function(user)
	user:SendData("$UserCommand 1 3 Menu\\Help$<%[mynick]> !help&#124;")
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

SaveToFile = function(file, table, tablename)
	local hFile = io.open(file, "w+") Serialize(table, tablename, hFile); hFile:close() 
end