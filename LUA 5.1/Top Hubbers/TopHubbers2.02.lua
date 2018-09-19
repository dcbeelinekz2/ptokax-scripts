--[[

	TopHubbers 2.02 - LUA 5.0/5.1 by jiten
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	Based on: OnHub Time Logger 1.65 by chill and Robocop's layout

	Usage: !tophubbers; !tophubbers x-y; !hubtime <nick>; !myhubtime

	CHANGELOG:
	¯¯¯¯¯¯¯¯¯¯
	Fixed: Typo in table.sort function;
	Added: OnExit (3/21/2006)
	Fixed: Missing pairs() in SaveToFile
	Changed: Removed iGlobalTime and added TotalTime count to OnTimer
	Changed: SecondsToTime function values (3/24/2006)
	Changed: math.floor/mod in TopHubbers' function; (3/5/2006)
	Changed: SecondsToTime month value (4/17/2006);
	Added: !hubtime <nick> - requested by speedX;
	Changed: SecondsToTime function and small code bits (8/16/2006)
	Changed: Table indexes;
	Changed: SecondsToTime function to MinutesToTime;
	Fixed: Inaccurate average uptime stuff (8/17/2006)
	Changed: Average uptime function;
	Changed: Session time for offline users doesn't get reset;
	Added: Average uptime warning on connect - requested by speedX (8/20/2006)
	Added: Customized profiles - requested by Naithif (8/20/2006)
	Added: User Commands - requested by TT;
	Added: Rankings and related commands [!myrank & !topranks] - requested by speedX;
	Added: Toggle rank info on connect - requested by TT;
	Fixed: !tophubbers x-y;
	Added: Comments to the code;
	Changed: Some code bits;
	Added: Toggle between total and average uptime (8/24/2006)
	Fixed: Minimum average uptime warning - reported by speedX;
	Added: Maximum shown hubbers - requested by Naithif (8/29/2006)
	Fixed: LUA 5.0/5.1 compatibility - reported by speedX (11/8/2006)
	Added: string.lower check - requested by SwapY and speedX (11/10/2006)

]]--

tSettings = {
	-- Bot Name
	sBot = frmHub:GetHubBotName(),

	-- Top Hubbers' DB
	fOnline = "tOnliners.tbl",

	-- RightClick Menu
	sMenu = "Top Hubbers",

	-- Maximum hubbers to show when using !tophubbers
	iMax = 20,

	-- Send message to users with lower than specified Average uptime (AUT) [true = on; false = off]
	bWarning = false,
	-- Minimum Average uptime (hours) that triggers the warning
	iAUT = 1,

	-- Send hubtime stats on connect [true = on; false = off]
	bRankOnConnect = false,

	-- Profiles checked [0 = off; 1 = on]
	tProfiles = { [-1] = 0, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1 },

	-- Ranks criteria ["average" = Average total uptime; "total" = Total uptime]
	sCriteria = "total",

	-- Ranks
	tRanks = { 
--[[		
		
		The ranks must be added in ascending order [from the lowest to the highest]

		{ "Rank", [time][string] }

		[time] must be 1 or more digit(s)
		[string] must be: s = second; m = minute; h = hour; D = day; W = week; M = month; Y = year

		Example: { "God", "1M, 2D, 10s" } 
		Meaning: To become a God, your total uptime must be equal or higher than 1 month, 2 days and 10 seconds
]]--

		-- Total uptime rank table
		total = {
			{ "Newbie", "1D, 1h, 1m, 1s" }, { "Member", "2D" }, { "Cool Member", "5D" }, 
			{ "Hub As", "10D" }, { "Smart As", "20D" }, { "Double As", "1M" }, 
			{ "Triple As", "2M" }, { "Conqueror", "3M" }, { "Viking", "4M" }, 
			{ "King", "6M" }, { "Emperor", "8M" }, { "Hub Legend", "10M" }, 
			{ "Hub God", "11M" }, { "God", "1Y, 1h, 1m, 1s" }
		},

		-- Daily average uptime rank table
		average = { 
			{ "Newbie", "1h" }, { "Member", "6h" }, { "Cool Member", "12h" }, 
			{ "Hub-As", "1D" }, { "Smart As", "5D" }, { "Double-As", "15D" }, 
			{ "Triple-As", "1M" }, { "Conqueror", "2M" }, { "Viking", "3M" }, 
			{ "King", "4M" }, { "Emperor", "6M" }, { "Hub Legend", "9M" }, 
			{ "Hub God", "11M" }, { "God", "1Y" }
		}
	}
}

tOnline = {}

Main = function()
	-- Register BotName if not registered
	if tSettings.sBot ~= frmHub:GetHubBotName() then frmHub:RegBot(tSettings.sBot) end
	-- Load DB content
	if loadfile(tSettings.fOnline) then dofile(tSettings.fOnline) end
	-- LUA 5.0/5.1 compatibility; Set and Start Timer
	string.gmatch = (string.gmatch or string.gfind); SetTimer(60*1000); StartTimer()
end 

OnTimer = function()
	-- For each hubber
	for i, v in pairs(tOnline) do
		-- Online
		if GetItemByName(i) then
			-- Sum
			v.SessionTime = v.SessionTime + 1; v.TotalTime = v.TotalTime + 1
		end
	end
end

OnExit = function()
	-- Save
	local hFile = io.open(tSettings.fOnline, "w+") Serialize(tOnline, "tOnline", hFile); hFile:close()
end

NewUserConnected = function(user)
	-- If profile has permission to be logged
	if tSettings.tProfiles[user.iProfile] and tSettings.tProfiles[user.iProfile] == 1 then
		local tNick = GetOnliner(user.sName)
		-- User already in DB
		if tNick then
			-- Warning on connect
			if tSettings.bWarning then
				-- Days since first login
				local iAverage = os.difftime(os.time(os.date("!*t")), tNick.Julian)/(60*60*24)
				if iAverage < 1 then iAverage = 1 end
				-- Less than allowed
				if tNick.TotalTime/iAverage < tSettings.iAUT*60 then 
					-- Warn
					user:SendPM(tSettings.sBot, "*** Your Average uptime (AUT) is less than "..tSettings.iAUT..
					" hour(s). We are planning to impose restrictions to users with and AUT lower than the allowed!")
				end
			end
			-- Reset and save time
			tNick.SessionTime = 0; tNick.Enter = os.date()
			-- Send rank info on connect
			if tSettings.bRankOnConnect then tCommands["myhubtime"].fFunction(user) end
		else
			-- Create new entry
			tOnline[user.sName] = { Julian = os.time(os.date("!*t")), Enter = os.date(), SessionTime = 0, TotalTime = 0, Leave = os.date() }
		end
	end
	-- Supports UserCommands
	if user.bUserCommand then
		-- For each entry in table
		for i, v in pairs(tCommands) do
			-- If member
			if v.tLevels[user.iProfile] then
				-- For each type
				for n in ipairs(v.tRC) do
					-- Send
					user:SendData("$UserCommand 1 3 "..tSettings.sMenu.."\\"..v.tRC[n][1]..
					"$<%[mynick]> !"..i..v.tRC[n][2].."&#124;")
				end
			end
		end
	end
end

OpConnected = NewUserConnected

UserDisconnected = function(user)
	local tNick = GetOnliner(user.sName)
	-- If profile must be logged and user is in DB
	if tSettings.tProfiles[user.iProfile] and tSettings.tProfiles[user.iProfile] == 1 and tNick then
		-- Log date
		tNick.Leave = os.date()
	end
end

OpDisconnected = UserDisconnected

ChatArrival = function(user, data)
	local _,_, to = string.find(data, "^$To:%s(%S+)%s+From:")
	local _,_, msg = string.find(data, "%b<>%s(.*)|$") 
	-- Message sent to Bot or in Main
	if (to and to == tSettings.sBot) or not to then
		-- Parse command
		local _,_, cmd = string.find(msg, "^%p(%S+)")
		-- Exists
		if cmd and tCommands[string.lower(cmd)] then
			cmd, user.SendMessage = string.lower(cmd), user.SendData
			-- PM
			if to == tSettings.sBot then user.SendMessage = user.SendPM end
			-- If user has permission
			if tCommands[cmd].tLevels[user.iProfile] then
				return tCommands[cmd].fFunction(user, msg), 1
			else
				return user:SendMessage(tSettings.sBot, "*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

ToArrival = ChatArrival

tCommands = {
	tophubbers = {
		fFunction = function(user, data)
			-- Table isn't empty
			if next(tOnline) then
				-- Parse limits
				local _,_, iStart, iEnd = string.find(data, "^%S+%s+(%d+)%-(%d+)$")
				-- Set if not set
				iStart, iEnd = (iStart or 1), (iEnd or tSettings.iMax)
				-- Header
				local tCopy, msg = {}, "\r\n\t"..string.rep("=", 120).."\r\n\tNr.  Total:\t\t\t\t\tSession:\t"..
				"Entered Hub:\tLeft Hub:\t\tRank:\t\tStatus:\tName:\r\n\t"..string.rep("-", 240).."\r\n"
				-- Loop through hubbers
				for i, v in pairs(tOnline) do
					-- Insert stats to temp table
					table.insert(tCopy, { sEnter = v.Enter, iSessionTime = tonumber(v.SessionTime),
					iTotalTime = tonumber(v.TotalTime), sLeave = v.Leave, sNick = i, sRank = GetRank(i) } )
				end
				-- Sort by total time
				table.sort(tCopy, function(a, b) return (a.iTotalTime > b.iTotalTime) end)
				-- Loop through temp table
				for i = iStart, iEnd, 1 do
					-- i exists
					if tCopy[i] then
						-- Populate
						local sStatus, v = "*Offline*", tCopy[i]; local sRank = v.sRank
						if GetItemByName(v.sNick) then sStatus = "*Online*" end
						if string.len(v.sRank) < 9 then sRank = sRank.."\t" end
						msg = msg.."\t"..i..".    "..MinutesToTime(v.iTotalTime).."\t"..v.iSessionTime..
						" min\t"..v.sEnter.."\t"..v.sLeave.."\t"..sRank.."\t"..sStatus.."\t"..v.sNick.."\r\n"
					end
				end
				msg = msg.."\t"..string.rep("-", 240)
				-- Send
				user:SendPM(tSettings.sBot, "Current Top Hubbers:\r\n"..msg.."\r\n")
			else
				user:SendMessage(tSettings.sBot, "*** Error: Top Hubbers' table is currently empty!")
			end
		end,
		tLevels = {
			[-1] = 0, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		tRC = { { "Show Top "..tSettings.iMax.." hubbers", "" }, { "Show Top x-y Hubbers", " %[line:x-y]" } }
	},
	hubtime = {
		fFunction = function(user, data)
			-- Parse nick
			local _,_, nick = string.find(data, "^%S+%s+(%S+)$")
			-- Exists
			if nick then 
				-- Return
				BuildStats(user, nick)
			else
				user:SendMessage(tSettings.sBot, "*** Syntax Error: Type !hubtime <nick>")
			end
		end,
		tLevels = { 
			[0] = 1, [1] = 1, [4] = 1, [5] = 1,
		},
		tRC = { { "Show an user's stats", " %[line:Nick]" } }
	},
	myhubtime = {
		fFunction = function(user)
			-- Return
			BuildStats(user, user.sName)
		end,
		tLevels = { 
			[-1] = 0, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		tRC = { { "Show my stats", "" } }
	},
}

BuildStats = function(user, nick)
	local tNick = GetOnliner(nick)
	-- In DB
	if tNick then
		-- Average uptime in days
		local iAverage = os.difftime(os.time(os.date("!*t")), tNick.Julian)/(60*60*24)
		if iAverage < 1 then iAverage = 1 end
		-- Generate message
		local sMsg = "\r\n\r\n\t"..string.rep("=", 40).."\r\n\t\t\tStats:\r\n\t"..
		string.rep("-", 80).."\r\n\t- Nick: "..nick.."\r\n\t- Total uptime: "..
		MinutesToTime(tNick.TotalTime, true).."\r\n\t- Daily average uptime: "..
		MinutesToTime((tNick.TotalTime/iAverage), true).."\r\n\t- Current Rank: "..GetRank(nick).."\r\n"
		-- Send stats
		user:SendData(tSettings.sBot, sMsg)
	else
		user:SendMessage(tSettings.sBot, "*** Error: No record found for '"..nick.."'!")
	end
end

GetRank = function(nick)
	local tNick = GetOnliner(nick)
	if tNick then
		-- Custom time table
		local tTime, sRank, iAverage = { s = 1/60, m = 1, h = 60, D = 60*24, W = 60*24*7, M = 60*24*30, Y = 60*24*30*12 }, tSettings.tRanks[string.lower(tSettings.sCriteria)][1][1]
		-- Average enabled
		if tSettings.bAverage then
			-- Days since first login
			iAverage = os.difftime(os.time(os.date("!*t")), tNick.Julian)/(60*60*24)
			if iAverage < 1 then iAverage = 1 end
		end
		-- For each rank
		for n in ipairs(tSettings.tRanks[string.lower(tSettings.sCriteria)]) do
			local iTime = 0
			-- For each digit and time string
			for i, v in string.gmatch(tSettings.tRanks[string.lower(tSettings.sCriteria)][n][2], "(%d+)(%w)") do
				-- Process
				if i and tTime[v] then iTime = iTime + i*tTime[v] end
			end
			local iValue = tNick.TotalTime
			-- Average
			if tSettings.bAverage then iValue = iValue/iAverage end
			-- Process rank if user hasn't logged in for the first time today
			if os.date("%d%m%y", tNick.Julian) ~= os.date("%d%m%y") and iValue > iTime then
				sRank = tSettings.tRanks[string.lower(tSettings.sCriteria)][n][1]
			end
		end
		return sRank
	end
end

MinutesToTime = function(iSeconds, bSmall)
	-- Build table with time fields
	local T = os.date("!*t", tonumber(iSeconds*60)); 
	-- Format to string
	local sTime = string.format("%i month(s), %i day(s), %i hour(s), %i minute(s)", T.month-1, T.day-1, T.hour, T.min)
	-- Small stat?
	if bSmall then
		-- For each digit
		for i in string.gmatch(sTime, "%d+") do
			-- Reduce if is preceeded by 0
			if tonumber(i) == 0 then sTime = string.gsub(sTime, "^"..i.."%s(%S+),%s", "") end
		end
	end
	-- Return
	return sTime
end

GetOnliner = function(user)
	-- For each hubber
	for i, v in pairs(tOnline) do
		-- Compare
		if string.lower(i) == string.lower(user) then
			-- Return
			return tOnline[i]
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