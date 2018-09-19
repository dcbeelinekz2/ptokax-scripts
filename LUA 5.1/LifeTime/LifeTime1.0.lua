--[[

	LifeTime Bot 1.0 - LUA 5.0/5.1 version by jiten
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

	DESCRIPTION:

	- Get Hub's current uptime;
	- Determine how old is the hub
]]--

tSettings = {

	-- Bot Name
	sBot = frmHub:GetHubBotName(),

	-- RightClick Menu
	sMenu = "LifeTime",

	-- Hub's 'birth' date
	iSetup = {
		year = 2006,
		month = 3,
		day = 28,
		hour = 21,
		min = 00,
		sec = 00
	},
}

ChatArrival = function(user, data)
	local _,_, to = string.find(data, "^$To:%s(%S+)%s+From:")
	local _,_, msg = string.find(data, "%b<>%s(.*)|$") 
	-- Message sent to Bot or in Main
	if (to and to == tSettings.sBot) or not to then
		-- Parse command
		local _,_, cmd = string.find(msg, "^%p(%S+)")
		-- Exists
		if cmd and tCommands[string.lower(cmd)] then
			cmd = string.lower(cmd)
			-- If user has permission
			if tCommands[cmd].tLevels[user.iProfile] and tCommands[cmd].tLevels[user.iProfile] == 1 then
				return tCommands[cmd].fFunction(user, msg), 1
			else
				return user:SendData(tSettings.sBot, "*** Error: You are not allowed to use this command!"), 1
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
			-- If member
			if v.tLevels[user.iProfile] then
				-- Send
				user:SendData("$UserCommand 1 3 "..tSettings.sMenu.."\\"..v.tRC[1]..
				"$<%[mynick]> !"..i..v.tRC[2].."&#124;")
			end
		end
	end
	user:SendData(tSettings.sBot, "*** Welcome to "..(frmHub:GetHubName() or "Unknown").."!"); tCommands["lifetime"].fFunction(user)
end

OpConnected = NewUserConnected

tCommands = {
	lifetime = {
		fFunction = function(user)
			local iDiff = os.difftime( os.time(os.date("!*t")), os.time(tSettings.iSetup))
			if iDiff > 0 then
				user:SendData(tSettings.sBot, "*** This hub is "..
				SecondsToTime(iDiff).." old and current uptime is "..SecondsToTime(frmHub:GetUpTime(), true).."!")
			else
				user:SendData(tSettings.sBot, "*** Error: You must enter a valid Hub Birthday!")
			end
		end,
		tLevels = {
			[-1] = 0, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		tRC = { "Show hub's age and uptime", "" }
	},
}

SecondsToTime = function(iTime, bSmall)
	-- Build table with time fields
	local T = os.date("!*t", tonumber(iTime)); 
	-- Format to string
	local sTime = string.format("%i month(s), %i day(s), %i hour(s), %i minute(s)", T.month-1, T.day-1, T.hour, T.min)
	-- Small stat?
	if bSmall then
		-- For each digit
		for i in string.gfind(sTime, "%d+") do
			-- Reduce if is preceeded by 0
			if tonumber(i) == 0 then sTime = string.gsub(sTime, "^"..i.."%s(%S+),%s", "") end
		end
	end
	-- Return
	return sTime
end