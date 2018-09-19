i can't to add it's type me 12.lua:46: attempt to index global `victim' (a nil value) y ?

-- Converted to Lua 5 by jiten
-- K-VIP by Seiya
-- Version 1.6 
-- add kick to the VIP you want 
-- without creating a new profile 
-- fix bug : all vip have the command 
-- fix bug : Kvip which is degrated can't use anymore the kik command 
-- fix bug : load (don't laugh) the svip.txt file when starting the script 
-- fix bug : VIP can't add/revoke VIP to/from K-VIP anymore 
-- add the userinfo command
-- Added by request a kick log and its command !vkicklog (made by nErBoS)
-- Added by request a Ban to a x amout of Kicks (made by nErBoS)

sBot = "@Dohko" 

savevipkick = "logs/svip.txt" -- you have to create a svip.txt file ine the ptokax\scripts\logs directory 
supervip = {} 
fVipLog = "logs/viplog.dat"
arrVipLog = {}
iBan = 2 -- Times of Kick equal to a ban

function Main() 
	LoadFromFile(savevipkick) 
	LoadFromFile(fVipLog)
end 

function dosavesupervip(user,data) 
	local savevipkick = io.open("logs/svip.txt", "w+")
	assert(savevipkick, "logs/svip.txt")
	savevipkick:write("supervip = {"); 
	for a,b in supervip do 
		if b then 
			savevipkick:write(string.format("[%q]=",a)..b..","); 
		end 
	end 
	savevipkick:write("}" ); 
	savevipkick:close()
end 


function ChatArrival (user,data) 
	data=string.sub(data,1,string.len(data)-1) 
	s,e,cmd,Name = string.find( data, "%b<>%s+(%S+)%s+(%S+)" ) 
	victim = GetItemByName(Name) 
	if cmd == "!addvkick" and ((user.iProfile == 0) or (user.iProfile == 4) or (user.iProfile == 5)) then 
		if victim.iProfile == 2 then 
			if supervip[victim.sName] == nil then 
				supervip[victim.sName] = 1 
				dosavesupervip() 
				SendPmToOps(sBot,"The Operator "..user.sName.." gave the K-VIP status to "..victim.sName..".") 
				victim:SendPM(sBot,"Congratulations! You've been upgrated to K-VIP. Just have a look at your right click for the kick command or type !extrahelp in main.") 
			else 
				supervip[victim.sName] = supervip[victim.sName] + 1 
				dosavesupervip() 
				SendPmToOps(sBot,"The Operator "..user.sName.." gave the K-VIP status to "..victim.sName..".") 
				victim:SendPM(sBot,"Congratulations! You've been upgrated to K-VIP. Just reconnect to have the kick command in your right click or type !extrahelp in main.") 
			end 
		else 
			user:SendData(sBot,"The user "..victim.sName.." isn't a VIP yet. So, he/se can't be upgraded to K-VIP.") 
		end 
		return 1 
	elseif cmd == "!delvkick" and ((user.iProfile == 0) or (user.iProfile == 4) or (user.iProfile == 5)) then 
		if victim.iProfile == 2 then 
			if supervip[victim.sName] ~= 0 then 
				supervip[victim.sName] = 0 
				dosavesupervip() 
				SendPmToOps(sBot,"The Operator "..user.sName.." has just revoked the K-VIP status from "..victim.sName..".") 
				victim:SendPM(sBot,"You've been revoked the K-VIP status.") 
			end 
		else 
			user:SendData(sBot,"The user "..victim.sName.." isn't a K-VIP.") 
		end 
		return 1 
	elseif cmd == "!vinfo" then 
		if ((user.iProfile == 2) and (supervip[user.sName] == 1)) or (user.iProfile == 0) or (user.iProfile == 4) or (user.iProfile == 5) then 
			UserInfo(user,data) 
		else 
			user:SendData(sBot,"You're not allowed to use this command.") 
		end 
		return 1 
	end 
	s,e,cmd,Name,reason = string.find( data, "%b<>%s+(%S+)%s+(%S+)%s*(.*)" ) 
	victim = GetItemByName(Name) 
	if cmd == "!vkick" then 
		if (supervip[user.sName] == 1) and (user.iProfile == 2) then 
			if victim.iProfile == -1 or victim.iProfile == 3 then 
				SendToAll(sBot,"The K-VIP "..user.sName.." is kicking "..victim.sName.." because: "..reason) 
				local curtime = os.date() 
				SendPmToOps (sBot,""..curtime.." - K-VIP Report: "..user.sName.." kicked "..victim.sName.." <"..victim.sIP.."> because: "..reason)
				victim:SendPM(sBot,"You are being kicked because : "..reason) 
				if (arrVipLog[victim.sName] == nil) then
					arrVipLog[victim.sName] = {}
					arrVipLog[victim.sName]["KICK"] = ""..curtime.." - User "..victim.sName.." ("..victim.sIP..") kicked by K-VIP "..user.sName.." - Reason : "..reason
					arrVipLog[victim.sName]["TIMES"] = 1
				else
					arrVipLog[victim.sName]["TIMES"] = arrVipLog[victim.sName]["TIMES"] + 1
					arrVipLog[victim.sName]["KICK"] = ""..curtime.." - User "..victim.sName.." ("..victim.sIP..") kicked by K-VIP "..user.sName.." - Reason : "..reason
				end
				if (arrVipLog[victim.sName]["TIMES"] > iBan) then
					victim:SendPM(sBot,"You have been kicked "..iBan.." times. You are being banned.")
					arrVipLog[victim.sName]["TIMES"] = 0
					victim:Ban()
				else
					victim:TempBan()
					victim:Disconnect()
					end
				SaveToFile(fVipLog , arrVipLog , "arrVipLog")
			else
				user:SendData(sBot,"You can't kick an OP or VIP")
			end
		else 
			user:SendData(sBot,"You're not allowed to use this command") 
		end 
		return 1 
	end
	s,e,cmd = string.find( data, "%b<>%s+(%S+)")
	if (cmd == "!vkicklog" and user.bOperator) then
		local sTmp,victim,table = "*** These are the logged K-VIP kicks:\r\n\r\n"
		local curtime = os.date() 
		for victim, table in arrVipLog do
			sTmp = sTmp.."\t"..table["KICK"].." - Kicked: "..table["TIMES"].." time(s)\r\n"
		end
		user:SendPM(sBot, sTmp)
		return 1
	end
end 

function NewUserConnected(user,data) 
	if (supervip[user.sName] == 0) or (supervip[user.sName] == nil) then

	else 
		if user.iProfile == 2 then 
			user:SendData("$UserCommand 1 2 K-VIP\\Kick$<%[mynick]> !vkick %[nick] %[line:Kick Reason]&#124;|") 
			user:SendData("$UserCommand 1 2 K-VIP\\Userinfo$<%[mynick]> !vinfo %[nick]&#124;|") 
			user:SendData("$UserCommand 1 2 K-VIP\\V-Kick Log$<%[mynick]> !vkicklog %[nick]&#124;|") 
		end 
	end 
end 

function OpConnected(user,data) 
	if user.iProfile == 0 or user.iProfile == 4 or (user.iProfile == 5) then 
		user:SendData("$UserCommand 1 2 K-VIP\\Add K-VIP$<%[mynick]> !addvkick %[nick]&#124;|") 
		user:SendData("$UserCommand 1 2 K-VIP\\Del K-VIP$<%[mynick]> !delvkick %[nick]&#124;|") 
		user:SendData("$UserCommand 1 2 K-VIP\\Userinfo$<%[mynick]> !vinfo %[nick]&#124;|")
		user:SendData("$UserCommand 1 2 K-VIP\\V-Kick Log$<%[mynick]> !vkicklog %[nick]&#124;|") 
	end 
end 

function loadfile(savevipkick)
	local f,e = io.open( savevipkick, "r" )
	if f then
		local r = f:read( "*a" )
		f:close()
		return r
	else
		return nil,"loadfile failed: "..e
	end
end

function UserInfo(user, data) 
	s,e,cmd,who = string.find(data, "%b<>%s+(%S+)%s+(%S+)%s*") 
	local usr = GetItemByName(who) 
	if usr == nil then 
		return 1 
	end 
	if usr.iProfile == 4 then 
		profile = "Moderator" 
	elseif usr.iProfile == -1 then 
		profile = "User" 
	elseif usr.iProfile == 0 then 
		profile = "Master" 
	elseif usr.iProfile == 1 then 
		profile = "Operator" 
	elseif usr.iProfile == 2 and supervip[usr.sName] == 0 then 
		profile = "VIP" 
	elseif usr.iProfile == 2 and supervip[usr.sName] == 1 then 
		profile = "K-VIP" 
	elseif usr.iProfile == 3 then 
		profile = "Reg" 
	elseif usr.iProfile == 5 then 
		profile = "NetFounder" 
	else 
		profile = "Unknown" 
	end 


	user:SendPM(sBot, "• Name: "..who.." |") 
	user:SendPM(sBot, "• Profile: "..profile.." |") 
	user:SendPM(sBot, "• IP: "..usr.sIP.." |") 

	_,b, dcver = string.find(usr.sMyInfoString,"V:(%x+.%x+)") 
	if (string.find(usr.sMyInfoString,"<DCGUI")) then 
		_,b, dcgui = string.find(usr.sMyInfoString,"V:(%x+.%x+.%x+)") 
		clienttype = "DCGUI" 
		version = dcgui 
	elseif (string.find(usr.sMyInfoString,"<DC")) then 
		_,b, nm201 = string.find(usr.sMyInfoString,"V:(%x+.%x+)") 
		clienttype = "Neo-Modus" 
		version = nm201 
	elseif (string.find(usr.sMyInfoString,"<+")) then 
		if string.find(usr.sMyInfoString,"<o") then 
			clienttype = "oDC" 
			version = dcver 
		elseif string.find(usr.sMyInfoString,"V:0.%x+%a") then 
			clienttype = "czDC++" 
			version = dcver 
		elseif string.find(usr.sMyInfoString,"L:") or string.find(usr.sMyInfoString,"B:") then 
			clienttype = "BCDC++" 
			version = dcver 
		elseif (string.find(usr.sMyInfoString,"<++")) then 
			clienttype = "DC++" 
			version = dcver 
		end 
	else 
		user:SendPM(sBot, "• NMDC1 or BlackDC") 
	return 1 
	end 

	if version == nil then user:SendPM(sBot, "• NMDC1 or BlackDC") return 1 end 

		user:SendPM(sBot, "• Client: "..clienttype.." v"..version) 
		-- active or pasive 
		if string.find(usr.sMyInfoString,"M:A") then 
			mode = "Active" 
			user:SendPM(sBot, "• Mode: "..mode) 
		elseif string.find(usr.sMyInfoString,"M:P") then 
			mode = "Passive" 
			user:SendPM(sBot, "• Mode: "..mode) 
		end 
	-- slot info 
	_,b, slots = string.find(usr.sMyInfoString,"S:(%x+)") 
	if slots ~= nil then 
		user:SendPM(sBot, "• "..slots.." - Slot(s) |") 
	end 
	-- hub info 
	_,b, guest = string.find(usr.sMyInfoString,"H:(%x+)/") 
	if guest == nil then 
		_,b, hubs = string.find(usr.sMyInfoString,"H:(%x+)") 
		if hubs ~= nil then 
			user:SendPM(sBot, "• "..hubs.." - Hub(s) |") 
		end 
	else 
		_,b, opped = string.find(usr.sMyInfoString,"H:%x+/%x+/(%x+)") 
		_,b, regged = string.find(usr.sMyInfoString,"H:%x+/(%x+)/") 
		if regged ~= nil then 
			user:SendPM(sBot, "• "..guest.." - Hub(s) as User |") 
			user:SendPM(sBot, "• "..regged.." - Hub(s) as VIP |") 
			user:SendPM(sBot, "• "..opped.." - Hub(s) as OP |") 
		end 
	end 
end

function Serialize(tTable, sTableName, sTab)
        assert(tTable, "tTable equals nil");
        assert(sTableName, "sTableName equals nil");

        assert(type(tTable) == "table", "tTable must be a table!");
        assert(type(sTableName) == "string", "sTableName must be a string!");

        sTab = sTab or "";
        sTmp = ""

        sTmp = sTmp..sTab..sTableName.." = {\n"

        for key, value in tTable do
                local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);

                if(type(value) == "table") then
                        sTmp = sTmp..Serialize(value, sKey, sTab.."\t");
                else
                        local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
                        sTmp = sTmp..sTab.."\t"..sKey.." = "..sValue
                end

                sTmp = sTmp..",\n"
        end

        sTmp = sTmp..sTab.."}"
        return sTmp
end

function SaveToFile(file , table , tablename)
	local handle = io.open(file,"w+")
        handle:write(Serialize(table, tablename))
	handle:flush()
        handle:close()
end

function LoadFromFile(file)
	local handle = io.open(file,"r")
	if (handle ~= nil) then
                dofile(file)
		handle:flush()
		handle:close()
        end
end
