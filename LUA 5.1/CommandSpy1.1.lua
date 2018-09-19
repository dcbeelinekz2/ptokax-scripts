--[[

	Command Spy 1.1 LUA 5.1
	
	by jiten (3/18/2006)

	Changelog:
	
	- Changed: Script will only search for ! and + (thanks TT)
	- Fixed: Missing () in GetProfileName

]]--

Settings = {
	sBot = frmHub:GetHubBotName(),
	fSpy = "Notify.tbl",
	tSpy = {}
}

Main = function()
	if loadfile(Settings.fSpy) then dofile(Settings.fSpy) end
end

ChatArrival = function(user,data)
	local s,e,msg = string.find(data,"^%b<>%s+([%!%+].*)|$")
	-- Command Spy related
	if msg then return ParseCommands(user,msg) end
end

ToArrival = function(user,data)
	local s,e,to,msg = string.find(data, "^%$To:%s+(%S+)%s+From:%s+%S+%s-%$%b<>%s+([%!%+].*)|$")
	if to == Settings.sBot and msg then return ParseCommands(user, msg) end
end

ParseCommands = function(user, data)
	for i,v in pairs(Settings.tSpy) do
		local nick = GetItemByName(i)
		if nick then
			nick:SendPM(Settings.sBot,os.date("%x %X").." - "..(GetProfileName(GetUserProfile(user.sName)) or "User").." "..user.sName.." used command: "..data)
		end
	end
	local s,e,cmd = string.find(data,"^%p(%S+)")
	tCmds = { 
		-- Start: Command Spy Command
		["cmdspy"] = {
			tFunc = function(user,data)
				local s,e,flag = string.find(data,"%S+%s+(%S+)")
				if flag then
					flag = string.lower(flag)
					local tTable = {
						["on"] = function()
							if Settings.tSpy[user.sName] then
								user:SendData(Settings.sBot,"*** Command Spy is already enabled for you!")
							else
								Settings.tSpy[user.sName] = 1
								user:SendData(Settings.sBot,"*** Command Spy is now enabled for you.")
							end
						end,
						["off"] = function()
							if Settings.tSpy[user.sName] then
								Settings.tSpy[user.sName] = nil
								user:SendData(Settings.sBot,"*** Command Spy is now disabled for you!")
							else
								user:SendData(Settings.sBot,"*** Command Spy is already disabled for you!.")
							end
						end
					}
					if tTable[flag] then
						tTable[flag]()
					else
						user:SendData(Settings.sBot,"*** Usage: !cmdspy <on/off>")
					end
				end
			end,
			tLevels = {
				[0] = 1,
				[5] = 1,
			},
		},
	}
	if cmd and tCmds[string.lower(cmd)] then
		cmd = string.lower(cmd)
		if tCmds[cmd].tLevels[user.iProfile] then
			return tCmds[cmd].tFunc(user,data), 1
		else
			return user:SendData(Settings.sBot,"*** Error: You are not allowed to use this command."), 1
		end
	end
end

OnExit = function()
	local hFile = io.open(Settings.fSpy,"w+") Serialize(Settings.tSpy,"Settings.tSpy",hFile); hFile:close()
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