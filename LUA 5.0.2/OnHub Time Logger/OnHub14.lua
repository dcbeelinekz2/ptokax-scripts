-- Converted and optimized to Lua 5 by jiten
-- some bug fixing (thx to zoni)
-- Added: User Uptime sending on connect (requested by kash)
-- Added: !nicktime (requested by kash)

--OnHub Time Logger V.1.65 by CHILL INC.
--thx to tezlo for the nice calculation from minutes to months, days, etc., and to Nagini, and to RabidWombat

--ChangeLog :
--5.12.03 Some Fixes.
--27.9.03 Added Serialisation.
--28.11.03 Rewriten Timer

bot = frmHub:GetHubBotName()	-- Name this bot to what you want
Max = 40			-- This number stands for the maximum of displayed users, set it to what U like
Max1 = 1			-- This number is for the timespan between each data saving in minutes.
Max2 = 1			-- This number stands for time in minutes, a user must be online till he is saved to the file.
HTFolder = "txt"		-- folder to save the Hubbers File (do create it)
File1 = "UserHubTime.txt"	-- Hubbers File
--- don't change this ----------------
var1 = 0
SHT = 0
HubUpTime = frmHub:GetUpTime()
UserHubTime = {}
UserSessionTime = {}
tDelay = {}
---------------------------------------

Main = function()
	if loadfile(HTFolder.."/"..File1) then dofile(HTFolder.."/"..File1) else os.execute("mkdir "..HTFolder) end
	SetTimer(1000) StartTimer()
	table.foreach(UserHubTime, function(i,_)
		if GetItemByName(i) then
			UserSessionTime[i] = 0
		end
	end)
	TopOnliners = GetUserMaxTime()
	UpdateTime = "Last Updated: "..os.date("%d/%m/%y at %H:%M:%S")
end 

OnTimer = function()
	SHT = SHT + 1
	table.foreach(UserSessionTime, function(i,_)
		if GetItemByName(i) then
			UserSessionTime[i] = UserSessionTime[i] + 1
		end
	end)
	var1 = var1 + 1
	if var1 >= Max1 then
		table.foreach(UserSessionTime, function (a,_)
			UserHubTime[a] = UserHubTime[a] + UserSessionTime[a]
			UserSessionTime[a] = 0
			if not GetItemByName(a) then
				UserSessionTime[a] = nil
			end
		end)
		HubUpTime = HubUpTime + SHT
		WriteFile(UserHubTime, "UserHubTime", File1)
		var1 = 0
		SHT = 0
		TopOnliners = GetUserMaxTime()
		UpdateTime = "Updated: "..os.date("%d/%m/%y at %H:%M:%S")
	end
	for nick,v in tDelay do
		tDelay[nick]["iTime"] = tDelay[nick]["iTime"] - 1
		if tDelay[nick]["iTime"] == 0 then
			if UserHubTime[nick.sName] then
				local tmp = UserHubTime[nick.sName] + UserSessionTime[nick.sName]
				local months, days, hours, minutes = math.floor(tmp/518400, 12), math.floor(tmp/43200, 30), math.floor(math.mod(tmp/1440, 24)), math.floor(math.mod(tmp/60, 60))
				if HubUpTime == 0 then nick:SendData(bot, "You have been online : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..math.floor(math.mod(tmp/60, 60)).." mins ).") return 0 end
				nick:SendData(bot, "You have been online : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..math.floor(math.mod(tmp/60, 60)).." mins ). That is "..string.format("%0.2f",(tmp/HubUpTime)*100).." % of the total HubUpTime.")
			end
		end
	end
end

OnExit = function()
	table.foreach(UserSessionTime, function (a,_)
		UserHubTime[a] = UserHubTime[a] + UserSessionTime[a]
		UserSessionTime[a] = 0
		if not GetItemByName(a) then
			UserSessionTime[a] = nil
		end
	end)
	HubUpTime = HubUpTime + SHT
	WriteFile(UserHubTime, "UserHubTime", File1)
end

NewUserConnected = function(curUser)
	if UserHubTime[curUser.sName]==nil then 
		UserHubTime[curUser.sName]=0
	end
	UserSessionTime[curUser.sName]=0
	tDelay[curUser] = {}
	tDelay[curUser]["iTime"] = 1
end

OpConnected = NewUserConnected

ChatArrival = function(curUser,data)
	local data = string.sub(data,1,-2)
	local s,e,cmd = string.find ( data, "%b<>%s+[%!%?%+%#](%S+)" )
	if cmd then
		local tCmds = {
			["myhubtime"] =		function(curUser,data)
							if UserHubTime[curUser.sName] then
								local tmp = UserHubTime[curUser.sName] + UserSessionTime[curUser.sName]
								local months, days, hours, minutes = math.floor(tmp/518400, 12), math.floor(tmp/43200, 30), math.floor(math.mod(tmp/1440, 24)), math.floor(math.mod(tmp/60, 60))
								if HubUpTime == 0 then curUser:SendData(bot, "You have been online : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..math.floor(math.mod(tmp/60, 60)).." mins ).") return 0 end
								curUser:SendData(bot, "You have been online : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..math.floor(math.mod(tmp/60, 60)).." mins ). That is "..string.format("%0.2f",(tmp/HubUpTime)*100).." % of the total HubUpTime.")
							end
						end,
			["allhubtime"] =	function(curUser,data)
							local tmp = HubUpTime + SHT
							local months, days, hours, minutes = math.floor(tmp/518400, 12), math.floor(tmp/43200, 30), math.floor(math.mod(tmp/1440, 24)), math.floor(math.mod(tmp/60, 60))
							curUser:SendPM(bot, "Current Top "..Max.." Hubbers ("..UpdateTime..")\r\n\r\n"..
							"\tHub's Online Time : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..math.floor(math.mod(tmp/60, 60)).." mins ).\r\n"..
							TopOnliners.."\r\n")
						end,
			["nicktime"] =		function (curUser,data)
							local s,e,nick = string.find(data, "%b<>%s+%S+%s+(%S+)")
							if nick then
								if UserHubTime[nick] then
									local tmp = UserHubTime[nick] + UserSessionTime[nick]
									local months, days, hours, minutes = math.floor(tmp/518400, 12), math.floor(tmp/43200, 30), math.floor(math.mod(tmp/1440, 24)), math.floor(math.mod(tmp/60, 60))
									if HubUpTime == 0 then curUser:SendData(bot, nick.." has been online : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..math.floor(math.mod(tmp/60, 60)).." mins ).") return 0 end
									curUser:SendData(bot, nick.." has been online : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..math.floor(math.mod(tmp/60, 60)).." mins ). That is "..string.format("%0.2f",(tmp/HubUpTime)*100).." % of the total HubUpTime.")
								else
									curUser:SendData(bot,"*** Error: "..nick.." isn't in the tophubbers list.")
								end
							else
								curUser:SendData(bot,"*** Syntax Error: Type !nicktime <nick>")
							end
						end,

			["hubtime"] =		function (curUser,data)
							local tmp = HubUpTime + SHT
							local months, days, hours, minutes = math.floor(tmp/518400, 12), math.floor(tmp/43200, 30), math.floor(math.mod(tmp/1440, 24)), math.floor(math.mod(tmp/60, 60))
							curUser:SendData(bot, "The hub has now been online : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..math.floor(math.mod(tmp/60, 60)).." mins ).")
						end,
				
		}
		if tCmds[cmd] then 
			return tCmds[cmd](curUser,data), 1
		end
	end
end

ToArrival = ChatArrival
----------------------------------------------------------------------------------------------------------
WriteFile = function(table, tablename, file)
	local handle = io.open(HTFolder.."/"..file, "w+")
	handle:write(tablename.." = {\n" )
	for key, value in table do
		if value >= Max2 then
			handle:write("\t"..string.format("[%q]",key).." = "..value..",\n")
		end
	end
	handle:write("}");
	handle:write("\r\nHubUpTime = "..HubUpTime)
	handle:close()
end
----------------------------------------------------------------------------------------------------------
GetUserMaxTime = function()
	local TCopy={}
	for i,v in UserHubTime do
		table.insert( TCopy, { tonumber(v),i } )
	end
	table.sort( TCopy, function(a, b) return (a[1] > b[1]) end)
	local msg,border = "\r\n",string.rep ("-", 180) 
	msg = msg.."\t"..border.."\r\n"
	msg = msg.."\tNr.\t\tTotal Time\t\t\t\tStatus\t\tNick\r\n"
	msg = msg.."\t"..border.."\r\n"
	for i = 1,Max do
		if TCopy[i] then
			local months, days, hours, minutes, o = math.floor(TCopy[i][1]/518400, 12), math.floor(math.mod(TCopy[i][1]/43200, 30)), math.floor(math.mod(TCopy[i][1]/1440, 24)), math.floor(math.mod(TCopy[i][1]/60, 60)), "*Offline*"
			if GetItemByName(TCopy[i][2]) then o = "*Online*"; end
			local m = o
			msg = msg.."\t"..i..".\t"..months.." Months, "..days.." Days, "..hours.." Hours, "..minutes.." Min ( "..math.floor(math.mod(TCopy[i][1]/60, 60)).." mins )\t\t"..m.."\t\t"..TCopy[i][2].."\r\n"
		end
	end
	msg = msg.."\t"..border.."\r\n"
	local TCopy={}
	return msg
end
----------------------------------------------------------------------------------------------------------