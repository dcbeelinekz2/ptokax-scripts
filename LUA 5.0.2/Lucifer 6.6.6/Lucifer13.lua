---/----------------------------------------------------------------------------------------------------------------------
-- Lucifer 6.6.6 mixed with features from NL's Adver Shield
--This is a Powerful AntiAdvertising Script
--Powered by Demone.Astaroth and OpiumVolage
--History: Base='multiline antiadvertise' by OpiumVolage (your tables simplify the work I did until that moment). Here its features:

-- LUA 5 version by jiten 
--	Modified a little bit
--	Commands to add, remove and list safe addresses
--	Set Action for advertising (warn, disconnect, kick, ban and timeban)
--	Site Protection
---/----------------------------------------------------------------------------------------------------------------------

BotName = frmHub:GetHubBotName()

advtrigs = {"dns2go","myftpsite","servebeer","mine.nu","ip.com","dynip","depecheconnect.com","zapto.org",
	"staticip","serveftp","ipactive","ip.org","no-ip","servegame","gotdns.org","ip.net","ip.co.uk",
	"ath.cx","dyndns","68.67.18.75","clanpimp","idlegames","sytes","unusualperson.com",
	"24.184.64.48","uni.cc","151.198.149.60","homeunix","24.209.232.97","ciscofreak.com",
	"deftonzs.com","24.187.50.121","flamenap","xs4all","serveftp","point2this.com","ip.info",
	"myftp","d2g","151.198.149.60","24.184.64.48","orgdns","myip.org","stufftoread.com",
	"ip.biz","dynu.com","mine.org","kick-ass.net","darkdata.net","ipme.net","udgnet.com","homeip.net",
	"e-net.lv","newgnr.com","bst.net","bsd.net","ods.org","x-host","bounceme.net","myvnc.com",
	"kyed.com","lir.dk","finx.org","sheckie.net","vizvaz.net","snygging.net","kicks-ass.com","nerdcamp.net",
	"cicileu.","3utilities.com","myftp.biz","redirectme.net","servebeer.com","servecounterstrike.com",
	"servehalflife.com","servehttp.com","serveirc.com","servemp3.com","servepics.com","servequake.com",
	"damnserver.com","ditchyourip.com","dnsiskinky.com","geekgalaxy.com","net-freaks.com","ip.ca",
	"securityexploits.com","securitytactics.com","servehumour.com","servep2p.com","servesarcasm.com",
	"workisboring.com","hopto","64.246.26.135","213.145.29.222","dnsalias"} 

-- file where the safe advertise triggs are stored
vFile = "validtrigs.tbl" 

-- Set action for advertising ( 0=Warn / 1=Disconnect / 2=Kick / 3=Ban / 4=TimeBan)
Action = 0
iTimeBan = 20 -- Time Ban period

-- Accepted "sites" or triggers infront of the address
Sites = { "www.", "http://", "ftp://", "irc.", "cs.", }

-- Insert here addresses you want to be informed (no kick)
controltrigs={ ["boi"]=1, ["speed"]=2, ["eski"]=3, ["grime"]=4, ["bbv"]=5, ["bigboi"]=6 }

tabAdvert = {} vTrigs = {}

Main = function()
	frmHub:RegBot(BotName)
	if loadfile(vFile) then dofile(vFile) end
	SetTimer(60000) StartTimer()
end

OnTimer = function()
	for key, value in tabAdvert do
		if (tabAdvert[key].iClock > os.clock()+60) then
			tabAdvert[key]=nil
		end
	end
end

ChatArrival = function(user, data)
	local data = string.sub(data,1,-2) 
	if user.bOperator then
		local s,e,cmd = string.find(data,"%b<>%s+(%S+)") 
		if cmd == "!showsafe" then
			if not next(vTrigs) then
				user:SendData(BotName,"*** Error: There aren't any Safe Addresses.")
			else
				local msg = "\r\n\r\n".."\t»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«".."\r\n" 
				msg = msg.."\t          ¤ Current Safe Addresses ¤".."\r\n" 
				msg = msg.."\t»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«".."\r\n" 
				local address,value
				for address, value in vTrigs do msg = msg.."\t &#8226;   "..address.."\r\n" end 
				user:SendPM(BotName,msg)
			end
			return 1
		end
		local s,e,trig = string.find(data,"%b<>%s+%S+%s+(%S+)") 
		if cmd and trig then
			if cmd == "!addsafe" then
				vTrigs[trig] = 1
				user:SendData(BotName,trig.." has been successfully added to the Safe Address List.")
				SaveToFile(vFile,vTrigs,"vTrigs")
				return 1
			elseif cmd == "!delsafe" then
				if vTrigs[trig] == 1 then
					vTrigs[trig] = nil
					user:SendData(BotName,trig.." has been successfully removed from the Safe Address List.")
					SaveToFile(vFile,vTrigs,"vTrigs")
				else
					user:SendData(BotName,"There is no Safe Address: "..trig)
				end
				return 1
			end
		end
	end
	if not user.bOperator then
		local _, _, msg = string.find(data, "^%b<>%s+(.*)")
		if adCheck(msg) ~= nil and Verify(user.sName, msg) then
			tabAdvert[user.sName]=nil
			local action = DoDisc(user,msg)
			s,e,onlymes = string.find(data, "%b<> (.*)")
			SendPmToOps (BotName, "User "..user.sName.." with IP "..user.sIP.." is "..action.." for advertising in main chat saying: "..onlymes.."")
			return 1
		end
		for key, value in controltrigs do
			if( string.find( string.lower(data), key) ) then
				s,e,onlymes = string.find(data, "%b<> (.*)")
				SendPmToOps(BotName, "Control: User "..user.sName.." with IP "..user.sIP.." told in main: "..onlymes.."")
			end
		end
		spam=0
		if( string.find( string.lower(data), "no",1,1) ) and ( string.find( string.lower(data), "ip.",1,1) ) then
			if ( string.find( string.lower(data), "com",1,1) ) or ( string.find( string.lower(data), "org",1,1) ) or ( string.find( string.lower(data), "info",1,1) ) then
				spam=spam+1;
			end;
		end;
		if( string.find( string.lower(data), "dns",1,1) ) and ( string.find( string.lower(data), "2",1,1) ) and ( string.find( string.lower(data), "go",1,1) ) then
			spam=spam+1;
		end
		if( string.find( string.lower(data), "dy",1,1) ) and ( string.find( string.lower(data), "nu",1,1) ) then
			if( string.find( string.lower(data), ".net",1,1) ) or ( string.find( string.lower(data), ".com",1,1) ) then
				spam=spam+1;
			end;
		end
		if( string.find( string.lower(data), "d n s a",1,1) ) or ( string.find( string.lower(data), "d n s .",1,1) ) or ( string.find( string.lower(data), "d n s 2",1,1) ) or ( string.find( string.lower(data), "o d s .",1,1) ) or ( string.find( string.lower(data), "d y n",1,1) ) then
			spam=spam+1;
		end
	end
end

ToArrival = function(user, data)
	local data = string.sub(data,1,-2) 
	if not user.bOperator then
		local _, _, to, from, msg = string.find(data, "^%$To:%s+(%S+)%s+From:%s+(%S+)%s-%$%b<>%s+(.*)")
		if GetItemByName(to) then
			local nick = GetItemByName(to)
			if not nick.bOperator then
				local userdata = to.." "..from
				if adCheck(msg) ~= nil and Verify(userdata, msg) then
					tabAdvert[userdata] = nil
					local action = DoDisc(user,msg,line)
					s,e,whoTo,from,mes = string.find(data,"$To:%s+(%S+)%s+From:%s+(%S+)%s+$%b<>%s+(.*)")  
					SendPmToOps (BotName, "User "..user.sName.." with IP "..user.sIP.." is "..action.." for advertising to "..whoTo.." this: "..mes.."")
					return 1
				end
				for key, value in controltrigs do
					if( string.find( string.lower(data), key) ) then
						s,e,whoTo,from,mes = string.find(data,"$To:%s+(%S+)%s+From:%s+(%S+)%s+$%b<>%s+(.*)")  
						SendPmToOps (BotName, "Control: User "..user.sName.." with IP "..user.sIP.." said to "..whoTo.." this: "..mes.."")
					end
				end
				spam=0
				if( string.find( string.lower(data), "no",1,1) ) and ( string.find( string.lower(data), "ip.",1,1) ) then
					if ( string.find( string.lower(data), "com",1,1) ) or ( string.find( string.lower(data), "org",1,1) ) or ( string.find( string.lower(data), "info",1,1) ) then
						spam=spam+1;
					end;
				end;
				if( string.find( string.lower(data), "dns",1,1) ) and ( string.find( string.lower(data), "2",1,1) ) and ( string.find( string.lower(data), "go",1,1) ) then
					spam=spam+1;
				end
				if( string.find( string.lower(data), "dy",1,1) ) and ( string.find( string.lower(data), "nu",1,1) ) then
					if( string.find( string.lower(data), ".net",1,1) ) or ( string.find( string.lower(data), ".com",1,1) ) then
						spam=spam+1;
					end;
				end
				if( string.find( string.lower(data), "d n s a",1,1) ) or ( string.find( string.lower(data), "d n s .",1,1) ) or ( string.find( string.lower(data), "d n s 2",1,1) ) or ( string.find( string.lower(data), "o d s .",1,1) ) or ( string.find( string.lower(data), "d y n",1,1) ) then
					spam=spam+1;
				end
			end
		end
	end
end

adCheck = function(Lines)
	for value,i in vTrigs do
		for index, site in Sites do
			if string.find(Lines,value,1,1) or string.find(Lines,site,1,1) then return nil end
		end
	end
	return 1
end

Verify = function(userdata, msg)
	if not msg then return end
	tmp =""
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
	for key, value in advtrigs do if (string.find(Lines, string.lower(value), 1, 1)) then return Lines end end
end

DoDisc = function(user,msg)
	if Action==0 then
		user:SendPM(BotName,"You are Warned for advertising: "..msg) return "Warned"
	elseif Action==1 then
		user:SendPM(BotName,"You are Disconnected for advertising: "..msg) user:Disconnect() return "Disconnected"
	elseif Action==2 then
		user:SendPM(BotName,"You are Kicked for advertising: "..msg) user:TempBan() return "Kicked" 
	elseif Action==3 then
		user:SendPM(BotName,"You are Banned for advertising: "..msg) user:Ban() return "Banned"
	elseif Action==4 then
		user:SendPM(BotName,"You are TimeBanned for advertising: "..msg) user:TimeBan(iTimeBan) return "TimeBanned"
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