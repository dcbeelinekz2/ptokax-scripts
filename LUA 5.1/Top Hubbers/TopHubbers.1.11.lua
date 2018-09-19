--[[

	TopHubbers 1.01 by jiten - LUA 5.1 (3/17/2006)

	Based on OnHub Time Logger 1.65 by chill and Robocop's layout 

	Usage: !tophubbers; !tophubbers x-y

	Added: OnExit function

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
			tOnline[v]["SessionTime"] = tOnline[v]["SessionTime"] + 1
		end
	end
end

OnExit = function()
	tFunctions.SaveToFile(fOnline,tOnline,"tOnline")
end

NewUserConnected = function(user)
	if user.bRegistered then
		if tOnline[user.sName] then
			tOnline[user.sName]["SessionTime"] = 0
			tOnline[user.sName]["Enter"] = os.date()
		else
			tOnline[user.sName] = { Enter = os.date(), SessionTime = 0, TotalTime = 0, Leave = os.date() }
		end
	end
end

OpConnected = NewUserConnected

UserDisconnected = function(user)
	if user.bRegistered and tOnline[user.sName] then
		tOnline[user.sName]["TotalTime"] = tOnline[user.sName]["TotalTime"] + tOnline[user.sName]["SessionTime"]
		tOnline[user.sName]["SessionTime"] = 0
		tOnline[user.sName]["Leave"] = os.date()
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
					table.insert( tCopy, { sEnter = v.Enter, iSessionTime = tonumber(v.SessionTime), iTotalTime = tonumber(v.TotalTime), iGlobalTime = tonumber(v.TotalTime) + tonumber(v.SessionTime), sLeave = v.Leave, sNick = i } )
				end
				table.sort( tCopy, function(a, b) return (a.sGlobalTime > b.sGlobalTime) end)
				for v,i in pairs(tCopy) do
					local sStatus = "*Offline*"; 
					if GetItemByName(tCopy[v].sNick) then sStatus= "*Online*" end
					msg = msg.."\t"..v..".    "..tFunctions.SecondsToTime(tCopy[v].iGlobalTime).."\t"..
					math.floor(math.mod(tCopy[v].iSessionTime/1, 60)).." min\t"..tCopy[v].sEnter.."\t"..
					tCopy[v].sLeave.."\t"..sStatus.."\t"..tCopy[v].sNick.."\r\n"
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
		local tTime = os.date("!*t", tonumber(iSeconds*60))
		return string.format("%i month(s), %i day(s), %i hour(s), %i minutes(s)", iSeconds/518400, iSeconds/86400, tTime.hour, tTime.min)
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
