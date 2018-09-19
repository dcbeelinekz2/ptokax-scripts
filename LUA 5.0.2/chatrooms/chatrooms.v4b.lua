-- Chatrooms v4b
-- Lua 5 version by jiten and Dessamator
-- Based on: Chatrooms v3 by tezlo

-- Changelog
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
-- Added: Hide chatrooms from non members !hide on/off by Dessamator
-- Changed: Lots of optimizations and debugging
-- Fixed: Hide Mode
-- Added: Lock Mode
-- Changed: Now Key, AutoLogin and Lock can be defined for each room (1/5/2006)
-- Fixed: Delchat MyINFO and Profile Permissions
-- Fixed: ToArrival args
-- Removed: Debugging commands
-- Fixed: Group Profiles cannot be hidden (1/10/2006)
-- Fixed: $OpList MyINFO (1/11/2006)
-- Fixed: RightClick for members and groups - thx to miago (1/16/2006)

sTag = ""			-- Set your Chatrooms Tag here. If you don't want it, set it to: sTag = ""
fChat = "Chatrooms.tbl"		-- Chatrooms' Database
bAutoLogin = "off"		-- Default AutoLogin Mode (on/off)
bKey = "on"			-- Default Chatroom Key  (on/off)
bLocked = "off"			-- Default Locked Mode (on/off) - If on, Room only members selected by owner Allowed.

-- If you're using Robocop profiles don't change this. If not, remove Profile 4 and 5 and follow this syntax: 
-- [Profile number] = value (higher value means more rights)
Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [4] = 5, [0] = 6, [5] = 7, }

-- Commands
Commands = {
	MakeChat = "mkchat", Away = "away", Leave = "leave", Members = "members", Invite = "invite",
	Remove = "remove", DelChat = "delchat", AutoLogin = "autologin", Hide = "hide", Lock = "lock", Key = "key",
}

tAllowed = {
	-- Profiles allowed to join every chatroom
	[0] = 1, -- master
	[1] = 1, -- operator
	[2] = 0, -- vip
	[3] = 0, -- reg
	[4] = 1, -- moderator
	[5] = 1, -- founder
	[-1] = 0, -- unreg
}

Main = function()
	chatrooms:load(usr,1)
end

OnExit = function()
	for i,v in chatrooms.items do
		SendToAll("$Quit "..i)
	end
end  

MyINFOArrival = function(user, data)
	chatrooms:load(user)
end

ChatArrival = function(user,data)
	local data = string.sub(data,1,-2)
	local s,e,cmd = string.find(data,"%b<>%s+%!(%S+)")
	if cmd and cmd == Commands.MakeChat and tCmds[Commands.MakeChat] then
		if tCmds[cmd][2] <= Levels[user.iProfile] then return tCmds[cmd][1](user,data), 1 end
	end
end

ToArrival = function(user,data)
	local data = string.sub(data,1,-2)
	local s,e,to,str = string.find(data, "^$To: (%S+) From: %S+ $%b<> (.*)")
	if chatrooms.items[to] then
		local tmp = chatrooms.items[to]
		local s,e,cmd,args = string.find(str, "^%!(%a+)%s*(.*)$")
		if cmd and tCmds[cmd] then
			if tCmds[cmd][2] <= Levels[user.iProfile] then return tCmds[cmd][1](user,data,tmp,to,args), 1 end
		end
		if tmp.members[user.sName] then
			if tmp.members[user.sName] ~= 1 then tmp.members[user.sName] = 1 end
			tmp:chat(str, user.sName) 
		else
			local Messager = function()
				if tmp.locked == "off" then
					if tmp.autologin == "on" then
						tmp:chat(str, user.sName)
					else
						tmp.members[user.sName] = 1 tmp:chat(user.sName.." joined", to) tmp:chat(str, user.sName) chatrooms:save()
					end
				else
					user:SendPM(to, "You're not a member here.")
				end
			end
			if next(tmp.groups) then
				if tAllowed[user.iProfile] == 1 or tmp.groups[user.iProfile] == 1 then Messager() else user:SendPM(to, "You're not a member here.") end
			else
				Messager()
			end
		end; 
		return 1
	end
end

NewUserConnected = function(user)
	for a,b in chatrooms.items do
		if b.groups[user.iProfile] or b.members[user.sName] then
			if user.bUserCommand then for i,v in tCmds do if(v[2] <= Levels[user.iProfile]) then user:SendData(v[3]) end end break end
		end
	end
end

OpConnected = NewUserConnected

tCmds = {
--	Commands Structure:
--	[Command] = { function, Lowest Profile that can use this command (check Levels table), RightClick Command},

	[Commands.MakeChat] = { 
				function(user, data) 
					local s,e,args = string.find(data, "^%b<>%s+%S+%s*(.*)") 
					local s,e,name,profiles = string.find(args,"(%S+)%s*(.*)") 
					if not s then 
						return user:SendData(frmHub:GetHubBotName(),"*** Syntax Error: Type !"..Commands.MakeChat.." <name> [groups]"), 1 
					elseif chatrooms.items[name] then	 
						return user:SendData(frmHub:GetHubBotName(),"*** Error: "..name.." is already a Chatroom."), 1 
					elseif GetItemByName(name) then 
						return user:SendData(frmHub:GetHubBotName(),"*** There is a user with that name"), 1 
					else 
						if bKey then SendToAll("$OpList "..sTag..name.."$$") else SendToAll("$MyINFO $ALL "..sTag..name.." ".." ".."$ $".." ".." $".." ".."$".."0".."$") end			 
						local tmp = chatrooms:new(sTag..name, user.sName, bAutoLogin, bLocked, bKey)
						string.gsub(profiles, "(%S+)", function(profile) 
							profile = tonumber(profile) or GetProfileIdx(profile) 
							if GetProfileName(profile) then tmp.groups[profile] = 1 end 
						end); tmp:chat("Hello", sTag..name) 
						chatrooms:save() 
					end 
				end, 4, "$UserCommand 1 3 Chatrooms\\Make$<%[mynick]> !"..Commands.MakeChat.." %[line:Chatroom] %[line:Profile (optional)]&#124;" },
	[Commands.Away] = { 
				function(user, data, tmp, to, args)
					tmp:chat(user.sName.." is away.. "..args, to)
					tmp.members[user.sName] = 0
				end, 1, "$UserCommand 1 3 Chatrooms\\Away$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Away.."&#124;" },
	[Commands.Leave] = { 
				function(user, data, tmp, to, args)
					if tmp.autologin == "off" then
						tmp.members[user.sName] = nil
						tmp:chat(user.sName.." left. "..args, to)
						chatrooms:save() chatrooms:load(user) 
					else
						user:SendPM(to, "Command disabled in AutoLogin mode!")
					end
				end, 1, "$UserCommand 1 3 Chatrooms\\Leave$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Leave.."&#124;" },
	[Commands.Members] = { 
				function(user, data, tmp, to)
					local n, na, msg,offline,away,on = 0, 0,"","Offline :\r\n"..string.rep ("=", 20),"Away :\r\n"..string.rep ("=", 20), "Online :\r\n"..string.rep ("=", 20)
					if tmp.autologin == "on" then
						if next(tmp.groups)  then
							user:SendPM(to, "This room is private, only Members can chat here.")
						else
							user:SendPM(to, "This room is public.")
						end	
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
				end, 1, "$UserCommand 1 3 Chatrooms\\Members$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Members.."&#124;" },
	[Commands.Invite] = { 
				function(user, data, tmp, to, args)
					string.gsub(args, "(%S+)", function(nick)
						if not tmp.members[nick] then
							tmp.members[nick] = 1 chatrooms:save()
							if GetItemByName(nick) then chatrooms:load(GetItemByName(nick)) end
							tmp:chat(nick.." has been invited to the room. Type !leave to leave, and !members to see who's invited.", to)
						end
					end);
				end, 4, "$UserCommand 1 3 Chatrooms\\Invite$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Invite.." %[line:Nick]&#124;" },
	[Commands.Remove] = { 
				function(user, data, tmp, to, args)
					string.gsub(args, "(%S+)", function(nick)
						if tmp.members[nick] and nick ~= tmp.owner then
							tmp:chat(nick.." has been removed from the room", to)
							tmp.members[nick] = nil chatrooms:save() 
							if GetItemByName(nick) then chatrooms:load(GetItemByName(nick)) end
						end
					end);
				end, 4, "$UserCommand 1 3 Chatrooms\\Remove$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Remove.." %[line:Nick]&#124;" },
	[Commands.DelChat] = { 
				function(user, data, tmp, to)
					tmp:chat("End of session.", to)
					for _,usr in frmHub:GetOnlineUsers() do
						if next(tmp.groups) then
							if tmp.groups[usr.iProfile] or tmp.members[usr.sName] or not tmp.hide[usr.iProfile] then usr:SendData("$Quit "..to) end
						else
							SendToAll("$Quit "..to)
						end
					end
					chatrooms.items[to] = nil
					chatrooms:save() chatrooms:load()
				end, 4, "$UserCommand 1 3 Chatrooms\\Delete$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.DelChat.." %[line:Chatroom]&#124;" },
	[Commands.AutoLogin] = {
				function(user, data, tmp, to, args)
					if string.lower(args) == "on" then
						tmp.autologin = "on" chatrooms:save()
						user:SendPM(to, "Chatroom AutoLogin Mode has been enabled.")
					elseif string.lower(args) == "off" then
						tmp.autologin = "off" chatrooms:save()
						user:SendPM(to, "Chatroom AutoLogin Mode has been disabled.")
					else
						user:SendPM(to, "*** Syntax Error: Type !"..Commands.AutoLogin.." <on/off>")
					end
				end, 4, "$UserCommand 1 3 Chatrooms\\Set AutoLogin$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.AutoLogin.." %[line:On/Off]&#124;" },
	[Commands.Key] = { 
				function(user, data, tmp, to, args)
					if string.lower(args) == "on" then
						tmp.key = "$OpList "..to.."$$" chatrooms:save()
						user:SendPM(to, "Chatroom Key Mode has been enabled.")
					elseif string.lower(args) == "off" then
						tmp.key = "$MyINFO $ALL "..to.." ".." ".."$ $".." ".." $".." ".."$".."0".."$" chatrooms:save()
						user:SendPM(to, "Chatroom Key Mode has been disabled.")
					else
						user:SendPM(to, "*** Syntax Error: Type !"..Commands.Key.." <on/off>")
					end
				end, 4, "$UserCommand 1 3 Chatrooms\\Set Key$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Key.." %[line:On/Off]&#124;" },
	[Commands.Lock] = { 
				function(user, data, tmp, to, args)
					if string.lower(args) == "on" then
						tmp.locked = "on" chatrooms:save()
						user:SendPM(to, "Chatroom Locked Mode has been enabled.")
					elseif string.lower(args) == "off" then
						tmp.locked = "off" chatrooms:save()
						user:SendPM(to, "Chatroom Locked Mode has been disabled.")
					else
						user:SendPM(to, "*** Syntax Error: Type !"..Commands.Lock.." <on/off>")
					end
				end, 4, "$UserCommand 1 3 Chatrooms\\Set Lock$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Hide.." %[line:On/Off]&#124;" },
	[Commands.Hide] = { 
				function(user, data, tmp, to, args)
					if args then
						if string.lower(args) == "off" then
							tmp.hide = {}
							user:SendPM(to, "Hide Deactivated.")
						else
							string.gsub(args, "(%S+)", function(profile) 
								if tmp.groups[profile] then user:SendPM(to, "This group is immune to hide.") return 0 end
								if string.lower(profile) == "unreg" or profile == "-1" then tmp.hide[-1] = 1 end
								profile = tonumber(profile) or GetProfileIdx(profile) 
								if GetProfileName(profile) then tmp.hide[profile] = 1 end 
							end)
							user:SendPM(to, args.." has been added to "..to.."'s Profile Hiding List.")
						end
						chatrooms:save() chatrooms:load()
					else
						user:SendPM(to, "*** Syntax Error: Type !"..Commands.Hide.." [groups]")
					end
				end, 4, "$UserCommand 1 3 Chatrooms\\Set Hide$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Hide.." %[line:Profiles (e.g. unreg/reg/vip]&#124;" },
}

botchat = function(self, msg, from)
	if self.autologin == "on" then
		if next(self.groups) then
			for _,user in frmHub:GetOnlineUsers() do
				if (self.groups[user.iProfile] or self.members[user.sName]) and user.sName ~= from and self.members[user.sName] ~= 0 then
					SendToNick(user.sName, "$To: "..user.sName.." From: "..self.name.." $<"..from.."> "..msg)
				end
			end
		else
			for _,user in frmHub:GetOnlineUsers() do
				if user.sName ~= from and self.members[user.sName] ~= 0 then
					SendToNick(user.sName, "$To: "..user.sName.." From: "..self.name.." $<"..from.."> "..msg)
				end
			end
		end
	else
		for nick,id in self.members do
			if nick ~= from and id == 1 then
				SendToNick(nick, "$To: "..nick.." From: "..self.name.." $<"..from.."> "..msg)
			end
		end
	end
end

chatrooms = {
	new = function(self, name, owner, autologin, locked, key)
		if key == "on" then key = "$OpList "..name.."$$" else key = "$MyINFO $ALL "..name.." ".." ".."$ $".." ".." $".." ".."$".."0".."$" end 
		local tmp = {
			name = name, owner = owner, autologin = autologin, key = key, hide = {},
			locked = locked, groups = {}, members = { [owner] = 1 }, chat = botchat
		};
		self.items[name] = tmp return tmp
	end,

	load = function(self,user,bLoad) 
		if bLoad then 
			if loadfile(fChat) then 
				self.items = dofile(fChat) 
			else	
				local f = io.open(fChat, "w+") f:write("return {\n"); f:write("}"); f:close() self.items = dofile(fChat) 
			end
		end
		local function bMember(usr,room)
			if usr then
				if (room.groups[usr.iProfile]) or (usr.sName == room.owner) or (room.members[usr.sName] and(room.members[usr.sName] ~= 2)) or (not(room.hide[usr.iProfile]))  then
					usr:SendData(room.key)
					return 1
				else
					usr:SendData("$Quit "..room.name)
					return 1
				end
			end
		end	
		for sName,room in chatrooms.items do
			-- room:chat("Hello", name) 
			room.chat = botchat
			if next(room.hide) then
				if not(bMember(user,room)) then for i,v in frmHub:GetOnlineUsers() do bMember(v,room) end end
			else
				if user then
					if user.sName == room.name then user:Disconnect() return 0 end -- drop user if nick==chatbot
					user:SendData(room.key) 
				else 
					SendToAll(room.key)
				end
			end 
		end
	end, 

	save = function(self)
		local f = io.open(fChat, "w+")
		f:write("return {\n");
		for name, tmp in self.items do
			f:write(string.format("\t[%q] = {\n\t\tname = %q,\n\t\towner = %q,\n\t\tautologin = %q,\n\t\tlocked = %q,\n\t\tkey = %q,"..
			"\n\t\tgroups = {\n", name, tmp.name, tmp.owner, tmp.autologin,tmp.locked,tmp.key))
			for id, stat in tmp.groups do f:write(string.format("\t\t\t[%d] = %d,\n", id, stat)) end; 
			f:write("\t\t},\n\t\tmembers = {\n")
			for nick, stat in tmp.members do f:write(string.format("\t\t\t[%q] = %d,\n", nick, stat)) end;
			f:write("\t\t},\n\t\thide = {\n");
			for user, stat in tmp.hide do f:write(string.format("\t\t\t[%d] = %d,\n", user, stat)) end;
			f:write("\t\t}\n\t},\n");
		end; 
		f:write("}"); f:close()
	end
}