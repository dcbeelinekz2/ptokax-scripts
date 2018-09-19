--[[ 

	Lucifer 6.6.6 - build 2.131

	LUA 5.1 version by jiten

	Thanks to Dessamator, GeceBekcisi and TïMê†råVêlléR for your contribution to this script

	Changelog:

	- Added: Triggered by to Control messages
	- Changed: Safe and Adver trig list (3/9/2006)
	- Changed: Updated to Lua 5.1
	- Added: Trig check on add (3/11/2006)
	- Added: Custom Action for specific profile (3/12/2006)
	- Added: Switch to send Control/Report messages to Main/PM (3/13/2006)
	- Changed: string.find to string.match and some minor mods (3/14/2006)
	- Fixed: nil user.s* - thanks to Toobster®™ (3/16/2006)
	- Changed: string.match - thanks to Northwind (3/23/2006)
	- Changed: string.lower in Safe and Site check (3/23/2006)
	- Added: string.lower to bUnSafe and Add command - thanks TT (3/26/2006)
	- Changed: Some cleaning up;
	- Rewritten: Chat and ToArrival;
	- Changed: Lucifer's sites sub-table;
	- Added: Customize tBlockedProfiles checked for Site trigs - requested by TT;
	- Changed: bUnsafe function to bFound;
	- Modified: DoDisc function to support 3x actions - requested by TT;
	- Added: User Action Log Cleaner (7/6/2006);
	- Fixed: Syntax Error on PM message - reported by TT (7/8/2006);
	- Changed: RightClick-related stuff (7/10/2006);
	- Fixed: Messages sent in PM to bots reported as in Main - reported by Toobster (7/16/2006)

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

-- Settings --
tSettings = {
	--=====================================================
	--      Please feel free to edit settings below
	-------------------------------------------------------
	--- Your bot's name, default is hub default
	sBot = frmHub:GetHubBotName(),

	--- RightClick syntax + menu name
	sRC = "Lucifer 6.6.6",
	--- Command strings
	tCommands = {
		sShowCommand = "showtrig",
		sAddCommand = "addtrig",
		sDelCommand = "deltrig",
	},

	-- File where the trigs are stored
	fTrigs = "tLucifer.tbl",
	--- Error log file location
	fLog = "Lucifer.log",
	
	-- Enable Action Sequence? Example: 3x Warns = Disconnect, 3x Disconnects = Kick, and so on (See Actions)
	bSequence = true,
		-- Maximum times before taking next Action (see Actions)
		iMaxAction = 3,
		-- Time to store user Actions (in minutes)
		iStoreAction = 30,

	-- Send Report/Control Messages to tFeedProfiles Profiles (true = on, false = off)
	bSendMsg = false,
		-- pm = Send in PM; main = Send to Main (not case-sensitive)
		sHow = "PM",

	--[[
	Description: Profiles who can't send/receive "bad" messages and specific Action
	Actions: [ 0 = Inform Ops (uncensored) / 1 = Silent (censored) / 2 = Warn / 3 = Disconnect / 4 = Kick / 5 = TimeBan / 6 = Ban ]
	]]--
	tBlockedProfiles = {

	--	Example: [3] = 5, (Reg users are TimeBanned)

		[-1] = 2,	-- Unreg Users
		[2] = 2,	-- VIPs
		[3] = 2,	-- Regs
	},
	-- Profiles who will receive feed from bot
	tFeedProfiles = {
		[0] = 1,	-- Masters
		[1] = 1,	-- Operators
		[4] = 1,	-- Moderators
		[5] = 1,	-- NetFounders
	},
	-- tBlockedProfiles that are checked for Site trigs (0 = disabled, 1 = enabled)
	tSiteProfiles = {

	--	Example: [3] = 1, (Reg users are checked for those trigs in tLucifer["site"])

		[-1] = 1,	-- Unreg Users
		[3] = 1,	-- Regs
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
	},
	[2] = "Advers"
}
-- Safe Trigs
tLucifer["safe"] = {
	-- Insert here accepted addresses
	[1] = { ["hub.no-ip.com"]=1, ["test.no-ip.com"]=1, },
	[2] = "Safe Addresses"
}
-- Control Trigs
tLucifer["control"] = {
	-- Insert here addresses you want to be informed (no kick)
	[1] = { ["hub"]=1, ["com"]=1, ["net"]=1, ["org"]=1, },
	[2] = "Control Trigs"
}
-- Site Trigs
tLucifer["site"] = {
	-- Censored Site triggers (set profile permissions in Settings.tSiteProfiles)
	[1] = { ["www."]=1, ["http://"]=1, ["ftp://"]=1, ["irc."]=1, ["cs."]=1, },
	[2] = "Sites"
}

-- Inbuilt hub functions

-- Main function
Main = function()
	-- Register bot name
	frmHub:RegBot(tSettings.sBot);
	-- Load table content
	if loadfile(tSettings.fTrigs) then dofile(tSettings.fTrigs) end;
	-- Set and start timer
	SetTimer(60000); StartTimer()
end

-- Table cleaning
OnTimer = function()
	-- tabAdvert cleaner
	for i, v in pairs(tSettings.tabAdvert) do
		if (tSettings.tabAdvert[i].iClock > os.clock() + 60) then tSettings.tabAdvert[i] = nil end
	end
	-- Action cleaner
	for i, v in pairs(tAction) do
		if (v.iClock > os.time() - tSettings.iStoreAction*60) then 
			tAction[i] = nil
		end
	end
end

-- Lets send user commands here
NewUserConnected = function(user)
	for i, v in pairs(tCommands) do
		if tCommands[i].tLevels[user.iProfile] then
			local tmp = tCommands[i].tRightClick
			for a, b in ipairs(tmp) do
				local sLine = ""
				if i ~= tSettings.tCommands.sShowCommand then sLine = " %[line:Trigger]" end
				user:SendData("$UserCommand 1 3 "..tSettings.sRC.."\\"..tmp.sType.."\\"..b[1]..
				"$<%[mynick]> !"..i.." "..b[1]..sLine.."&#124;")
			end
		end
	end
end

OpConnected = NewUserConnected

ChatArrival = function(user, data)
	local _,_, to = string.find(data,"^$To:%s(%S+)%s+From:")
	local _,_, msg = string.find(data,"%b<>%s(.*)|$") 
	-- Message sent in Main or PM (except to Lucifer's Bot)
	if (to and to ~= tSettings.sBot) or not to then
		-- If user's profile is blocked and he advertised
		if tSettings.tBlockedProfiles[user.iProfile] and PubCheck(user, msg, to) then
			return 1
		end
	end
	-- Commands in Main or in PM to Lucifer's Bot
	if (to and to == tSettings.sBot) or not to then
		-- Parse commands
		local _,_, cmd = string.find(msg, "^%p(%S+)")
		if cmd and tCommands[string.lower(cmd)] then
			cmd, user.SendMessage = string.lower(cmd), user.SendData
			if to == tSettings.sBot then user.SendMessage = user.SendPM end
			if tCommands[cmd].tLevels[user.iProfile] then
				return tCommands[cmd].fFunction(user, msg), 1
			else
				return user:SendMessage(tSettings.sBot, "*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

ToArrival = ChatArrival

-- Error log and report
OnError = function(sError)
	local sError = "Lucifer 6.6.6 - Script Error: "..os.date().." - "..sError
	SendToOps(tSettings.sBot, sError); SendPmToOps(tSettings.sBot, sError)
	local file, err = io.open(tSettings.fLog, "a+")
	if file then file:write(sError.."\n") end; file:close()
end

-- Commands
tCommands = {

	[tSettings.tCommands.sShowCommand] = {
		fFunction = function(user,data)
			local _,_, type = string.find(data,"^%S+%s+(%S+)$")
			if type and tLucifer[string.lower(type)] then
				type = string.lower(type)
				if next(tLucifer[type][1]) then
					local msg = "\r\n\r\n".."\t"..string.rep("- -",20).."\r\n\t\tCurrent "..tLucifer[type][2]..
					":\r\n\t"..string.rep("- -",20).."\r\n"
					for v, i in pairs(tLucifer[type][1]) do msg = msg.."\t • "..v.."\r\n" end
					user:SendMessage(tSettings.sBot, msg)
				else
					user:SendMessage(tSettings.sBot, "*** Error: There aren't '"..tLucifer[type][2].."'.")
				end
			else
				user:SendMessage(tSettings.sBot, "*** Syntax Error: !"..tSettings.tCommands.sShowCommand..
				" <safe/adver/control/site>")
			end	
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		tRightClick = { { "Safe" }, { "Adver" }, { "Control" }, { "Site" }, sType = "Show Trigger" }
	},
	
	[tSettings.tCommands.sAddCommand] = {
		fFunction = function(user,data)
			local _,_, type, trig = string.find(data,"^%S+%s+(%S+)%s+(.+)$") 
			if type and tLucifer[string.lower(type)] and trig then
				type = string.lower(type) 
				if tLucifer[type][1][string.lower(trig)] then
					user:SendData(tSettings.sBot, "*** Error: There is already a '"..trig.."' in the "..
					tLucifer[type][2].." list!")
				else
					tLucifer[type][1][string.lower(trig)] = 1; SaveToFile(tSettings.fTrigs, tLucifer, "tLucifer")
					user:SendMessage(tSettings.sBot, "*** '"..trig.."' has been successfully added to the "..
					tLucifer[type][2].." list.")
				end
			else
				user:SendMessage(tSettings.sBot,"*** Syntax Error: !"..tSettings.tCommands.sAddCommand..
				" <safe/adver/control/site> <address>")
			end
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		tRightClick = { { "Safe" }, { "Adver" }, { "Control" }, { "Site" }, sType = "Add Trigger" }
	},

	[tSettings.tCommands.sDelCommand] = {
		fFunction = function(user,data)
			local _,_, type, trig = string.find(data,"^%S+%s+(%S+)%s+(.+)$") 
			if type and tLucifer[string.lower(type)] and trig then
				type = string.lower(type)
				if tLucifer[type][1][string.lower(trig)] then
					tLucifer[type][1][string.lower(trig)] = nil; SaveToFile(tSettings.fTrigs, tLucifer, "tLucifer")
					user:SendMessage(tSettings.sBot, "*** "..trig.." has been successfully removed from the "..
					tLucifer[type][2].." List.")
				else
					user:SendMessage(tSettings.sBot, "*** Error: There is no "..tLucifer[type][2]..": "..trig)
				end
			else
				user:SendMessage(tSettings.sBot, "*** Syntax Error: !"..tSettings.tCommands.sDelCommand..
				" <safe/adver/control/site> <address>")
			end
		end,
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRightClick = { { "Safe" }, { "Adver" }, { "Control" }, { "Site" }, sType = "Delete Trigger" }
	}
}

-- Pub checker
PubCheck = function(user, msg, to)
	local userdata, tmp = user.sName, "in Main Chat: "..msg
	if to then
		if GetItemByName(to) then to = GetItemByName(to).sName end
		userdata = to.." "..user.sName; tmp = "to <"..to.."> this: "..msg 
	end
	if (not bFound(msg, "safe") and Verify(userdata, msg)) or (tSettings.tSiteProfiles[user.iProfile] and 
		tSettings.tSiteProfiles[user.iProfile] == 1 and bFound(msg, "site")) then
		local trig = (Verify(userdata, msg) or bFound(msg, "site"))
		tSettings.tabAdvert[userdata] = nil
		SendTo((GetProfileName(GetUserProfile(user.sName)) or "User").." "..user.sName.." ("..
		user.sIP..") is "..DoDisc(user, msg).." for advertising "..tmp.." - Triggered by: "..trig)
		if tSettings.tBlockedProfiles[user.iProfile] ~= 0 then return true end
	end
	for i, v in pairs(tLucifer["control"][1]) do
		if string.find(string.lower(msg), i) then
			SendTo("Control: <"..user.sName.."> ("..user.sIP..") said "..tmp.." - Triggered by: "..i)
		end
	end
end

-- Reporter
SendTo = function(msg)
	if tSettings.bSendMsg then
		for i,v in ipairs(frmHub:GetOnlineUsers()) do 
			if tSettings.tFeedProfiles[v.iProfile] then 
				local tTable = {
					["main"] = function( ... ) v:SendData( ... ) end,
					["pm"] = function( ... ) v:SendPM( ... ) end,
				}
				local sHow = string.lower(tSettings.sHow)
				if tTable[sHow] then tTable[sHow](tSettings.sBot, msg) end
			end
		end
	end
end

-- Site/safe checker
bFound = function(Lines, tTable)
	local Lines = string.lower(Lines)
	for value, i in pairs(tLucifer[tTable][1]) do
		if string.find(Lines, string.lower(value), 1, true) then
			return value
		end
	end
	return false
end

-- Lucifer core
Verify = function( ... )
	for i = 1, select("#", ... ) do
		local userdata, msg = select(i, ... )
		if not msg then return end; userdata = tostring(userdata)
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
		local Lines = tSettings.tabAdvert[userdata].l1..tSettings.tabAdvert[userdata].l2..tSettings.tabAdvert[userdata].l3..
		tSettings.tabAdvert[userdata].l4..tSettings.tabAdvert[userdata].l5..tSettings.tabAdvert[userdata].l6..
		tSettings.tabAdvert[userdata].l7..tSettings.tabAdvert[userdata].l8..tSettings.tabAdvert[userdata].l9
		for i, v in pairs(tLucifer["adver"][1]) do
			if (string.find(Lines, string.lower(i), 1, true)) then return i end
		end
	end
end

tAction = {}

-- Advertise handling
DoDisc = function( user, ... )
	local msg = select(1, ... )
	local tTable = {
		[0] = { sMsg = "being monitored" },
		[1] = { sMsg = "censored" },
		[2] = { sMsg = "warned" },
		[3] = { sMsg = "disconnected", sAction = function() user:Disconnect() end},
		[4] = { sMsg = "kicked", sAction = function() user:TempBan(0, "Advertising", tSettings.sBot, 1) end },
		[5] = { sMsg = "temporarily banned", sAction = function() user:TempBan(0, "Advertising", tSettings.sBot, 1) end},
		[6] = { sMsg = "banned", sAction = function() user:Ban("Advertising", tSettings.sBot, 1) end },
	}
	local tmp = tTable[tSettings.tBlockedProfiles[user.iProfile]]
	if tmp then
		-- Action Sequence Enabled
		if tSettings.bSequence then
			-- Create user action table
			tAction[string.lower(user.sName)] = (tAction[string.lower(user.sName)] or { iClock = os.time() })
			-- User's Action Variable
			local tTemp = tAction[string.lower(user.sName)]; 
			-- Create if necessary
			tTemp.iAction = (tTemp.iAction or 0)
			-- Sum
			tTemp.iAction = tTemp.iAction + 1
			-- If higher than allowed
			if tTemp.iAction >= tSettings.iMaxAction then
				local iMax = (tonumber(tSettings.tBlockedProfiles[user.iProfile]) + 
					tonumber(math.floor(tTemp.iAction/tSettings.iMaxAction)))
				-- If under maximum actions
				if iMax <= 6 then
					-- Goto to next action
					tmp = tTable[iMax]
				else
					-- Use the last one
					tmp = tTable[table.getn(tTable)]
				end
			end
		end
		user:SendPM(tSettings.sBot, "You are "..tmp.sMsg.." for advertising: "..msg)
		if tmp.sAction then tmp.sAction() end; return tmp.sMsg
	end
end

-- File handling
Serialize = function(tTable, sTableName, hFile, sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in pairs(tTable) do
		if (type(value) ~= "function") then
			local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
			if(type(value) == "table") then
				Serialize(value, sKey, hFile, sTab.."\t");
			else
				local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
				hFile:write(sTab.."\t"..sKey.." = "..sValue);
			end
			hFile:write(",\n");
		end
	end
	hFile:write(sTab.."}");
end

SaveToFile = function(file, table, tablename)
	local hFile = io.open(file,"w+") Serialize(table, tablename, hFile); hFile:close() 
end