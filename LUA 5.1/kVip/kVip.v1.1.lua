--[[

	kVip 1.1 - LUA 5.0/5.1 by jiten (8/6/2006)

	Based on: K-VIP v 1.6 by Seiya

	CHANGELOG:
	¯¯¯¯¯¯¯¯¯¯
	- Added: Kick to the VIP you want without creating a new profile;
	- Fixed: All vip have the command;
	- Fixed: Kvip which is degrated can't use anymore the kik command;
	- Fixed: Load (don't laugh) the svip.txt file when starting the script;
	- Fixed: VIP can't add/revoke VIP to/from K-VIP anymore;
	- Added: Userinfo command;
 	- Added: By request a kick log and its command !vkicklog (made by nErBoS);
	- Added: By request a Ban to a x amout of Kicks (made by nErBoS);
	- Changed: Almost complete rewrite of the code (12/2/2005);
	- Rewritten: Whole code (once more);
	- Removed: Userinfo command (8/6/2006);
	- Changed: Some code bits;
	- Added: Intro for kVips - some examples taken from Intro/Outro by Madman;
	- Added: Kick report sent to every kVip and Ops (8/7/2006).

]]--

tSettings = {
	-- Bot Name
	sName = frmHub:GetHubBotName(),

	-- Script Version
	iVersion = "1.1",

	-- Bot Description
	sDescription = "",
	-- Bot Email
	sEmail = "",

	-- RightClick Menu
	sMenu = "kVip",

	-- Maximum Kicks for a Ban
	iMax = 3,

	-- Send Intros? (true = on, false = off)
	bIntro = false,

	-- Profiles Immune to kVip's kick
	tImmune = { [0] = 1, [1] = 1, [4] = 1, [5] = 1 },

	-- kVip DB
	fVip = "tVip.tbl",
	-- kVip's Kicks DB
	fLog = "tKick.tbl",

	-- Commands
	sRemove = "kdel", sAdd = "kadd", sHelp = "khelp",
	sKick = "kkick", sLog = "klog", sList = "klist"
}

tVip, tLog = {}, {}

Main = function()
	-- Register BotName
	if tSettings.sName ~= frmHub:GetHubBotName() then
		frmHub:RegBot(tSettings.sName, 1, tSettings.sDescription, tSettings.sEmail)
	end
	-- Load DB content
	if loadfile(tSettings.fVip) then dofile(tSettings.fVip) end
	if loadfile(tSettings.fLog) then dofile(tSettings.fLog) end
end

ChatArrival = function(user, data)
	local _,_, to = string.find(data,"^$To:%s(%S+)%sFrom:")
	local _,_, msg = string.find(data,"%b<>%s(.*)|$") 
	-- Message sent to kVip Bot or in Main
	if (to and to == tSettings.sName) or not to then
		-- Parse command
		local _,_, cmd = string.find(msg, "^%p(%S+)")
		-- Exists
		if cmd and tCommands[string.lower(cmd)] then
			cmd, user.SendMessage = string.lower(cmd), user.SendData
			-- PM
			if to == tSettings.sName then user.SendMessage = user.SendPM end
			-- If user has permission
			if tCommands[cmd].tLevels[user.iProfile] or (tCommands[cmd].bVip and tVip[string.lower(user.sName)]) then
				return tCommands[cmd].fFunction(user, msg), 1
			else
				return user:SendMessage(tSettings.sName, "*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

ToArrival = ChatArrival

NewUserConnected = function(user)
	if tSettings.bIntro then
		local tIntro = {
			"[USER] crawls in.",
			"In a fiery explosion [USER] appears.",
			"With a crazed look in their eyes [USER] arrives.",
			"Sir [USER] of the east lunatic fringe has arrived.",
			"[USER] arrives yelling and screaming like a maniac.",
			"[USER] arrives ranting and raving about aliens or some such rot.",
			"The demented [USER] has arrived.",
		}
		if user.iProfile == GetProfileIdx("VIP") and tVip[string.lower(user.sName)] then
			local sMsg = string.gsub(tIntro[math.random(1, table.getn(tIntro))], "%[USER%]", "kVip "..user.sName)
			SendToAll(tSettings.sName, sMsg)
		end
	end
	-- Supports UserCommands
	if user.bUserCommand then
		-- For each entry in table
		for i, v in pairs(tCommands) do
			-- If member
			if v.tLevels[user.iProfile] or (tCommands[i].bVip and tVip[string.lower(user.sName)]) then
				-- Send
				user:SendData("$UserCommand 1 3 "..tSettings.sMenu.."\\"..v.tRC[1]..
				"$<%[mynick]> !"..i..v.tRC[2].."&#124;")
			end
		end
	end
end

OpConnected = NewUserConnected

tCommands = {
	[tSettings.sHelp] = {
		fFunction = function(user)
			-- Header
			local sMsg = "\r\n\r\n\t\t\t"..string.rep("=", 75).."\r\n"..string.rep("\t", 6).."kVip Bot v."..
			tSettings.iVersion.." by jiten; Based on Seiya's\t\t\t\r\n\t\t\t"..string.rep("-", 150)..
			"\r\n\t\t\tAvailable Commands:\r\n\r\n"
			-- Loop through table
			for i, v in pairs(tCommands) do
				-- If user has permission
				if v.tLevels[user.iProfile] or (tCommands[i].bVip and tVip[string.lower(user.sName)]) then
					-- Populate
					sMsg = sMsg.."\t\t\t!"..i.."\t\t"..v.sDesc.."\r\n"
				end
			end
			-- Send
			user:SendMessage(tSettings.sName, sMsg.."\t\t\t"..string.rep("-", 150));
		end,
		tLevels = { [-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, },
		sDesc = "\tDisplays this help menu",
		tRC = { "Help", "" },
	},
	[tSettings.sAdd] = {
		fFunction = function(user, data)
			-- Parse nick
			local _,_, nick = string.find(data, "^%S+%s(%S+)$")
			-- Exists
			if nick then
				-- Already a kVip
				if tVip[string.lower(nick)] then
					user:SendMessage(tSettings.sName, "*** Error: '"..nick.."' is already a kVip!")
				else 
					local bVip = nil
					-- Loop through Reg users to confirm VIP status
					for i, v in ipairs(frmHub:GetRegisteredUsers()) do
						if string.lower(nick) == string.lower(v.sNick) and
							v.iProfile == GetProfileIdx("VIP") then	bVip = 1; break
						end
					end
					-- VIP
					if bVip then
						-- Set, save and report kVip
						tVip[string.lower(nick)] = 1; SaveToFile(tSettings.fVip, tVip, "tVip")
						user:SendMessage(tSettings.sName,"*** You have just given the kVip status to '"..nick.."'!") 
						SendPmToOps(tSettings.sName, "*** "..(GetProfileName(GetUserProfile(user.sName)) or "User")..
						" '"..user.sName.."' gave the kVip status to '"..nick.."'!") 
					else
						user:SendMessage(tSettings.sName,"*** Error: '"..nick.."' isn't a VIP.")
					end
				end 
			else
				user:SendMessage(tSettings.sName,"*** Syntax Error: Type !"..tSettings.sAdd.." <nick>")
			end
		end,
		tLevels = { [0] = 1, [5] = 1, },
		sDesc = "\tGives the kVip status",
		tRC = { "Give kVip status", " %[line:Nick]" },
	},
	[tSettings.sRemove] = {
		fFunction = function(user, data)
			-- Parse nick
			local _,_, nick = string.find(data, "^%S+%s(%S+)$")
			-- Found
			if nick then
				-- Already kVip
				if tVip[string.lower(nick)] then
					-- Delete, save and report
					tVip[string.lower(nick)] = nil; SaveToFile(tSettings.fVip, tVip, "tVip")
					user:SendMessage(tSettings.sName,"*** You have just revoked the kVip status from '"..nick.."'!") 
					SendPmToOps(tSettings.sName, "*** "..(GetProfileName(GetUserProfile(user.sName)) or "User")..
					" '"..user.sName.."' has just revoked the kVip status from '"..nick.."'!") 
				else 
					user:SendMessage(tSettings.sName,"*** Error: '"..nick.."' isn't a kVip.")
				end 
			else
				user:SendMessage(tSettings.sName,"*** Syntax Error: Type !"..tSettings.sRemove.." <nick>")
			end
		end,
		tLevels = { [0] = 1, [5] = 1, },
		sDesc = "\tRevokes the kVip status",
		tRC = { "Revoke kVip status", " %[line:Nick]" },
	},
	[tSettings.sKick] = {
		fFunction = function(user, data)
			-- Parse nick and reason
			local _,_, nick, reason = string.find(data, "^%S+%s(%S+)%s*(.*)$")
			-- Nick exists
			if nick then
				-- Online
				if GetItemByName(nick) then
					local nick = GetItemByName(nick)
					-- Immune to kVips
					if tSettings.tImmune[nick.iProfile] then
						user:SendMessage(tSettings.sName, "*** Error: You can't kick "..
						(GetProfileName(GetUserProfile(nick.sName)) or "User").."s!")
					else 
						-- Report
						SendToAll(tSettings.sName, "*** kVIP "..user.sName.." is kicking "..nick.sName..
						" because: "..reason) 
						local sMessage = "*** "..os.date().." - kVip Report: "..user.sName..
						" ("..user.sIP..") kicked "..nick.sName.." because: "..reason
						-- Loop through kVips
						for i, v in pairs(tVip) do
							-- Online
							if GetItemByName(i) then
								-- Send
								GetItemByName(i):SendPM(tSettings.sName, sMessage)
							end
						end
						-- Send to Ops
						SendPmToOps(tSettings.sName, sMessage)
						nick:SendPM(tSettings.sName, "*** You are being kicked because: "..reason)
						-- Log kick and message
						tLog[string.lower(nick.sName)] = (tLog[string.lower(nick.sName)] or { 0, os.date()..
						" - "..nick.sName.." ("..nick.sIP..") kicked by "..user.sName.." - Reason: "..reason } )
						-- Sum
						tLog[string.lower(nick.sName)][1] = tLog[string.lower(nick.sName)][1] + 1
						-- If higher than allowed
						if tLog[string.lower(nick.sName)][1] > tSettings.iMax then
							-- Report and ban
							nick:SendPM(tSettings.sName, "*** You have been kicked "..
							tLog[string.lower(nick.sName)][1].." times. You are being banned!");
							tLog[string.lower(nick.sName)][1] = 0; nick:Ban()
						else
							-- Tempban, disconnect and save
							nick:TempBan(); nick:Disconnect();
						end
						-- Save
						SaveToFile(tSettings.fLog, tLog, "tLog")
					end 
				else
					user:SendMessage(tSettings.sName, "*** Error: '"..nick.."' isn't online!")
				end
			else
				user:SendMessage(tSettings.sName,"*** Syntax Error: Type !"..tSettings.sRemove.." <nick> [reason]")
			end
		end,
		tLevels = { },
		sDesc = "\tkVip's kick command",
		tRC = { "kVip's kick", " %[nick] %[line:Reason]" },
		bVip = true,
	},
	[tSettings.sLog] = {
		fFunction = function(user)
			-- Log DB isn't empty
			if next(tLog) then
				-- Header
				local msg = "\r\n\r\n\t"..string.rep("=", 80).."\r\n\t\t\t\tCurrent kVip's KickLog:\r\n\t"..
				string.rep("-", 160).."\r\n"
				-- Loop through kicks
				for i, v in pairs(tLog) do msg = msg.."\t • "..v[2].." - #Kicked: "..v[1].."\r\n" end
				user:SendMessage(tSettings.sName, msg)
			else
				user:SendMessage(tSettings.sName, "*** Error: There aren't kVip kicks.")
			end
		end,
		tLevels = { [0] = 1, [1] = 1, [4] = 1, [5] = 1, },
		sDesc = "\tDisplays kVip's KickLog",
		tRC = { "Display kVip's KickLog", "" },
	},
	[tSettings.sList]= {
		fFunction = function(user)
			-- kVip's DB isn't empty
			if next(tVip) then
				-- Header
				local msg = "\r\n\r\n\t"..string.rep("=", 30).."\r\n\t\tCurrent kVips:\r\n\t"..
				string.rep("-", 60).."\r\n"
				-- Loop through kVips
				for v, i in pairs(tVip) do msg = msg.."\t • "..string.upper(string.sub(v, 1, 1))..
				string.sub(v, 2, string.len(v)).."\r\n" end
				user:SendMessage(tSettings.sName, msg)
			else
				user:SendMessage(tSettings.sName, "*** Error: There aren't registered kVips.")
			end
		end,
		tLevels = { [0] = 1, [1] = 1, [4] = 1, [5] = 1, },
		sDesc = "\tList registered kVips",
		tRC = { "List kVips", "" },
		bVip = true
	},
}

Serialize = function(tTable, sTableName, hFile, sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in pairs(tTable) do
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