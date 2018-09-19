--[[

	OpChat Plus v2.0 - LUA 5.0/5.1 by jiten (7/6/2006)

	Based on: OpChat++ by nErBoS

	Features:

	- List, Invite, Remove and members to/from OpChat

]]--

tOpChat = {
	-- Bot Name
	sName = "OpChat",
	-- Database
	fFile = "tOpChat.tbl",
	-- Send message to invited users on hub/script restart (true = on, false = off)
	bSend = true,
		-- Message sent (true = on, false = off)
		sMsg = "You are currently invited to OpChat",
	-- Commands
	sMembers = "members", sInvite = "invite", sRemove = "remove",
}

tMembers = {}

Main = function()
	-- If OpChat Plus' BotName is the same as hub's
	if frmHub:GetOpChatName() == tOpChat.sName then
		-- Rename hub's and disable
		frmHub:SetOpChatName(tOpChat.sName.."_"); frmHub:SetOpChat(0)
	end;
	-- Register OpChat Plus's BotName
	frmHub:RegBot(tOpChat.sName)
	-- Load database content
	if loadfile(tOpChat.fFile) then dofile(tOpChat.fFile) end
	-- Populate database
	for i, v in ipairs(frmHub:GetOperators()) do
		tMembers[string.lower(v.sNick)] = 1
	end
end

ToArrival = function(user, data)
	-- Parse to and msg
	local _,_, to, msg = string.find(data, "^$To:%s+(%S+)%s+From:%s+%S+%s+$%b<>%s+(.*)|$")
	-- Message sent to OpChat Plus's Bot
	if string.lower(to) == string.lower(tOpChat.sName) then
		-- If command
		local _,_, cmd = string.find(msg, "^%!(%a+)")
		-- If table contains it
		if cmd and tCommands[string.lower(cmd)] then
			-- Process
			return tCommands[cmd].tFunc(user, msg), 1
		end
		-- If member or operator
		if tMembers[string.lower(user.sName)] or user.bOperator then
			-- Set as member
			tMembers[string.lower(user.sName)] = tMembers[string.lower(user.sName)] or 1
			-- Send message
			PM(msg, user.sName)
		else
			-- Report
			user:SendPM(tOpChat.sName, "*** You're not a member here!")
		end
		return 1
	end
end

NewUserConnected = function(user)
	-- Supports UserCommands
	if user.bUserCommand then
		-- For each entry in table
		for i,v in pairs(tCommands) do
			-- If member
			if tMembers[string.lower(user.sName)] then
				-- Send
				user:SendData("$UserCommand 1 3 OpChat Plus\\"..v.tRC[1].."$$To: "..
				tOpChat.sName.." From: %[mynick] $<%[mynick]> !"..i..v.tRC[2].."&#124;")
			end
		end
	end
end

OpConnected = NewUserConnected

tCommands = {
	[tOpChat.sMembers] = {
		tFunc = function(user)
			-- Member
			if tMembers[string.lower(user.sName)] then
				-- Header
				local tMsg = "\r\n\r\n\t"..string.rep("=", 20).."\r\n\t        Member List:\r\n\t"..
				string.rep("-", 40).."\r\n"
				-- Populate
				for v,i in pairs (tMembers) do 
					tMsg = tMsg.."\t • "..v.."\r\n"
				end
				-- Send
				user:SendPM(tOpChat.sName, tMsg)
			end
		end,
		tRC = { "Member List", "" }
	},
	[tOpChat.sInvite] = {
		tFunc = function(user, data)
			-- Get nick
			local _,_, nick = string.find(data, "^%S+%s(%S+)$")
			-- Exists
			if nick then
				-- If member
				if tMembers[string.lower(nick)] then
					-- Already
					user:SendPM(tOpChat.sName, "*** Error: "..nick.." has already been invited to "..tOpChat.sName)
				else
					-- Send Message
					PM("*** "..nick.." has been invited to this room!", tOpChat.sName)
					-- Set member
					tMembers[string.lower(nick)] = 1
					-- Inform invited
					if GetItemByName(nick) then
						GetItemByName(nick):SendPM(tOpChat.sName, "*** You have been invited to "..
						tOpChat.sName.." by "..user.sName)
					end
					-- Save to DB
					SaveToFile(tOpChat.fFile, tMembers, "tMembers")
				end
			else
				user:SendPM(tOpChat.sName, "*** Error: You must type a nick!")
			end
		end,
		tRC = { "Invite User", " %[line:User]" }
	},
	[tOpChat.sRemove] = {	
		tFunc = function(user, data)
			-- Get nick
			local _,_, nick = string.find(data, "^%S+%s(%S+)$")
			-- Nick found
			if nick then
				-- If member
				if tMembers[string.lower(nick)] then
					-- Remove
					tMembers[string.lower(nick)] = nil
					-- Report to online nick
					if GetItemByName(nick) then
						GetItemByName(nick):SendPM(tOpChat.sName, "*** You have been removed from "..
						tOpChat.sName.." by "..user.sName)
					end
					-- Inform other members
					PM("*** "..nick.." has been removed from this room!", tOpChat.sName)
					-- Save
					SaveToFile(tOpChat.fFile, tMembers, "tMembers")
				else
					user:SendPM(tOpChat.sName, "*** Error: "..nick.." isn't a member of "..tOpChat.sName)
				end
			else
				user:SendPM(tOpChat.sName, "*** Error: You must type a nick!")
			end
		end,
		tRC = { "Remove User", " %[line:User]" }
	},
}

PM = function(msg, from)
	-- For each member
	for nick, id in pairs(tMembers) do
		-- For everyone except sender
		if nick ~= from then
			-- Send
			SendToNick(nick, "$To: "..nick.." From: "..tOpChat.sName.." $<"..from.."> "..msg)
		end
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

SaveToFile = function(file,table,tablename)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end