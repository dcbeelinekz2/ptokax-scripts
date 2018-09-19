--[[

	TopHubbers 1.1d - LUA 5.1 by jiten

	Based on OnHub Time Logger 1.65 by chill and Robocop's layout 

	Usage: !tophubbers; !tophubbers x-y

	Fixed: Typo in table.sort function;
	Added: OnExit (3/21/2006)
	Fixed: Missing pairs() in SaveToFile
	Changed: Removed iGlobalTime and added TotalTime count to OnTimer
	Changed: SecondsToTime function values (3/24/2006)
	Changed: math.floor/mod in TopHubbers' function; (3/5/2006)
	Changed: SecondsToTime month value (4/17/2006).

]]--

fOnline = "tOnliners.tbl"	-- Hubbers File
tOnline = {}

Main = function()
	if loadfile(fOnline) then dofile(fOnline) end
	SetTimer(60*1000) StartTimer()
end 

OnTimer = function()
	for v,i in pairs(tOnline) do
		if GetItemByName(v) then
			i.SessionTime = i.SessionTime + 1; i.TotalTime = i.TotalTime + 1
		end
	end
end

OnExit = function()
	tFunctions.SaveToFile(fOnline,tOnline,"tOnline")
end

NewUserConnected = function(user)
	if user.bRegistered then
		if tOnline[user.sName] then
			tOnline[user.sName].SessionTime = 0
			tOnline[user.sName].Enter = os.date()
		else
			tOnline[user.sName] = { Enter = os.date(), SessionTime = 0, TotalTime = 0, Leave = os.date() }
		end
	end
end

OpConnected = NewUserConnected

UserDisconnected = function(user)
	if user.bRegistered and tOnline[user.sName] then
		tOnline[user.sName].SessionTime = 0; tOnline[user.sName].Leave = os.date()
	end
end

OpDisconnected = UserDisconnected

ChatArrival = function(user,data)
	local data = string.sub(data,1,-2)
	local s,e,cmd = string.find(data,"^%b<>%s+%!(%S+)")
	if cmd and tCmds[string.lower(cmd)] then
		cmd = string.lower(cmd)
		if tCmds[cmd].tLevels[user.iProfile] then
			return tCmds[cmd].tFunc(user,data),1
		else
			return user:SendData(frmHub:GetHubBotName(), "*** Error: You are not allowed to use this command!"),1
		end
	end
end

tCmds = {
	["tophubbers"] = {
		tFunc = function(user,data)
			if next(tOnline) then
				local s,e,iStart,iEnd = string.find(data,"%b<>%s+%S+%s+(%d+)%-(%d+)")
				iStart = iStart or 1; iEnd = iEnd or 20
				local tCopy, msg = {}, "\r\n\t"..string.rep("=",105).."\r\n\tNr.  Total:\t\t\t\t\tSession:\tEntered Hub:\tLeft Hub:"..
				"\t\tStatus:\tName:\r\n\t"..string.rep("-",210).."\r\n"
				for i,v in pairs(tOnline) do
					table.insert( tCopy, { sEnter = v.Enter, iSessionTime = tonumber(v.SessionTime), iTotalTime = tonumber(v.TotalTime), sLeave = v.Leave, sNick = i } )
				end
				table.sort( tCopy, function(a, b) return (a.iTotalTime > b.iTotalTime) end)
				for v,i in pairs(tCopy) do
					local sStatus = "*Offline*"; 
					if GetItemByName(i.sNick) then sStatus= "*Online*" end
					msg = msg.."\t"..v..".    "..tFunctions.SecondsToTime(i.iTotalTime*60).."\t"..
					i.iSessionTime.." min\t"..i.sEnter.."\t"..i.sLeave.."\t"..sStatus.."\t"..i.sNick.."\r\n"
				end
				msg = msg.."\t"..string.rep("-",210)
				user:SendPM(frmHub:GetHubBotName(), "Current Top Hubbers:\r\n"..msg.."\r\n")
			else
				user:SendData(frmHub:GetHubBotName(), "*** Error: Top Hubbers' table is currently empty!")
			end
		end,
		tLevels = {
			[-1] = 0,
			[0] = 1,
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
			[5] = 1,
		},
	},
}

tFunctions = {

	-- Function from A.I. 2 by plop
	SecondsToTime = function(iSeconds)
		local tTime = os.date("!*t", tonumber(iSeconds))
		return string.format("%i month(s), %i day(s), %i hour(s), %i minute(s)", tTime.month-1, tTime.day-1, tTime.hour, tTime.min)
	end,

	Serialize = function(tTable,sTableName,hFile,sTab)
		sTab = sTab or "";
		hFile:write(sTab..sTableName.." = {\n");
		for key,value in pairs(tTable) do
			if (type(value) ~= "function") then
				local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
				if(type(value) == "table") then
					tFunctions.Serialize(value,sKey,hFile,sTab.."\t");
				else
					local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
					hFile:write(sTab.."\t"..sKey.." = "..sValue);
				end
				hFile:write(",\n");
			end
		end
		hFile:write(sTab.."}");
	end,

	SaveToFile = function(file,table,tablename)
		local hFile = io.open(file,"w+") tFunctions.Serialize(table,tablename,hFile); hFile:close() 
	end,
}