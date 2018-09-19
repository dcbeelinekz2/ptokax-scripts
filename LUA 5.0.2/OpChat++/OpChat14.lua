--/ Lua 5 version 1.1a by jiten
-- Changed: Profile Permissions;
-- Added: Optional message to every user invited on Hub Start/Script Restart
-- Added: Automatic Folder creating
-- Added: add, read and del commands (requested by Krisalys)
-- Fixed: Commands handling

--## OpChat++ By nErBoS 
--## Commands: 
--## +invite <nick> -- Invites an user to OpChat
--## +delinvite <nick> -- Removes the user from OpChat
--## +invitelist -- List all OpChat invited users
--## +talklog -- Show all the talking while you were offline

--## Settings ##-- 
sOpChat = "sOpChat"					-- OpChat Bot Name (Set it to everything but "OpChat")
sBot = frmHub:GetHubBotName()				-- Bot Name
sFolder = "Logs"					-- Folder where the .tbl files are stord
fInvite = "Invite.tbl"					-- File where the invited users are stored
fLog = "Log.tbl"					-- File where the chat logs are stored
fRelease = "Releases.tbl"				-- File where the Address File is stored
sendCustom = 0						-- 1 = Custom Message to invited user on Hub/Script Restart; 0 = Not
customMsg = "You are currently invited to OpChat"	-- Message sent to them
arrOpLevel = {						-- Put here the profile with operator privileges and its respective level
	["Master"] = 0,
	["Operator"] = 1,
} 
--## END ##--

arrInvite = {} arrLog = {} Releases = {}

Main = function() 
	frmHub:RegBot(sOpChat)
	if loadfile(sFolder.."/"..fInvite) then dofile(sFolder.."/"..fInvite) else os.execute("mkdir "..sFolder) end
	if loadfile(sFolder.."/"..fLog) then dofile(sFolder.."/"..fLog) end Refresh() if loadfile(sFolder.."/"..fRelease) then dofile(sFolder.."/"..fRelease) end
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
	if (arrLog[user.sName] == nil) then 
		Refresh() 
	elseif (arrLog[user.sName]["Talk"] ~= "") then 
		user:SendPM(sOpChat, "There was chat while you were offline. Type +talklog to read it.") 
	end 
	arrLog[user.sName]["Mode"] = "online" 
end 

OpDisconnected = function(user) 
	arrLog[user.sName]["Mode"] = "offline" 
end 

ChatArrival = function(user, data) 
	local data = string.sub(data, 1, -2) 
	local s,e,cmd = string.find(data,"%b<>%s+[%!%?%+%#](%S+)")
	if (string.sub(data,1,1) == "<") or (string.sub(data,1,5+string.len(sOpChat)) == "$To: "..sOpChat) then
		if cmd then
			local tCmds = {
			["invitelist"] =	function(user)
							local sTmp,op,usr = "List of Users invited to OpChat:\r\n\r\n" 
							for usr, op in arrInvite do 
								sTmp = sTmp.."User: "..usr.."\tInvited by: "..op.."\r\n" 
							end 
							user:SendPM(sOpChat, sTmp) 
						end,
			["talklog"] =		function(user)
							if (arrLog[user.sName]["Talk"] == "") then 
								user:SendPM(sOpChat, "There aren't any chat logs for you to see. You were always online.") 
							else 
								user:SendPM(sOpChat, "Chat while you were offline:\r\n\r\n"..arrLog[user.sName]["Talk"]) 
								user:SendPM(sOpChat, "The chat logs were cleaned.") 
								arrLog[user.sName]["Talk"] = "" 
								SaveToFile(sFolder.."/"..fLog , arrLog , "arrLog") 
							end 
						end,
			["add"]	=	function(user,data)
						local s,e,rel,desc = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)")
						if rel == nil or desc == nil then
							user:SendData(sBot,"*** Error: Type +add <name> <address>")
						else
							table.insert( Releases, { user.sName, rel, desc, os.date(), } )
							SaveToFile(sFolder.."/"..fRelease,Releases,"Releases")
							SendToAll(sBot, user.sName.." added a new Address: "..rel..". For more details type: +read")
						end
					end,
			["read"] =	function(user,data)
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
					end,
			}
			local mCmds = {
			["invite"] =		function(user,data)
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
						end,
			["delinvite"] =		function(user,data)
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
						end,
			["del"]	=	function(user,data)
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
					end,

			}
			if tCmds[cmd] then
				if user.bOperator or arrInvite[string.lower(user.sName)] then
					return tCmds[cmd](user,data),1 
				else
					return user:SendData(sBot,"*** Error: You are not allowed to use this command."),1
				end
			elseif mCmds[cmd] then
				if user.iProfile == 0 then
					return mCmds[cmd](user,data),1 
				else
					return user:SendData(sBot,"*** Error: You are not allowed to use this command."),1
				end
			end
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
	SaveToFile(sFolder.."/"..fLog , arrLog , "arrLog") 
end 

SaveToLog = function(from, talk) 
	local usr,aux 
	for usr, aux in arrLog do 
		if (arrLog[usr]["Mode"] == "offline") then 
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