--[[

	HelpDesk 1.1 by jiten (3/2/2006)

	Changelog:

	- Added: Commands work in Mainchat;
	- Changed: Operators are able to leave and join HelpDesk;
	- Added: Members command;
	- Changed: Operator autologin switch (3/4/2006)
	- Changed: Commands can be changed in tDesk
	- Changed: Message on login (3/5/2006)

]]--

tDesk = {
	-- Bot Name
	sBot = "[_HeLPDeSK_]",
	-- HelpDesk database
	fHelp = "tHelpDesk.tbl",
	-- Autologin every operator on script re/start
	bAutoLogin = true,
	-- Commands
	sLeave = "leave", sJoin = "helpdesk", sMembers = "members"
}
tMembers = {}

Main = function()
	frmHub:RegBot(tDesk.sBot)
	if loadfile(tDesk.fHelp) then dofile(tDesk.fHelp) end
	if tDesk.bAutoLogin then
		for a,b in pairs(frmHub:GetOperators()) do
			tMembers[b.sNick] = 1
			SaveToFile(tDesk.fHelp,tMembers,"tMembers")
		end
	end
end

ChatArrival = function(user,data)
	local s,e,cmd = string.find(data, "^%b<>%s+%!(%a+)")
	if cmd and tCmds[string.lower(cmd)] then
		return tCmds[cmd](user, data), 1
	end
end

ToArrival = function(user,data)
	local s,e,to,msg = string.find(data, "^$To:%s+(%S+)%s+From:%s+%S+%s+$%b<>%s+(.*)|$")
	if to == tDesk.sBot then
		local s,e,cmd = string.find(msg, "^%!(%a+)")
		if cmd and tCmds[string.lower(cmd)] then
			return tCmds[cmd](user, data), 1
		end
		if tMembers[user.sName] or user.bOperator then
			tMembers[user.sName] = tMembers[user.sName] or 1
			PM(msg, user.sName)
		else
			user:SendPM(tDesk.sBot, "*** You're not a member here. Type !helpdesk to login.")
		end
		return 1
	end
end

tCmds = {
	[tDesk.sLeave] = function(user)
		if tMembers[user.sName] then
			tMembers[user.sName] = nil
			user:SendPM(tDesk.sBot,"*** You have left the HelpDesk!")
			PM(user.sName.." left!",tDesk.sBot)
			SaveToFile(tDesk.fHelp,tMembers,"tMembers")
		end
	end,
	[tDesk.sJoin] = function(user)
		if not tMembers[user.sName] then
			PM(user.sName.." joined!",tDesk.sBot)
			tMembers[user.sName] = 1
			user:SendPM(tDesk.sBot,"*** You have joined the HelpDesk!\r\n\tIf you have any questions or problems "..
			"write them here, maybe we can help you. If nobody answers then try again later.\r\n\t"..
			"!"..tDesk.sLeave..": Leave the HelpDesk.")
			SaveToFile(tDesk.fHelp,tMembers,"tMembers")
		end
	end,
	[tDesk.sMembers] = function(user)
		if tMembers[user.sName] then
			local tMsg = "\r\n\r\n\t"..string.rep("-",40).."\r\n\t    Member List:\r\n\t"..string.rep("-",40).."\r\n"
			table.foreach(tMembers, function(v,i)
				tMsg = tMsg.."\t • "..v.."\r\n"
			end)
			user:SendPM(tDesk.sBot,tMsg)
		end
	end
}

PM = function(msg, from)
	for nick, id in pairs(tMembers) do
		if nick ~= from then
			SendToNick(nick, "$To: "..nick.." From: "..tDesk.sBot.." $<"..from.."> "..msg)
		end
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

SaveToFile = function(file,table,tablename)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end