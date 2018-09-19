--[[

	------------------------------------------------------------------------------
	------- Lua 5 version by jiten   Lua 5.1 version by TiMeTrAVelleR      -------
	-------                  countdown bot by plop                         -------
	-------             original julian day made by tezlo                  -------
	-------      modifyd by chilla 2 also handle hours, mins, seconds      -------
	------------------------------------------------------------------------------

	------------------------------------------------------------------------------
	-------           THE TEXT FILE LOADS ON BOT START                     -------
	------------------------------------------------------------------------------
	------- this may sound weird but this 2 make sure it shows on time,    -------
	-------      as i allready seen some big ascii's come by               -------
	------------------------------------------------------------------------------

	Changelog:

	Added: Customizable countdown;
	Changed: Small stuff;
	Added: RightClick (3/28/2006).

]]--

Settings = {
	-- Bot Name
	sBot = "-TÓMÍﬂÙÜ-",
	-- First Timer for this bot (2 digits)
	-- After first setup, has to be changed with command
	iSetup = {
		iYear = 06,
		iMonth = 3,
		iDay = 28,
		iHour = 21,
		iMinute = 00,
		iSecond = 00,
	},
	-- Timer DB
	fTime = "tTime.tbl",
	-- Send txt content to Main
	bSend = false,
	-- CountDown file to be shown
	fCountDown = "happynewyear.txt",
}

Main = function()
	if loadfile(Settings.fTime) then dofile(Settings.fTime) end
	SetTimer(100 * 1000); StartTimer()
	local tmp = TimeLeft()
	if tmp then SendToAll(Settings.sBot,tmp) end; Sync(); last = 0
end

ChatArrival = function(user, data) 
	local s,e,cmd = string.find(data,"^%b<>%s+[%!%+](%S+).*|$") 
	if cmd then
		if tCommands[string.lower(cmd)] then
			cmd = string.lower(cmd)
			if tCommands[cmd].tLevels[user.iProfile] then
				return tCommands[cmd].tFunc(user, data), 1
			else
				return user:SendData(Settings.sBot,"*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

tCommands = {
	daysleft = {
		tFunc = function(user)
			local tmp = TimeLeft()
			if tmp then user:SendData(Settings.sBot,tmp) end
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		tRC = "Time Left$<%[mynick]> !{}"
	},
	settimer = {
		tFunc = function(user,data)
			local s,e,args = string.find(data,"^%b<>%s+%S+%s+(.*)|$")
			local s,e,d,m,y,H,M,S = string.find(args,"^(%d%d)\/(%d%d)\/(%d%d)%s(%d%d)%:(%d%d)%:(%d%d)$")
			if d and m and y and H and M and S then
				Settings.iSetup = { 
					iDay = tonumber(d), iMonth = tonumber(m), iYear = tonumber(y),
					iHour = tonumber(H), iMinute = tonumber(M), iSecond = tonumber(S)
				}
				local hFile = io.open(Settings.fTime,"w+") Serialize(Settings.iSetup,"Settings.iSetup",hFile); hFile:close()
				user:SendData(Settings.sBot,"*** Countdown Bot has been successfully set to: "..args);
				StartTimer(); Sync(); last = 0
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !settimer dd/mm/yy hh:mm:ss")
			end
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1,
		},
		tRC = "Set Timer$<%[mynick]> !{} %[line:dd/mm/yy hh:mm:ss]"
	}
}

NewUserConnected = function(user)
	for i,v in pairs(tCommands) do
		local sRC = string.gsub(v.tRC,"{}",i)
		user:SendData("$UserCommand 1 3 CountDown Bot\\"..sRC.."&#124;")
	end
	local tmp = TimeLeft()
	if tmp then user:SendData(Settings.sBot,tmp) end
end

OpConnected = NewUserConnected

OnTimer = function()
	if last == 0 then
		SendToAll(Settings.sBot, TimeLeft()); Sync()
	elseif last == 1 then
		-- Send message and kill timer
		SendAscii(); StopTimer()
	end
end

jdatehms = function(d, m, y,ho,mi,se)
	local a, b, c = 0, 0, 0
	if m <= 2 then y = y - 1 m = m + 12 end
	if (y*10000 + m*100 + d) >= 15821015 then a = math.floor(y/100) b = 2 - a + math.floor(a/4) end
	if y <= 0 then c = 0.75 end
	return math.floor(365.25*y - c) + math.floor(30.6001*(m+1) + d + 1720994 + b),ho*3600+mi*60+se
end

TimeLeft = function()
	local tmp = Settings.iSetup
	local curday,cursec = jdatehms(tonumber(os.date("%d")),tonumber(os.date("%m")),tonumber(os.date("%y")),tonumber(os.date("%H")),tonumber(os.date("%M")),tonumber(os.date("%S")))
	local iday,isec = jdatehms(tmp.iDay,tmp.iMonth,tmp.iYear,tmp.iHour,tmp.iMinute,tmp.iSecond)
	local tmp = isec-cursec
	local hours, minutes,seconds = math.floor(math.mod(tmp/3600, 60)), math.floor(math.mod(tmp/60, 60)), math.floor(math.mod(tmp/1, 60))
	local day = iday-curday
	if day >= 0 then
		line = "LiVe SeT FroM TiMeTrAVelleR At: http://stream01.pcextreme.nl:8035/stream In "
		if day ~= 0 then line = line.." "..day.." Days" end
		if hours ~= 0 then line = line.." "..hours.." Hours" end
		if minutes ~= 0 then line = line.." "..minutes.." Minutes" end
		if seconds ~= 0 then line = line.." "..seconds.." Seconds ;) " end
		return line
	end
end

SendAscii = function()
	if Settings.bSend then
		local text
		local f = io.open(Settings.fCountDown)
		if f then text = f:read("*all"); f:close(); return string.gsub( text, "\n", "\r\n" ) end 
		SendToAll(Settings.sBot,text)
	end
	SendToAll(Settings.sBot, "Oki Here We Go    ;)")
end

Sync = function()
	local tmp = Settings.iSetup
	local curday,cursec = jdatehms(tonumber(os.date("%d")),tonumber(os.date("%m")),tonumber(os.date("%y")),tonumber(os.date("%H")),tonumber(os.date("%M")),tonumber(os.date("%S")))
	local iday,isec = jdatehms(tmp.iDay,tmp.iMonth,tmp.iYear,tmp.iHour,tmp.iMinute,tmp.iSecond)
	local tmp = isec-cursec
	local hours, minutes,seconds = math.floor(math.mod(tmp/3600, 60)), math.floor(math.mod(tmp/60, 60)), math.floor(math.mod(tmp/1, 60))
	local day = iday-curday
	if day ~= 0 then
		adjust = (math.floor(math.mod(minutes, 60))*60)+seconds
		if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(3600 * 1000) end
	else
		if tmp > 3600 then  --- every hours a msg
			adjust = (math.floor(math.mod(minutes, 60))*60)+seconds
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(3600 * 1000) end
		elseif tmp > 900 then  -- every 15 mins a msg
			adjust = (math.floor(math.mod(minutes, 15))*60)+seconds
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(900 * 1000) end
		elseif tmp > 300 then  -- every 5 mins a msg
			adjust = (math.floor(math.mod(minutes, 5))*60)+seconds
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(300 * 1000) end
		elseif tmp > 60 then  -- every min a msg
			adjust = (math.floor(math.mod(minutes, 1))*60)+seconds
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(60 * 1000) end
		elseif tmp > 15 then  -- every 15 secs a msg
			adjust = math.floor(math.mod(seconds, 15))
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(15 * 1000) end
		elseif tmp > 10 then  -- every 10 secs a msg
			adjust = math.floor(math.mod(seconds, 10))
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(5 * 1000) end
		elseif tmp > 1 then
			SetTimer(1 * 1000) 
		else
			last = 1
			SetTimer(1 * 1000)
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