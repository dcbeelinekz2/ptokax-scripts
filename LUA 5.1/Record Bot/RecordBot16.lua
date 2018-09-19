--[[

	RecordBot 1.6 - LUA 5.0/5.1 by jiten (11/8/2006)

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
	- Changed: Chat and ToArrival structure;
	- Removed: !rb.set command;
	- Merged: tSettings and Record table;
	- Changed: Some code bits and variables;
	- Updated: To LUA 5.1 (11/8/2006)

]]--

tSettings = {

	-- Bot Name
	sBot = "RecordBot",

	-- Toggle automatically register Bot Name [true = on, false = off]
	bRegister = true,

	-- RecordBot DB
	fRecord = "tRecord.tbl",

	-- Ignore table
	tIgnore = { ["jiten"] = 1, ["yournick"] = 1, },

	-- Top Sharer and Top Share validation delay (minutes)
	iDelay = 0,

	-- Message settings [ true = on, false = off ]

		-- Show report in Main
		bMain = true,

		-- Show report in PM
		bPM = false,

		-- Show report on Login
		bLogin = true,

	-- Commands
	sHelp = "rb.help", sShow = "rb.show", sSetup = "rb.set", sReset = "rb.reset"

}

tRecord, tDelay = {}, {}

Main = function()
	if (tSettings.sBot ~= frmHub:GetHubBotName() or tSettings.bRegister) then frmHub:RegBot(tSettings.sBot) end
	if loadfile(tSettings.fRecord) then dofile(tSettings.fRecord) end
	SetTimer(1000); StartTimer()
end

ChatArrival = function(user, data)
	-- Define vars
	local _,_, to = string.find(data, "^$To:%s(%S+)%s+From:")
	local _,_, msg = string.find(data, "%b<>%s(.*)|$") 
	-- Message sent to Bot or in Main
	if (to and to == tSettings.sBot) or not to then
		-- Parse command
		local _,_, cmd = string.find(msg, "^%p(%S+)")
		-- Exists
		if cmd and tCommands[string.lower(cmd)] then
			cmd, user.SendMessage = string.lower(cmd), user.SendData
			-- PM
			if to == tSettings.sBot then user.SendMessage = user.SendPM end
			-- If user has permission
			if tCommands[cmd].tLevels[user.iProfile] and tCommands[cmd].tLevels[user.iProfile] == 1 then
				return tCommands[cmd].fFunction(user), 1
			else
				return user:SendMessage(tSettings.sBot, "*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

ToArrival = ChatArrival

OnExit = function()
	SaveToFile(tRecord, "tRecord", tSettings.fRecord)
end

tCommands = {
	[tSettings.sHelp] =	{ 
		fFunction = function(user)
			-- Header
			local sMsg = "\r\n\r\n\t\t\t"..string.rep("=", 80).."\r\n"..string.rep("\t", 6).."RecordBot - LUA 5.1 version by jiten "..
			"\t\t\t\r\n\t\t\t"..string.rep("-", 160).."\r\n\t\t\tAvailable Commands:".."\r\n\r\n"
			-- Loop through table
			for i,v in pairs(tCommands) do
				-- If user has permission
				if v.tLevels[user.iProfile] and v.tLevels[user.iProfile] == 1 then
					-- Populate
					sMsg = sMsg.."\t\t\t!"..i.."\t\t"..v.tDesc.."\r\n"
				end
			end
			-- Send
			user:SendMessage(tSettings.sBot, sMsg.."\t\t\t"..string.rep("-",160));
		end, 
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		tDesc = "\tDisplays this help message\t\t\t!"..tSettings.sHelp.."",
	},
	[tSettings.sShow] = { 
		fFunction = function(user)
			if next(tRecord) then
				local msg = "\r\n\r\n\t"..string.rep ("=", 50).."\r\n\tRecord\t\tValue\t\tDate - Time\n\t"..string.rep ("-", 100).."\r\n"..
				"\tShare\t\t"..(DoShareUnits(tRecord.iShare) or 0).." \t\t"..(tRecord.tShare or "n/a")..
				"\r\n\tUsers\t\t"..(tRecord.iUsers or 0).." user(s)\t\t"..(tRecord.tUsers or "n/a")..
				"\r\n\tTop Sharer\t"..(tRecord.sMaxSharer or "n/a").." ("..(DoShareUnits(tRecord.iMaxSharer) or 0)..
				")\t"..(tRecord.tMaxSharer or "n/a").."\r\n\t"..string.rep ("-", 100)
				user:SendMessage(tSettings.sBot, msg)
			else
				user:SendMessage(tSettings.sBot, "*** Error: No records have been saved.")
			end
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, 
		},
		tDesc = "\tShows this hub's all time share and user record\t!"..tSettings.sShow,
	},
	[tSettings.sReset] = {
		fFunction = function(user)
			tRecord = {}; SendToAll(tSettings.sBot, "*** Hub records have been reset!");
		end, 
		tLevels = {
			[-1] = 0, [0] = 1, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 1, 
		},
		tDesc = "\tResets all records\t\t\t\t!"..tSettings.sReset,
	},
};

NewUserConnected = function(user)
	if not tSettings.tIgnore[user.sName] then
		local iUserCount = frmHub:GetUsersCount()
		tRecord.iUsers, tRecord.tUsers = (tRecord.iUsers or 0), (tRecord.tUsers or "n/a")
		if (iUserCount > tRecord.iUsers) then
			tRecord.iUsers, tRecord.tUsers = iUserCount, os.date()
			if tSettings.bPM then
				SendPmToNick(user.sName, "*** Thanks, buddie. You've just raised the all-time share record!");
			end;
			if tSettings.bMain then
				SendToAll(tSettings.sBot, "*** "..user.sName.." has just raised the all-time user record to: "..
				tRecord.iUsers.." users at "..os.date().." :)");
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
				local iTotalShare, iShare, sNick = frmHub:GetCurrentShareAmount(), nick.iShareSize, nick.sName
				tRecord.iShare = (tRecord.iShare or 0)
				if (iTotalShare > tRecord.iShare) then
					tRecord.iShare, tRecord.tShare = iTotalShare, os.date()
					if tSettings.bPM then SendPmToNick(nick.sName, tSettings.sBot, "*** Thanks, buddie. You have just raised the all-time share record to "..DoShareUnits(iTotalShare).." :)"); end;
					if tSettings.bMain then SendToAll(tSettings.sBot, "*** "..nick.sName.." has just raised the all-time share record to: "..DoShareUnits(iTotalShare).." on "..os.date("%x")); end;
				end

				tRecord.iMaxSharer = (tRecord.iMaxSharer or 0)
				if (iShare > tRecord.iMaxSharer) then
					tRecord.iMaxSharer, tRecord.sMaxSharer, tRecord.tMaxSharer = iShare, nick.sName, os.date()
					if tSettings.bPM then SendPmToNick(nick.sName, "*** Thanks, buddie. You are our highest sharer with: "..DoShareUnits(iShare).."."); end;
					if tSettings.bMain then SendToAll(tSettings.sBot, "*** "..nick.sName.." is our all-time biggest sharer with: "..DoShareUnits((iShare)).." since "..os.date("%x").." :)"); 	end;
				end

				if tSettings.bLogin then
					local sMsg = "\r\n\r\n\t"..string.rep("=", 50).."\r\n\t\t\tStats\r\n\t"..
					string.rep("-", 100).."\r\n\r\n\tShare record: "..(DoShareUnits(tonumber(tRecord.iShare)) or 0).." [ "..
					(tRecord.tShare or "n/a").." ]\r\n\tUser record: "..(tRecord.iUsers or 0).." users [ "..
					(tRecord.tUsers or "n/a").." ]\r\n\tTop Sharer: "..(tRecord.sMaxSharer or "n/a")..
					" ("..(DoShareUnits(tRecord.iMaxSharer) or 0)..") [ "..(tRecord.tMaxSharer or "n/a").." ]\r\n"
					nick:SendData(tSettings.sBot, sMsg)
				end;
			end
			tDelay[nick] = nil
		end
	end
end

-- By kepp and NotRambitWombat 
DoShareUnits = function(intSize)
	if intSize and intSize ~= 0 then 
		local tUnits, intSize, sUnits = { "Bytes", "KB", "MB", "GB", "TB" }, tonumber(intSize)
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