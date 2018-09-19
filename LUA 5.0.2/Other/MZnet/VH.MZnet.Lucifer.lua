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
Mute = {}
Lucifer = {}
Lucifer["adver"] = {
	[1] = {
	["ÖRG"] = 1, ["ÕRG"] = 1, ["ÒRG"] = 1, ["ÔRG"] = 1, ["õrg"] = 1, ["ôrg"] = 1, ["òrg"] = 1, ["örg"] = 1, ["0rg"] = 1,
	["noip"] = 1, 
	["côm"] = 1, ["cóm"] = 1, ["c0m"] = 1, ["cõm"] = 1,
	["z0n"] = 1, ["m0z"] = 1, 
	["moeen"] = 1,  ["helmo"] = 1, 
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

Lucifer["mute"] = {
	[1] = { 
	["myftpsite"] = 1, ["bounceme"] = 1,  ["redirectme"] = 1, ["dyndns"] = 1, ["dns2go"] = 1, ["myftporg"] = 1, 
	["redirectmenet"] = 1, ["serveftp"] = 1, ["sytesnet"] = 1, ["zaptoorg"] = 1, ["utilitiescom"] = 1, 
	["mozserver"] = 1, ["realcity"] = 1, ["luckyhub"] = 1, ["mzzone"] = 1, ["mzportal"] = 1, ["mozcorporation"] = 1, 
	["mzusers"] = 1, ["rdnoitadas"] = 1,  ["zuluhub"] = 1, ["confusaonoip"] = 1, ["roadblock"] = 1, ["hgmz"] = 1, 
	["noitadasisctem"] = 1, ["rapmz"] = 1, ["mzonline"] = 1, ["moznoheart"] = 1, ["mzgeneration"] = 1, ["beatzone"] = 1,
	["latinosspot"] = 1, ["hollyhub"] = 1, ["onlygame"] = 1, ["mzconnectingserver"] = 1, ["niggazhub"] = 1, ["zonehub"] = 1, 
	["hyperheat"] = 1, ["virtualdeath"] = 1, ["mzgandja"] = 1, ["virtualmoz"] = 1, ["mzbebados"] = 1, ["pipset"] = 1,
	["edy1988"] = 1, ["mzwizard"] = 1, ["mozgame"] = 1, ["isctemorg"] = 1, ["mozputos"] = 1,
	["radicalhub"] = 1, ["mozcorp"] = 1, ["afromoz"] = 1, ["dreamhub"] = 1, ["revolutionhub"] = 1, ["mzoffline"] = 1,
	["paismz"] = 1, ["mzhub"] = 1, ["hubmoz"] = 1, ["mozbar"] = 1, ["mzsystem"] = 1, ["kitass"] = 1, ["mozville"] = 1, 
	["ñ¤"] = 1, ["ñº"] = 1, ["ñø"] = 1, ["ñð"] = 1, ["nð"] = 1, ["nø"] = 1, ["n¤"] = 1, 
	["&#124;&#124;"] = 1, ["m&#124;z"] = 1, ["h&#124;u"] = 1, ["o&#124;z"] = 1, ["u&#124;b"] = 1, ["i&#124;p"] = 1, ["n&#124;o"] = 1, 
	["noiporg"] = 1, ["noipinfo"] = 1, ["noipcom"] = 1, ["noipbiz"] = 1, ["n0ip"] = 1,
	["ipbiz"] = 1, ["ipinfo"] = 1, ["iporg"] = 1, ["!p"] = 1,
	},
	[2] = "Mute trigs",
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
	if Mute[user.sName] then user:SendData(sBot,"*** You're gagged!") return 1 end
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
	["gag"] = 
	function(user, data)
		local s,e,usr = string.find(data,"%S+%s+(%S+)")
		local Muted = GetItemByName(usr)
		if Muted == nil then
			user:SendData(sBot,"*** Error: User is not online!")
		else
			if Mute[Muted.sName] == nil then
				Mute[Muted.sName] = 1 user:SendData(sBot,"*** "..Muted.sName.." has been Muted!")
			end
		end
	end, 
	["ungag"] = 
	function(user, data)
		local s,e,usr = string.find(data,"%S+%s+(%S+)")
		local Muted = GetItemByBane(usr)
		if Muted == nil then
			user:SendData(sBot,"*** Error: User is not online!")
		else
			if Mute[Muted.sName] then
				Mute[Muted.sName] = nil; user:SendData(sBot,"*** "..Muted.sName.." has Been UnMuted!")
			end
		end
	end, 
	["showgag"] = 
	function(user, data)
		local names = ""
		for index, value in Mute do
			local line = value[1].." ("..index..")"
			names = names.." "..line.."\r\n"
		end
		user:SendPM(sBot,"\r\n\r\nMuted User (IP).\r\n\r\n"..names)
	end, 
	["ungagall"] = 
	function(user, data)
		user:SendData(sBot,"*** All muted users can now speak!") Mute = {};
	end, 
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
	local adver, mute = Verify(userdata, msg, Lucifer["adver"][1]), Verify(userdata, msg, Lucifer["mute"][1])
	if adCheck(msg) ~= nil and adver then
		tabAdvert[userdata] = nil SendToAll("censored")
		SendTo("User <"..user.sName.."> ("..user.sIP..") is "..DoDisc(user,msg).." for advertising "..tmp.." - \""..adver.."\"")
		if Action ~= 0 then return true end
	end
	if adCheck(msg) ~= nil and mute then
		tabAdvert[userdata] = nil Mute[user.sName] = 1 SendToAll("gagged")
		SendTo("User <"..user.sName.."> ("..user.sIP..") is "..DoDisc(user,msg).." for advertising "..tmp.." - \""..mute.."\"")
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
		--for site, index in Lucifer["site"][1] do
			--or string.find(Lines,site,1,1) 
			if string.find(Lines,value,1,1) then return nil end
		--end
	end
	return 1
end

Verify = function(userdata, msg, tTable)
	if not msg then return end
	local tmp = ""
	if (string.find(msg,"([.:%-&#;])", 1, 1)) then
		string.gsub(string.lower(msg), "([a-zñðøº¤0-9.:%-])", function(x) tmp = tmp..x end)
	else
		string.gsub(string.lower(msg), "([a-zñðøº¤0-9&#;])", function(x) tmp = tmp..x end)
	end
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
	for value, key in tTable do if (string.find(Lines, string.lower(value), 1, 1)) then return value end end
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
