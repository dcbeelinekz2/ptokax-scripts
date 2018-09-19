--[[

	HelpDesk 1.1d - LUA 5.0/5.1 by jiten (4/14/2006)

	Changelog:

	- Added: Commands work in Mainchat;
	- Changed: Operators are able to leave and join HelpDesk;
	- Added: Members command;
	- Changed: Operator autologin switch (3/4/2006)
	- Changed: Commands can be changed in tDesk
	- Changed: Message on login (3/5/2006)
	- Added: RightClick Commands (3/7/2006)
	- Changed: Updated to LUA 5.1;
	- Added: Mutor's TrigChat 1.01e trigs Table as an example;
	- Added: Search for trigs ending with a ? and return assigned string - requested by jaydee (4/14/2006).

]]--

tDesk = {
	-- Bot Name
	sBot = "[_HeLPDeSK_]",
	-- HelpDesk database
	fHelp = "tHelpDesk.tbl",
	-- Autologin every operator on script re/start
	bAutoLogin = true,
	-- Message sent to user when there's no trig?
	sMsg = "If you have any question, talk to jaydee or sampleman.",
	-- Commands
	sLeave = "leave", sJoin = "helpdesk", sMembers = "members"
}
tMembers = {}

tTrigs = {
	["faq"] = "Checkout the DC++ Definitive FAQ -> http://www.broadbandreports.com/faq/dc/",
	["needs sleep"] = "Ya, [User] get some rest. You look like death warmed over...",
	["no slot"] = "Quit yer whining [User]",
	["good bye"] = "Bye, [User]",
	["hi "] = "Hi, [User], Welcome to Mutor's Archive!",
	["Hey"] = {
		[1] = "Hey now, [User], Welcome to Mutor's Archive!",
		[2] = "Hey look everyone, its [USER]",
	},
	["anyone have"] = "[User], please use the search tool, instead of making requests in main chat.",
	["cock"] = "Hey [User]! Watch the language. Dont use words like that in here please.",
	["lol"] = {
		[1] = ":D",
		[2] = "hehe [USER]",
	},
	["anyone got"] = "[User], please use the search tool, instead of making requests in main chat.",
	["bbiab"] = "Cya soon then...[User]",
	["zzz"] = "Ya, [User] get some rest. I've seen corpses with better complexion...",
	["hehe"] = "haha, [User]",
	["what's up"] = "Same ol, Same ol [User]",
	["Yo "] = "Yo, [User]. What's up dude?",
	["see ya"] = "See Ya, [User]",
	["Hi "] = "Hi, [User], Welcome to Mutor's Archive!",
	["dick"] = "Hey [User]! Watch the language. Dont use words like that in here please.",
	["kk"] = "Alright...[User]",
	["gay"] = "Listen [User]! Dont be jealous because you cant accessorize an outfit.",
	["rofl"] = {
		[1] = "OK [User], you can get off the floor now. :), It wasnt that funny :D",
		[2] = "What are you doing down there [USER], nothing is that funny.",
		[3] = "Get off the floor [USER], you don't know where it's been.",
	},
	["wb"] = "Glad you could make it back...",
}

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

NewUserConnected = function(user)
	if user.bUserCommand then
		user:SendData("$UserCommand 1 3 HelpDesk\\Join$<%[mynick]> !"..tDesk.sJoin.."&#124;")
		user:SendData("$UserCommand 1 3 HelpDesk\\Leave$<%[mynick]> !"..tDesk.sLeave.."&#124;")
		user:SendData("$UserCommand 1 3 HelpDesk\\Member List$<%[mynick]> !"..tDesk.sMembers.."&#124;")
	end
end

OpConnected = NewUserConnected

tCmds = {
	[tDesk.sLeave] = function(user)
		if tMembers[user.sName] then
			tMembers[user.sName] = nil
			user:SendPM(tDesk.sBot,"*** You have left the HelpDesk!")
			PM("*** "..user.sName.." left!",tDesk.sBot)
			SaveToFile(tDesk.fHelp,tMembers,"tMembers")
		end
	end,
	[tDesk.sJoin] = function(user)
		if not tMembers[user.sName] then
			PM("*** "..user.sName.." joined!",tDesk.sBot)
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
			for v,i in pairs (tMembers) do
				tMsg = tMsg.."\t • "..v.."\r\n"
			end
			user:SendPM(tDesk.sBot,tMsg)
		end
	end
}

PM = function(msg, from)
	for nick, id in pairs(tMembers) do
		if nick ~= from then
			SendToNick(nick, "$To: "..nick.." From: "..tDesk.sBot.." $<"..from.."> "..msg)
		end
		local Exists = nil
		if string.find(msg,".*%?$") then
			for i,v in pairs(tTrigs) do
				if string.find(string.lower(msg),string.lower(i),1,1) then
					if type(v) == "string" then
						sMsg = string.gsub(v,"%b[]", from)
					else
						sMsg = string.gsub(v[math.random(1,table.getn(v))],"%b[]", from)
					end
					Exists = 1
				end
			end
			local nick = GetItemByName(nick)
			if Exists then 
				if nick then nick:SendPM(tDesk.sBot,sMsg) end
			else
				if nick then nick:SendPM(tDesk.sBot,"*** "..from..": "..tDesk.sMsg) end
			end
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