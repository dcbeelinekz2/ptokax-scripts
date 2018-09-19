--[[

	Main Censor 1.0 LUA 5.1 (3/23/2006)
	By jiten

]]--

tSettings = {
	sBot = frmHub:GetHubBotName(),
	fCensor = "tCensor.tbl", tCensor = {}, tLevels = {},
	sSetup = "mainchat", sList = "list",
}

Main = function()
	if loadfile(tSettings.fCensor) then dofile(tSettings.fCensor) end
	for a,b in pairs(GetProfiles()) do
		tSettings.tLevels[a] = b
	end
	tSettings.tLevels[-1] = "Unreg"; tSettings.tLevels["unreg"] = -1
end

ChatArrival = function(user,data)
	local tmp = tSettings.tCensor[user.iProfile]
	if tmp and tmp == 1 then
		return user:SendData(tSettings.sBot,"*** Your profile is not allowed to talk in Main Chat!"), 1
	else
		local s,e,cmd = string.find(data,"^%b<>%s+[%!%+](%S+).*|$")
		-- If cmd and tCmds contains it
		if cmd then
			-- Lower it
			cmd = string.lower(cmd)
			-- If user is allowed to use
			if tCmds[cmd].tLevels[user.iProfile] then
				return tCmds[cmd].tFunc(user,data), 1
			else
				return user:SendData(tSettings.sBot,"*** Error: You are not allowed to use this command."), 1
			end
		end
	end
end

NewUserConnected = function(user)
	for i,v in pairs(tCmds) do
		if v.tLevels[user.iProfile] then user:SendData("$UserCommand 1 3 Main Censor\\"..v.tRC.."&#124;") end
	end
end

OpConnected = NewUserConnected

tCmds = {
	[tSettings.sSetup] = {
		tFunc = function(user,data)
			local s,e,profile,flag = string.find(data,"^%b<>%s+%S+%s+(%S+)%s+(%S+).*|$") 
			if profile and flag then
				local tmp; tmp = tonumber(profile) or GetProfileIdx(profile)
				if string.lower(profile) == "unreg" then tmp = -1 end; flag = string.lower(flag)
				if tSettings.tLevels[tmp] then 
					local tSetup = {
						["on"] = function()
							tSettings.tCensor[tmp] = 1; OnExit()
							user:SendData(tSettings.sBot,"*** Main Chat has been blocked for "..profile.."!")
						end,
						["off"] = function()
							tSettings.tCensor[tmp] = 0; OnExit()
							user:SendData(tSettings.sBot,"*** Main Chat has been enabled for "..profile.."!")
						end,
					}
					if tSetup[flag] then 
						tSetup[flag]()
					else
						user:SendData(tSettings.sBot,"*** Error: The flag should be <on/off>")
					end
				else
					user:SendData(tSettings.sBot,"*** Error: "..profile.." doesn´t exist!")
				end
			else
				user:SendData(tSettings.sBot,"*** Syntax Error: Type !"..tSettings.sSetup.." <Profile ID/Name> <on/off>")
			end
		end,
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRC = "Enable/Disable$<%[mynick]> !"..tSettings.sSetup.." %[line:Profile ID or Name] %[line:on/off]"
	},
	[tSettings.sList] = {
		tFunc = function(user)
			if next(tSettings.tCensor) then
				local sMsg = "\r\n\r\n".."\t"..string.rep("- -",20).."\r\n\t\tBlocked Profiles List:\r\n\t"..
				string.rep("- -",20).."\r\n"
				for i,v in pairs(tSettings.tCensor) do
					local tmp = "*unblocked*"; if tonumber(v) == 1 then tmp = "*blocked*" end
					sMsg = sMsg.."\r\n\t• "..(GetProfileName(i) or "Unreg").."\t "..tmp
				end
				user:SendData(tSettings.sBot,sMsg)
			else
				user:SendData(tSettings.sBot,"*** Error: Main Block list is empty!")
			end
		end,
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRC = "List Blocked Profiles$<%[mynick]> !"..tSettings.sList
	}
}

OnExit = function()
	local hFile = io.open(tSettings.fCensor,"w+") Serialize(tSettings.tCensor,"tSettings.tCensor",hFile); hFile:close()
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