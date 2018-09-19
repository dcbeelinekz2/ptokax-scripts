---  Awayer v3 --- idea by QuitckThinker
--- by Herodes
--- This bot has been writen offline and based on no other script
--- Although the initial idea for the AwayBot is from tezlo's RetroBot...
--- This diplays a prefix for those operators and above that are away
--- It also places the Away message in the users description ...
--- --- --- This script works only for Operators (as intended) --- --- ---
--- !away <reason>   --- <reason> is optional
--- !back
--- !awaylist
--- feel free to develop this further ...  
--- --- v 2 --- ---
--- currently has a problem with the following path ..
--- 1) <user> !away
--- 2) user reconnnects 
--- 3) <user> !back 
--- this produces a lot of shity names in the list ... dunno y ...:(
--- --- v 3 --- ---
--- fixed v2 problem but has abother one ...
--- following path ..
--- 1) <user> !away
--- 2) <user> <chatmsg> or <user> !back
--- 3) user disconnects ...
--- 4) user receives nickname reserved message (???)
--- --- all other scenarios I have tested and work fine ...
--- --- --- --- --- --- ---
tAways = {}

awpref = "[AWAY]"
defmsg = "I'm away. I might answer later if you're lucky."

function Main()
	Bot = frmHub:GetHubBotName()
end

function NewUserConnected(user)
	for nick, msg in tAways do
		user:SendData("$Quit "..nick)
		--- user:SendData("You are missing "..nick)
	end
	if GetItemByName(user.sName) and tAways[user.sName] then
		SendToAll("$Quit "..user.sName)
	end
end

OpConnected = NewUserConnected

function MyINFOArrival(user, data)
	if (tAways[user.sName]) then 
		local s,e,name = string.find(data, "%$MyINFO %$ALL (%S+)")
		frmHub:UnregBot(awpref..user.sName)
		frmHub:RegBot(awpref..user.sName)
		newinfo = string.gsub(data, user.sName, awpref..user.sName)
		SendToAll(newinfo)
		SendToAll("$Quit "..user.sName)
		return 1
	end
end

function ToArrival(user, data)
	local s,e,whoTo,from = string.find(data, "%$To:%s(%S+)%sFrom:%s(%S+)%s%$")
	-- SendToAll("from "..from.." to "..whoTo)
	if string.find(whoTo, awpref) then
		whoTo = string.sub(whoTo, string.len(awpref)+1, string.len(whoTo) )
	end
	-- SendToAll("the nick "..whoTo)
	if tAways[whoTo]["reason"] then
		SendPmToNick(from, whoTo, tAways[whoTo]["reason"].." <Awayer v2>")
	end
	local s,e,msg = string.find(data, "%b<>%s+(%S+)")
	SendPmToNick(whoTo, from, msg)
end

function ValidateNickArrival(user, data)
	local s,e,name = string.find(data, "%$ValidateNick%s(%S+)|")
	if tAways[name] then
		UnRegIt(name)
		--- SendToAll("connecting "..name)
	end
end

function GetINFOArrival(user, data)
	local s,e,from, to = string.find(data, "$GetINFO%s(%S+)%s(%S+)")
	if ( (from ~= awpref..to) or (to ~= awpref..from) ) then
		if tAways[from] == 1 then
			data = string.gsub(data, from, awpref..from)
			SendToAll("$Quit "..from)
		end
		if tAways[to] == 1 then
			data = string.gsub(data, to, awpref..to)
			SendToAll("$Quit "..to)
		end
		if GetItemByName(from) then
			local oper =  GetItemByName(from)
			if oper.bOperator then
				frmHub:UnregBot(oper.bOperator)
			end
		end
		SendToNick(to, data)
	elseif ( (string.find(data, "$GetINFO%s"..awpref..to.."%s"..to)) or (string.find(data, "$GetINFO%s"..awpref..from.."%s"..from)) ) then
		return 1
	end		
end

function ChatArrival(user, data)
	data =string.sub(data, 1, string.len(data)-1)
	local s,e,cmd = string.find(data, "%b<>%s+(%S+)")
	if (user.bOperator) then
		if cmd == "!away" then
			local s,e,arg = string.find(data, "%b<>%s+"..cmd.."%s(.*)")
			if arg == nil or arg == "" then arg = defmsg end
			if not tAways[user.sName] then
				local s,e,name,desc,tag, con,email,share   = string.find(user.sMyInfoString, "$MyINFO $ALL (%S+)%s+(.*)<([^$]+)$ $([^$]*)$([^$]*)$([^$]+)")
				tAways[user.sName] = {}
				tAways[user.sName] = {}
				if desc == nil then desc = "" end
				tAways[user.sName]["d"] = desc
				tAways[user.sName]["t"] = "<"..tag
				tAways[user.sName]["c"] = con
				if email == nil then email = "" end
				tAways[user.sName]["e"] = email
				tAways[user.sName]["s"] = share
				tAways[user.sName]["reason"] = arg
				user:SendData("Awayer", "You are now set to away ..")
				RegIt(awpref..user.sName)
				SendToAll("$MyINFO $ALL "..awpref..user.sName.." AwayMsg: "..arg..tAways[user.sName]["t"].."$ $"..tAways[user.sName]["c"].."$"..tAways[user.sName]["e"].."$$"..tAways[user.sName]["s"].."$|")
				SendToAll("$Quit "..user.sName.."|")
			else
--				user:SendData("Awayer", "You are away already ... ")
--				SendToAll("$Quit "..user.sName.."|")
			end
--			SendToAll("$Quit "..user.sName.."|")
			return 1
		elseif cmd == "!back" then
			if tAways[user.sName] then
				UnRegIt(awpref..user.sName)
				SendToAll("Awayer", user.sName.." is back .. :)")
				RegIt(user.sName)
				SendToAll("$MyINFO $ALL "..user.sName.." "..tAways[user.sName]["d"]..tAways[user.sName]["t"].."$ $"..tAways[user.sName]["c"].."$"..tAways[user.sName]["e"].."$$"..tAways[user.sName]["s"].."$|")
				tAways[user.sName] = nil
			else 
				user:SendData("Awayer", "You were not away... :)")
			end
			return 1
		elseif cmd == "!awaylist" then
			local list = "These users are set to away\r\n"
			local cnt = 0
			for nick, msg in tAways do
				cnt = cnt + 1
				list = list.."\t"..cnt..". "..nick.."\tAway Msg :"..msg.."\r\n"
			end
			user:SendData(list)
			return 1
		elseif tAways[user.sName] then
			UnRegIt(awpref..user.sName)
			user:SendData("Awayer", "You spoke in main chat so you are not away anymore.|")
			RegIt(user.sName)
			SendToAll("$MyINFO $ALL "..user.sName.." "..tAways[user.sName]["d"]..tAways[user.sName]["t"].."$ $"..tAways[user.sName]["c"].."$"..tAways[user.sName]["e"].."$$"..tAways[user.sName]["s"].."$|")
			tAways[user.sName] = nil
		end
	end

	local s,e,name = string.find(data, "%$Quit%s(%S+)")
	-- local usr = GetItemByName(name)
	--- if usr then
	-- if tAways[name] then
		UnRegIt(name)
	--- end
	--- SendToAll("disconnecting "..name)
end

function OpDisconnected(user)
	if tAways[user.sName] then
		UnRegIt(awpref..user.sName)
		-- SendToAll("Was Away ... by the nick "..awpref..user.sName.." and the reason "..tAways[user.sName]["reason"])
	end
	UnRegIt(user.sName)
	SendToAll(user.sName)
	--- SendToAll("$Quit "..user.sName)
	--- SendToAll("$Quit "..awpref..user.sName)
end

function RegIt(name)
--	frmHub:UnregBot(name)
--	frmHub:RegBot(name)
end

function UnRegIt(name)
--	frmHub:RegBot(name)
--	frmHub:UnregBot(name)
	SendToAll("$Quit "..name.."|")
end
