-- chatrooms v3 by tezlo

-- Lua 5 version by jiten
-- fixed chatroom loading/saving onexit by jiten (5/28/2005)
-- Changed: Commands structure (5/29/2005)
-- Changed: Chatrooms don't have key now
-- Added: Rightclick support
-- Added: Chatroom Key Switch (6/19/2005)
-- Removed: Extra rightclick endpipes

tKey = 1	-- 0 = Chatrooms don't have key; 1 = Chatrooms have Key

tCmds = {
	MakeChat = "mkchat",
	Away = "away",
	Leave = "leave",
	Members = "members",
	Invite = "invite",
	Remove = "remove",
	DelChat = "delchat",
}

Main = function()
	chatrooms:load()
end

OnExit = function()
	chatrooms:save()
end

ChatArrival = function(user, data)
	local s, e, cmd, args = string.find(data, "^%b<> %!(%a+)%s*(.*)|$")
	if cmd == tCmds.MakeChat and user.bOperator then
		local s, e, name, profiles = string.find(args, "(%S+)%s*(.*)")
		if not s then
			user:SendData(">> Syntax: !mkchat <name> [groups]")
		elseif chatrooms.items[name] then	
			user:SendData(">> "..name.." is already a Chatroom.")
		elseif GetItemByName(name) then
			user:SendData(">> There is a user with that name")
		else
			if tKey = 1 then frmHub:RegBot(name) else frmHub:RegBot(name,0,"","") end
			local tmp = chatrooms:new(name, user.sName)
			string.gsub(profiles, "(%S+)", function(profile)
				profile = tonumber(profile) or GetProfileIdx(profile)
				if GetProfileName(profile) then tmp.groups[profile] = 1 end
			end); tmp:chat("Hello", name)
			chatrooms:save()
			return 1
		end
	end
end

ToArrival = function(user,data)
	local s, e, to, str = string.find(data, "^$To: (%S+) From: %S+ $%b<> (.*)|$")
	if chatrooms.items[to] then
		local tmp = chatrooms.items[to]
		if not tmp.members[user.sName] then
			if user.bOperator or tmp.groups[user.iProfile] == 1 then
				tmp.members[user.sName] = 1
				tmp:chat(user.sName.." joined", to)
				tmp:chat(str, user.sName)
				chatrooms:save()
			else
				user:SendPM(to, "You're not a member here.")
			end
		else
			local isowner = (tmp.owner == user.sName)
			local s, e, cmd, args = string.find(str, "^%!(%a+)%s*(.*)$")
			if not s then
				tmp.members[user.sName] = 1
				tmp:chat(str, user.sName)
			elseif cmd == tCmds.Away then
				tmp:chat(user.sName.." is away.. "..args, to)
				tmp.members[user.sName] = 0
			elseif cmd == tCmds.Leave then
				tmp:chat(user.sName.." left. "..args, to)
				tmp.members[user.sName] = nil
				chatrooms:save()
			elseif cmd == tCmds.Members then
				local n, na, msg = 0, 0
				for nick, stat in tmp.members do
					if not GetItemByName(nick) then msg = " (offline)"
					elseif stat == 0 then msg = " (away)"
					else msg, na = "", na+1
					end; n = n+1
					user:SendPM(to, "\t"..nick..msg)
				end; user:SendPM(to, na.."/"..n.." active members.")
			elseif cmd == tCmds.Invite then
				string.gsub(args, "(%S+)", function(nick)
					if not tmp.members[nick] then
						tmp.members[nick] = 1
						tmp:chat(nick.." has been invited to the room. Type !leave to leave, and !members to see who's invited.", to)
					end
				end); chatrooms:save()
			elseif cmd == tCmds.Remove and isowner then
				string.gsub(args, "(%S+)", function(nick)
					if tmp.members[nick] and nick ~= tmp.owner then
						tmp:chat(nick.." has been removed from the room", to)
						tmp.members[nick] = nil
					end
				end); chatrooms:save()
			elseif cmd == tCmds.DelChat and isowner then
				tmp:chat("End of session.", to)
				chatrooms.items[to] = nil
				chatrooms:save()
				frmHub:UnregBot(to)
			else
				tmp:chat(str, user.sName)
			end
		end; return 1
	end
end

botchat = function(self, msg, from)
	for nick, id in self.members do
		if nick ~= from and id == 1 then
			SendToNick(nick, "$To: "..nick.." From: "..self.name.." $<"..from.."> "..msg)
		end
	end
end

chatrooms = {
	new = function(self, name, owner)
		local tmp = {
			name = name,
			owner = owner,
			groups = {},
			members = { [owner] = 1 },
			chat = botchat
		}; self.items[name] = tmp
		return tmp
	end,

	load = function(self)
		self.items = dofile("logs/chatrooms.tbl") or {}
		for name, room in self.items do
			if tKey = 1 then frmHub:RegBot(name) else frmHub:RegBot(name,0,"","") end
			room.chat = botchat
			room:chat("Hello", name)
		end
	end,

	save = function(self)
		if loadfile("logs/chatrooms.tbl") then 
			local f = io.open("logs/chatrooms.tbl", "w+")
			f:write("return {\n");
			for name, tmp in self.items do
				f:write(string.format("\t[%q] = {\n\t\tname = %q,\n\t\towner = %q,\n\t\tgroups = {\n", name, tmp.name, tmp.owner))
				for id, stat in tmp.groups do
					f:write(string.format("\t\t\t[%d] = %d,\n", id, stat))
				end; f:write("\t\t},\n\t\tmembers = {\n")
				for nick, stat in tmp.members do
					f:write(string.format("\t\t\t[%q] = %d,\n", nick, stat))
				end; 
				f:write("\t\t}\n\t},\n");
			end; 
			f:write("}"); f:close()
		else
			local f = io.open("logs/chatrooms.tbl", "w+")
			f:write("return {\n"); f:write("}"); f:close()
		end
	end
}

NewUserConnected = function(user)
	user:SendData("$UserCommand 1 2 Chatrooms\\Leave$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.Leave.."&#124;")
	user:SendData("$UserCommand 1 2 Chatrooms\\Members$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.Members.."&#124;")
	user:SendData("$UserCommand 1 2 Chatrooms\\Away$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.Away.."&#124;")
end

OpConnected = function(user)
	NewUserConnected(user)
	user:SendData("$UserCommand 1 2 Chatrooms\\Delete$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.DelChat.." %[line:Chatroom]&#124;")
	user:SendData("$UserCommand 1 2 Chatrooms\\Invite$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.Invite.." %[line:Nick]&#124;")
	user:SendData("$UserCommand 1 2 Chatrooms\\Remove$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.Remove.." %[line:Nick]&#124;")
	user:SendData("$UserCommand 1 3 Chatrooms\\Make$<%[mynick]> !"..tCmds.MakeChat.." %[line:Chatroom]&#124;")
end
