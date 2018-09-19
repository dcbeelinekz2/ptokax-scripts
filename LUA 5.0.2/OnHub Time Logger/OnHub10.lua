-- Converted and optimized to Lua 5 by jiten

--OnHub Time Logger V.1.65 by CHILL INC.
--thx to tezlo for the nice calculation from minutes to months, days, etc., and to Nagini, and to RabidWombat
--Create a "txt" Folder in the PtokaX scripts Folder, like this /scripts/txt/

--ChangeLog :
--5.12.03 Some Fixes.
--27.9.03 Added Serialisation.
--28.11.03 Rewriten Timer

tSetup = {
	mSet = { -- Script Settings
		-- Name this bot to what you want
		bot = frmHub:GetHubBotName(),
		--This number stands for the maximum of displayed users, set it to what U like
		Max = 40,
		--This number is for the timespan between each data saving in minutes.
		Max1 = 1,
		--This number stands for time in minutes, a user must be online till he is saved to the file.
		Max2 = 1,
		sStuff = {
			HTFolder = "txt", -- folder to save the Hubbers File (do create it)
			File1 = "UserHubTime.txt", -- Hubbers File
		},
		-- don't change this
		var1 = 0,
		SHT = 0,
		HubUpTime = frmHub:GetUpTime() or 0,
		--------------------
	},
	UserHubTime = {},
	UserSessionTime = {},
}
--- time settings
sec = 1000 
min = 60 * sec
-----------------
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

Main = function()
	local f = io.open(tSetup.mSet.sStuff.HTFolder.."/"..tSetup.mSet.sStuff.File1)
	if f then
		f:close();
		dofile(tSetup.mSet.sStuff.HTFolder.."/"..tSetup.mSet.sStuff.File1)
	end
	SetTimer(1 * min) 
	StartTimer()
	table.foreach(tSetup.UserHubTime, function(i,_)
		if GetItemByName(i) then
			tSetup.UserSessionTime[i] = 0
		end
	end)
	TopOnliners = GetUserMaxTime()
	UpdateTime = "Last Updated: "..os.date("%d/%m/%y at %H:%M:%S")
end 

OnTimer = function()
	tSetup.mSet.SHT = tSetup.mSet.SHT + 1
	table.foreach(tSetup.UserSessionTime, function(i,_)
		if GetItemByName(i) then
			tSetup.UserSessionTime[i] = tSetup.UserSessionTime[i] + 1
		end
	end)
	tSetup.mSet.var1 = tSetup.mSet.var1 + 1
	if tSetup.mSet.var1 >= tSetup.mSet.Max1 then
		table.foreach(tSetup.UserSessionTime, function (a,_)
			tSetup.UserHubTime[a] = tSetup.UserHubTime[a] + tSetup.UserSessionTime[a]
			tSetup.UserSessionTime[a] = 0
			if not GetItemByName(a) then
				tSetup.UserSessionTime[a] = nil
			end
		end)
		tSetup.mSet.HubUpTime = tSetup.mSet.HubUpTime + tSetup.mSet.SHT
		WriteFile(tSetup.UserHubTime, "tSetup.UserHubTime", tSetup.mSet.sStuff.File1)
		tSetup.mSet.var1 = 0
		tSetup.mSet.SHT = 0
		TopOnliners = GetUserMaxTime()
		UpdateTime = "Updated: "..os.date("%d/%m/%y at %H:%M:%S")
	end
end

OnExit = function()
	table.foreach(tSetup.UserSessionTime, function (a,_)
		tSetup.UserHubTime[a] = tSetup.UserHubTime[a] + tSetup.UserSessionTime[a]
		tSetup.UserSessionTime[a] = 0
		if not GetItemByName(a) then
			tSetup.UserSessionTime[a] = nil
		end
	end)
	tSetup.mSet.HubUpTime = tSetup.mSet.HubUpTime + tSetup.mSet.SHT
	WriteFile(tSetup.UserHubTime, "tSetup.UserHubTime", tSetup.mSet.sStuff.File1)
end

NewUserConnected = function(curUser)
	if tSetup.UserHubTime[curUser.sName]==nil then
		tSetup.UserHubTime[curUser.sName]=0
	end
	tSetup.UserSessionTime[curUser.sName]=0
end

OpConnected = NewUserConnected

ChatArrival = function(curUser,data)
	data = string.sub(data,1,-2)
	local s,e,cmd = string.find ( data, "%b<>%s+[%!%?%+%#](%S+)" )
	if cmd then
		local tCmds = {
			["myhubtime"] =		function(curUser,data)
							local tmp = tSetup.UserHubTime[curUser.sName] + tSetup.UserSessionTime[curUser.sName]
							local months, days, hours, minutes = math.floor(tmp/43200), math.floor(math.mod(tmp/1440, 30)), math.floor(math.mod(tmp/60, 24)), math.floor(math.mod(tmp/1, 60))
							if tSetup.mSet.HubUpTime == 0 then curUser:SendData(tSetup.mSet.bot, "You have been online : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..tmp.." min ).") return 0 end
							curUser:SendData(tSetup.mSet.bot, "You have been online : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..tmp.." min ). That is "..math.floor(math.mod((tmp*(tSetup.mSet.HubUpTime/60)),60)).." % of the total HubUpTime.")
						end,
			["allhubtime"] =	function(curUser,data)
							local tmp = tSetup.mSet.HubUpTime + tSetup.mSet.SHT
							local months, days, hours, minutes = math.floor(tmp/43200), math.floor(math.mod(tmp/1440, 30)), math.floor(math.mod(tmp/60, 24)), math.floor(math.mod(tmp/1, 60))
							curUser:SendPM(tSetup.mSet.bot, "Current Top "..tSetup.mSet.Max.." Hubbers ("..UpdateTime..")\r\n\r\n"..
							"\tHub's Online Time : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..tmp.." min ).\r\n"..
							TopOnliners.."\r\n")
						end,
			["hubtime"] =		function (curUser,data)
							local tmp = tSetup.mSet.HubUpTime + tSetup.mSet.SHT
							local months, days, hours, minutes = math.floor(tmp/518400, 12), math.floor(tmp/43200, 30), math.floor(math.mod(tmp/1440, 24)), math.floor(math.mod(tmp/60, 60))
							curUser:SendData(tSetup.mSet.bot, "The hub has now been online : "..months.." months, "..days.." days, "..hours.." hours, "..minutes.." minutes ( "..math.floor(math.mod(tmp/60, 60)).." min ).")
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
	local handle = io.open(tSetup.mSet.sStuff.HTFolder.."/"..file, "w+")
	handle:write(tablename.." = {\n" )
	for key, value in table do
		if value >= tSetup.mSet.Max2 then
			handle:write("\t"..string.format("[%q]",key).." = "..value..",\n")
		end
	end
	handle:write("}");
	handle:write("\r\nHubUpTime = "..tSetup.mSet.HubUpTime)
	handle:close()
end
----------------------------------------------------------------------------------------------------------
GetUserMaxTime = function()
	local TCopy={}
	for i,v in tSetup.UserHubTime do
		table.insert( TCopy, { tonumber(v),i } )
	end
	table.sort( TCopy, function(a, b) return (a[1] > b[1]) end)
	local msg,border = "\r\n",string.rep ("-", 180) 
	msg = msg.."\t"..border.."\r\n"
	msg = msg.."\tNr.\t\tTotal Time\t\t\t\tStatus\t\tNick\r\n"
	msg = msg.."\t"..border.."\r\n"
	for i = 1,tSetup.mSet.Max do
		if TCopy[i] then
			local months, days, hours, minutes, o = math.floor(TCopy[i][1]/43200), math.floor(math.mod(TCopy[i][1]/1440, 30)), math.floor(math.mod(TCopy[i][1]/60, 24)), math.floor(math.mod(TCopy[i][1]/1, 60)), "*Offline*"
			if GetItemByName(TCopy[i][2]) then o = "*Online*"; end
			local m = o
			msg = msg.."\t"..i..".\t"..months.." Months, "..days.." Days, "..hours.." Hours, "..minutes.." Min ( "..TCopy[i][1].." min )\t\t"..m.."\t\t"..TCopy[i][2].."\r\n"
		end
	end
	msg = msg.."\t"..border.."\r\n"
	local TCopy={}
	return msg
end
----------------------------------------------------------------------------------------------------------
 
