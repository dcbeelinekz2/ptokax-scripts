--## OpChat++
--## By nErBoS 
--## Converted to Lua 5 by jiten (english version)
--## Changed: Invite and delinvite to Masters
--## Changed: Message on restart scripts to every invited user
--## Operator Commands: 
--## +invite <nick> -- Invites an user to OpChat
--## +delinvite <nick> -- Removes the user from OpChat
--## +invitelist -- List all OpChat invited users
--## +talklog -- Show all the talking while u were offline-

sOpChat = "sOpChat"

arrInvite = {} arrLog = {} 
fInvite = "logs/invite.dat" 
fLog = "logs/log.dat" 

--## Settings ##-- 

arrOpLevel = { --Put here the profile with operator privileges and its respective level
["Master"] = 0, 
["Operator"] = 1, 
["Moderator"] = 4, 
["NetFounder"] = 5, 
} 

--## FIM ##-- 

function Main() 
	frmHub:RegBot(sOpChat)
	if loadfile(fInvite) then dofile(fInvite) end
	if loadfile(fLog) then dofile(fLog) end Refresh() 
	for usr, aux in arrInvite do 
		if (GetItemByName(usr) ~= nil) then 
			SendToNick(GetItemByName(usr).sName, "$To: "..GetItemByName(usr).sName.." From: "..sOpChat.." $<"..sOpChat.."> You are currently invited to OpChat.") 
		end 
	end
end 

function OnExit() 
	SaveToFile(fInvite , arrInvite , "arrInvite") 
	SaveToFile(fLog , arrLog , "arrLog") 
end 

function OpConnected(user) 
	if (arrLog[user.sName] == nil) then 
		Refresh() 
	elseif (arrLog[user.sName]["Talk"] ~= "") then 
		user:SendPM(sOpChat, "There was chat while you were offline. Type +talklog to read it.") 
	end 
	arrLog[user.sName]["Mode"] = "online" 
end 

function OpDisconnected(user) 
	arrLog[user.sName]["Mode"] = "offline" 
end 

function ChatArrival(user, data) 
	local data = string.sub(data, 1, -2) 
	local s,e,cmd = string.find(data, "%b<>%s+(%S+)") 
	if user.bOperator then
		if (cmd == "+invitelist") then 
			InviteList(user) 
			return 1 
		elseif (cmd == "+talklog") then 
			ShowTalkLog(user) 
			return 1 
		end
	elseif user.iProfile == 0 then
		if (cmd == "+invite") then 
			InviteUser(user, data) 
			return 1 
		elseif (cmd == "+delinvite") then 
			RemoveInvite(user, data) 
			return 1
		end
	end
	local _,_,whoTo = string.find(data,"$To:%s+(%S+)")
	if (whoTo == sOpChat) then
		if (user.bOperator or arrInvite[string.lower(user.sName)] ~= nil) then 
			SendTalkToOps(data) 
			SendTalkToInvited(data)
			return 1
		else 
			user:SendPM(sOpChat, "You can't talk in OpChat.") 
			return 1 
		end 
	end 
end 

ToArrival = ChatArrival

InviteUser = function(user, data) 
	local s,e,nick = string.find(data, "%b<>%s+%S+%s+(%S+)") 
	if (nick == nil) then 
		user:SendPM(sOpChat, "Syntax Error, +invite <nick> . You have to type a nick.") 
	elseif (arrInvite[string.lower(nick)] ~= nil) then 
		user:SendPM(sOpChat, "User "..nick.." has already been invited to OpChat.") 
	else 
		arrInvite[string.lower(nick)] = user.sName 
		user:SendPM(sOpChat, "User "..nick.." was invited to OpChat.") 
		if (GetItemByName(nick) ~= nil) then 
			GetItemByName(nick):SendPM(sOpChat, "You were invited to OpChat by Operator "..user.sName) 
		end 
		SendPmToOps(sOpChat, "User "..nick.." was invited to OpChat by Operator "..user.sName) 
		SaveToFile(fInvite , arrInvite , "arrInvite") 
	end 
end 

RemoveInvite = function(user, data) 
	local s,e,nick = string.find(data, "%b<>%s+%S+%s+(%S+)") 
	if (nick == nil) then 
		user:SendPM(sOpChat, "Syntax Error, +delinvite <nick> . You have to type a nick.") 
	elseif (arrInvite[string.lower(nick)] == nil) then 
		user:SendPM(sOpChat, "User "..nick.." wasn't invited to OpChat.") 
	else 
		arrInvite[string.lower(nick)] = nil 
		user:SendPM(sOpChat, "User "..nick.." is no longer invited to OpChat.") 
		if (GetItemByName(nick) ~= nil) then 
			GetItemByName(nick):SendPM(sOpChat, "The invitation to OpChat was removed by Operator "..user.sName) 
		end 
		SendPmToOps(sOpChat, ""..nick.." 's invitation to OpChat was removed by Operator "..user.sName) 
		SaveToFile(fInvite , arrInvite , "arrInvite") 
	end 
end 

InviteList = function(user) 
	local sTmp,op,usr = "List of Users invited to OpChat:\r\n\r\n" 
	for usr, op in arrInvite do 
		sTmp = sTmp.."User: "..usr.."\tInvited by: "..op.."\r\n" 
	end 
	user:SendPM(sOpChat, sTmp) 
end 

SendTalkToOps = function(data) 
	local s,e,from,talk = string.find(data, "$To:%s+%S+%s+From:%s+(%S+)%s+$%b<>%s+(.+)") 
	local aux,profile,usr 
	if (from ~= nil and talk ~= nil) then 
		SaveToLog(from, talk) 
		for aux, profile in GetProfiles() do 
			for aux, usr in GetUsersByProfile(profile) do 
				if (GetItemByName(usr) ~= nil and GetItemByName(usr).bOperator and GetItemByName(usr).sName ~= from) then 
					SendToNick(GetItemByName(usr).sName, "$To: "..GetItemByName(usr).sName.." From: "..sOpChat.." $<"..from.."> "..talk) 
				end 
			end 
		end 
	end 
end 

SendTalkToInvited = function(data) 
	local s,e,from,talk = string.find(data, "$To:%s+%S+%s+From:%s+(%S+)%s+$%b<>%s+(.+)") 
	local aux,usr 
	if (from ~= nil and talk ~= nil) then 
		for usr, aux in arrInvite do 
			if (GetItemByName(usr) ~= nil and GetItemByName(usr).sName ~= from) then 
				SendToNick(GetItemByName(usr).sName, "$To: "..GetItemByName(usr).sName.." From: "..sOpChat.." $<"..from.."> "..talk) 
			end 
		end 
	end 
end 

Refresh = function() 
	local aux,aux2,usr,profile 
	for profile, aux in arrOpLevel do 
		for aux2, usr in GetUsersByProfile(profile) do 
			if (arrLog[usr] == nil) then 
				arrLog[usr] = {} 
				if (GetItemByName(usr) == nil) then 
					arrLog[usr]["Mode"] = "offline" 
				else 
					arrLog[usr]["Mode"] = "online" 
				end 
					arrLog[usr]["Talk"] = "" 
			elseif (GetItemByName(usr) == nil) then		
				arrLog[usr]["Mode"] = "offline" 
			else 
				arrLog[usr]["Mode"] = "online" 
			end 
		end 
	end 
	SaveToFile(fLog , arrLog , "arrLog") 
end 

SaveToLog = function(from, talk) 
	local usr,aux 
	for usr, aux in arrLog do 
		if (arrLog[usr]["Mode"] == "offline") then 
			arrLog[usr]["Talk"] = arrLog[usr]["Talk"].."<"..from.."> "..talk.."\r\n" 
		end 
	end 
	SaveToFile(fLog , arrLog , "arrLog") 
end 

ShowTalkLog = function(user) 
	if (arrLog[user.sName]["Talk"] == "") then 
		user:SendPM(sOpChat, "There aren't any chat logs for you to see. You were always online.") 
	else 
		user:SendPM(sOpChat, "Chat while you were offline:\r\n\r\n"..arrLog[user.sName]["Talk"]) 
		user:SendPM(sOpChat, "The chat logs were cleaned.") 
		arrLog[user.sName]["Talk"] = "" 
		SaveToFile(fLog , arrLog , "arrLog") 
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