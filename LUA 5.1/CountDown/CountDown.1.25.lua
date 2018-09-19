--[[

	CountDown Bot 1.25 - LUA 5.0/5.1 version by jiten and TiMeTrAVelleR

	Based on: Countdown bot by plop

	Changelog:

	Added: Customizable countdown;
	Changed: Small stuff;
	Added: RightClick (3/28/2006);
	Added: Start and Stop Timer (3/30/2006);
	Added: Customizable message (3/31/2006);
	Changed: !setmsg now parses all message (3/31/2006);
	Added: OnExit function (4/1/2006);
	Rewritten: All julian functions to os.*;
	Changed: Other small mods (4/9/2006);
	Added: bSend to define Timer status - reported by TT (4/13/2006)
	Changed: Sync() function - reported by TT (4/15/2006)
	Fixed: Hopefully TimeLeft() function (4/17/2006)
	Changed: !*t to *t;
	Changed: Settings table (6/5/2006)
	Added: month to string.format - reported by TT;
	Added: Leviathan profiles (9/30/2006)

]]--

-- Bot Name
sBot = "-TÓMÍﬂÙÜ-"
-- Timer DB
fTime = "tTime.tbl"
-- Send txt content to Main (true/false)
bSend = false
-- CountDown file to be shown
fCountDown = "happynewyear.txt"

-- After first setup, has to be changed with command
Settings = {
	-- First Timer for this bot
	iSetup = {
		year = 2006,
		month = 3,
		day = 28,
		hour = 21,
		min = 00,
		sec = 00
	},
	-- Custom message sent on timer
	sMsg = "LiVe SeT FroM TiMeTrAVelleR At: http://stream01.pcextreme.nl:8035/stream in",
	-- Timer Status
	bRun = false
}

Main = function()
	if loadfile(fTime) then dofile(fTime) end
	SetTimer(100 * 1000); if Settings.bRun then StartTimer(); Sync() end
	local tmp = TimeLeft(); if tmp then SendToAll(sBot,tmp) end;
end

ChatArrival = function(user, data) 
	local _,_, cmd = string.find(data,"^%b<>%s+[%!%+](%S+).*|$") 
	if cmd then
		if tCommands[string.lower(cmd)] then
			cmd = string.lower(cmd)
			if tCommands[cmd].tLevels[user.iProfile] then
				return tCommands[cmd].tFunc(user, data), 1
			else
				return user:SendData(sBot,"*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

NewUserConnected = function(user)
	for i,v in pairs(tCommands) do
		local sRC = string.gsub(v.tRC,"{}",i)
		user:SendData("$UserCommand 1 3 CountDown Bot\\"..sRC.."&#124;")
	end
	local tmp = TimeLeft(); if tmp then user:SendData(sBot,tmp) end
end

OpConnected = NewUserConnected

OnTimer = function()
	if os.difftime( os.time(Settings.iSetup), os.time(os.date("*t")) ) == 0 then
		-- Send message and kill timer
		SendAscii(); StopTimer(); Settings.bRun = false
	else
		local tmp = TimeLeft(); if tmp then SendToAll(sBot,tmp) end; Sync()
	end
end

OnExit = function()
	local hFile = io.open(fTime,"w+") Serialize(Settings,"Settings",hFile); hFile:close()
end

tCommands = {
	setmsg = {
		tFunc = function(user,data)
			local _,_, msg = string.find(data,"^%b<>%s+%S+%s+(.*)|$")
			if msg then
				Settings.sMsg = msg;
				user:SendData(sBot,"*** CountDown Bot's message has been changed to: "..msg)
			end
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1, [6] = 1,
		},
		tRC = "Set Message$<%[mynick]> !{} %[line:Message]"
	},
	starttimer = {
		tFunc = function(user)
			StartTimer(); Sync(); Settings.bRun = true
			user:SendData(sBot,"*** CountDown Bot's timer has been started!")
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1, [6] = 1,
		},
		tRC = "Start Timer$<%[mynick]> !{}"
	},
	stoptimer = {
		tFunc = function(user)
			StopTimer(); Settings.bRun = false
			user:SendData(sBot,"*** CountDown Bot's timer has been started!")
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1, [6] = 1,
		},
		tRC = "Stop Timer$<%[mynick]> !{}"
	},
	daysleft = {
		tFunc = function(user)
			local tmp = TimeLeft()
			if tmp then user:SendData(sBot,tmp) end
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1,
		},
		tRC = "Time Left$<%[mynick]> !{}"
	},
	settimer = {
		tFunc = function(user,data)
			local _,_, args = string.find(data,"^%b<>%s+%S+%s+(.*)|$")
			if args then
				local _,_, d, m, y, H, M, S = string.find(args,"^(%d%d)\/(%d%d)\/(%d%d%d%d)%s(%d%d)%:(%d%d)%:(%d%d)$")
				if d then
					Settings.iSetup = { 
						hour = tonumber(H), min = tonumber(M), day = tonumber(d),
						month = tonumber(m), year = tonumber(y), sec = tonumber(S)
					}
					user:SendData(sBot,"*** CountDown Bot has been successfully set to: "..args); OnExit()
				else
					user:SendData(sBot,"*** Syntax Error: Type !settimer dd/mm/yyyy hh:mm:ss")
				end
			else
				user:SendData(sBot,"*** Syntax Error: Type !settimer dd/mm/yyyy hh:mm:ss")
			end
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1, [6] = 1,
		},
		tRC = "Set Timer$<%[mynick]> !{} %[line:dd/mm/yyyy hh:mm:ss]"
	}
}

TimeLeft = function()
	local iDiff = os.difftime( os.time(Settings.iSetup), os.time(os.date("*t")) )
	if iDiff > 0 then
		local T = os.date("*t",iDiff)
		local sTime = string.format("%i month(s), %i day(s), %i hour(s), %i minute(s) and %i second(s)", T.month-1, T.day-1, T.hour-2, T.min, T.sec)
		-- For each digit
		for i in string.gmatch(sTime, "%d+") do
			-- Reduce if is preceeded by 0
			if tonumber(i) == 0 then sTime = string.gsub(sTime, "^"..i.."%s(%S+),%s", "") end
		end
		return Settings.sMsg.." "..sTime
	end
end

SendAscii = function()
	if bSend then
		local text; local f = io.open(fCountDown)
		if f then text = f:read("*all"); f:close() end; text = string.gsub(text, "\n", "\r\n")
		SendToAll(sBot, "\r\n"..text)
	end
	SendToAll(sBot, "Oki Here We Go    ;)")
end

Sync = function()
	local iDiff = os.difftime( os.time(Settings.iSetup), os.time(os.date("*t")) )
	if iDiff > 0 then
		local T, iAdjust = os.date("*t",iDiff)
		if T.day-1 ~= 0 then
			iAdjust = T.min*60 + T.sec; if iAdjust ~= 0 then SetTimer(iAdjust * 1000) else SetTimer(3600*1000) end
		else
			local tTable = {
				{ fAdjust = T.min*60 + T.sec, iTimer = 3600 },
				{ fAdjust = math.mod(T.min, 15)*60 + T.sec, iTimer = 900 },
				{ fAdjust = math.mod(T.min, 5)*60 + T.sec, iTimer = 300 },
				{ fAdjust = math.mod(T.min, 1)*60 + T.sec, iTimer = 60 },
				{ fAdjust = math.mod(T.sec, 15), iTimer = 15 },
				{ fAdjust = math.mod(T.sec, 5), iTimer = 5, iIndex = 10 },
				{ fAdjust = math.mod(T.sec, 1), iTimer = 1 },
			}
			for i in ipairs(tTable) do
				if iDiff > (tTable[i].iIndex or tTable[i].iTimer) then
					iAdjust = tTable[i].fAdjust; 
					if iAdjust ~= 0 then SetTimer(iAdjust*1000) else SetTimer(tTable[i].iTimer*1000) end; break
				end
			end
		end
	end
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