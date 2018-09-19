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


tKey = 1			-- 0 = Chatrooms don't have key; 1 = Chatrooms have Key
sTag = ""			-- Set your Chatrooms Tag here. If you don't want it, set it to: sTag = ""
fChat = "Chatrooms.tbl"		-- Chatrooms' Database
bRestrict = true		-- Warning: Only applies to command (without specifying a profile): !mkchat chatname
				-- If true, the chatroom will be available only to those invited by the owner.
				-- If false, it will be availabe to everyone.

-- If you're using Robocop profiles don't change this. If not, remove Profile 4 and 5 and follow this syntax: 
-- [Profile number] = value (higher value means more rights)
Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [4] = 5, [0] = 6, [5] = 7, }

tCmds = {	-- Set Profile Permissions according to "value" in Levels table.
		-- Example: MakeChat = { "mkchat", 2 },
		--	    Reg and above users are allowed to create chatrooms.
	MakeChat = { "mkchat", 4 },
	Away = { "away", 1 },
	Leave = { "leave", 1 },
	Members = { "members", 1 },
	Invite = { "invite", 4 },
	Remove = { "remove", 4 },
	DelChat = { "delchat", 4 },
}

Main = function()
	chatrooms:load()
end

OnExit = function()
	chatrooms:save()
end

ChatArrival = function(user, data)
	local s, e, cmd, args = string.find(data, "^%b<> %!(%a+)%s*(.*)|$")
	if CheckPermission(user,cmd,tCmds.MakeChat[1]) then
		local s, e, name, profiles = string.find(args, "(%S+)%s*(.*)")
		if not s then
			return user:SendData(frmHub:GetHubBotName(),"*** Syntax Error: Type !mkchat <name> [groups]"), 1
		elseif chatrooms.items[name] then	
			return user:SendData(frmHub:GetHubBotName(),"*** Error: "..name.." is already a Chatroom."), 1
		elseif GetItemByName(name) then
			return user:SendData(frmHub:GetHubBotName(),"*** There is a user with that name"), 1
		else
			if tKey == 1 then frmHub:RegBot(sTag..name) else frmHub:RegBot(sTag..name,0,"","") end
			local tmp = chatrooms:new(sTag..name, user.sName)
			string.gsub(profiles, "(%S+)", function(profile)
				profile = tonumber(profile) or GetProfileIdx(profile)
				if GetProfileName(profile) then tmp.groups[profile] = 1 end
			end); tmp:chat("Hello", sTag..name)
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
			if next(tmp.groups) then
				if user.bOperator or tmp.groups[user.iProfile] == 1 then
--				if tmp.groups[user.iProfile] == 1 then  -- Uncomment this line and comment the above one if you want
									-- the chatroom to be available only for users of the same 
									-- profile. So, Operators won't join like they do in the other line.
					tmp.members[user.sName] = 1
					tmp:chat(user.sName.." joined", to)
					tmp:chat(str, user.sName)
					chatrooms:save()
				else
					user:SendPM(to, "You're not a member here.")
				end
			else
				if bRestrict then
					user:SendPM(to, "You're not a member here.")
				else
					tmp.members[user.sName] = 1
					tmp:chat(user.sName.." joined", to)
					tmp:chat(str, user.sName)
					chatrooms:save()
				end
			end
		else
			local isowner = (tmp.owner == user.sName)
			local s, e, cmd, args = string.find(str, "^%!(%a+)%s*(.*)$")
			if not s then
				tmp.members[user.sName] = 1
				tmp:chat(str, user.sName)
			elseif CheckPermission(user,cmd,tCmds.Away[1]) then
				tmp:chat(user.sName.." is away.. "..args, to)
				tmp.members[user.sName] = 0
			elseif CheckPermission(user,cmd,tCmds.Leave[1]) then
				tmp:chat(user.sName.." left. "..args, to)
				tmp.members[user.sName] = nil
				chatrooms:save()
			elseif CheckPermission(user,cmd,tCmds.Members[1]) then
				local n, na, msg = 0, 0
				for nick, stat in tmp.members do
					if not GetItemByName(nick) then msg = " (offline)"
					elseif stat == 0 then msg = " (away)"
					else msg, na = "", na+1
					end; n = n+1
					user:SendPM(to, "\t"..nick..msg)
				end; user:SendPM(to, na.."/"..n.." active members.")
			elseif CheckPermission(user,cmd,tCmds.Invite[1]) then
				string.gsub(args, "(%S+)", function(nick)
					if not tmp.members[nick] then
						tmp.members[nick] = 1
						tmp:chat(nick.." has been invited to the room. Type !leave to leave, and !members to see who's invited.", to)
					end
				end); chatrooms:save()
			elseif CheckPermission(user,cmd,tCmds.Remove[1]) then
				string.gsub(args, "(%S+)", function(nick)
					if tmp.members[nick] and nick ~= tmp.owner then
						tmp:chat(nick.." has been removed from the room", to)
						tmp.members[nick] = nil
					end
				end); chatrooms:save()
			elseif CheckPermission(user,cmd,tCmds.DelChat[1]) then
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
		self.items = dofile(fChat) or {}
		for name, room in self.items do
			if tKey == 1 then frmHub:RegBot(name) else frmHub:RegBot(name,0,"","") end
			room.chat = botchat
			room:chat("Hello", name)
		end
	end,

	save = function(self)
		if loadfile(fChat) then 
			local f = io.open(fChat, "w+")
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
			local f = io.open(fChat, "w+")
			f:write("return {\n"); f:write("}"); f:close()
		end
	end
}

CheckPermission = function(user,cmd,tCmd)
	for i,v in tCmds do
		if cmd == tCmd and v[1] == tCmd then
			if Levels[user.iProfile] >= v[2] then
				return true
			end
			return false
		end
	end
end

NewUserConnected = function(user)
	user:SendData("$UserCommand 1 2 Chatrooms\\Leave$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.Leave[1].."&#124;")
	user:SendData("$UserCommand 1 2 Chatrooms\\Members$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.Members[1].."&#124;")
	user:SendData("$UserCommand 1 2 Chatrooms\\Away$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.Away[1].."&#124;")
end

OpConnected = function(user)
	NewUserConnected(user)
	user:SendData("$UserCommand 1 2 Chatrooms\\Delete$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.DelChat[1].." %[line:Chatroom]&#124;")
	user:SendData("$UserCommand 1 2 Chatrooms\\Invite$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.Invite[1].." %[line:Nick]&#124;")
	user:SendData("$UserCommand 1 2 Chatrooms\\Remove$&#36;To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..tCmds.Remove[1].." %[line:Nick]&#124;")
	user:SendData("$UserCommand 1 3 Chatrooms\\Make$<%[mynick]> !"..tCmds.MakeChat[1].." %[line:Chatroom]&#124;")
end
