--[[ 

	Birthday Man v.4.06 - LUA 5.0/5.1 by jiten (7/15/2006)

	Based on: BirthdayMan v 3.5 by Herodes and mods by Cêñoßy†ê

	Changelog:
	
	Rewritten: Whole code;

	Changed: Command structure to tables (Function, Permissions, RightClick and Ddescription);
	Changed: B-Day table structure to Julian values;
	Removed: File content that was sent on B-Day;
	Removed: Allowed Age;
	Removed: Topic updater (maybe in the future);
	Changed: Whole B-Day counting system to os.*;
	Changed: Commands returned according to input (Main or PM);
	Changed: Many other mods that can't recall at the moment (12-04-2006);
	Added: addbirthday command - requested by TT (13-04-2006);
	Fixed: Zodiac Sign Dates - thanks to Walazo;
	Changed: Error message on empty !bornon result - thanks to Walazo;
	Changed: !birthdays' content structure to fix bad tabbing;
	Changed: Settings.iVer;
	Added: string.lower checks - thanks to Walazo (4/14/2006)
	Fixed: !bornon Year function - thanks to Walazo
	Added: sNick to keep original nick - requested by TT (4/15/2006);
	Changed: *t to !*t;
	Fixed: Birthday is at midnight - reported by TT (6/25/2006)
	Added: Send Text File content - requested by TT (7/6/2006)
	Added: Hub Topic updater - requested by UwV (7/11/2006)
	Added: Celebrity's feature - requested by UwV (7/15/2006)

]]--

-- Edit at will
Settings = {
	-- Bot's Name
	sBot = "B-Day",
	-- Script version
	iVer = "4.06",
	-- Register in userlist
	bReg = false,

	-- Send File Content (true = on, false = off)
	bSendText = false,
	-- Birthday Text File
	fText = "cake.txt",

	-- Update hub topic (true = on, false = off)
	bUpdateTopic = false,
	-- Use Celebrity's command (true = on, false = off)
	bCelebrity = false,

	-- Minimum allowed year
	iMin = 1900,
	-- Time to check for B-Dayers (in hours)
	iTime = 12,
	-- B-Day Man DB
	fBirth = "tBirthday.tbl",
	-- Celebrity's DB
	fCelebrity = "tCelebrity.tbl"
}

tBirthday = {}

Main = function()
	if loadfile(Settings.fBirth) then dofile(Settings.fBirth) end
	-- garbagecollect method (Based on Mutor's)
	gc = nil; if _VERSION == "Lua 5.1" then gc = "collect" end
	if (Settings.sBot ~= frmHub:GetHubBotName()) or Settings.bReg then frmHub:RegBot(Settings.sBot) end
	SetTimer(Settings.iTime*60*60*1000); StartTimer()
end

OnTimer = function()
	-- Check B-Days
	tFunctions.BDayCheck("OnTimer")
	-- Collect garbage
	collectgarbage(gc); io.flush()
end

NewUserConnected = function(user)
	if user.bUserCommand then
		for i, v in pairs(tCommands) do
			if v.tLevels[user.iProfile] then
				local sRC = string.gsub(v.tRC, "{}", i)
				user:SendData("$UserCommand 1 3 B-Day Bot\\"..sRC.."&#124;")
			end
		end
	end
	-- Check B-Days on connect
	tFunctions.BDayCheck("OnConnect", user)
end

OpConnected = NewUserConnected

ChatArrival = function(user, data)
	local _,_, to = string.find(data, "^$To:%s(%S+)%s+From:")
	local _,_, cmd = string.find(data, "%b<>%s+[%!%+](%S+).*|$") 
	if cmd then
		if tCommands[string.lower(cmd)] then
			cmd = string.lower(cmd)
			if to == Settings.sBot then user.SendMessage = user.SendPM else user.SendMessage = user.SendData end
			if tCommands[cmd].tLevels[user.iProfile] then
				return tCommands[cmd].tFunc(user, data), 1
			else
				return user:SendMessage(Settings.sBot, "*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

ToArrival = ChatArrival

tCommands = {
	mybirthday = {
		tFunc = function(user, data)
			if tBirthday[string.lower(user.sName)] then
				local sDate = tFunctions.JulianToDate(tBirthday[string.lower(user.sName)])
				user:SendMessage(Settings.sBot, "*** Error: I already have your Birthday on "..sDate..
				"! If it wasn't correctly set, ask Operators for help!")
			else
				local _,_, args = string.find(data, "^%b<>%s+%S+%s+(.*)|$")
				if args then
					local _,_, d, m, y = string.find(args, "^(%d%d)\/(%d%d)\/(%d%d%d%d)$")
					if d and m and y then
						tFunctions.AddBirth(user, user.sName, args, d, m, y)
					else
						user:SendMessage(Settings.sBot, "*** Error: Birthday syntax must be - dd/mm/yyyy")
					end
				else
					user:SendMessage(Settings.sBot, "*** Syntax Error: Type !mybirthday dd/mm/yyyy")
				end
			end
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\tAdds your B-Day",
		tRC = "Add your B-Day$<%[mynick]> !{} %[line:dd/mm/yyyy]"
	},
	addbirthday = {
		tFunc = function(user, data)
			local _,_, args = string.find(data, "^%b<>%s+%S+%s+(.*)|$")
			if args then
				local _,_, nick,d,m,y = string.find(args, "^(%S+)%s+(%d%d)\/(%d%d)\/(%d%d%d%d)$")
				if d and m and y and nick then
					if tBirthday[string.lower(nick)] then
						local sDate = tFunctions.JulianToDate(tBirthday[string.lower(nick)])
						user:SendMessage(Settings.sBot, "*** Error: I already have "..nick.."'s Birthday on "..sDate..
						"! If it wasn't correctly set, ask Operators for help!")
					else
						tFunctions.AddBirth(user, nick, args, d, m, y)
					end
				else
					user:SendMessage(Settings.sBot, "*** Error: Birthday syntax must be: <nick> dd/mm/yyyy")
				end
			else
				user:SendMessage(Settings.sBot, "*** Syntax Error: Type !addbirthday <nick> dd/mm/yyyy")
			end
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\tAdds another user's B-Day",
		tRC = "Add another user's B-Day$<%[mynick]> !{} %[line:Nick] %[line:dd/mm/yyyy]"
	},
	delbirthday = {
		tFunc = function(user, data)
			local _,_, nick = string.find(data, "^%b<>%s+%S+%s+(%S+).*|$")
			if nick then
				if tBirthday[string.lower(nick)] then
					tBirthday[string.lower(nick)] = nil; tFunctions.SaveToFile(Settings.fBirth, tBirthday, "tBirthday")
					user:SendMessage(Settings.sBot, "*** Success: "..nick.."'s Birthday was successfully deleted from the DB!")
				else
					user:SendMessage(Settings.sBot, "*** Error: "..nick.."'s Birthday hasn't been added to the DB yet; or there's a Syntax Error: Type !delbirthday <nick>")
				end
			else
				user:SendMessage(Settings.sBot, "*** Syntax Error: Type !delbirthday <nick>")
			end
		end,
		tLevels = {
			[0] = 1, [5] = 1,
		},
		sDesc = "\tDelete a specific B-Day",
		tRC = "Delete user's B-Day$<%[mynick]> !{} %[line:Nick]"
	},
	birthdays = {
		tFunc = function(user)
			if next(tBirthday) then
				local sMsg, n = "\r\n\t"..string.rep("=", 105).."\r\n\tNr.\tStatus:\t\tZodiac Sign:\tWeekday:"..
				"\tBirthdate:\t\t\tName:\r\n\t"..string.rep("-", 210).."\r\n", 0
				for i, v in pairs(tBirthday) do
					local sStatus = "*Offline*"
					n = n + 1; if GetItemByName(i) then sStatus= "*Online*" end; 
					local sDate, sWDay, sZodiac = tFunctions.JulianToDate(v)
					sMsg = sMsg.."\t"..n..".\t"..sStatus.."\t\t"..sZodiac.."\t\t"..sWDay.."\t\t"..sDate.."\t\t"..v.sNick.."\r\n"
				end
				user:SendMessage(Settings.sBot, sMsg)
			else
				user:SendMessage(Settings.sBot, "*** Error: There are no saved Birthdays!")
			end
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\t\tShows all Birthdays",
		tRC = "Show all B-Days$<%[mynick]> !{}"
	},
	myage = {
		tFunc = function(user)
			if tBirthday[string.lower(user.sName)] then
				user:SendMessage(Settings.sBot, "*** You're "..tFunctions.JulianToTime(user).." old according to the Hub's clock!")
			else
				user:SendMessage(Settings.sBot, "*** Error: Please add your Birthday before using this command. Type !"..
				"bhelp for more details!")
			end
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\t\tDisplays your exact age",
		tRC = "Show your age$<%[mynick]> !{}"
	},
	bhelp = {
		tFunc = function(user)
			local sMsg = "\r\n\t\t"..string.rep("-", 190).."\r\n"..string.rep("\t", 5).."BirthdayMain v."..
			Settings.iVer.." by jiten; based on: Herodes'\t\t\t\r\n\t\t"..string.rep("-", 190).."\r\n\t\tAvailable Commands:".."\r\n\r\n"
			for i, v in pairs(tCommands) do
				if v.tLevels[user.iProfile] then
					sMsg = sMsg.."\t\t!"..i.."\t\t"..v.sDesc.."\r\n"
				end
			end
			user:SendMessage(Settings.sBot, sMsg.."\t\t"..string.rep("-", 190));
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\t\tDisplays this help message",
		tRC = "Show command list$<%[mynick]> !{}"
	},
	bornon = {
		tFunc = function(user)
			if tBirthday[string.lower(user.sName)] then
				local sMsg, tSame, tUser = "", {}, tBirthday[string.lower(user.sName)]
				local tTable = { 
					["%m"] = { sDesc = "Month" }, ["%d"] = { sDesc = "Day" }, 
					["%y"] = { sDesc = "Year", bExtend = true }
				}
				for i, v in pairs(tBirthday) do
					if i ~= string.lower(user.sName) then
						for a, b in pairs(tTable) do
							local T, L = os.date("!*t", v.iJulian), os.date("!*t", tUser.iJulian)
							local tFunction = function()
								if tSame[b.sDesc] then tSame[b.sDesc] = tSame[b.sDesc].."; "..v.sNick else tSame[b.sDesc] = v.sNick end
							end
							if b.bExtend then
								if T.year - v.iAdjust == L.year - tUser.iAdjust then tFunction() end
							else
								if os.date(a, v.iJulian) == os.date(a, tUser.iJulian) then tFunction() end
							end
						end
					end
				end
				for i, v in pairs(tSame) do sMsg = sMsg.."\t"..i.."\t"..v.."\r\n" end;
				if sMsg ~= "" then
					user:SendMessage(Settings.sBot, "\r\n\t"..string.rep("=", 105)..
					"\r\n\t\t\t\t\t\tPeople born in the same \"Field\" as yours:\r\n\tField:"..
					"\tNick:\r\n\t"..string.rep("-", 210).."\r\n"..sMsg) 
				else
					user:SendMessage(Settings.sBot, "*** Error: There are no common Birthday fields!") 
				end
			else 
				user:SendMessage(Settings.sBot, "*** Error: Please add your Birthday before using this command. Type !"..
				"bhelp for more details!")
			end
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\t\tShows users with whom you share your Birthday",
		tRC = "Show list of users you share dates$<%[mynick]> !{}"
	},
	celeb = {
		tFunc = function(user)
			if Settings.bCelebrity then
				if loadfile(Settings.fCelebrity) then dofile(Settings.fCelebrity) end
				local sMsg, tSame, tUser = "", {}, tBirthday[string.lower(user.sName)]
				if tUser then
					for i, v in pairs(tCelebrity) do
						if os.date("%m%d", v.iJulian) == (os.date("%m%d", tUser.iJulian)) then
							sMsg = sMsg.." • "..v.sNick..";\r\n\t"
						end
					end
					user:SendMessage(Settings.sBot, "\r\n\t"..string.rep("=", 105)..
					"\r\n\t\t\t\t\tCelebrities born on the same Day - Month ["..os.date("%d - %b", tUser.iJulian).."] as you:\r\n\t"..
					string.rep("-", 210).."\r\n\t"..sMsg); collectgarbage(gc); io.flush()
				else
					user:SendMessage(Settings.sBot, "*** Error: Please add your Birthday before using this command. Type !"..
					"bhelp for more details!")
				end
			else
				user:SendMessage(Settings.sBot, "*** Error: Celebrity's command is disabled!")
			end
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\t\tShows a list of celebrities that share your birthday",
		tRC = "Shows celebrities that share your birthday$<%[mynick]> !{}"
	}
}

tFunctions = {}
tFunctions.AddBirth = function(user, nick, args, d, m, y)
	if tonumber(y) > Settings.iMin then
		local tmp
		if tonumber(y) < 1970 then tmp = 1970 - y; y = 1970 else tmp = 0 end
		local tTable = { day = tonumber(d), month = tonumber(m), year = tonumber(y), hour = 0, min = 0, sec = 0 }
		tBirthday[string.lower(nick)] = { sNick = nick, iJulian = os.time(tTable), iAdjust = tmp }
		tFunctions.SaveToFile(Settings.fBirth, tBirthday, "tBirthday")
		local sDate, sWDay, sZodiac = tFunctions.JulianToDate(tBirthday[string.lower(nick)])
		user:SendMessage(Settings.sBot, "*** "..nick.."'s Birthday is on "..sDate.."! I didn't "..
		"know "..nick.." was a "..tFunctions.Zodiac(tBirthday[string.lower(nick)].iJulian).."!")
		user:SendMessage(Settings.sBot, "*** New Birthday added by "..user.sName.." on: "..sDate);
	else
		user:SendMessage(Settings.sBot, "*** Error: The miminum allowed year is "..Settings.iMin.."!")
	end
end

tFunctions.BDayCheck = function(Mode, nick)
	local sTopic = nil
	-- Check B-Days
	for i, v in pairs(tBirthday) do
		if os.date("%m%d", v.iJulian) == (os.date("%m%d")) then
			if sTopic then sTopic = sTopic.."; "..v.sNick else sTopic = v.sNick end
		end
		if sTopic and tFunctions[Mode] then tFunctions[Mode](nick, i, v, sTopic) end
	end
end

tFunctions.OnConnect = function(user, i, v)
	if i ~= string.lower(user.sName) then
		local T = os.date("!*t", os.difftime(os.time(os.date("!*t")), os.time(os.date("!*t", v.iJulian))))
		user:SendData(Settings.sBot, "*** It's "..v.sNick.."'s Birthday today! :D He/She is turning "..
		(T.year-1970+v.iAdjust).." today! Give a wish :)")
	else
		user:SendData(Settings.sBot, "**** Hey, I know! You have your Birthday TODAY! Happiest of Birthdays!")
		SendToAll(Settings.sBot, "*** Guys!!! "..user.sName.." is here! What do we say? :)")
	end
end

tFunctions.OnTimer = function(user, i, v, sTopic)
	if GetItemByName(i) then
		-- Send File Content
		if Settings.bSendText then
			local sMsg = ""
			local f = io.open(Settings.fText)
			if f then sMsg = f:read("*all"); f:close() end
			SendToAll(Settings.sBot, "\r\n\r\n"..sMsg)
		end
		-- Send Message
		local user = GetItemByName(i)
		local T = os.date("!*t", os.difftime(os.time(os.date("!*t")), os.time(os.date("!*t", v.iJulian))))
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
			"A "..tFunctions.Zodiac(v.iJulian).." is turning "..iAge
			.." today! It's "..user.sName.."'s birthday!!!"
		}
		SendToAll(Settings.sBot, tSurprise[math.random(1, table.getn(tSurprise))])
	end
	-- Update Topic
	if Settings.bUpdateTopic then
		local _,_, sHubTopic = string.find((frmHub:GetHubTopic() or ""), "(.-)%s-%sToday's.*")
		frmHub:SetHubTopic((sHubTopic or "").."Today's birthday(s): "..sTopic)
	end
end

tFunctions.JulianToDate = function(v)
	local iYear = (os.date("%Y", v.iJulian) - v.iAdjust)
	local sDate = os.date("%b %d, "..iYear, v.iJulian)
	local sWDay, sZodiac = os.date("%a", v.iJulian), tFunctions.Zodiac(v.iJulian)
	return sDate, sWDay, sZodiac
end

tFunctions.Zodiac = function(iJulian)
	local tZodiac = {
		[01] = { 20, "Capricorn", "Aquarius" }, [02] = { 19, "Aquarius", "Pisces" },
		[03] = { 21, "Pisces",  "Aries" }, [04] = { 20, "Aries", "Taurus" }, 
		[05] = { 21, "Taurus", "Gemini" }, [06] = { 21, "Gemini", "Cancer" },
		[07] = { 23, "Cancer", "Leo" }, [08] = { 23, "Leo", "Virgo" },
		[09] = { 23, "Virgo", "Libra" }, [10] = { 23, "Libra", "Scorpio" },
		[11] = { 22, "Scorpio", "Sagittarius" }, [12] = { 22, "Sagittarius", "Capricorn"},
	}
	local tTmp = tonumber(os.date("%m", iJulian))
	if tZodiac[tTmp][1] > tonumber(os.date("%d", iJulian)) then return tZodiac[tTmp][2] else  return tZodiac[tTmp][3] end
end

tFunctions.JulianToTime = function(user)
	local iDiff = os.difftime(os.time(os.date("!*t")), os.time(os.date("!*t", tBirthday[string.lower(user.sName)].iJulian)))
	if iDiff > 0 then
		local T = os.date("!*t", iDiff)
		return string.format("%i year(s), %i month(s) and %i day(s)", (T.year-1970+tBirthday[string.lower(user.sName)].iAdjust), (T.month-1), (T.day-1), T.hour, T.min, T.sec)
	end
end

tFunctions.Serialize = function(tTable, sTableName, hFile, sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key, value in pairs(tTable) do
		if (type(value) ~= "function") then
			local sKey = (type(key) == "string") and string.format("[%q]", key) or string.format("[%d]", key);
			if(type(value) == "table") then
				tFunctions.Serialize(value, sKey, hFile, sTab.."\t");
			else
				local sValue = (type(value) == "string") and string.format("%q", value) or tostring(value);
				hFile:write(sTab.."\t"..sKey.." = "..sValue);
			end
			hFile:write(",\n");
		end
	end
	hFile:write(sTab.."}");
end

tFunctions.SaveToFile = function(file, table, tablename)
	local hFile = io.open(file, "w+") tFunctions.Serialize(table, tablename, hFile); hFile:close() 
end