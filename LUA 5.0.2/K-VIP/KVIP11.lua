-- K-VIP (LUA 5 version by jiten)
-- based on K-VIP by Seiya v1.6 

-- add kick to the VIP you want 
-- without creating a new profile 
-- fix bug : all vip have the command 
-- fix bug : Kvip which is degrated can't use anymore the kik command 
-- fix bug : load (don't laugh) the svip.txt file when starting the script 
-- fix bug : VIP can't add/revoke VIP to/from K-VIP anymore 
-- add the userinfo command
-- Added by request a kick log and its command !vkicklog (made by nErBoS)
-- Added by request a Ban to a x amout of Kicks (made by nErBoS)
-- Almost complete rewrite of the code (12/2/2005)

sBot = frmHub:GetHubBotName()

iBan = 2 -- Times of Kick equal to a ban

kVip = {} kFile = "kVip.tbl"
vLog = {} vFile = "kVipLog.tbl"

-- If you're using PtokaX's default profiles it should be like this:
-- Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [0] = 5 }
-- If you're using Robocop profiles don't change this.
Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [4] = 5, [0] = 6, [5] = 7, }

Main = function()
	local CreateFile = function(file,table)
		local f = io.open(file, "w+")
		f:write(table.." = {\n"); f:write("}"); f:close()
	end
	if loadfile(kFile) then dofile(kFile) else CreateFile(kFile,"kVip") end
	if loadfile(vFile) then dofile(vFile) else CreateFile(vFile,"vLog") end
end

ChatArrival = function(user,data)
	local data = string.sub(data,1,-2)
	local s,e,cmd = string.find(data,"%b<>%s+([%-%+%?%!]%S+)")
	if cmd and tCmds[cmd] then
		if tCmds[cmd][2] <= Levels[user.iProfile] or (tCmds[cmd][3] == 1 and kVip[user.sName]) then
			return tCmds[cmd][1](user,data),1
		else
			return user:SendData(sBot,"*** Error: You are not allowed to use this command."),1
		end
	end
end

ToArrival = ChatArrival

NewUserConnected = function(user)
	if user.bUserCommand then 
		for i,v in tCmds do if(v[2] <= Levels[user.iProfile]) then user:SendData(v[4]) end end
	end
end

OpConnected = NewUserConnected

tCmds = {
--	Commands Structure:
--	[Command] = { function, Lowest Profile that can use this command (check Levels table), Command for kVIPs (1 = on, 0 off), RightClick Command},

	-- Start: K-VIP Commands
	["!addvkick"] = {
	function(user,data)
		local s,e,victim = string.find(data, "%b<>%s+%S+%s+(%S+)")
		if victim then
			if kVip[victim] == nil then
				local bVip = nil
				for i,v in frmHub:GetRegisteredUsers() do
					if string.lower(victim) == string.lower(v.sNick) and v.iProfile == 2 then bVip = 1 end
				end
				if bVip then
					kVip[victim] = 1 SaveToFile(kFile,kVip,"kVip")
					SendPmToOps(sBot,"The Operator "..user.sName.." gave the K-VIP status to "..victim..".") 
				else
					user:SendData(sBot,"*** Error: "..victim.." is not a VIP.")
				end
			else 
				user:SendData(sBot,"*** Error: "..victim.." is already a K-VIP.")
			end 
		else
			user:SendData(sBot,"*** Syntax Error: Type !addvkick <nick>")
		end
	end, 4, 0, "$UserCommand 1 2 K-VIP\\Add K-VIP$<%[mynick]> !addvkick %[nick]&#124;" },
	["!delvkick"] = {
	function(user,data)
		local s,e,victim = string.find(data, "%b<>%s+%S+%s+(%S+)")
		if victim then
			if kVip[victim] then
				kVip[victim] = nil SaveToFile(kFile,kVip,"kVip") 
				SendPmToOps(sBot,"The Operator "..user.sName.." has just revoked the K-VIP status from "..victim..".") 
			else 
				user:SendData(sBot,"The user "..victim.." isn't a K-VIP.") 
			end
		else
			user:SendData(sBot,"*** Syntax Error: Type !delvkick <nick>")
		end
	end, 4, 0, "$UserCommand 1 2 K-VIP\\Del K-VIP$<%[mynick]> !delvkick %[nick]&#124;" },
	["!vinfo"] = {
	function(user,data)
		local s,e,cmd,who = string.find(data, "%b<>%s+(%S+)%s+(%S+)%s*")  
		local usr = GetItemByName(who)  
		if usr == nil then user:SendData(sBot,"Error: User is not online.") return 1 end  
		local tmp = "" if user.sMode == "A" then tmp = "Active" else tmp = "Passive" end
		local temp="\r\n\r\n\t• Name: "..usr.sName.." \r\n"  
		temp = temp.."\t• Profile: "..(GetProfileName(usr.iProfile) or "Not Registered").." \r\n"  
		temp = temp.."\t• IP: "..(usr.sIP or "n/a").." \r\n"  
		temp = temp.."\t• Client: "..(usr.sClient or "n/a").." "..(usr.sClientVersion or "n/a").."\r\n" 
		temp = temp.."\t• Mode: "..tmp.." \r\n" 
		temp = temp.."\t• Slots: "..(usr.iSlots or "n/a").."\r\n"  
		temp = temp.."\t• Connected to: "..(usr.iHubs or "n/a").." Hub(s) \r\n"  
		temp = temp.."\t• "..(usr.iNormalHubs or "n/a").." Hub(s) as User \r\n"  
		temp = temp.."\t• "..(usr.iRegHubs or "n/a").." Hub(s) as VIP \r\n"  
		temp = temp.."\t• "..(usr.iOpHubs or "n/a").." Hub(s) as OP"
		user:SendPM(sBot, temp) 
	end, 3, 1, "$UserCommand 1 3 K-VIP\\Info$<%[mynick]> !vinfo %[nick]&#124;" },
	["!vkick"] = {
	function(user,data)
		local s,e,victim,reason = string.find( data, "%b<>%s+%S+%s+(%S+)%s*(.*)" ) 
		local victim = GetItemByName(victim)
		if victim then
			if victim.iProfile == -1 or victim.iProfile == 3 then 
				SendToAll(sBot,"The K-VIP "..user.sName.." is kicking "..victim.sName.." because: "..reason) 
				SendPmToOps (sBot,""..os.date().." - K-VIP Report: "..user.sName.." kicked "..victim.sName.." <"..victim.sIP.."> because: "..reason)
				victim:SendPM(sBot,"You are being kicked because: "..reason) 
				if (vLog[victim.sName] == nil) then
					vLog[victim.sName] = {} vLog[victim.sName]["TIMES"] = 1
					vLog[victim.sName]["KICK"] = ""..os.date().." - User "..victim.sName.." ("..victim.sIP..") kicked by K-VIP "..user.sName.." - Reason : "..reason
				else
					vLog[victim.sName]["KICK"] = ""..os.date().." - User "..victim.sName.." ("..victim.sIP..") kicked by K-VIP "..user.sName.." - Reason : "..reason
					vLog[victim.sName]["TIMES"] = vLog[victim.sName]["TIMES"] + 1
				end
				if vLog[victim.sName]["TIMES"] > iBan then
					victim:SendPM(sBot,"You have been kicked "..iBan.." times. You are being banned.")
					vLog[victim.sName]["TIMES"] = 0
				else
					victim:TempBan() victim:Disconnect() SaveToFile(vFile,vLog,"vLog")
				end
			else
				user:SendData(sBot,"*** Error: You can't kick an OP or VIP.")
			end
		else
			user:SendData(sBot,"*** Error: User is not online.")
		end
	end, 3, 1, "$UserCommand 1 3 K-VIP\\Kick$<%[mynick]> !vkick %[nick] %[line:Kick Reason]&#124;" },
	["!vkicklog"] = {
	function(user,data)
		local sTmp,victim,table = "*** These are the logged K-VIP kicks:\r\n\r\n"
		for victim, table in vLog do
			sTmp = sTmp.."\t"..table["KICK"].." - Kicked: "..table["TIMES"].." time(s)\r\n"
		end
		user:SendPM(sBot, sTmp)
	end, 4, 0, "$UserCommand 1 2 K-VIP\\V-Kick Log$<%[mynick]> !vkicklog %[nick]&#124;" },
	["!showkvip"] = {
	function(user,data)
		if next(kVip) then
			local temp="\r\n\r\n".."\t"..string.rep("«»",12).."\r\n" 
			temp = temp.."\t ¤ Current Regged K-VIP's ¤".."\r\n" 
			temp = temp.."\t"..string.rep("«»",12).."\r\n" 
			local usr,aux 
			for usr, aux in kVip do 
				if GetItemByName(usr) then 
					temp = temp.."\t • [online]   "..usr.."\r\n" 
				else 
					temp = temp.."\t • [offline]   "..usr.."\r\n" 
				end 
			end 
			user:SendData(sBot,temp) 
		else
			user:SendData(sBot,"*** Error: There aren't registered K-VIPs.")
		end
	end, 3, 1, "$UserCommand 1 3 K-VIP\\Show K-VIPs$<%[mynick]> !showkvip&#124;" },
	-- End: K-VIP Commands
}

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