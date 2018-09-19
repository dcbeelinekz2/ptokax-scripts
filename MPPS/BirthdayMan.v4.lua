--[[ 

	Birthday Man v.4 - LUA 5.0/5.1 by jiten for Voltron (4/12/2006)

	Based on: BirthdayMan v 3.5 by Herodes and mods by Cêñoßy†ê

	Changelog:
	
	Rewritten: Whole code;

	Changed: Command structure to tables (Function, Permissions, RightClick and Ddescription);
	Changed: B-Day table structure to Julian values;
	Removed: File content that was sent on B-Day;
	Removed: Allowed Age;
	Removed: Topic updater (maybe in the future);
	Changed: Whole B-Day counting system to os.*;
	Changed: Many other mods that can't recall at the moment (4/12/2006).

]]--

-- Edit at will
Settings = {
	-- Bot's Name
	sBot = "B-Day",
	-- Script version
	iVer = 4,
	-- Register in userlist
	bReg = true,
	-- Minimum allowed year
	iMin = 1900,
	-- Time to check for B-Dayers (in hours)
	iTime = 12,
	-- B-Day Man DB
	fBirth = "tBirthday.tbl",
}

tBirthday = {}

setArrival("OnStartup", function()
	if loadfile(Settings.fBirth) then dofile(Settings.fBirth) end
	if (Settings.sBot ~= GetBotName()) or Settings.bReg then RegBot(Settings.sBot,"","") end
	SetTimer(Settings.iTime*60*60*1000) StartTimer()
end)

setArrival("OnTimer", function()
	-- Check B-Days
	BDayCheck("OnTimer")
end)

setArrival("UserConnected", function(user)
	for i,v in pairs(tCmds) do
		if v.tLevels[user.iProfile] then
			local sRC = string.gsub(v.tRC,"{}",i)
			user:SendData("$UserCommand 1 3 B-Day Bot\\"..sRC.."&#124;")
		end
	end
	-- Check B-Days on connect
	BDayCheck("OnConnect",user)
end)

OpConnected = NewUserConnected

setArrival("ChatArrival", function(user, data)
	local s,e,cmd = string.find(data,"^[%!%+](%S+).*") 
	if cmd then
		if tCmds[string.lower(cmd)] then
			cmd = string.lower(cmd)
			if tCmds[cmd].tLevels[user.iProfile] then
				tCmds[cmd].tFunc(user,data); return 1
			else
				user:SendData(Settings.sBot,"*** Error: You are not allowed to use this command!"); return 1
			end
		end
	end
end)

tCmds = {
	mybirthday = {
		tFunc = function(user,data)
			if tBirthday[user.sName] then
				local sDate = JulianToDate(tBirthday[user.sName])
				user:SendData(Settings.sBot,"*** Error: I already have your Birthday on "..sDate..
				"! If it wasn't correctly set, ask Operators for help!")
			else
				local s,e,args = string.find(data,"^%S+%s+(.*)")
				if args then
					local s,e,d,m,y = string.find(args,"^(%d%d)\/(%d%d)\/(%d%d%d%d)$")
					if d and m and y then
						if tonumber(y) > Settings.iMin then
							local tmp
							if tonumber(y) < 1970 then tmp = 1970 - y; y = 1970 else tmp = 0 end
							local tTable = { day = tonumber(d), month = tonumber(m), year = tonumber(y) }
							tBirthday[user.sName] = { iJulian = os.time(tTable), iAdjust = tmp }
							vDC.SaveFile(tBirthday,"tBirthday",Settings.fBirth)
							local sDate, sWDay, sZodiac = JulianToDate(tBirthday[user.sName])
							user:SendData(Settings.sBot,"*** Your Birthday is on "..sDate.."! I didn't "..
							"know you were a "..Zodiac(tonumber(os.date("%m",tBirthday[user.sName].iJulian))).."!")
							user:SendData(Settings.sBot,"*** New Birthday added by "..user.sName.." on: "..args);
						else
							user:SendData(Settings.sBot,"*** Error: The miminum allowed year is "..Settings.iMin.."!")
						end
					else
						user:SendData(Settings.sBot,"*** Error: Birthday syntax must be - dd/mm/yyyy")
					end
				else
					user:SendData(Settings.sBot,"*** Syntax Error: Type !mybirthday dd/mm/yyyy")
				end
			end
		end,
		tLevels = {
			[1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1
		},
		sDesc = "\tAdds your B-Day",
		tRC = "Add your B-Day$<%[mynick]> !{} %[line:dd/mm/yyyy]"
	},
	delbirthday = {
		tFunc = function(user,data)
			local s,e,nick = string.find(data,"^%S+%s+(%S+).*")
			if nick then
				if tBirthday[string.lower(nick)] then
					tBirthday[string.lower(nick)] = nil; vDC.SaveFile(tBirthday,"tBirthday",Settings.fBirth)
					user:SendData(Settings.sBot,"*** Success: "..nick.."'s Birthday was successfully deleted from the DB!")
				else
					user:SendData(Settings.sBot,"*** Error: "..nick.."'s Birthday hasn't been added to the DB yet!")
				end
			else
				user:SendData(Setings.sBot,"*** Syntax Error: Type !delbirthday <nick>")
			end
		end,
		tLevels = {
			[4] = 1, [5] = 1, [6] = 1
		},
		sDesc = "\tDelete a specific B-Day",
		tRC = "Delete user's B-Day$<%[mynick]> !{} %[line:Nick]"
	},
	birthdays = {
		tFunc = function(user)
			if next(tBirthday) then
				local sMsg, n = "\r\n\t"..string.rep("=",105).."\r\n\tNr.\tBirthdate:\t\t\tWeekday:\tZodiac Sign:"..
				"\tStatus:\t\tName:\r\n\t"..string.rep("-",210).."\r\n", 0
				for i,v in pairs(tBirthday) do
					local sStatus = "*Offline*"
					n = n + 1; if GetItemByName(i) then sStatus= "*Online*" end; 
					local sDate, sWDay, sZodiac = JulianToDate(v)
					sMsg = sMsg.."\t"..n.."\t"..sDate.."\t\t"..sWDay.."\t\t"..sZodiac.."\t\t"..sStatus.."\t\t"..i.."\r\n"
				end
				user:SendData(Settings.sBot,sMsg)
			else
				user:SendData(Settings.sBot,"*** Error: There are no saved Birthdays!")
			end
		end,
		tLevels = {
			[1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1
		},
		sDesc = "\t\tShows all Birthdays",
		tRC = "Show all B-Days$<%[mynick]> !{}"
	},
	myage = {
		tFunc = function(user)
			if tBirthday[user.sName] then
				user:SendData(Settings.sBot,"*** You're "..JulianToTime(user).." old according to the Hub's clock!")
			else
				user:SendData(Settings.sBot,"*** Error: Please add your Birthday before using this command. Type !"..
				"bhelp for more details!")
			end
		end,
		tLevels = {
			[1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1
		},
		sDesc = "\t\tDisplays your exact age",
		tRC = "Show your age$<%[mynick]> !{}"
	},
	bhelp = {
		tFunc = function(user)
			local sMsg = "\r\n\t\t"..string.rep("-", 190).."\r\n"..string.rep("\t",5).."BirthdayMain v."..
			Settings.iVer.." by jiten; based on: Herodes'\t\t\t\r\n\t\t"..string.rep("-",190).."\r\n\t\tAvailable Commands:".."\r\n\r\n"
			for i,v in pairs(tCmds) do
				if v.tLevels[user.iProfile] then
					sMsg = sMsg.."\t\t!"..i.."\t\t"..v.sDesc.."\r\n"
				end
			end
			user:SendData(Settings.sBot, sMsg.."\t\t"..string.rep("-",190));
		end,
		tLevels = {
			[1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1
		},
		sDesc = "\t\tDisplays this help message",
		tRC = "Show command list$<%[mynick]> !{}"
	},
	bornon = {
		tFunc = function(user)
			if tBirthday[user.sName] then
				local sMsg = "\r\n\t"..string.rep("=",105).."\r\n\t\t\t\t\t\tPeople born in the same \"Field\" as yours:\r\n\tField:"..
				"\tNick:\r\n\t"..string.rep("-",210).."\r\n"
				user:SendData(Settings.sBot,sMsg..SameBDay(user,tBirthday[user.sName].iJulian)) 
			else 
				user:SendData(Settings.sBot,"*** Error: Please add your Birthday before using this command. Type !"..
				"bhelp for more details!")
			end
		end,
		tLevels = {
			[1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1
		},
		sDesc = "\t\tShows users with whom you share your Birthday",
		tRC = "Show list of users you share dates$<%[mynick]> !{}"
	},
}

SameBDay = function(user,iValue)
	local sMsg, tSame = "", {}
	local tTable = { ["%m"] = { sDesc = "Month" }, ["%d"] = { sDesc = "Day" }, ["%y"] = { sDesc = "Year", bExtend = true } }
	for i,v in pairs(tBirthday) do
		if i ~= user.sName then
			for a,b in pairs(tTable) do
				local T,L = os.date("*t",v.iJulian), os.date("*t",tBirthday[user.sName].iJulian)
				if (b.bExtend and (T.year+v.iAdjust) == (L.year+tBirthday[user.sName].iAdjust)) or os.date(a,v.iJulian) == (os.date(a,iValue)) then
					tSame[b.sDesc] = (tSame[b.sDesc].."; "..i or i)
				end
			end
		end
	end
	for i,v in pairs(tSame) do sMsg = sMsg.."\t"..i.."\t"..v.."\r\n" end; return sMsg
end

BDayCheck = function(Mode,user)
	-- Check B-Days on connect
	for i,v in pairs(tBirthday) do
		if os.date("%m%d",v.iJulian) == (os.date("%m%d")) then
			local tTable = {
				["OnConnect"] = function()
					if user.sName ~= i then
						local T = os.date("*t",os.difftime(os.time(os.date("*t")),os.time(os.date("*t",v.iJulian))))
						user:SendData(Settings.sBot,"*** It's "..i.."'s Birthday today! :D He/She is turning "..
						(T.year-1970+v.iAdjust).." today! Give a wish :)")
					else
						user:SendData(Settings.sBot,"**** Hey, I know! You have your Birthday TODAY! Happiest of Birthdays!")
						SendToAll(Settings.sBot, "*** Guys!!! "..user.sName.." is here! What do we say? :)")
					end
				end,
				["OnTimer"] = function()
					local tNow = {}
					if GetItemByName(i) then
						local user = GetItemByName(i)
						local T = os.date("*t",os.difftime(os.time(os.date("*t")),os.time(os.date("*t",v.iJulian))))
						local iAge = (T.year - 1970 + v.iAdjust)
						local tSurprise = {
							user.sName.." is gonna have a PAAARTY today! He/She is turning "..
							iAge.."! Happy Birthday!!!",
							"All of you: Spam "..user.sName.." with Birthday messages ;) ... turning "..
							iAge.." today!!!",
							"Who's turning "..iAge.." today? :D The day AND the night belongs to "..
							user.sName.."!",
							"Happy Birthday to you, Happy Birthday dear "..user.sName..
							", we all wish you that "..iAge.." will be better than your "..
							(iAge-1).."! :)",
							"I think Mr "..user.sName.." has his/her birthday today. He/She should be "..
							"turning "..iAge.." today ;D",
							"A "..Zodiac(tonumber(os.date("%m",v.iJulian))).." is turning "..iAge
							.." today! It's "..user.sName.."'s birthday!!!"
						}
						SendToAll(Settings.sBot,tSurprise[math.random(1,table.getn(tSurprise))])
					end
				end,
			}
			if tTable[Mode] then return tTable[Mode]() end
		end
	end
end

JulianToDate = function(v)
	local iYear = (os.date("%Y",v.iJulian) - v.iAdjust)
	local sDate = os.date("%B %d, "..iYear,v.iJulian)
	local sWDay, sZodiac = os.date("%A",v.iJulian), Zodiac(tonumber(os.date("%m",v.iJulian)))
	return sDate, sWDay, sZodiac
end

Zodiac = function(iMonth)
	local tZodiac = {
		[01] = "Aquarius", [02] = "Pisces", [03] = "Aries", [04] = "Taurus",  [05] = "Gemini", [06] = "Cancer",
		[07] = "Leo", [08] = "Virgo", [09] = "Libra", [10] = "Scorpio", [11] = "Sagittarius", [12] = "Capricorn",
	}
	if tZodiac[iMonth] then return tZodiac[iMonth] end
end

JulianToTime = function(user)
	local iDiff = os.difftime(os.time(os.date("*t")),os.time(os.date("*t",tBirthday[user.sName].iJulian)))
	if iDiff > 0 then
		local T = os.date("*t",iDiff)
		return string.format("%i year(s), %i month(s) and %i day(s)", (T.year-1970+tBirthday[user.sName].iAdjust), (T.month-1), (T.day-1), T.hour, T.min, T.sec)
	end
end