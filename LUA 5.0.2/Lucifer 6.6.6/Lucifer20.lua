---/----------------------------------------------------------------------------------------------------------------------
-- Lucifer 6.6.6

-- LUA 5 version by jiten 
--	Modified a little bit
--	Commands to add, remove and list safe addresses
--	Set Action for advertising (warn, disconnect, kick, ban and timeban) from NL's Adver Shield
--	Site Protection from NL's Adver Shield
--	Changed: Command Structure (11/25/2005)
--	Changed: Optimized and reduced the code (Dessamator and jiten)
--	Fixed: Huge bug when advertising in Main/PM and being censored/kicked for anything (11/27/2005)
--	Removed: Unnecessary code (Dessamator and jiten) (11/30/2005)
--	Added: Censoring only option to custom Actions
--	Changed: Completely command and trigs' structures
--	Added: File handling for each table (add/del/show)
--	Added: Immune Profiles allowed to use the commands
--	Added: Option to send or not the Control/Report messages
--	Changed: SendMsg placement (12/31/2005)
--	Added: Inform only tAllowed Profiles to Actions (requested by Star) (1/2/2006)
--	Removed: http:// and www. from the Site List
--	Added: Exact Adver in report to ops (user is advertising: msg - Triggered by: adver) (1/22/2006)

-- This is a Powerful AntiAdvertising Script
-- Powered by Demone.Astaroth and OpiumVolage
-- History: Base='multiline antiadvertise' by OpiumVolage (your tables simplify the work I did until that moment). Here its features:
--             1)Script can block this types of advertisement: A) <user> example.no-ip.com
--					       B) <user> e x a m p l e . n o - i p . c o m
--					       C)<user>example.
--					          <user>no-
--					          <user>ip.
--					          <user>com
--					       D)<user>e
--					          x
--					          a
--					          m
--					          p
--					          l
--					          e
--					          .
--					          n
--					          o
--					          -					      
--					          i
--					          p
--					          .
--					          c
--					          o
--					          m
--             2)You can insert valid addresses (like yours) in trigs, so bot won't kick you
--             3)Users conversating with ops don't get kicked
--             4)Why the Timer? It cleans memory.

--             Demone.Astaroth addons: 1)added an huge list of addresses
--		   	      2)When advertising: user advised on Pm before disconnection; Bot sends to all in main chat the kicking message (without IP); 
--	                                         advertise-infos send to Op-chat directly without troubling any Op with Pms! Infos contain user's IP, user To(if PM) and last message
--			         Just replace INSERT.HERE.YOUR.OP-CHAT.NAME fields with yours.
--	     	                      3)inserted Disconnect and TimeBan (15 minutes) instead of gagging user
--		   	      4)Prevented very splitted addresses (with more tabAdvert lines)
--                                	      5)added Control-addresses: user isn't kicked for these addresses but Ops are informed in any case.
--                                                  	                                 this is useful for friend-hubs addresses, if u also want to control them
-- 	                                      6)added ControlUser status: if u're scary about your vips advertising their hubs and stealing you user, 
--                   	                                                                  you can't insert the tag [VIP] or anything else in the specific space: they will not
--                                     	                                                  get kicked for any addresses, but in case of typing a Control-address, Ops will be
--                                                        	                                  informed.
--	                                      7)Fixed some bug (Thanks Opium)
--			      8)Added a new string-pieces find way to catch advertises

---/----------------------------------------------------------------------------------------------------------------------

sBot = frmHub:GetHubBotName()

Lucifer = {}
Lucifer["adver"] = {
	[1] = {
		["dns2go"]=1,["myftpsite"]=1,["servebeer"]=1,["mine.nu"]=1,["ip.com"]=1,["dynip"]=1,["depecheconnect.com"]=1,
		["zapto.org"]=1, ["staticip"]=1,["serveftp"]=1,["ipactive"]=1,["ip.org"]=1,["no-ip"]=1,["servegame"]=1,
		["gotdns.org"]=1,["ip.net"]=1,["ip.co.uk"]=1,["ath.cx"]=1,["dyndns"]=1,["68.67.18.75"]=1,["clanpimp"]=1,
		["idlegames"]=1,["sytes"]=1,["unusualperson.com"]=1,["24.184.64.48"]=1,["uni.cc"]=1,["151.198.149.60"]=1,
		["homeunix"]=1,["24.209.232.97"]=1,["ciscofreak.com"]=1,["deftonzs.com"]=1,["24.187.50.121"]=1,["flamenap"]=1,
		["xs4all"]=1,["serveftp"]=1,["point2this.com"]=1,["ip.info"]=1,	["myftp"]=1,["d2g"]=1,["151.198.149.60"]=1,
		["24.184.64.48"]=1,["orgdns"]=1,["myip.org"]=1,["stufftoread.com"]=1,["ip.biz"]=1,["dynu.com"]=1,["mine.org"]=1,
		["kick-ass.net"]=1,["darkdata.net"]=1,["ipme.net"]=1,["udgnet.com"]=1,["homeip.net"]=1,	["e-net.lv"]=1,
		["newgnr.com"]=1,["bst.net"]=1,["bsd.net"]=1,["ods.org"]=1,["x-host"]=1,["bounceme.net"]=1,["myvnc.com"]=1,
		["kyed.com"]=1,["lir.dk"]=1,["finx.org"]=1,["sheckie.net"]=1,["vizvaz.net"]=1,["snygging.net"]=1,["kicks-ass.com"]=1,
		["nerdcamp.net"]=1,["cicileu."]=1,["3utilities.com"]=1,["myftp.biz"]=1,["redirectme.net"]=1,["servebeer.com"]=1,
		["servecounterstrike.com"]=1,["servehalflife.com"]=1,["servehttp.com"]=1,["serveirc.com"]=1,["servemp3.com"]=1,
		["servepics.com"]=1,["servequake.com"]=1,["damnserver.com"]=1,["ditchyourip.com"]=1,["dnsiskinky.com"]=1,
		["geekgalaxy.com"]=1,["net-freaks.com"]=1,["ip.ca"]=1,["securityexploits.com"]=1,["securitytactics.com"]=1,
		["servehumour.com"]=1,["servep2p.com"]=1,["servesarcasm.com"]=1,["workisboring.com"]=1,["hopto"]=1,
		["64.246.26.135"]=1,["213.145.29.222"]=1,["dnsalias"]=1,["kicks-ass.org"]=1,["stabilt.se"]=1,["ostabil.nu"]=1,
		["snusk.nu"]=1,["fetftp.nu"]=1,
	},
	[2] = "Advers",
}
Lucifer["safe"] = {
	-- Insert here accepted addresses
	[1] = { ["hub.no-ip.com"]=1, ["test.no-ip.com"]=1, },
	[2] = "Safe Addresses",
}

Lucifer["control"] = {
	-- Insert here addresses you want to be informed (no kick)
	[1] = { ["boi"]=1, ["speed"]=1, ["eski"]=1, ["grime"]=1, ["bbv"]=1, ["bigboi"]=1, },
	[2] = "Control Trigs",
}

Lucifer["site"] = {
	-- Accepted "sites" or triggers infront of the address
	[1] = { ["www."]=1, ["http://"]=1, ["ftp://"]=1, ["irc."]=1, ["cs."]=1, },
	[2] = "Sites",
}

tAllowed = {
	-- Profiles that are Immune to the Anti-Advertiser and are able to use the commands
	[0] = 1, -- master
	[1] = 1, -- operator
	[2] = 0, -- vip
	[3] = 0, -- reg
	[4] = 1, -- moderator
	[5] = 1, -- founder
	[-1] = 0, -- unreg
}

-- file where the trigs are stored
fLucifer = "tLucifer.tbl" 

-- Set action for advertising [ 0=Inform Ops (uncensored) / 1=Silent (censored) / 2=Warn / 3=Disconnect / 4=Kick / 5=Ban / 6=TimeBan ]
Action = 2

-- Time Ban period
iTimeBan = 20

-- Send Report/Control Messages to tAllowed Profiles (true = on, false = off)
SendMsg = true

tabAdvert = {}

Main = function()
	frmHub:RegBot(sBot)
	if loadfile(fLucifer) then dofile(fLucifer) end
	SetTimer(60000) StartTimer()
end

OnTimer = function()
	for key, value in tabAdvert do
		if (tabAdvert[key].iClock > os.clock()+60) then tabAdvert[key] = nil end
	end
end

ChatArrival = function(user,data)
	local data = string.sub(data,1,-2) 
	local s,e,msg = string.find(data, "^%b<>%s+(.*)")
	if tAllowed[user.iProfile] == 1 then
		local s,e,cmd = string.find(msg,"^[%!%+](%S+)")
		if cmd and tCmds[cmd] then return tCmds[cmd](user,msg),1 end
	else
		if PubCheck(user,data,msg) then return 1 end
	end
end

tCmds = {
	["showtrig"] = 
	function(user,data)
		local s,e,type = string.find(data,"%S+%s+(%S+)")
		if type and Lucifer[string.lower(type)] then
			type = string.lower(type)
			if next(Lucifer[type][1]) then
				local msg = "\r\n\r\n".."\t"..string.rep("- -",20).."\r\n" 
				msg = msg.."\t\tCurrent "..Lucifer[type][2]..":\r\n" 
				msg = msg.."\t"..string.rep("- -",20).."\r\n"
				for v, i in Lucifer[type][1] do msg = msg.."\t • "..v.."\r\n" end
				user:SendPM(sBot,msg)
			else
				user:SendData(sBot, "*** Error: There aren't "..Lucifer[type][2]..".")
			end
		else
			user:SendData(sBot,"*** Syntax Error: !showtrig <safe/adver/control/site>")
		end
	end,

	["addtrig"] =
	function(user,data)
		local s,e,type,trig = string.find(data,"%S+%s+(%S+)%s*(.*)") 
		if type and Lucifer[string.lower(type)] and trig and trig ~= "" then
			type = string.lower(type) Lucifer[type][1][trig] = 1 SaveToFile(fLucifer,Lucifer,"Lucifer")
			user:SendData(sBot,trig.." has been successfully added to the "..Lucifer[type][2].." List.")
		else
			user:SendData(sBot,"*** Syntax Error: !addtrig <safe/adver/control/site> hub.no-ip.com")
		end
	end,

	["deltrig"] = 
	function(user,data)
		local s,e,type,trig = string.find(data,"%S+%s+(%S+)%s*(.*)") 
		if type and Lucifer[string.lower(type)] and trig and trig ~= "" then
			type = string.lower(type)
			if Lucifer[type][1][trig] then
				Lucifer[type][1][trig] = nil SaveToFile(fLucifer,Lucifer,"Lucifer")
				user:SendData(sBot,trig.." has been successfully removed from the "..Lucifer[type][2].." List.")
			else
				user:SendData(sBot,"There is no "..Lucifer[type][2]..": "..trig)
			end
		else
			user:SendData(sBot,"*** Syntax Error: !deltrig <safe/adver/control/site> hub.no-ip.com")
		end
	end,
}

ToArrival = function(user, data)
	local data = string.sub(data,1,-2) 
	if tAllowed[user.iProfile] ~= 1 then
		local _, _, to, from, msg = string.find(data, "^%$To:%s+(%S+)%s+From:%s+(%S+)%s-%$%b<>%s+(.*)")
		if GetItemByName(to) and tAllowed[GetItemByName(to).iProfile] ~= 1 and PubCheck(user, data, msg, to, from) then return 1 end
	end
end

PubCheck = function(user, data, msg, to, from)
	local userdata, tmp = "", "in Main Chat: "..msg
	if to then userdata = to.." "..from; tmp = "to <"..to.."> this: "..msg else userdata = user.sName end
	local SendTo = function(msg)
		if SendMsg then
			for i,v in frmHub:GetOnlineUsers() do if tAllowed[v.iProfile] == 1 then v:SendPM(sBot,msg) end end
		end
	end
	if adCheck(msg) ~= nil and Verify(userdata, msg) then
		local trig = Verify(userdata,msg)
		tabAdvert[userdata] = nil
		SendTo("User <"..user.sName.."> ("..user.sIP..") is "..DoDisc(user,msg).." for advertising "..tmp.." - Triggered by: "..trig)
		if Action ~= 0 then return true end
	end
	for key, value in Lucifer["control"][1] do
		if( string.find( string.lower(data), key) ) then
			SendTo("Control: User <"..user.sName.."> ("..user.sIP..") said "..tmp)
		end
	end
end

adCheck = function(Lines)
	for value,i in Lucifer["safe"][1] do
		for site, index in Lucifer["site"][1] do
			if string.find(Lines,value,1,1) or string.find(Lines,site,1,1) then return nil end
		end
	end
	return 1
end

Verify = function(userdata, msg)
	if not msg then return end
	local tmp = ""
	string.gsub(string.lower(msg), "([a-z0-9.:%-])", function(x) tmp = tmp..x end)
	if not tabAdvert[userdata] then
		tabAdvert[userdata] = { iClock = os.clock(), l1 = "", l2 = "", l3 = "", l4= "", l5= "",l6= "",l7= "",l8= "",l9 = tmp}
	else
		tabAdvert[userdata].iClock = os.clock()
		tabAdvert[userdata].l1 = tabAdvert[userdata].l2
		tabAdvert[userdata].l2 = tabAdvert[userdata].l3
		tabAdvert[userdata].l3 = tabAdvert[userdata].l4
		tabAdvert[userdata].l4 = tabAdvert[userdata].l5
		tabAdvert[userdata].l5 = tabAdvert[userdata].l6
		tabAdvert[userdata].l6 = tabAdvert[userdata].l7
		tabAdvert[userdata].l7 = tabAdvert[userdata].l8
		tabAdvert[userdata].l8 = tabAdvert[userdata].l9
		tabAdvert[userdata].l9 = tmp
	end
	local Lines = tabAdvert[userdata].l1..tabAdvert[userdata].l2..tabAdvert[userdata].l3..tabAdvert[userdata].l4..tabAdvert[userdata].l5..tabAdvert[userdata].l6..tabAdvert[userdata].l7..tabAdvert[userdata].l8..tabAdvert[userdata].l9
	for value, key in Lucifer["adver"][1] do if (string.find(Lines, string.lower(value), 1, 1)) then return value end end
end

DoDisc = function(user,msg)
	if Action == 0 then
		return "Being Monitored"
	elseif Action == 1 then
		return "Censored"
	elseif Action == 2 then
		user:SendPM(sBot,"You are Warned for advertising: "..msg) return "Warned"
	elseif Action == 3 then
		user:SendPM(sBot,"You are Disconnected for advertising: "..msg) user:Disconnect() return "Disconnected"
	elseif Action == 4 then
		user:SendPM(sBot,"You are Kicked for advertising: "..msg) user:TempBan() return "Kicked" 
	elseif Action == 5 then
		user:SendPM(sBot,"You are Banned for advertising: "..msg) user:Ban() return "Banned"
	elseif Action == 6 then
		user:SendPM(sBot,"You are TimeBanned for advertising: "..msg) user:TimeBan(iTimeBan) return "TimeBanned"
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
---/----------------------------------------------------------------------------------------------------------------------
