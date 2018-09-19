--[[

	HelpDesk by jiten (3/2/2006)

]]--

tSettings = {
	sBot = "[_HeLPDeSK_]",
	fHelp = "tHelpDesk.tbl",
}
tMembers = {}

Main = function()
	frmHub:RegBot(tSettings.sBot)
	for a,b in pairs(frmHub:GetOperators()) do
		tMembers[b.sNick] = tMembers[b.sNick] or 1
		SaveToFile(tSettings.fHelp,tMembers,"tHelpDesk")
	end
end

ToArrival = function(user,data)
	local s,e,to,msg = string.find(data, "^$To:%s+(%S+)%s+From:%s+%S+%s+$%b<>%s+(.*)|$")
	if to == tSettings.sBot then
		local s,e,cmd = string.find(msg, "^%!(%a+)")
		if not user.bOperator and cmd and tCmds[cmd] then
			return tCmds[cmd](user),1
		end
		if tMembers[user.sName] or user.bOperator then
			tMembers[user.sName] = tMembers[user.sName] or 1
			PM(msg, user.sName)
		else
			user:SendPM(tSettings.sBot, "*** Type !helpdesk to login.")
		end
		return 1
	end
end

tCmds = {
	["leave"] = function(user)
		if tMembers[user.sName] then
			tMembers[user.sName] = nil
			user:SendPM(tSettings.sBot,"*** You have left the HelpDesk!")
			PM(user.sName.." left!",user.sName)
			SaveToFile(tSettings.fHelp,tMembers,"tHelpDesk")
		end
	end,
	["helpdesk"] = function(user)
		if not tMembers[user.sName] then
			tMembers[user.sName] = 1
			user:SendPM(tSettings.sBot,"*** You have joined the HelpDesk!")
			PM(user.sName.." joined!",user.sName)
			SaveToFile(tSettings.fHelp,tMembers,"tHelpDesk")
		end
	end,
}

PM = function(msg, from)
	for nick, id in pairs(tMembers) do
		if nick ~= from then
			SendToNick(nick, "$To: "..nick.." From: "..tSettings.sBot.." $<"..from.."> "..msg)
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