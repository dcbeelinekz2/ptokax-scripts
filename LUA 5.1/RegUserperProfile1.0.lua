--[[

	Registered Users per Profile - LUA 5.0/5.1 by jiten (8/9/2006)

]]--

tSettings = {
	-- Bot Name
	sName = frmHub:GetHubBotName(),

	-- Command Name
	sCommand = "showreg",

	-- RightClick Menu
	sMenu = "Menu"
}

ChatArrival = function(user, data)
	local _,_, to = string.find(data,"^$To:%s(%S+)%sFrom:")
	local _,_, msg = string.find(data,"%b<>%s(.*)|$") 
	-- Message sent to Bot or in Main
	if (to and to == tSettings.sName) or not to then
		-- Parse command
		local _,_, cmd = string.find(msg, "^%p(%S+)")
		-- Exists
		if cmd and tCommands[string.lower(cmd)] then
			cmd = string.lower(cmd)
			-- If user has permission
			if tCommands[cmd].tLevels[user.iProfile] then
				return tCommands[cmd].fFunction(user, msg), 1
			else
				return user:SendData(tSettings.sName, "*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

ToArrival = ChatArrival

NewUserConnected = function(user)
	-- Supports UserCommands
	if user.bUserCommand then
		-- For each entry in table
		for i, v in pairs(tCommands) do
			-- If has permission
			if v.tLevels[user.iProfile] then
				-- Send
				user:SendData("$UserCommand 1 3 "..tSettings.sMenu.."\\"..v.tRC[1]..
				"$<%[mynick]> !"..i..v.tRC[2].."&#124;")
			end
		end
	end
end

OpConnected = NewUserConnected

tCommands = {
	[tSettings.sCommand] = {
		fFunction = function(user, data)
			-- Search for profile
			local _,_, profile = string.find(data, "^%S+%s(%S+)$")
			-- Exists
			if profile then
				-- Temporary table
				local tProfiles = {}
				-- Loop through profiles
				for i, v in ipairs(GetProfiles()) do
					-- Add to custom table
					tProfiles[string.lower(v)] = GetProfileIdx(v)
				end
				-- Profile Exists
				if tProfiles[string.lower(profile)] then
					-- Header
					local sMsg, n = "\r\n\r\n\t"..string.rep("=", 35).."\r\n\t\tUsers by Profile - "..
					GetProfileName(tProfiles[string.lower(profile)])..":\r\n\t"..string.rep("-", 70).."\r\n\t", 0
					-- Loop through registered users
					for i, v in ipairs(frmHub:GetRegisteredUsers()) do
						local sStatus = "off"
						-- Look for users with same profile
						if v.iProfile == GetProfileIdx(profile) then
							-- Sum + If online
							n = n + 1; if GetItemByName(v.sNick) then sStatus = "on" end
							-- Add content
							sMsg = sMsg.."\t"..n..". ["..sStatus.."line] "..v.sNick.."\r\n\t"
						end
					end
					-- Send
					user:SendData(tSettings.sName, sMsg)
				else
					user:SendData(tSettings.sName, "*** Error: There isn't such profile!")
				end
			else
				user:SendData(tSettings.sName, "*** Syntax Error: !"..tSettings.sCommand.." <profile name>")
			end
		end,
		tLevels = { [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, },
		tRC = { "Show registered Users", " %[line:Profile Name]" },
	},
}