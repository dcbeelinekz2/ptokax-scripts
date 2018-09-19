--[[

	FilterBan v1.0 BETA - LUA 5.0/5.1 by jiten (5/29/2006)
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	Based on: FilterBan v 0.0.0.4 (beta) by Hellkeepa

	A thousand thanks to Mutor (suggestions); and Toobster (debugging, suggestions)

	DESCRIPTION:
	¯¯¯¯¯¯¯¯¯¯¯¯
	Upon !fban'ing a certain user, its details are added to the table:

	Nick$ShareSize$Description$Client$ClientVersion$sMode$OpHubs$Hubs$Slots$IP$Connection$Email$TimesBanned$BanType$

	Then, whenever a user logs in, his info is checked against the one previously stored.
	This comparison is based on the filters found in tRules. Some of them are hard (accurate) and some aren't (fuzzy).
	Depending on the miminum allowed rules (Settings.iFuzzy; Settings.iHard), the user is temp/permbanned or 
	a suspision report is sent to Operators and no action is taken.

	Requirements for immediate perm/tempban:

	- Hard rules are equal or higher than Settings.iHard; or 
	- Fuzzy rules are equal or higher than Settings.iFuzzy; or
	- One (1) hard rule AND Settings.iFuzzy - 1 fuzzy rules register as true.

	Requirements to generate suspision report for OPs (without any action):

	- One (1) or more Fuzzy AND One (1) or more Hard rules register true; or
	- Two (2) or more Fuzzy rules register true.

	FILTERS:
	¯¯¯¯¯¯¯¯
	These are the filters mentioned above by type (hard/fuzzy).
	Each filter contains several fields that must match connecting user's in order to return true.
	
	Filter													Type

	1. ClientName & ClientVersion & Mode & HubCount								(hard)
	2. ClientName & ClientVersion & Mode & OpHubCount							(hard)
	3. ClientName & ClientVersion & Mode & Slots								(fuzzy)
	4. ClientName & Mode & HubCount										(fuzzy)
	5. ClientName & ClientVersion & HubCount								(fuzzy)
	6. ClientName & Mode & OpHubCount									(fuzzy)

	7. Share Size ~= 100 MB											(hard)
	8. Connection type											(fuzzy)
	9. Username												(hard)
	10. Description												(fuzzy)
	11. E-Mail												(hard)
	12. IP													(fuzzy)

	USAGE:
	¯¯¯¯¯¯
	!fban <nick> <Reason> [time]
		If nick is given it'll automatically add the IP as well to the standard banlist.
		Reason for the ban, works like normal ban/kick-command.
		[Time] for temp-bans.
		*** Example: !fban Hellkeepa Testing this script 1h

	!fb_set <filter> <on|off> [h|f]
		"Filter" is the name of the corresponding filter you want to turn on/off.
		"on" will turn the filter on, "off" will turn it off.
		Adding "h" or "f" to the end will determine wether the rule is "hard" or "fuzzy".

	!funban <IP>
		Unbans a specific user previously banned with !fban

	!listbans
		Lists currently stored FilterBans

]]--

-- Edit at will
Settings = {
	-- Bot's Name
	sBot = "FilterBan",
	-- BotName where the Ban/Suspect messages are sent in PM
	sTo = frmHub:GetOpChatName(),
	-- Script version
	iVer = "1.0",
	-- Rightclick Menu
	sMenu = "FilterBan",
	-- Register in userlist
	bReg = false,
	-- Full Ban (1 = on; 0 = off)
	bFullBan = 0,
	-- Minimum Number of "fuzzy" rules to break to trigger filter (don't change if you don't know how to)
	iFuzzy = 3,
	-- Minimum Number of "hard" rules to break to trigger filter (don't change if you don't know how to)
	iHard = 2,
	-- Maximum TempBbans allowed to permanently Ban user
	iMaxTempBans = 3,
	-- Timespan between BanList Check (minutes)
	iTime = 30,
	-- Ban Message
	sMsg = "You are banned, no coming back until it's lifted.",
	-- FilterBan DB
	fBan = "tBan.tbl",
}

tBan = {}; tFunctions = {}

-- Rules' table (don't change if you don't know how to)
tRules = {

	--[[
		Rule Name = {
			bEnable = true/false,	[Enable/Disable]
			sFilter = h/f,		[Hard/Fuzzy]
			bCalc = true/false	[Sharesize related]
			tRules = { ... }	[Fields to check]
		}
	]]--

	Tag1 = { 
		bEnable = true, sFilter = "h", 
		tRules = { "sClient", "sClientVersion", "sMode", "iHubs" } },
	Tag2 = { 
		bEnable = true, sFilter = "h",
		tRules = { "sClient", "sClientVersion", "sMode", "iOpHubs" } },
	Tag3 = { 
		bEnable = true, sFilter = "f",
		tRules = { "sClient", "sClientVersion", "sMode", "iSlots" } },
	Tag4 = { 
		bEnable = true, sFilter = "f",
		tRules = { "sClient", "sMode", "iHubs" } },
	Tag5 = { 
		bEnable = true, sFilter = "f",
		tRules = { "sClient", "sClientVersion", "iHubs" } },
	Tag6 = { 
		bEnable = true, sFilter = "f",
		tRules = { "sClient", "sMode", "iOpHubs" } },
	Share  = {
		bEnable = true, sFilter = "h", bCalc = true,
		tRules = { "iShareSize" } },
	Connection = { 
		bEnable = true, sFilter = "f",
		tRules = { "sConnection" } },
	Nick = { 
		bEnable = true , sFilter = "h",
		tRules = { "sName" } },
	IP = { 
		bEnable = true, sFilter = "f",
		tRules = { "sIP" } },
	Description = { 
		bEnable = true, sFilter = "f",
		tRules = { "sDescription" } },
	Email = { 
		bEnable = true, sFilter = "h",
		tRules = { "sEmail" } }
}

Main = function()
	-- Load tBan content
	if loadfile(Settings.fBan) then dofile(Settings.fBan) end
	-- Register Bot
	if (Settings.sBot ~= frmHub:GetHubBotName()) or Settings.bReg then frmHub:RegBot(Settings.sBot) end
	-- string.gmatch/gfind and garbagecollect method (Based on Mutor's)
	fMatch, gc = string.gfind, nil
	if _VERSION == "Lua 5.1" then fMatch = string.gmatch; gc = "collect" end
	-- Set and start timer
	SetTimer(Settings.iTime*60*1000); StartTimer(); OnTimer()
end

ChatArrival = function(user,data)
	-- Parse necessary vars
	local s,e,to = string.find(data,"^$To:%s(%S+)%s+From:")
	local s,e,cmd = string.find(data,"%b<>%s+[%!%+](%S+).*|$") 
	-- Prefix found
	if cmd then
		-- Table command
		if tCommands[string.lower(cmd)] then
			cmd = string.lower(cmd)
			if to == Settings.sBot then user.SendMessage = user.SendPM else user.SendMessage = user.SendData end
			if tCommands[cmd].tLevels[user.iProfile] then
				-- Return function
				return tCommands[cmd].tFunc(user,data), 1
			else
				return user:SendMessage(Settings.sBot,"*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

ToArrival = ChatArrival

MyINFOArrival = function(user,data)
	-- Check if not operator and not connected
	if not user.bOperator and not user.bConnected then
		-- Define vars
		local Rules, doTag, sNick = { f = { 0 }, h = { 0 } }, "f"
		for i,v in pairs(tRules) do
			-- If Rule is enabled
			if v.bEnable then
				-- string.sub first 3 chars
				local sTag = string.sub(i,1,3)
				if (sTag == "Tag" and (doTag == "f" or (doTag == "h" and v.sFilter == "h")) or not sTag ~= "Tag") then
					local iCount = 0
					-- For each rule in Filter
					for ext, str in ipairs(v.tRules) do
						-- For each filterbanned user
						for n, info in ipairs(tBan) do
							-- Create user object
							local nick = tFunctions.CreateObject(tBan[n])
							-- If user.str / not equal to "" / table data isn't empty
							if user[str] and user[str] ~= "" and nick[str] ~= "" then
								-- if user.str and table's info is identical
								if tFunctions.HitFilter(user[str], nick[str], v.bCalc) then
									-- Count
									iCount = iCount + 1
									-- All fields of the rule are the same
									if iCount == table.getn(v.tRules) then
										-- Sum to Rules custom table
										Rules[v.sFilter][1] = Rules[v.sFilter][1] + 1;
										-- Add Rule Name to custom table
										if Rules[v.sFilter].sMsg then 
											Rules[v.sFilter].sMsg = Rules[v.sFilter].sMsg.."; "..i
										else
											Rules[v.sFilter].sMsg = i
										end
										-- Capture nick
										sNick = nick
										-- Tag based filter
										if sTag == "Tag" then
											-- Adjust filter table
											tFunctions.UpdateFilter(Rules, doTag, v.sFilter)
										end
									end
								end
							end
						end
					end
				end
			end
			-- Garbage Collector
			collectgarbage(gc)
		end
		-- Report and take action
		if sNick then tFunctions.Report(user, Rules, sNick) end
	end
end

NewUserConnected = function(user)
	-- If UserCommand
	if user.bUserCommand then
		-- For each value in tCommands
		for i,v in pairs(tCommands) do
			-- If user's profile has permission
			if v.tLevels[user.iProfile] then
				-- For each n in tRC
				for n in ipairs(v.tRC) do
					-- Replace {} with the command name
					local sRC = string.gsub(v.tRC[n],"{}",i)
					-- Send
					user:SendData("$UserCommand 1 3 "..Settings.sMenu.."\\"..sRC.."&#124;")
				end
			end
		end
	end
end

OpConnected = NewUserConnected

OnTimer = function()
	-- Custom frmHub table
	local tTable = { ["perm"] = frmHub:GetPermBanList(), ["temp"] = frmHub:GetTempBanList() }
	-- Read tBans inversely
	for n = table.getn(tBan), 1, -1 do
		-- Create user object
		local nick, Exists = tFunctions.CreateObject(tBan[n]), nil
		-- For each frmHub banned user
		for i,v in ipairs(tTable[nick.sBanType]) do
			-- Both IPs are the same
			if v.sIP == nick.sIP then Exists = 1 end
		end
		-- Delete if doesn't exist
		if not Exists then table.remove(tBan,n) end
	end
end

OnExit = function()
	-- Save table content
	local hFile = io.open(Settings.fBan,"w+"); tFunctions.Serialize(tBan, "tBan", hFile); hFile:close() 
end

tCommands = {
	fbset = {
		tFunc = function(user,data)
			local s,e,rule = string.find(data,"^%b<>%s+%S+%s+(%w+).*|$")
			if rule then
				if tRules[rule] then
					local s,e,stat,type = string.find(data,"^%b<>%s+%S+%s+%S+%s+(%w+)%s?([%w]?).*|$")
					if stat then
						local tTable = {
							tStatus = { on = true, off = false },
							tType = { f = { bType = true, sDesc = "Fuzzy" }, h = { bType = false, sDesc = "Hard" } }
						}
						-- On/off
						if tTable.tStatus[string.lower(stat)] then
							local sStat, sRule = string.lower(stat), string.lower(rule)
							tRules[sRule].bStatus = tTable.tStatus[sStat]
							-- Fuzzy/Hard
							if type then
								local sType = string.lower(type)
								if tTable.tType[sType] then
									tRules[sRule].bFuzzy = tTable.tType[sType].bType
									user:SendMessage(Settings.sBot,"*** Type changed to \""..
									tTable.tType[sType].sDesc.."\" for rule '"..rule.."'.")
								end
							end
							user:SendMessage(Settings.sBot,"*** Rule '"..rule.."' successfully turned "..
							sStat.."!")
						else
							user:SendMessage(Settings.sBot,"*** Error: No valid status given. No"..
							"changes done!")
						end
					else
						user:SendMessage(Settings.sBot,"*** Syntax Error: Type: !fbset <filter> <on/off> <f/h>")
					end
				else
					user:SendMessage(Settings.sBot,"*** Error: No rule by the name \""..rule.."\" exists. "..
					"Please try again!")
				end
			else
				user:SendMessage(Settings.sBot,"*** Syntax Error: Type !fbset <filter> <on/off> <f/h>")
			end
		end,
		tLevels = {
			[0] = 1, [5] = 1,
		},
		sDesc = "\tSetup FilterBan",
		tRC = { "Setup$<%[mynick]> !{} %[line:Filter] %[line:<on/off>] %[line:<f/h>]" }
	},
	fban = {
		tFunc = function(user,data)
			local s,e,nick,rnb = string.find(data,"^%b<>%s+%S+%s+(%S+)%s+(.*)|$")
			if nick and rnb then
				if GetItemByName(nick) then
					local nick, Exists, iIndex = GetItemByName(nick)
					-- For each filterban
					for i in ipairs(tBan) do
						-- Parse IP
						local s,e,sIP = string.find(tBan[i],"(%d+%.%d+%.%d+%.%d+)")
						-- IP exists
						if sIP == nick.sIP then 
							Exists = tonumber(i); s,e,iIndex = string.find(tBan[i],"%$(%d+)%$%S+%$$")
						end; break
					end
					-- If reason
					if rnb then
						-- If timeban
						local s,e,reason,time = string.find(rnb, "(.*)%s+(%d+%w)"); 
						local sType, sReason = "perm", rnb
						-- Define Ban type
						if time then sType, sReason = "temp", reason end
						-- Generate Ban Entry
						if Exists then
							-- Replace existing Ban
							tFunctions.AddToTable(nick, sType, Exists, iIndex)
						else
							-- Add new Ban
							tFunctions.AddToTable(nick, sType)
						end
						-- Take Action
						tFunctions.TakeAction(nick, sReason, user.sName, sType, tFunctions.GetBanTime(time or 0), (iIndex or 1))
						-- Report
						SendPmToOps(Settings.sTo,"*** "..user.sName.." "..sType.."banned "..nick.sName.." ("..nick.sIP..") because: "..rnb)
						nick:SendPM(Settings.sBot,"*** "..Settings.sMsg.." Reason: "..rnb)
						-- Disconnect
						--nick:Disconnect()
					else
						user:SendMessage(Settings.sBot,"*** Error: You must type a reason!")
					end
				else
					user:SendMessage(Settings.sBot,"*** Error: '"..nick.."' isn't online!")
				end
			else
				user:SendMessage(Settings.sBot,"*** Syntax Error: Type !fban <nick> <reason>")
			end
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\tFilterBan's Ban command",
		tRC = { "PermBan User$<%[mynick]> !{} %[nick] %[line:Reason]", 
			"TimeBan User$<%[mynick]> !{} %[nick] %[line:Reason] %[line:Time:<m/h/d/w>]"
		}
	},
	funban = {
		tFunc = function(user,data)
			local s,e,IP = string.find(data,"^%b<>%s+%S+%s+(%d+%.%d+%.%d+%.%d+).*|$")
			if IP then
				local nick = nil
				-- For each filterban
				for i in ipairs(tBan) do
					-- Parse IP
					local s,e,sIP = string.find(tBan[i],"(%d+%.%d+%.%d+%.%d+)")
					-- Remove existing IP
					if sIP == IP then 
						nick = tBan[i]; table.remove(tBan, i)
					end
				end
				if nick then
					-- Get Ban Type
					local s,e,sBanType = string.find(nick,"%$(%w+)%$$")
					local tTable = { 
						["perm"] = { tTbl = frmHub:GetPermBanList(), tFunc = function() Unban(IP) end },
						["temp"] = { tTbl = frmHub:GetTempBanList(), tFunc = function() TempUnban(IP) end }
					}
					-- For each ban in frmHub tables
					for i,v in ipairs(tTable[sBanType].tTbl) do
						-- Unban IP
						if v.sIP == IP then tTable[sBanType].tFunc() end
					end
					user:SendMessage(Settings.sBot,"*** "..IP.." ban has been successfully removed from the ban list!")
				else
					user:SendMessage(Settings.sBot,"*** Error: "..IP.." hasn't been banned yet!")
				end
			else
				user:SendMessage(Settings.sBot,"*** Syntax Error: Type !funban <nick>")
			end
		end,
		tLevels = {
			[0] = 1, [5] = 1,
		},
		sDesc = "\tFilterBan's IP unban command",
		tRC = { "Unban IP$<%[mynick]> !{} %[line:IP]" }
	},
	fbhelp = {
		tFunc = function(user)
			-- Help menu
			local sMsg = "\r\n\t\t"..string.rep("-", 190).."\r\n"..string.rep("\t",5).."FilterBan v."..
			Settings.iVer.." by jiten; based on: Hellkeepa's\t\t\t\r\n\t\t"..string.rep("-",190).."\r\n\t\tAvailable Commands:".."\r\n\r\n"
			-- For each field in tCommands
			for i,v in pairs(tCommands) do
				-- If user's profile has permission
				if v.tLevels[user.iProfile] then
					-- Process
					sMsg = sMsg.."\t\t!"..i.."\t\t"..v.sDesc.."\r\n"
				end
			end
			user:SendMessage(Settings.sBot, sMsg.."\t\t"..string.rep("-",190));
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\tList current Filterbans",
		tRC = { "List Bans$<%[mynick]> !{}" }
	},
	listbans = {
		tFunc = function(user)
			local tTable, sMsg = { ["perm"] = frmHub:GetPermBanList(), ["temp"] = frmHub:GetTempBanList() }, ""
			if next(tBan) then
				-- For each filterban
				for i,v in ipairs(tBan) do
					-- Create user object
					local nick = tFunctions.CreateObject(tBan[i])
					-- Generate content
					sMsg = sMsg.."\r\n\r\n\t"..string.rep("=",40).."\r\n\t\t*Banned IP*\t*User*\r\n\t"..
					string.rep("-",80).."\r\n\t\t"..nick.sIP.."\t\t"..nick.sName.."\r\n"
				end
				user:SendMessage(Settings.sBot, sMsg);
			else
				user:SendMessage(Settings.sBot, "*** Error: Filter Ban database is empty!")
			end
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\tDisplays this help message",
		tRC = { "Show command list$<%[mynick]> !{}" }
	},
}

tFunctions.UpdateFilter = function(Rules, doTag, sFilter)
	-- Check if previous "fuzzy" tag filter should be upgraded.
	if sFilter == "h" and doTag == "h" then
		-- Remove one from failed fuzzy triggers.
		Rules["f"][1] = Rules["f"][1] - 1;
	-- Check if a Tag filter was triggered, and break if it was.
	elseif sFilter == "f" then
		doTag = "h"; 
	else
		doTag = false
	end
end

tFunctions.HitFilter = function(Actual, Table, bCalc)
	-- If rule is Share
	if bCalc then
		local iActual, iTable = tonumber(Actual), tonumber(Table);
		-- Test share-size. Return "true" if triggered, "false" otherwise.
		if ((iActual <= iTable and iActual + 100*1024 >= iTable) or (iActual >= iTable and iActual- 100*1024 <= iTable)) then
			return true;
		end;
	-- Test other rules. Return "true" if triggered, "false" otherwise.
	elseif string.lower(Actual) == string.lower(Table) then
		return true;
	end
	return false;
end

tFunctions.CreateObject = function(sValue)
	-- Custom user table fields
	local tTable, user, n = { 
		"sName", "iShareSize", "sDescription", "sClient", "sClientVersion", "sMode", "iOpHubs",
		"iHubs", "iSlots", "sIP", "sConnection", "sEmail", "iTimes", "sBanType"
	}, {}, 0
	-- Parse sValue data
	for str in fMatch(sValue,"(.-)%$") do
		-- Add str to each field
		n = n + 1; if string.find(str, "^%s$") then str = "" end; user[tTable[n]] = str
	end
	return user
end

tFunctions.Report = function(user, Rules, nick)
	-- Action triggered
	if(Rules["h"][1] >= Settings.iHard or (Rules["h"][1] >= 1 and Rules["f"][1] >= Settings.iFuzzy - 1) or Rules["f"][1] >= Settings.iFuzzy) then
		-- Custom frmHub table
		local tTable, sReason = { ["perm"] = frmHub:GetPermBanList(), ["temp"] = frmHub:GetTempBanList() }
		-- Loop through hub bans
		for i,v in ipairs(tTable[nick.sBanType]) do
			-- IPs are identical
			if nick.sIP == v.sIP then
				-- Replace Ban entry
				tFunctions.AddToTable(user, nick.sBanType, tonumber(i), nick.iTimes);
				-- Take action
				tFunctions.TakeAction(user, v.sReason, v.sBy, nick.sBanType, (tonumber(v.iTime) or 0)/60, nick.iTimes)
				-- Report
				SendPmToOps(Settings.sTo,"\r\n\r\n\t"..string.rep("=",80)..
				"\r\n\t\t\t\t\t*Ban Details*\r\n\t"..string.rep("-",160).."\r\n\t• "..
				"User '"..user.sName.."' ("..user.sIP..") "..nick.sBanType.."banned "..nick.iTimes.." time(s) "..
				"because: "..v.sReason.."\r\n\t• Previous Information: '"..nick.sName.."' ("..nick.sIP..
				")\r\n\t"..string.rep("-",160).."\r\n\r\n\t"..string.rep("=",80)..
				"\r\n\t\t\t\t\t*Rules Triggered*\r\n\t"..string.rep("-",160).."\r\n\t• Fuzzy: "..
				Rules["f"].sMsg.." ("..Rules["f"][1]..")\r\n\t• Hard: "..Rules["h"].sMsg..
				" ("..Rules["h"][1]..")\r\n\t"..string.rep("-",160));
				user:SendPM(Settings.sBot,"*** "..Settings.sMsg.." Reason: "..v.sReason)
				--user:Disconnect();
				break
			end
		end
	-- Suspect detected
	elseif ((Rules["f"][1] >= 1 and Rules["h"][1] >= 1) or Rules["f"][1] >= 2) then
		SendPmToOps(Settings.sTo,"\r\n\r\n\t*** User "..user.sName.." ("..user.sIP..") triggered "..Rules["h"][1]..
		" hard filter(s) and "..Rules["f"][1].." fuzzy filter(s).\n\t*** Possible "..nick.sBanType.."banned member '"..
		nick.sName.."', but too few filters triggered. Please verify and ban manually if necessary.\n");
	end
end

tFunctions.TakeAction = function(sVictim, sReason, sBy, sBanType, iTime, iBanTimes)
	local tTable = { 
		-- PermBan and TempBan related table
		["temp"] = function() TempBan(sVictim.sIP, tonumber(iTime), sReason, sBy, Settings.bFullBan) end,
		["perm"] = function() Ban(sVictim.sIP, sReason, sBy, Settings.bFullBan) end, 
	}
	-- If tTable contains ban type
	if tTable[sBanType] then
		-- If Perm or Temp Bans higher than limit
		if sBanType == "perm" or (sBanType == "temp" and tonumber(iBanTimes) == Settings.iMaxTempBans) then
			-- Perm Ban
			tTable["perm"]()
		else
			-- TempBan
			tTable["temp"]()
		end
	end
end

-- Add entry to tBan
tFunctions.AddToTable = function(nick, sBanType, iReplace, iBanTimes)
	if iBanTimes then
		-- Sum current Bans
		iBanTimes = tonumber(iBanTimes) + 1
	else
		-- Start counting
		iBanTimes = 1
	end
	-- Reset counter when user is tempbanned for iBanTime'th time
	if sBanType == "temp" and iBanTimes > Settings.iMaxTempBans then iBanTimes = 1; sBanType = "perm" end
	-- Create table entry
	local tString = (nick.sName.."$"..(tonumber(nick.iShareSize or 0)).."$"..
	(nick.sDescription or " ").."$"..(nick.sClient or " ").."$"..
	(tonumber(nick.sClientVersion) or " ").."$"..(nick.sMode or " ").."$"..
	(nick.iOpHubs or 0).."$"..(nick.iHubs or 0).."$"..(nick.iSlots or 0).."$"..
	nick.sIP.."$"..(nick.sConnection or " ").."$"..(nick.sEmail or " ").."$"..iBanTimes.."$"..sBanType.."$")
	-- Insert/Replace
	if iReplace then table.remove(tBan, iReplace) end; table.insert(tBan, tString)
end

-- Function by NightLitch
tFunctions.GetBanTime = function(time)
	-- Convert %d+%w to minutes
	local timetable = {["m"] = 1,["h"] = 60,["d"] = (60*24),["w"] = ((60*24)*7)}
	local min = 0
	for i,v in fMatch(time, "(%d+)(%a)") do
		if i and v and timetable[v] then min = min + i*timetable[v] end
	end
	return min
end

-- File handling
tFunctions.Serialize = function(tTable,sTableName,hFile,sTab)
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
end