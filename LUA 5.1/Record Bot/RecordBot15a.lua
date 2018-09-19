--[[

	RecordBot 1.5a - LUA 5.1 by jiten (3/22/2006)

	Based on RecordBot vKryFinal written by bonki 2003

	Description: Logs and displays a hub's all time share and user record.

	- Fixed: Huge users bug and some stuff (thx to TïMê†råVêlléR)
	- Fixed: Stats sending before MOTD
	- Added: Top Share and Sharer Record (requested by XPMAN)
	- Added: Reg Bot switch (requested by (uk)jay)
	- Fixed: Nil Max Sharer (thx Cosmos)
	- Added: Ignore List (requested by chettedeboeuf)
	- Fixed: User Record Time (11/26/2005)
	- Added: Top Sharer and Share validation delay (requested by chettedeboeuf)
	- Changed: Command Parsing and profile permission structure
	- Fixed: Top Sharer and Share Delay bug (thx to chettedeboeuf)
	- Chaged: Some code rewritten
	- Added: Time/Date to each record message (requested by Troubadour)
	- Changed: Updated to LUA 5.1

]]--

tSettings = {
	-- Bot Name, Mail and Description
	Bot = { sName = "RecordBot", sMail = "bonki@no-spam.net", sDesc = "RecordBot - LUA 5 version by jiten" },
	-- RecordBot Database
	fRecord = "tRecord.tbl",
	-- true: Register Automatically, false: don't
	bRegister = true,
	-- Top Sharer and Top Share validation delay in minutes
	iDelay = 0,
	-- Ignore table
	tIgnore = { ["jiten"] = 1, ["yournick"] = 1, },
	-- Commands
	sHelp = "rb.help", sShow = "rb.show", sSetup = "rb.set", sReset = "rb.reset"
}

Record = { 
	-- RecordBot DB
	tDB = {},
	-- RecordBot message settings
	tSetup = { 
		-- Show report in Main
		main = 1,
		-- Show report in PM
		pm = 0,
		-- Show report on Login
		login = 1
	},
}

-- Delay table (don't change this)
tDelay = {}

Main = function()
	if tSettings.bRegister then frmHub:RegBot(tSettings.Bot.sName, 1, tSettings.Bot.sDesc, tSettings.Bot.sMail) end
	if loadfile(tSettings.fRecord) then dofile(tSettings.fRecord) end;
	SetTimer(1000); StartTimer()
end

ChatArrival = function(user, data)
	local data = string.sub(data,1,-2) 
	local s,e,cmd = string.find(data, "%b<>%s+[%!%+](%S+)" )
	if cmd and tCmds[cmd] then
		cmd = string.lower(cmd);
		if tCmds[cmd].tLevels[user.iProfile] then
			return tCmds[cmd].tFunc(user,data), 1
		else
			return user:SendData(tSettings.Bot.sName, "*** Error: You do not have sufficient rights to run that command!"), 1;
		end
	end
end

OnExit = function()
	SaveToFile(Record,"Record",tSettings.fRecord)
end

tCmds = {
	[tSettings.sHelp] =	{ 
		tFunc = function(user)
			local sMsg = "\r\n\t\r\n\t\t\t\t\t"..tSettings.Bot.sDesc.."\r\n\r\n\t\t\t\tLogs and displays a hub's all"..
			"time share and user record.\r\n\t\r\n\tAvailable Commands:".."\r\n\r\n";
			for cmd, v in pairs(tCmds) do
				if tCmds[cmd].tLevels[user.iProfile] then sMsg = sMsg.."\t!"..cmd.."\t "..v.tDesc.."\r\n"; end
			end
			user:SendData(tSettings.Bot.sName,sMsg);
		end, 
		tLevels = {
			[-1] = 1,
			[0] = 1,
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
			[5] = 1,
		},
		tDesc = "\tDisplays this help message\t\t\t!"..tSettings.sHelp.."",
	},
	[tSettings.sShow] = { 
		tFunc = function(user)
			local tTable = Record.tDB
			if next(tTable) then
				local border = string.rep ("-", 100)
				local msg = "\r\n\t"..border.."\r\n\tRecord\t\tValue\t\tDate - Time\n\t"..border.."\r\n"..
				"\tShare\t\t"..(DoShareUnits(tTable.iShare) or 0).." \t\t"..(tTable.tShare or "*not available*")..
				"\r\n\tUsers\t\t"..(tTable.iUsers or 0).." user(s)\t\t"..(tTable.tUsers or "*not available*")..
				"\r\n\tTop Sharer\t"..(tTable.sMaxSharer or "*not available*").." ("..(DoShareUnits(tTable.iMaxSharer) or 0)..
				")\t"..(tTable.tMaxSharer or "*not available*").."\r\n\t"..border
				user:SendData(tSettings.Bot.sName,msg)
			else
				user:SendData(tSettings.Bot.sName, "*** Error: No records have been saved.")
			end
		end,
		tLevels = {
			[-1] = 1,
			[0] = 1,
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
			[5] = 1,
		},
		tDesc = "\tShows this hub's all time share and user record\t!"..tSettings.sShow,
	},
	[tSettings.sSetup] = {
		tFunc = function(user, args)
			local s,e,type,flag = string.find(args,"^%S+%s+%S+%s+(%S+)%s+(%S+)")
			if type and Record.tSetup[string.lower(type)] then
				local tTable = { ["enable"] = 1, ["disable"] = 0 }
				if flag and tTable[string.lower(flag)] then
					Record.tSetup[string.lower(type)] = tTable[string.lower(flag)]
					user:SendData(tSettings.Bot.sName, "*** Show in "..string.upper(string.sub(type,1,1))..
					string.lower(string.sub(type,2,string.len(type))).." Mode has been "..flag.."d!");
				end
			else
				user:SendData(tSettings.Bot.sName, "*** Syntax Error: Type !"..tSettings.sSetup.." <login/pm/main> <enable/disable>");
			end
		end, 
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tDesc = "\tSetup RecordBot\t\t\t\t!"..tSettings.sSetup.." <main/login/pm> <enable/disable>",
	},
	[tSettings.sReset] = {
		tFunc = function(user)
			Record.tDB = {}
			SendToAll(tSettings.Bot.sName, "*** Hub records have been reset!");
		end, 
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tDesc = "\tResets all records\t\t\t\t!"..tSettings.sReset,
	},
};

NewUserConnected = function(user)
	if tSettings.tIgnore[user.sName] ~= 1 then
		local iUserCount, tTable = frmHub:GetUsersCount(), Record.tDB
		tTable.iUsers = tTable.iUsers or 0; tTable.tUsers = tTable.tUsers or "*not available*"
		if (iUserCount > tTable.iUsers) then
			tTable.iUsers = iUserCount; tTable.tUsers = os.date()
			if (Record.tSetup.pm == 1) then
				SendPmToNick(user.sName, "*** Thanks, buddie. You've just raised the all-time share record!");
			end;
			if (Record.tSetup.main == 1) then
				SendToAll(tSettings.Bot.sName, "*** "..user.sName.." has just raised the all-time user record to: "..
				tTable.iUsers.." users at "..os.date().." :)");
			end;
		end
		tDelay[user] = {}
		tDelay[user]["iTime"] = tSettings.iDelay*60
	end
end

OpConnected = NewUserConnected

OnTimer = function()
	for nick,v in pairs(tDelay) do
		tDelay[nick]["iTime"] = tDelay[nick]["iTime"] - 1
		if tDelay[nick]["iTime"] <= 0 then
			if GetItemByName(nick.sName) then
				local iTotalShare, iShare, sNick, tTable = frmHub:GetCurrentShareAmount(), nick.iShareSize, nick.sName, Record.tDB
				tTable.iShare = tTable.iShare or 0
				if (iTotalShare > tTable.iShare) then
					tTable.iShare = iTotalShare; tTable.tShare = os.date()
					if (Record.tSetup.pm == 1) then SendPmToNick(nick.sName, tSettings.Bot.sName, "*** Thanks, buddie. You have just raised the all-time share record to "..DoShareUnits(iTotalShare).." :)"); end;
					if (Record.tSetup.main == 1) then SendToAll(tSettings.Bot.sName, "*** "..nick.sName.." has just raised the all-time share record to: "..DoShareUnits(iTotalShare).." on "..os.date("%x")); end;
				end

				tTable.iMaxSharer = tTable.iMaxSharer or 0
				if (iShare > tTable.iMaxSharer) then
					tTable.iMaxSharer = iShare; tTable.sMaxSharer = nick.sName; tTable.tMaxSharer = os.date()
					if (Record.tSetup.pm == 1) then SendPmToNick(nick.sName, "*** Thanks, buddie. You are our highest sharer with: "..DoShareUnits(iShare).."."); end;
					if (Record.tSetup.main == 1) then SendToAll(tSettings.Bot.sName, "*** "..nick.sName.." is our all-time biggest sharer with: "..DoShareUnits((iShare)).." since "..os.date("%x").." :)"); 	end;
				end

				if (Record.tSetup.login == 1) then
					local sMsg = "\r\n\r\n\tShare record: "..(DoShareUnits(tonumber(tTable.iShare)) or 0).." at "..
					(tTable.tShare or "*not available*").."\r\n\tUser record: "..(tTable.iUsers or 0).." users at "..
					(tTable.tUsers or "*not available*").."\r\n\tTop Sharer: "..(tTable.sMaxSharer or "*not available*")..
					" ("..(DoShareUnits(tTable.iMaxSharer) or 0)..") at "..(tTable.tMaxSharer or "*not available*").."\r\n"
					nick:SendData(tSettings.Bot.sName,sMsg)
				end;
			end
			tDelay[nick] = nil
		end
	end
end

-- By kepp and NotRambitWombat 
DoShareUnits = function(intSize)
	if intSize and intSize ~= 0 then 
		local tUnits = { "Bytes", "KB", "MB", "GB", "TB" }; intSize = tonumber(intSize); 
		local sUnits; 
		for index in ipairs(tUnits) do 
			if(intSize < 1024) then sUnits = tUnits[index];  break;  else   intSize = intSize / 1024;  end 
		end 
		return string.format("%0.1f %s",intSize, sUnits);
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

SaveToFile = function(table,tablename,file)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end