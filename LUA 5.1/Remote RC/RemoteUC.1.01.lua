--[[

	Remote UserCommands 1.01 - LUA 5.0/5.1 by jiten (8/6/2006)

	Requested by: Juelz

	DESCRIPTION:
	¯¯¯¯¯¯¯¯¯¯¯¯
	- Remotely enable/disable custom user commands

	CHANGELOG:
	¯¯¯¯¯¯¯¯¯¯
	- Changed: UserCommands are sent per profile - similar to Mutor's PxCommands' method - requested by Juelz;
	- Added: Missing NewUserConnected and OpConnected function;
	- Changed: Some code bits;
	- Added: Some comments to the code.

]]--

tSettings = {
	-- Bot Name
	sBot = frmHub:GetHubBotName(),
	-- UserCommand Users' database
	fRC = "tRC.tbl",
	-- RightClick Menu
	sMenu = "Menu"
}

tRC = {}

Main = function()
	-- Load DB content
	if loadfile(tSettings.fRC) then dofile(tSettings.fRC) end
end

ChatArrival = function(user, data)
	-- Parse command
	local _,_, cmd = string.find(data, "^%b<>%s+%!(%S+).*|$")
	-- Return function content if table contains cmd
	if cmd and tCommands[cmd] then return tCommands[cmd](user, data), 1 end
end

NewUserConnected = function(user)
	-- If enabled, send
	if tRC[string.lower(user.sName)] then SendRC(user) end
end

OpConnected = NewUserConnected

tCommands = {
	clicker = function(user, data)
		-- If registered user
		if user.bRegistered then
			-- Parse arg
			local _,_, arg = string.find(data, "^%b<>%s+%S+%s+(%S+)|$")
			-- Exists
			if arg then
				if string.lower(arg) == "on" then
					-- Already enabled
					if tRC[string.lower(user.sName)] then
						user:SendData(tSettings.sBot, "*** Error: You have already enabled your personal User Commands.")
					else
						-- Add and save
						tRC[string.lower(user.sName)] = 1; SaveToFile(tSettings.fRC, tRC, "tRC"); SendRC(user)
						user:SendData(tSettings.sBot, "*** Your personal User Commands have been enabled!")
					end
				elseif string.lower(arg) == "off" then
					-- Already enabled
					if tRC[string.lower(user.sName)] then
						-- Delete, save and clear UserCommands
						tRC[string.lower(user.sName)] = nil; SaveToFile(tSettings.fRC, tRC, "tRC")
						user:SendData("$UserCommand 255 3")
						user:SendData(tSettings.sBot, "*** Your personal User Commands have been disabled!")
					else
						user:SendData(tSettings.sBot, "*** Error: You haven't enabled your personal User Commands!")
					end
				else
					user:SendData(tSettings.sBot, "*** Syntax Error: The only options available for !clicker are <on/off>")
				end
			else
				user:SendData(tSettings.sBot, "*** Syntax Error: Type !clicker <on/off>")
			end
		else
			user:SendData(tSettings.sBot, "*** Error: Register yourself to enable your User Commands!")
		end
	end,
	viewclicker = function(user)
		-- UserCommands' table isn't empty
		if next(tRC) then
			-- Header
			local tmp  = "\r\n\r\n\tRightClick-Enabled Users:\r\n\t"..string.rep("-", 45).."\r\n" 
			-- Populate with users
			for i,v in pairs(tRC) do
				tmp = tmp.."\t•  "..string.upper(string.sub(i, 1, 1))..string.sub(i, 2, string.len(i)).."\r\n" 
			end 
			-- Send
			user:SendData(tSettings.sBot, tmp)
		else
			user:SendData(tSettings.sBot, "*** Error: There are no RightClick-Enabled Users!")
		end
	end,
}

SendRC = function(user)
	local tCommands = {
--[[
		[Profile Number] = {

			Command: !kick <nick> <reason>
			
			Structure: { "Command description", "!command", " %[line:fields]" }
			NOTE: If there are no fields, leave it like this: ""

			Code: { "Kick a user", "!kick", " %[line:Nick] %[line:Reason]" }
		}
]]
		-- Master's UserCommands
		[0] = {
			{ "Enable/Disable UserCommands", "!clicker", " %[line:<on/off>]" },
			{ "List UserCommand-Enabled Users", "!viewclicker", "" },
		},
		-- Operator's UserCommands
		[1] = {

		},
		-- VIP's UserCommands
		[2] = {

		},
		-- Reg's UserCommands
		[3] = {

		},
	}
	-- tCommand contains the profile
	if tCommands[user.iProfile] then
		-- Loop through profile's sub-table
		for i, v in ipairs(tCommands[user.iProfile]) do
			-- Send
			user:SendData("$UserCommand 1 3 "..tSettings.sMenu.."\\"..v[1].."$<%[mynick]> "..v[2]..v[3].."&#124;")
		end
	end
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