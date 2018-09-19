--[[ 

	Lucifer 6.6.6 - build 2.0

	LUA 5 version by jiten

	Thanks to Dessamator and GeceBekcisi for your contribution to this script

	- Commands to add, remove and list safe addresses
	- Set Action for advertising (warn, disconnect, kick, ban and timeban) from NL's Adver Shield
	- Site Protection from NL's Adver Shield
	- Changed: Command Structure (11/25/2005)
	- Changed: Optimized and reduced the code (Dessamator and jiten)
	- Fixed: Huge bug when advertising in Main/PM and being censored/kicked for anything (11/27/2005)
	- Removed: Unnecessary code (Dessamator and jiten) (11/30/2005)
	- Added: Censoring only option to custom Actions
	- Changed: Completely command and trigs' structures
	- Added: File handling for each table (add/del/show)
	- Added: Immune Profiles allowed to use the commands
	- Added: Option to send or not the Control/Report messages
	- Changed: SendMsg placement (12/31/2005)
	- Added: Inform only tAllowed Profiles to Actions (requested by Star) (1/2/2006)
	- Removed: http:// and www. from the Site List
	- Added: Exact Adver in report to ops (user is advertising: msg - Triggered by: adver) (1/22/2006)
	- Removed: Unnecessay vars (2/21/2006)
	- Changed: User nicks count for Control messages - requested by GB (2/28/2006)
	- Changed: Code gained a new look - by GeceBekcisi
	- Changed: Rightclick isn't looped anymore on user connect
	- Removed: Some extra vars in PubCheck and ToArrival
	- Added: OnError function - by Gecebekcisi
	- Changed: Commands do work in PM too - by GeceBekcisi
	- Added: GetProfileNameByNick - by Gecebekcisi
	- Changed: New DoDisc function
	- Changed: Some minor changes (3/3/2006)
	- Added: build to script (request by everyone) :P

	LUA 4 History

	     This is a Powerful AntiAdvertising Script
	     Powered by Demone.Astaroth and OpiumVolage
	     History: Base='multiline antiadvertise' by OpiumVolage (your tables simplify the work I did until that moment).
	     Here its features:

	     1)Script can block this types of advertisement: A) <user> example.no-ip.com
					       B) <user> e x a m p l e . n o - i p . c o m
					       C)<user>example.
					          <user>no-
					          <user>ip.
					          <user>com
					       D)<user>e
					          x
					          a
					          m
					          p
					          l
					          e
					          .
					          n
					          o
					          -					      
					          i
					          p
					          .
					          c
					          o
					          m
             2) You can insert valid addresses (like yours) in trigs, so bot won't kick you
             3) Users conversating with ops don't get kicked
             4) Why the Timer? It cleans memory.

             Demone.Astaroth addons:
		1) Added:  an huge list of addresses
		2) When advertising: user advised on Pm before disconnection; 
		   Bot sends to all in main chat the kicking message (without IP); 
		   advertise-infos send to Op-chat directly without troubling any Op with Pms!
		   Infos contain user's IP, user To(if PM) and last message
		   Just replace INSERT.HERE.YOUR.OP-CHAT.NAME fields with yours.
	     	3) Inserted: Disconnect and TimeBan (15 minutes) instead of gagging user
		4) Prevented: very splitted addresses (with more tSettings.tabAdvert lines)
		5) Added: Control-addresses: user isn't kicked for these addresses but Ops are informed in any case.
		   this is useful for friend-hubs addresses, if u also want to control them
		6) Added: ControlUser status: if u're scary about your vips advertising their hubs and stealing you user, 
		   you can't insert the tag [VIP] or anything else in the specific space: they will not
                   get kicked for any addresses, but in case of typing a Control-address, Ops will be informed.
		7) Fixed: some bug (Thanks Opium)
		8) Added: a new string-pieces find way to catch advertises

]]--

--[[ ------------------------- Settings ------------------------- ]]--
tSettings = {
	--// --------------------------------------------------
	--// Please feel free to edit settings below 
	--// --------------------------------------------------
	-- Basic Settings
	--- Your bot's name, default is hub default
	sBot = frmHub:GetHubBotName(),
	--- Error log file location
	sLogFile = "Lucifer.log",
	--- Right click menu's name, default is hub name
	sRightClickMenu = frmHub:GetHubName(),
	--- Command strings
	tCommands = {
		sShowTrigCMD = "showtrig",
		sAddTrigCMD = "addtrig",
		sDelTrigCMD = "deltrig",
	},
	-- file where the trigs are stored
	sTrigsFile = "tLucifer.tbl",
	-- Set action for advertising [ 0=Inform Ops (uncensored) / 1=Silent (censored) / 2=Warn / 3=Disconnect / 4=Kick / 5=Ban / 6=TimeBan ]
	iAction = 2,
	-- Send Report/Control Messages to tFeedProfiles Profiles (true = on, false = off)
	SendMsg = true,
	-- Profiles who can't receive "bad" messages from users, if target user is blocked, source user will be kicked etc...
	tBlockedProfiles = {
		[-1] = 1,	-- Unreg Users
		[2] = 1,	-- VIPs
		[3] = 1,	-- Regs
	},
	-- Profiles who will receive feed from bot
	tFeedProfiles = {
		[0] = 1,	-- Masters
		[1] = 1,	-- Operators
		[4] = 1,	-- Moderators
		[5] = 1,	-- NetFounders
	},
	tabAdvert = {}
}

tLucifer = {}
-- Advertise Trigs
tLucifer["adver"] = {
	[1] = {
		["dns2go"]=1,["myftpsite"]=1,["servebeer"]=1,["mine.nu"]=1,["ip.com"]=1,["dynip"]=1,["depecheconnect.com"]=1,
		["zapto.org"]=1, ["staticip"]=1,["serveftp"]=1,["ipactive"]=1,["ip.org"]=1,["no-ip"]=1,["servegame"]=1,
		["gotdns.org"]=1,["ip.net"]=1,["ip.co.uk"]=1,["ath.cx"]=1,["dyndns"]=1,["clanpimp"]=1,["idlegames"]=1,
		["sytes"]=1,["unusualperson.com"]=1,["24.184.64.48"]=1,["uni.cc"]=1,["homeunix"]=1,["ciscofreak.com"]=1,
		["deftonzs.com"]=1,["flamenap"]=1,["xs4all"]=1,["serveftp"]=1,["point2this.com"]=1,["ip.info"]=1,["myftp"]=1,["d2g"]=1,
		["24.184.64.48"]=1,["orgdns"]=1,["myip.org"]=1,["stufftoread.com"]=1,["ip.biz"]=1,["dynu.com"]=1,["mine.org"]=1,
		["kick-ass.net"]=1,["darkdata.net"]=1,["ipme.net"]=1,["udgnet.com"]=1,["homeip.net"]=1,	["e-net.lv"]=1,["mine.nu"]=1,
		["newgnr.com"]=1,["bst.net"]=1,["bsd.net"]=1,["ods.org"]=1,["x-host"]=1,["bounceme.net"]=1,["myvnc.com"]=1,
		["kyed.com"]=1,["lir.dk"]=1,["finx.org"]=1,["sheckie.net"]=1,["vizvaz.net"]=1,["snygging.net"]=1,["kicks-ass.com"]=1,
		["nerdcamp.net"]=1,["cicileu."]=1,["3utilities.com"]=1,["myftp.biz"]=1,["redirectme.net"]=1,["servebeer.com"]=1,
		["servecounterstrike.com"]=1,["servehalflife.com"]=1,["servehttp.com"]=1,["serveirc.com"]=1,["servemp3.com"]=1,
		["servepics.com"]=1,["servequake.com"]=1,["damnserver.com"]=1,["ditchyourip.com"]=1,["dnsiskinky.com"]=1,
		["geekgalaxy.com"]=1,["net-freaks.com"]=1,["ip.ca"]=1,["securityexploits.com"]=1,["securitytactics.com"]=1,
		["servehumour.com"]=1,["servep2p.com"]=1,["servesarcasm.com"]=1,["workisboring.com"]=1,["hopto"]=1,
		["64.246.26.135"]=1,["213.145.29.222"]=1,["dnsalias"]=1,["kicks-ass.org"]=1,["stabilt.se"]=1,["ostabil.nu"]=1,
		["snusk.nu"]=1,["fetftp.nu"]=1,["dotcom"]=1,["dotnet"]=1,["dotorg"]=1,
		["turkeyhub"]=1,["P2pTurkey.com"]=1,["P2pTurkey"]=1,["hub.net"]=1,["dcturk"]=1,
	},
	[2] = "Advers",
}
-- Safe Trigs
tLucifer["safe"] = {
	-- Insert here accepted addresses
	[1] = {["dcrehberi.sytes.net"]=1, ["Anatolia.no-ip.org"]=1, ["turkish-pride.no-ip.org"]=1, },
	[2] = "Safe Addresses",
}
-- Control Trigs
tLucifer["control"] = {
	-- Insert here addresses you want to be informed (no kick)
	[1] = { ["hub"]=1, ["com"]=1, ["net"]=1, ["org"]=1, ["www."]=1, ["http://"]=1, },
	[2] = "Control Trigs",
}
-- Site Trigs
tLucifer["site"] = {
	-- Accepted "sites" or triggers infront of the address
	[1] = { ["ftp://"]=1, ["irc."]=1, ["cs."]=1, },
	[2] = "Sites",
}

-- Inbuilt hub functions

-- Main function
Main = function()
	frmHub:RegBot(tSettings.sBot)
	if loadfile(tSettings.sTrigsFile) then dofile(tSettings.sTrigsFile) end
	SetTimer(60000) StartTimer()
end

-- Table cleaning
OnTimer = function()
	for key, value in tSettings.tabAdvert do
		if (tSettings.tabAdvert[key].iClock > os.clock()+60) then tSettings.tabAdvert[key] = nil end
	end
end

-- Lets send user commands here
NewUserConnected = function(curUser)
	for Key,Table in pairs(tCommands) do
		if tCommands[Key].tLevels[curUser.iProfile] then
			curUser:SendData(tCommands[Key]["tRightClick"])
		end
	end
end

OpConnected = NewUserConnected

-- Grab text from Mainchat and do the tricks
ChatArrival = function(curUser, data)
	local s,e,msg = string.find(data, "^%b<>%s+(.*)|$")
	curUser.SendMessage = curUser.SendData
	if tSettings.tBlockedProfiles[curUser.iProfile] and tFunctions.PubCheck(curUser, msg) then return 1 end
	return tFunctions.ParseCommands(curUser,msg)
end

-- Grab text from PMs and do the tricks
ToArrival = function(curUser, data)
	local _, _, to, msg = string.find(data, "^%$To:%s+(%S+)%s+From:%s+%S+%s-%$%b<>%s+(.*)|$")
	if to == tSettings.sBot then
		curUser.SendMessage = curUser.SendPM
		return tFunctions.ParseCommands(curUser, msg)
	else
		local to = GetItemByName(to)
		if to and tSettings.tBlockedProfiles[to.iProfile] then
			if tSettings.tBlockedProfiles[curUser.iProfile] and tFunctions.PubCheck(curUser, msg, to.sName) then
				return 1
			end
		end
	end
end

-- Error log and report
OnError = function(ErrorMsg)
	local sError = "Lucifer.6.6.6-ScriptError: "..os.date().." - "..ErrorMsg
	SendToOps(tSettings.sBot,sError) 
	SendPmToOps(tSettings.sBot,sError)
	local file,err = io.open(tSettings.sLogFile, "a+")
	if file then file:write(sError.."\n") end
	file:close()
end

-- Commands
tCommands = {}
tCommands[tSettings.tCommands.sShowTrigCMD] = {
	fFunction = function(curUser,data)
		local s,e,type = string.find(data,"%S+%s+(%S+)")
		if type and tLucifer[string.lower(type)] then
			type = string.lower(type)
			if next(tLucifer[type][1]) then
				local msg = "\r\n\r\n".."\t"..string.rep("- -",20).."\r\n" 
				msg = msg.."\t\tCurrent "..tLucifer[type][2]..":\r\n" 
				msg = msg.."\t"..string.rep("- -",20).."\r\n"
				for v, i in tLucifer[type][1] do msg = msg.."\t • "..v.."\r\n" end
				curUser:SendMessage(tSettings.sBot,msg)
			else
				curUser:SendMessage(tSettings.sBot, "*** Error: There aren't "..tLucifer[type][2]..".")
			end
		else
			curUser:SendMessage(tSettings.sBot,"*** Syntax Error: !"..tSettings.tCommands.sShowTrigCMD.." <safe/adver/control/site>")
		end	
	end,
	tLevels = {
		[0] = 1,
		[1] = 1,
		[4] = 1,
		[5] = 1,
	},
	tRightClick = "$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Show Trigger\\Safe$<%[mynick]> !"..tSettings.tCommands.sShowTrigCMD.." safe&#124;|"..
		"$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Show Trigger\\Advertise$<%[mynick]> !"..tSettings.tCommands.sShowTrigCMD.." adver&#124;|"..
		"$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Show Trigger\\Control$<%[mynick]> !"..tSettings.tCommands.sShowTrigCMD.." control&#124;|"..
		"$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Show Trigger\\Site$<%[mynick]> !"..tSettings.tCommands.sShowTrigCMD.." site&#124;"
}
tCommands[tSettings.tCommands.sAddTrigCMD] = {
	fFunction = function(curUser,data)
		local s,e,type,trig = string.find(data,"%S+%s+(%S+)%s*(.*)") 
		if type and tLucifer[string.lower(type)] and trig and trig ~= "" then
			type = string.lower(type) tLucifer[type][1][trig] = 1 tFunctions.SaveToFile(tSettings.sTrigsFile,tLucifer,"tLucifer")
			curUser:SendMessage(tSettings.sBot,trig.." has been successfully added to the "..tLucifer[type][2].." List.")
		else
			curUser:SendMessage(tSettings.sBot,"*** Syntax Error: !"..tSettings.tCommands.sAddTrigCMD.." <safe/adver/control/site> <address>")
		end	
	end,
	tLevels = {
		[0] = 1,
		[1] = 1,
		[4] = 1,
		[5] = 1,
	},
	tRightClick = "$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Add Trigger\\Safe$<%[mynick]> !"..tSettings.tCommands.sAddTrigCMD.." safe %[line:Enter the trigger]&#124;|"..
		"$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Add Trigger\\Advertise$<%[mynick]> !"..tSettings.tCommands.sAddTrigCMD.." adver %[line:Enter the trigger]&#124;|"..
		"$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Add Trigger\\Control$<%[mynick]> !"..tSettings.tCommands.sAddTrigCMD.." control %[line:Enter the trigger]&#124;|"..
		"$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Add Trigger\\Site$<%[mynick]> !"..tSettings.tCommands.sAddTrigCMD.." site %[line:Enter the trigger]&#124;"
}
tCommands[tSettings.tCommands.sDelTrigCMD] = {
	fFunction = function(curUser,data)
		local s,e,type,trig = string.find(data,"%S+%s+(%S+)%s*(.*)") 
		if type and tLucifer[string.lower(type)] and trig and trig ~= "" then
			type = string.lower(type)
			if tLucifer[type][1][trig] then
				tLucifer[type][1][trig] = nil tFunctions.SaveToFile(tSettings.sTrigsFile,tLucifer,"tLucifer")
				curUser:SendMessage(tSettings.sBot,trig.." has been successfully removed from the "..tLucifer[type][2].." List.")
			else
				curUser:SendMessage(tSettings.sBot,"There is no "..tLucifer[type][2]..": "..trig)
			end
		else
			curUser:SendMessage(tSettings.sBot,"*** Syntax Error: !"..tSettings.tCommands.sDelTrigCMD.." <safe/adver/control/site> <address>")
		end
	end,
	tLevels = {
		[0] = 1,
		[5] = 1,
	},
	tRightClick = "$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Delete Trigger\\Safe$<%[mynick]> !"..tSettings.tCommands.sDelTrigCMD.." safe %[line:Enter the trigger]&#124;|"..
		"$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Delete Trigger\\Advertise$<%[mynick]> !"..tSettings.tCommands.sDelTrigCMD.." adver %[line:Enter the trigger]&#124;|"..
		"$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Delete Trigger\\Control$<%[mynick]> !"..tSettings.tCommands.sDelTrigCMD.." control %[line:Enter the trigger]&#124;|"..
		"$UserCommand 2 3 "..tSettings.sRightClickMenu.."\\Lucifer 6.6.6\\Delete Trigger\\Site$<%[mynick]> !"..tSettings.tCommands.sDelTrigCMD.." site %[line:Enter the trigger]&#124;"
}

-- Custom built functions
tFunctions = {}

-- Command parsing
tFunctions.ParseCommands = function(curUser, data)
	local s,e,Command = string.find(data, "^%p(%S+)")
	if Command and tCommands[string.lower(Command)] then
		Command = string.lower(Command)
		if tCommands[Command].tLevels[curUser.iProfile] then
			return tCommands[Command].fFunction(curUser, data), 1
		else
			return curUser:SendMessage(tSettings.sBot, "*** Error: You are not allowed to use this command!"), 1
		end
	end
end

-- Pub checker
tFunctions.PubCheck = function(user, msg, to)
	local userdata, tmp = "", "in Main Chat: "..msg
	if to then userdata = to.." "..user.sName; tmp = "to <"..to.."> this: "..msg else userdata = user.sName end
	local SendTo = function(msg)
		if tSettings.SendMsg then
			for i,v in frmHub:GetOnlineUsers() do if tSettings.tFeedProfiles[v.iProfile] then v:SendPM(tSettings.sBot,msg) end end
		end
	end
	if not tFunctions.adCheck(msg) and tFunctions.Verify(userdata, msg) then
		local trig = tFunctions.Verify(userdata,msg)
		tSettings.tabAdvert[userdata] = nil
		SendTo((GetProfileName(GetUserProfile(user.sName)) or "User").." "..user.sName.." ("..user.sIP..") is "..tFunctions.DoDisc(user,msg).." for advertising "..tmp.." - Triggered by: "..trig)
		if tSettings.iAction ~= 0 then return true end
	end
	for key, value in tLucifer["control"][1] do
		if( string.find( string.lower(msg), key) ) then
			SendTo("Control: <"..user.sName.."> ("..user.sIP..") said "..tmp)
		end
	end
end

-- Site/safe checker
tFunctions.adCheck = function(Lines)
	for value,i in tLucifer["safe"][1] do
		for site, index in tLucifer["site"][1] do
			if string.find(Lines,value,1,1) or string.find(Lines,site,1,1) then
				return nil
			end
		end
	end
end

-- Lucifer core
tFunctions.Verify = function(userdata, msg)
	if not msg then return end
	local tmp = ""
	string.gsub(string.lower(msg), "([a-z0-9.:%-])", function(x) tmp = tmp..x end)
	if not tSettings.tabAdvert[userdata] then
		tSettings.tabAdvert[userdata] = { iClock = os.clock(), l1 = "", l2 = "", l3 = "", l4= "", l5= "",l6= "",l7= "",l8= "",l9 = tmp}
	else
		tSettings.tabAdvert[userdata].iClock = os.clock()
		tSettings.tabAdvert[userdata].l1 = tSettings.tabAdvert[userdata].l2
		tSettings.tabAdvert[userdata].l2 = tSettings.tabAdvert[userdata].l3
		tSettings.tabAdvert[userdata].l3 = tSettings.tabAdvert[userdata].l4
		tSettings.tabAdvert[userdata].l4 = tSettings.tabAdvert[userdata].l5
		tSettings.tabAdvert[userdata].l5 = tSettings.tabAdvert[userdata].l6
		tSettings.tabAdvert[userdata].l6 = tSettings.tabAdvert[userdata].l7
		tSettings.tabAdvert[userdata].l7 = tSettings.tabAdvert[userdata].l8
		tSettings.tabAdvert[userdata].l8 = tSettings.tabAdvert[userdata].l9
		tSettings.tabAdvert[userdata].l9 = tmp
	end
	local Lines = tSettings.tabAdvert[userdata].l1..tSettings.tabAdvert[userdata].l2..tSettings.tabAdvert[userdata].l3..tSettings.tabAdvert[userdata].l4..tSettings.tabAdvert[userdata].l5..tSettings.tabAdvert[userdata].l6..tSettings.tabAdvert[userdata].l7..tSettings.tabAdvert[userdata].l8..tSettings.tabAdvert[userdata].l9
	for value, key in tLucifer["adver"][1] do if (string.find(Lines, string.lower(value), 1, 1)) then return value end end
end

-- Advertise handling
tFunctions.DoDisc = function(user,msg)
	local tTable = {
		[0] = { sMsg = "being monitored" },
		[1] = { sMsg = "censored" },
		[2] = { sMsg = "warned", },
		[3] = { sMsg = "disconnected", sAction = function() user:Disconnect() end},
		[4] = { sMsg = "kicked", sAction = function() user:TempBan(0, "Advertising", tSettings.sBot, 1) end },
		[5] = { sMsg = "banned", sAction = function() user:Ban("Advertising", tSettings.sBot, 1) end },
		[6] = { sMsg = "temporarily banned", sAction = function() user:TempBan(0, "Advertising", tSettings.sBot, 1) end},
	}
	local tmp = tTable[tSettings.iAction]
	if tmp then
		user:SendPM(tSettings.sBot,"You are "..tmp.sMsg.." for advertising: "..msg)
		if tmp.sAction then tmp.sAction() end
		return tmp.sMsg
	end
end

-- File handling
tFunctions.Serialize = function(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in tTable do
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

tFunctions.SaveToFile = function(file,table,tablename)
	local hFile = io.open(file,"w+") tFunctions.Serialize(table,tablename,hFile); hFile:close() 
end