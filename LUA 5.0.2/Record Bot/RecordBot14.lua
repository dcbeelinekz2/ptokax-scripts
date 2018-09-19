--/-------------------------------------------------------------------
-- Lua 5 version by jiten 
-- Heavily optimized version
-- fixed huge users bug and some stuff (thx to TïMê†råVêlléR)
-- Fixed stats sending before MOTD
-- Added: Top Share and Sharer Record (requested by XPMAN)
-- Added: Reg Bot switch (requested by (uk)jay)
-- Fixed: Nil Max Sharer (thx Cosmos)
-- Added: Ignore List (requested by chettedeboeuf)
-- Fixed: User Record Time (11/26/2005)
-- Added: Top Sharer and Share validation delay (requested by chettedeboeuf)
-- Changed: Command Parsing and profile permission structure
-- Fixed: Top Sharer and Share Delay bug (thx to chettedeboeuf)

-- RecordBot vKryFinal written by bonki 2003
-- Logs and displays a hub's all time share and user record.
--/-------------------------------------------------------------------
mSet = {
	bot = { name = "RecordBot", mail = "bonki@no-spam.net", desc = "RecordBot LUA 5 version by jiten", },
	fRecord = "records.tbl", fConfig = "config.tbl", Config = {}, 
	doRegBot = 1, -- 1 = Register Bot, 0 = Don't Register
	iDelay = 1, -- Top Sharer and Top Share validation delay in minutes
	tIgnore = { ["jiten"] = 1, ["yournick"] = 1, } -- Ignore List (["nick"] = 1)
}

-- If you're using Robocop profiles don't change this. If not, remove Profile 4 and 5 and follow this syntax: 
-- [Profile number] = value (higher value means more rights)
Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [4] = 5, [0] = 6, [5] = 7, }

Record = {} tDelay = {}
--/-------------------------------------------------------------------
Main = function()
	if mSet.doRegBot == 1 then frmHub:RegBot(mSet.bot.name, 1, mSet.bot.desc, mSet.bot.mail) end
	if mSet.Config.main == nil then mSet.Config.main = 1 end
	if mSet.Config.PM == nil then mSet.Config.PM = 1 end
	if mSet.Config.Login == nil then mSet.Config.Login= 1 end
	if loadfile(mSet.fConfig) then dofile(mSet.fConfig) end
	if loadfile(mSet.fRecord) then dofile(mSet.fRecord) end
	SetTimer(1000) StartTimer()
end

ChatArrival = function(curUser, sData)
	local sData = string.sub(sData,1,-2) 
	local s,e,cmd,args = string.find(sData, "%b<>%s+[%!%?%+%#](%S+)%s*([^%|]*)" )
	if cmd then
		local tmp = "\r\n\t";
		local sHelpOutput = tmp.."\r\n\t"..mSet.bot.desc..tmp.."Logs and displays a hub's all time share and user record."..
			tmp.."\r\n\tAvailable Commands:".."\r\n\r\n";

		tCommands = {
		["rb.help"] =	{ 
				function(curUser)
					curUser:SendData(mSet.bot.name, sHelpOutput);
				end, 1, "\t\t\tDisplays this help message.", },
		["rb.show"] = { 
				function(curUser)
					if not next(Record) then curUser:SendData(mSet.bot.name, "No records have been saved."); return 0 end
					if Record.Share == nil then Record.Share = 0 end if Record.Users == nil then Record.Users = 0 end
					local msg, border = "", string.rep ("-", 100)
					msg = msg.."\r\n\t"..border.."\r\n"
					msg = msg.."\tRecord\t\tValue\t\tDate - Time\n"
					msg = msg.."\t"..border.."\r\n"
					msg = msg.."\tShare\t\t"..DoShareUnits((Record.Share)).." \t\t"..Record.tShare.."\r\n"
					msg = msg.."\tUsers\t\t"..Record.Users.." user(s)\t\t"..Record.tUsers.."\r\n"
					msg = msg.."\tTop Sharer\t"..Record.maxSharer.." ("..DoShareUnits((Record.maxShare))..")\r\n"
					msg = msg.."\t"..border
					curUser:SendData(mSet.bot.name,msg)
				end, 1, "\t\t\tShows this hub's all time share and user record.", },
		["rb.showmain"] = {
				function(curUser, args)
					if (args == "enable") then
						mSet.Config.main = 1 WriteTable(mSet.Config,"Config",mSet.fConfig) curUser:SendData(mSet.bot.name, "Enabled!");
					elseif (args == "disable") then
						mSet.Config.main = 0 WriteTable(mSet.Config,"Config",mSet.fConfig) curUser:SendData(mSet.bot.name, "Disabled!");
					else
						curUser:SendData(mSet.bot.name, "Syntax error!");
					end
				end, 4, "<enable/disable>\tmain message.", },
		["rb.showpm"] = { 
				function(curUser, args)
					if (args == "enable") then
						mSet.Config.PM = 1 WriteTable(mSet.Config,"Config",mSet.fConfig) curUser:SendData(mSet.bot.name, "Enabled!");
					elseif (args == "disable") then
						mSet.Config.PM = 0 WriteTable(mSet.Config,"Config",mSet.fConfig) curUser:SendData(mSet.bot.name, "Disabled!");
					else
						curUser:SendData(mSet.bot.name, "Syntax error!");
					end
				end, 4, "<enable/disable>\tprivate message.", },
		["rb.showlogin"] = {
				function(curUser, args)
					if (args == "enable") then
						mSet.Config.Login = 1 WriteTable(mSet.Config,"Config",mSet.fConfig) curUser:SendData(mSet.bot.name, "Enabled!");
					elseif (args == "disable") then
						mSet.Config.Login = 0 WriteTable(mSet.Config,"Config",mSet.fConfig) curUser:SendData(mSet.bot.name, "Disabled!");
					else
						curUser:SendData(mSet.bot.name, "Syntax error!");
					end
				end, 4, "<enable/disable>\treport on login.", },
		["rb.reset"] = {
				function(curUser)
					Record = nil Record = {} WriteTable(Record,"Record",mSet.fRecord) SendToAll(mSet.bot.name, "Hub records reset!");
				end, 4, "\t\t\tResets all records.", },
		};
		for sCmd, tCmd in tCommands do
			if(tCmd[2] <= Levels[curUser.iProfile]) then
				sHelpOutput   = sHelpOutput.."\t"..sCmd.."\t "..tCmd[3].."\r\n";
			end
		end
		cmd = string.lower(cmd);
		if (tCommands[cmd]) then
			if tCommands[cmd][2] <= Levels[curUser.iProfile] then
				return tCommands[cmd][1](curUser, string.lower(args)), 1;
			else
				return curUser:SendData(mSet.bot.name, "You do not have sufficient rights to run that command!"), 1;
			end
		end
	end
end

NewUserConnected = function(curUser)
	if mSet.tIgnore[curUser.sName] ~= 1 then
		local aUsers = frmHub:GetUsersCount()
		Record.Users = Record.Users or 0
		if ( aUsers > Record.Users ) then
			Record.Users = aUsers Record.tUsers = os.date() WriteTable(Record,"Record",mSet.fRecord)
			if (mSet.Config.PM == 1) then SendPmToNick(curUser.sName, "Thanks, buddie. You've just raised the all-time share record!"); end;
			if (mSet.Config.main == 1) then SendToAll(mSet.bot.name, curUser.sName.." has just raised the all-time user record to: "..Record.Users.." users :)"); 	end;
		end
		tDelay[curUser] = {}
		tDelay[curUser]["iTime"] = mSet.iDelay*60
	end
end

OpConnected = NewUserConnected

OnTimer = function()
	for nick,v in tDelay do
		tDelay[nick]["iTime"] = tDelay[nick]["iTime"] - 1
		if tDelay[nick]["iTime"] == 0 then
			if GetItemByName(nick.sName) then
				local aShare,maxShare,maxSharer = frmHub:GetCurrentShareAmount(),nick.iShareSize,nick.sName
				Record.Share = Record.Share or 0
				if ( aShare > Record.Share) then
					Record.Share = aShare Record.tShare = os.date() WriteTable(Record,"Record",mSet.fRecord)
					if (mSet.Config.PM == 1) then SendPmToNick(nick.sName, mSet.bot.name, sNewSharePMResponse); end;
					if (mSet.Config.main == 1) then SendToAll(mSet.bot.name, nick.sName.." has just raised the all-time share record to: "..DoShareUnits((Record.Share))); end;
				end

				Record.maxShare = Record.maxShare or 0
				if ( maxShare > Record.maxShare ) then
					Record.maxShare = maxShare Record.maxSharer = nick.sName WriteTable(Record,"Record",mSet.fRecord)
					if (mSet.Config.PM == 1) then SendPmToNick(nick.sName, "Thanks, buddie. You are our highest sharer with: "..DoShareUnits((Record.maxShare)).."."); end;
					if (mSet.Config.main == 1) then SendToAll(mSet.bot.name, nick.sName.." is our all-time biggest sharer with: "..DoShareUnits((Record.maxShare)).." :)"); 	end;
				end

				if (mSet.Config.Login == 1) then
					nick:SendData(mSet.bot.name, "Share record: "..DoShareUnits(tonumber(Record.Share)));
					nick:SendData(mSet.bot.name, "User record: "..Record.Users.." users");
					nick:SendData(mSet.bot.name, "Top Sharer: "..(Record.maxSharer or "Not Available").." ("..DoShareUnits((Record.maxShare))..")");
				end;
			end
			tDelay[nick] = nil
		end
	end
end

DoShareUnits = function(intSize)				--- Thanks to kepp and NotRambitWombat 
	if intSize ~= 0 then 
		local tUnits = { "Bytes", "KB", "MB", "GB", "TB" } 
		intSize = tonumber(intSize); 
		local sUnits; 
		for index = 1, table.getn(tUnits) do 
			if(intSize < 1024) then 
				sUnits = tUnits[index]; 
				break; 
			else  
				intSize = intSize / 1024; 
			end 
		end 
		return string.format("%0.1f %s",intSize, sUnits); 
	else 
		return "0" 
	end 
end

Serialize = function(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in tTable do
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

WriteTable = function(table,tablename,file)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end