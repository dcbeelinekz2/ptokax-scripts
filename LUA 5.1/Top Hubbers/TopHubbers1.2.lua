--[[

	TopHubbers 1.2 - LUA 5.0/5.1 by jiten

	Based on OnHub Time Logger 1.65 by chill and Robocop's layout 

	Usage: !tophubbers; !tophubbers x-y

	Fixed: Typo in table.sort function;
	Added: OnExit (3/21/2006)
	Fixed: Missing pairs() in SaveToFile
	Changed: Removed iGlobalTime and added TotalTime count to OnTimer
	Changed: SecondsToTime function values (3/24/2006)
	Changed: math.floor/mod in TopHubbers' function; (3/5/2006)
	Changed: SecondsToTime month value (4/17/2006);
	Added: !hubtime <nick> - requested by speedX;
	Changed: SecondsToTime function and small code bits (8/16/2006)

]]--

sBot = frmHub:GetHubBotName()
fOnline = "tOnliners.tbl"
tOnline = {}

Main = function()
	if loadfile(fOnline) then dofile(fOnline) end
	SetTimer(60*1000) StartTimer()
end 

OnTimer = function()
	for i, v in pairs(tOnline) do
		if GetItemByName(i) then
			v.iSessionTime = v.iSessionTime + 1; v.iTotalTime = v.iTotalTime + 1
		end
	end
end

OnExit = function()
	SaveToFile(fOnline, tOnline, "tOnline")
end

NewUserConnected = function(user)
	if user.bRegistered then
		if tOnline[user.sName] then
			tOnline[user.sName].iSessionTime = 0; tOnline[user.sName].sEnter = os.date()
		else
			tOnline[user.sName] = { sEnter = os.date(), iSessionTime = 0, iTotalTime = 0, sLeave = os.date() }
		end
	end
end

OpConnected = NewUserConnected

UserDisconnected = function(user)
	if user.bRegistered and tOnline[user.sName] then
		tOnline[user.sName].iSessionTime = 0; tOnline[user.sName].sLeave = os.date()
	end
end

OpDisconnected = UserDisconnected

ChatArrival = function(user,data)
	local _,_, cmd = string.find(data,"^%b<>%s+%!(%S+).*|$")
	if cmd and tCmds[string.lower(cmd)] then
		cmd = string.lower(cmd)
		if tCmds[cmd].tLevels[user.iProfile] then
			return tCmds[cmd].fFunction(user, data),1
		else
			return user:SendData(sBot, "*** Error: You are not allowed to use this command!"),1
		end
	end
end

tCmds = {
	tophubbers = {
		fFunction = function(user, data)
			if next(tOnline) then
				local _,_, iStart, iEnd = string.find(data, "^%b<>%s+%S+%s+(%d+)%-(%d+)|$")
				iStart, iEnd = (iStart or 1), (iEnd or 20)
				local tCopy, msg = {}, "\r\n\t"..string.rep("=", 105).."\r\n\tNr.  Total:\t\t\t\t\tSession:\t"..
				"Entered Hub:\tLeft Hub:\t\tStatus:\tName:\r\n\t"..string.rep("-", 210).."\r\n"
				for i, v in pairs(tOnline) do
					table.insert(tCopy, { sEnter = v.sEnter, iSessionTime = tonumber(v.iSessionTime), 
					iTotalTime = tonumber(v.iTotalTime), sLeave = v.sLeave, sNick = i } )
				end
				table.sort(tCopy, function(a, b) return (a.iTotalTime > b.iTotalTime) end)
				for i, v in pairs(tCopy) do
					local sStatus = "*Offline*"; 
					if GetItemByName(v.sNick) then sStatus = "*Online*" end
					msg = msg.."\t"..i..".    "..SecondsToTime(v.iTotalTime*60).."\t"..
					v.iSessionTime.." min\t"..v.sEnter.."\t"..v.sLeave.."\t"..sStatus.."\t"..v.sNick.."\r\n"
				end
				msg = msg.."\t"..string.rep("-", 210)
				user:SendPM(sBot, "Current Top Hubbers:\r\n"..msg.."\r\n")
			else
				user:SendData(sBot, "*** Error: Top Hubbers' table is currently empty!")
			end
		end,
		tLevels = {
			[-1] = 0, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
	},
	hubtime = {
		fFunction = function(user, data)
			local _,_, nick = string.find(data, "^%b<>%s+%S+%s+(%S+)|$")
			if nick then 
				if tOnline[nick] then
					user:SendData(sBot, "*** "..nick.."'s Total uptime: "..
					SecondsToTime(tOnline[nick].iTotalTime*60, true).."; Daily average uptime: "..
					SecondsToTime(tOnline[nick].iTotalTime/(24*60), true))
				else
					user:SendData(sBot, "*** Error: No record found for '"..nick.."'!")
				end
			else
				user:SendData(sBot, "*** Syntax Error: Type !hubtime <nick>")
			end
		end,
		tLevels = { 
			[0] = 1, [1] = 1, [4] = 1, [5] = 1,
		},
	},
}

SecondsToTime = function(iSeconds, bSmall)
	local T = os.date("!*t", tonumber(iSeconds)); string.gfind = (string.gfind or string.gmatch)
	local sTime = string.format("%i month(s), %i day(s), %i hour(s), %i minute(s)", T.month-1, T.day-1, T.hour, T.min)
	if bSmall then
		for i in string.gfind(sTime, "%d+") do
			if tonumber(i) == 0 then sTime = string.gsub(sTime, "^"..i.."%s(%S+),%s", "") end
		end
	end
	return sTime
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