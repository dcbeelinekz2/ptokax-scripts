-- chatrooms v3 by tezlo

-- Lua 5 version by jiten
-- fixed chatroom loading/saving onexit by jiten (5/28/2005)
-- Changed: Commands structure (5/29/2005)
-- Changed: Chatrooms don't have key now
-- Added: Rightclick support
-- Added: Chatroom Key Switch (6/19/2005)
-- Removed: Extra rightclick endpipes
-- Added: Optional Tag
-- Changed: Chatroom deleting and user removing to creator and operators (7/14/2005)
-- Added: Custom Profile Permission for commands 
-- Added: Option to create chatrooms for all users. Set bRestrict to false and type: !mkchat chatroom_name
-- Added: Option to set chatroom only for same profile users / allow operators
-- Fixed: File Handling (10/24/2005)
-- Changed: Command Parsing
-- Added: Autologin switch for each chatroom: !autologin on/off
-- Code optimized a bit (10/30/2005)
-- Added: hide chatrooms from non members !hide on/off by Dessamator

tCmds = {}
tKey = 1			-- 0 = Chatrooms don't have key; 1 = Chatrooms have Key
sTag = ""			-- Set your Chatrooms Tag here. If you don't want it, set it to: sTag = ""
fChat = "Chatrooms.tbl"		-- Chatrooms' Database
bRestrict = false		-- Warning: Only applies to command (without specifying a profile): !mkchat chatname
				-- If true, the chatroom will be available only to those invited by the owner.
				-- If false, it will be availabe to everyone.

-- If you're using Robocop profiles don't change this. If not, remove Profile 4 and 5 and follow this syntax: 
-- [Profile number] = value (higher value means more rights)
Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [4] = 5, [0] = 6, [5] = 7, }

Commands = {	-- Set Profile Permissions according to "value" in Levels table.
		-- Example: MakeChat = { "mkchat", 2 },
		--	   Reg and above users are allowed to create chatrooms.
	MakeChat = { "mkchat", 4 },
	Away = { "away", 1 },
	Leave = { "leave", 1 },
	Members = { "members", 1 },
	Invite = { "invite", 4 },
	Remove = { "remove", 4 },
	DelChat = { "delchat", 4 },
	AutoLogin = { "autologin", 4 },
	Hide = { "hide",4},
}

Main = function()
	chatrooms:load()
end

OnExit = function()
	chatrooms:save()
end


MyINFOArrival = function(user, data)
	chatrooms:load(user)
end

ChatArrival = function(user,data)
	local data = string.sub(data,1,-2)
	local s,e,cmd = string.find(data,"%b<>%s+%!(%S+)")
	if cmd then
		local mCmds = { 
		["mkchat"] = function(user, data)
			local s,e,args = string.find(data, "^%b<>%s+%S+%s*(.*)")
			local s,e,name,profiles = string.find(args,"(%S+)%s*(.*)")
			if not s then
				return user:SendData(frmHub:GetHubBotName(),"*** Syntax Error: Type !mkchat [groups]"), 1
			elseif chatrooms.items[name] then	
				return user:SendData(frmHub:GetHubBotName(),"*** Error: "..name.." is already a Chatroom."), 1
			elseif GetItemByName(name) then
				return user:SendData(frmHub:GetHubBotName(),"*** There is a user with that name"), 1
			else
				if tKey == 1 then frmHub:RegBot(sTag..name) else frmHub:RegBot(sTag..name,0,"","") end
				local tmp = chatrooms:new(sTag..name, user.sName, "")
				string.gsub(profiles, "(%S+)", function(profile)
					profile = tonumber(profile) or GetProfileIdx(profile)
					if GetProfileName(profile) then tmp.groups[profile] = 1 end
				end); tmp:chat("Hello", sTag..name)
				chatrooms:save()
				return 1
			end
		end }
		if mCmds[cmd] then
			for i,v in Commands do 
				if Levels[user.iProfile] >= v[2] then return mCmds[cmd](user,data), 1 end
			end
		end
	end
end

ToArrival = function(user,data)
	local data = string.sub(data,1,-2)
	local s,e,to,str = string.find(data, "^$To: (%S+) From: %S+ $%b<> (.*)")
	if chatrooms.items[to] then
		local tmp = chatrooms.items[to]
		if not tmp.members[user.sName] then
			local Messager = function()
				if tmp.status == "auto" then
					tmp:chat(str, user.sName)
				else
					tmp.members[user.sName] = 1 tmp:chat(user.sName.." joined", to) tmp:chat(str, user.sName) chatrooms:save()
				end
			end
			if next(tmp.groups) then
				if user.bOperator or tmp.groups[user.iProfile] == 1 then
--				if tmp.groups[user.iProfile] == 1 then  -- Uncomment this line and comment the above one if you want
									-- the chatroom to be available only for users of the same 
									-- profile. So, Operators won't join like they do in the other line.

					Messager()
				else
					user:SendPM(to, "You're not a member here.")
				end
			else
				if bRestrict then user:SendPM(to, "You're not a member here.") else Messager() end
			end
		else
			local s,e,cmd,args = string.find(str, "^%!(%a+)%s*(.*)$")
			if cmd then
				local tCmds = {
				[Commands.Away[1]] = function(user, data, tmp, to, args)
					tmp:chat(user.sName.." is away.. "..args, to)
					if tmp.status == "auto" then tmp.away[user.sName] = 1 else tmp.members[user.sName] = 0 end
				end,
				[Commands.Leave[1]] = function(user, data, tmp, to, args)
					tmp:chat(user.sName.." left. "..args, to)
					if tmp.status == "auto" then tmp.away[user.sName] = 1 else tmp.members[user.sName] = nil end
					chatrooms:save()
				end,
				[Commands.Members[1]] = function(user, data, tmp, to)
				local n, na, msg,offline,away,on = 0, 0,"","Offline :\r\n"..string.rep ("=", 20),"Away :\r\n"..string.rep ("=", 20), "Online :\r\n"..string.rep ("=", 20)
					if tmp.status=="on" and tmp.groups  then
						user:SendPM(to, "This room is private, only Members can chat here.")
					elseif tmp.status=="on" then
						user:SendPM(to, "This room is public, all users can chat.")
					else
						for nick, stat in tmp.members do
							if not GetItemByName(nick) then offline = offline.."\r\n"..nick
							elseif stat == 0 then away = away.."\r\n"..nick
							else msg, na = "", na+1
							on = on.."\r\n"..nick
							end; n = n+1
						end; 
					user:SendPM(to, "\r\n"..on.."\r\n\r\n"..offline.."\r\n\r\n"..away.."\r\n\r\n"..na.."/"..n.." active members.")
					end
				end,
				[Commands.Invite[1]]	= function(user, data, tmp, to, args)
						string.gsub(args, "(%S+)", function(nick)
							if not tmp.members[nick] then
								tmp.members[nick] = 1
								tmp:chat(nick.." has been invited to the room. Type !leave to leave, and !members to see who's invited.", to)
							end
						end); chatrooms:save()
				end,
				[Commands.Remove[1]]	= function(user, data, tmp, to, args)
					string.gsub(args, "(%S+)", function(nick)
						if tmp.members[nick] and nick ~= tmp.owner then
							tmp:chat(nick.." has been removed from the room", to)
							tmp.members[nick] = nil
						end
					end); chatrooms:save()
				end,
				[Commands.DelChat[1]] = function(user, data, tmp, to)
					tmp:chat("End of session.", to)
					chatrooms.items[to] = nil
					chatrooms:save()		
					SendToAll("$Quit "..to)
				end,
				[Commands.AutoLogin[1]] = function(user, data, tmp, to, args)
					if string.lower(args) == "on" then
						tmp.status = "auto" chatrooms:save()
						user:SendPM(to, "Chatroom AutoLogin Mode has been enabled.")
					elseif string.lower(args) == "off" then
						tmp.status = "" chatrooms:save()
						user:SendPM(to, "Chatroom AutoLogin Mode has been disabled.")
					else
						user:SendPM(to, "*** Syntax Error: Type !autologin on/off")
					end
				end, 
				[Commands.Hide[1]] = function(user, data, tmp, to, args)
					if string.lower(args) == "on" then
						tmp.hide="on"
					
						user:SendPM(to, "Chatroom hide Mode has been enabled.")
					elseif string.lower(args) == "off" then
						tmp.hide = "off" 
						user:SendPM(to, "Chatroom Hide Mode has been disabled.")
					else
						user:SendPM(to, "*** Syntax Error: Type !hide on/off")
					end
				chatrooms:save()
				chatrooms:load()
				end,  
}
				if tCmds[cmd] then
					for i,v in Commands do
						if Levels[user.iProfile] >= v[2] then return tCmds[cmd](user, data, tmp, to, args), 1 end
					end
				end
			elseif not s then 
				tmp.members[user.sName] = 1 tmp:chat(str, user.sName) 
			else
				tmp:chat(str, user.sName)
			end
		end; 
		return 1
	end
end

botchat = function(self, msg, from)
	local SendPM = function(a,b,tTable,tMode)
		for a, b in tTable do
			if tMode == 1 then
				if b.sName ~= from and not self.away[b.sName] then 
					SendToNick(b.sName, "$To: "..b.sName.." From: "..self.name.." $<"..from.."> "..msg)
				end
			else
				if a ~= from and b == 1 then
					SendToNick(a, "$To: "..a.." From: "..self.name.." $<"..from.."> "..msg)
				end
			end
		end
	end
	if self.status == "auto" then
		if next(self.groups) then
			for v, i in self.groups do SendPM(_,user,frmHub:GetOnlineUsers(v), 1) end SendPM(nick, id, self.members, 0)
		else
			SendPM(_,user,frmHub:GetOnlineUsers(), 1)
		end
	else
		SendPM(nick, id, self.members, 0)
	end
end

chatrooms = {
	new = function(self, name, owner)
		local tmp = { name = name, owner = owner, status = "", hide ="off", groups = {}, members = { [owner] = 1 }, away = {}, chat = botchat };
		self.items[name] = tmp return tmp
	end,

	load = function(self,user)
		local function HideBots(room,Status,v)
		local KeyCheck
		if tKey then KeyCheck = "$OpList "..room.name  else KeyCheck ="$MyINFO $ALL "..room.name.." ".." ".."$ $".." ".." $".." ".."$".."0".."$" end
		if Status then 	SendToAll(KeyCheck) end
		v=v or user
			for i,v in frmHub:GetOnlineUsers() do
					if v.sName~= room.owner and not(room.members[v.sName]) or not(room.groups[v.iProfile]) then v:SendData("$Quit "..room.name) 
					else v:SendData(KeyCheck) end
			if user then break end
			end
		end
	
		if loadfile(fChat) then
			self.items = dofile(fChat)
			for name, room in self.items do
				-- room:chat("Hello", name)
				room.chat = botchat
				if user and room.hide =="on" then HideBots(room,"",user)
				elseif room.hide =="off" then     HideBots(room,"on") 
				elseif not user then		 HideBots(room) 
				end
			end
		
		else
			local f = io.open(fChat, "w+") f:write("return {\n"); f:write("}"); f:close() self.items = dofile(fChat)
		end
	end,

	save = function(self)
		local f = io.open(fChat, "w+")
		f:write("return {\n");
		for name, tmp in self.items do
			f:write(string.format("\t[%q] = {\n\t\tname = %q,\n\t\towner = %q,\n\t\tstatus = %q,\n\t\thide = %q,\n\t\tgroups = {\n", name, tmp.name, tmp.owner, tmp.status,tmp.hide))
			for id, stat in tmp.groups do f:write(string.format("\t\t\t[%d] = %d,\n", id, stat)) end; 
			f:write("\t\t},\n\t\tmembers = {\n")
			for nick, stat in tmp.members do f:write(string.format("\t\t\t[%q] = %d,\n", nick, stat)) end;
			f:write("\t\t},\n\t\taway = {\n");
			for user, stat in tmp.away do f:write(string.format("\t\t\t[%q] = %d,\n", user, stat)) end;
			f:write("\t\t}\n\t},\n");
		end; 
		f:write("}"); f:close()
	end
}

NewUserConnected = function(user)
	user:SendData("$UserCommand 1 2 Chatrooms\\Leave$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Leave[1].."|")
	user:SendData("$UserCommand 1 2 Chatrooms\\Members$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Members[1].."|")
	user:SendData("$UserCommand 1 2 Chatrooms\\Away$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Away[1].."|")
end

OpConnected = function(user)
	NewUserConnected(user)
	user:SendData("$UserCommand 0 2")
	user:SendData("$UserCommand 1 2 Chatrooms\\Delete$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.DelChat[1].." %[line:Chatroom]|")
	user:SendData("$UserCommand 1 2 Chatrooms\\Invite$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Invite[1].." %[line:Nick]|")
	user:SendData("$UserCommand 1 2 Chatrooms\\Remove$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Remove[1].." %[line:Nick]|")
	user:SendData("$UserCommand 1 3 Chatrooms\\Make$<%[mynick]> !"..Commands.MakeChat[1].." %[line:Chatroom] %[line:Profile (optional)]|")
	user:SendData("$UserCommand 1 2 Chatrooms\\Set AutoLogin$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.AutoLogin[1].." %[line:On/Off]|")
	user:SendData("$UserCommand 1 2 Chatrooms\\Set Hide$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Hide[1].." %[line:On/Off]|")
end