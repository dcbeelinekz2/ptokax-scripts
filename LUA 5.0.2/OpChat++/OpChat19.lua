--/ Lua 5 version 1.1d by jiten
-- Changed: Profile Permissions;
-- Added: Optional message to every user invited on Hub Start/Script Restart
-- Added: Automatic Folder creating
-- Added: add, read and del commands (requested by Krisalys)
-- Fixed: Commands handling
-- Optimized and removed arrOpLevel table
-- Changed the add comand parsing
-- Fixed: Hopefully fixed bug with OpConnected/Disconnected function
-- Changed: OpChat++'s Bot Name can be set to anything
-- Added: Profile permission for each command (12/20/2005)
-- Fixed: Bug with command table return (thx to TM)
-- Removed: ChatArrival (12/27/2005)
-- Added: Option to choose which profiles can read/write in OpChat (1/7/2006)

--## OpChat++ By nErBoS 
--## Commands: 
--## +invite <nick> -- Invites an user to OpChat
--## +delinvite <nick> -- Removes the user from OpChat
--## +invitelist -- List all OpChat invited users
--## +talklog -- Show all the talking while you were offline

--## Settings ##-- 
sOpChat = "Op.Chat"					-- OpChat++ Bot Name sOpChat must be set to anything but the Reserved Nicks (check PtokaX\cfg\ReservedNicks.xml). 
sBot = frmHub:GetHubBotName()				-- Bot Name
sFolder = "Logs"					-- Folder where the .tbl files are stord
fInvite = "Invite.tbl"					-- File where the invited users are stored
fLog = "Log.tbl"					-- File where the chat logs are stored
fRelease = "Releases.tbl"				-- File where the Address File is stored
sendCustom = 0						-- 1 = Custom Message to invited user on Hub/Script Restart; 0 = Not
customMsg = "You are currently invited to OpChat"	-- Message sent to them

-- If you're using PtokaX's default profiles it should be like this:
-- Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [0] = 5 }
-- If you're using Robocop profiles don't change this.
Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [4] = 5, [0] = 6, [5] = 7, }

tAllowed = {
	-- Profiles allowed to talk in OpChat++
	[0] = 1, -- master
	[1] = 1, -- operator
	[2] = 0, -- vip
	[3] = 0, -- reg
	[4] = 1, -- moderator
	[5] = 1, -- founder
	[-1] = 0, -- unreg
}
--## END ##--

arrInvite = {} arrLog = {} Releases = {}

Main = function() 
	if frmHub:GetOpChatName() == sOpChat then frmHub:SetOpChatName(sOpChat.."_") frmHub:SetOpChat(0) end frmHub:RegBot(sOpChat)
	if loadfile(sFolder.."/"..fInvite) then dofile(sFolder.."/"..fInvite) else os.execute("mkdir "..sFolder) end
	if loadfile(sFolder.."/"..fLog) then dofile(sFolder.."/"..fLog) end
	if loadfile(sFolder.."/"..fRelease) then dofile(sFolder.."/"..fRelease) end
	if sendCustom == 1 then
		for usr, aux in arrInvite do 
			if (GetItemByName(usr) ~= nil) then 
				SendToNick(GetItemByName(usr).sName, "$To: "..GetItemByName(usr).sName.." From: "..sOpChat.." $<"..sOpChat.."> "..customMsg..".") 
			end 
		end
	end
end 

OnExit = function() 
	SaveToFile(sFolder.."/"..fInvite , arrInvite , "arrInvite") 
	SaveToFile(sFolder.."/"..fLog , arrLog , "arrLog") 
end 

OpConnected = function(user) 
	if arrLog[user.sName] == nil then
		arrLog[user.sName] = {}
		arrLog[user.sName]["Talk"] = ""
	elseif arrLog[user.sName]["Talk"] ~= "" then 
		user:SendPM(sOpChat, "There was chat while you were offline. Type +talklog to read it.") 
	end 
	arrLog[user.sName]["Mode"] = "online" 
	SaveToFile(sFolder.."/"..fLog,arrLog,"arrLog") 
end 

OpDisconnected = function(user) 
	if arrLog[user.sName] == nil then arrLog[user.sName] = {} arrLog[user.sName]["Talk"] = "" end
	arrLog[user.sName]["Mode"] = "offline"
	SaveToFile(sFolder.."/"..fLog,arrLog,"arrLog") 
end 

ToArrival = function(user,data)
	local data = string.sub(data,1,-2) 
	local _,_,whoTo = string.find(data,"$To:%s+(%S+)")
	if (whoTo == sOpChat) then
		local s,e,cmd = string.find(data,"%b<>%s+[%!%?%+%#](%S+)")
		if cmd then
			if tCmds[cmd] then
				if tCmds[cmd][2] <= Levels[user.iProfile] or arrInvite[string.lower(user.sName)] then
					return tCmds[cmd][1](user,data),1
				else
					return user:SendData(sBot,"*** Error: You are not allowed to use this command."),1
				end
			elseif mCmds[cmd] then
				if mCmds[cmd][2] <= Levels[user.iProfile] then
					return mCmds[cmd][1](user,data),1
				else
					return user:SendData(sBot,"*** Error: You are not allowed to use this command."),1
				end
			end
		elseif (tAllowed[user.iProfile] == 1 or arrInvite[string.lower(user.sName)] ~= nil) then 
			SendTalkToOps(data) 
			SendTalkToInvited(data)
			return 1
		else 
			user:SendPM(sOpChat, "You can't talk in OpChat.") 
			return 1 
		end 
	end 
end

tCmds = {
--	Commands Structure:
--	[Command] = { function, Lowest Profile that can use this command (check Levels table) },
--	Example:
--	["invitelist"] = { function, 4 } -- All users with and above 4 (that would be Profile 1, 4, 0 and 5 in Levels table) can use this command.

	["invitelist"] = {
	function(user)
		local sTmp,op,usr = "List of Users invited to OpChat:\r\n\r\n" 
		for usr, op in arrInvite do 
			sTmp = sTmp.."User: "..usr.."\tInvited by: "..op.."\r\n" 
		end 
		user:SendPM(sOpChat, sTmp) 
	end, 4 },
	["talklog"] = {
	function(user)
		if (arrLog[user.sName]["Talk"] == "") then 
			user:SendPM(sOpChat, "There aren't any chat logs for you to see. You were always online.") 
		else 
			user:SendPM(sOpChat, "Chat while you were offline:\r\n\r\n"..arrLog[user.sName]["Talk"]) 
			user:SendPM(sOpChat, "The chat logs were cleaned.") 
			arrLog[user.sName]["Talk"] = "" 
			SaveToFile(sFolder.."/"..fLog , arrLog , "arrLog") 
		end 
	end, 4 },
	["add"]	= {
	function(user,data)
		local s,e,rel,desc = string.find(data, "%b<>%s+%S+%s+(.*)%s+(ftp+.*)")
		if rel == nil or desc == nil then
			user:SendData(sBot,"*** Error: Type +add <name> <address>")
		else
			table.insert( Releases, { user.sName, rel, desc, os.date(), } )
			SaveToFile(sFolder.."/"..fRelease,Releases,"Releases")
			SendToAll(sBot, user.sName.." added a new Address: "..rel..". For more details type: +read")
		end
	end, 4 },
	["read"] = {
	function(user,data)
		local msg, Exists = "", nil
		for i = 1, table.getn(Releases) do
			if Releases[i] then
				msg = msg.."\r\n\tNumber "..i..".\r\n\t["..Releases[i][2].."]\r\n\t["..Releases[i][3].."]\r\n\tPosted by: "..Releases[i][1].." on "..Releases[i][4].."\r\n" Exists = 1
			end
		end
		if Exists == nil then 
			user:SendData(sBot,"*** Error: The Address list is empty.")
		else
			user:SendPM(sBot,msg)
		end
	end, 4 },
}

mCmds = {
--	Commands Structure:
--	[Command] = { function, Lowest Profile that can use this command (check Levels table) },
	["invite"] = {
	function(user,data)
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
			SaveToFile(sFolder.."/"..fInvite , arrInvite , "arrInvite") 
		end 
	end, 4 },
	["delinvite"] =	{
	function(user,data)
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
			SaveToFile(sFolder.."/"..fInvite , arrInvite , "arrInvite") 
		end 
	end, 4 },
	["del"]	= {
	function(user,data)
		local s,e,i = string.find(data,"%b<>%s+%S+%s+(%S+)")
		if i then
			if Releases[tonumber(i)] then
				table.remove(Releases,i)
				SaveToFile(sFolder.."/"..fRelease,Releases,"Releases")
				user:SendData(sBot,"Address "..i..". was deleted succesfully!")
			else
				user:SendData(sBot,"*** Error: There is no Address "..i..".")
			end
		else
			user:SendData(sBot,"*** Error: Type +del <ID>")
		end
	end, 4},
}

SendTalkToOps = function(data) 
	local s,e,from,talk = string.find(data, "$To:%s+%S+%s+From:%s+(%S+)%s+$%b<>%s+(.+)") 
	local aux,profile,usr 
	if (from ~= nil and talk ~= nil) then 
		SaveToLog(from, talk) 
		for aux, profile in GetProfiles() do 
			for aux, usr in GetUsersByProfile(profile) do 
				if (GetItemByName(usr) ~= nil and tAllowed[GetItemByName(usr).iProfile] == 1 and GetItemByName(usr).sName ~= from) then 
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

SaveToLog = function(from, talk) 
	local usr,aux 
	for usr, aux in arrLog do 
		if (arrLog[usr]["Mode"] == "offline") then 
			arrLog[usr]["Talk"] = arrLog[usr]["Talk"] or ""
			arrLog[usr]["Talk"] = arrLog[usr]["Talk"].."<"..from.."> "..talk.."\r\n" 
		end 
	end 
	SaveToFile(sFolder.."/"..fLog , arrLog , "arrLog") 
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