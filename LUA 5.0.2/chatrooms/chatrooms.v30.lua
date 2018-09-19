-- chatrooms v3
-- tezlo
-- converted to LUA 5 by jiten and bastya_elvtars

function Main()
	if not verify("logs/chatrooms.dat") then
		local f = io.open("logs/chatrooms.dat", "w+")
		f:write("return {\n")
		f:write("}")
		f:close()
	else
		chatrooms:load()
	end
end

function OnExit()
	chatrooms:save()
end

function ChatArrival(user, data)
	if string.sub(data, 1, 1) == "<" then
		local s, e, cmd, args = string.find(data, "^%b<> %!(%a+)%s*(.*)|$")
		if cmd == "mkchat" and user.bOperator then
			local s, e, name, profiles = string.find(args, "(%S+)%s*(.*)")
			if not s then
				user:SendData(">> Syntax: !mkchat <name> [groups]")
			elseif chatrooms.items[name] then	
				user:SendData(">> "..name.." is already a Chatroom.")
			elseif GetItemByName(name) then
				user:SendData(">> There is a user with that name")
			else
				frmHub:RegBot(name)
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
end

function ToArrival(user,data)
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
				elseif cmd == "away" then
					tmp:chat(user.sName.." is away.. "..args, to)
					tmp.members[user.sName] = 0
				elseif cmd == "leave" then
					tmp:chat(user.sName.." left. "..args, to)
					tmp.members[user.sName] = nil
					chatrooms:save()
				elseif cmd == "members" then
					local n, na, msg = 0, 0
					for nick, stat in tmp.members do
						if not GetItemByName(nick) then msg = " (offline)"
						elseif stat == 0 then msg = " (away)"
						else msg, na = "", na+1
						end; n = n+1
						user:SendPM(to, "\t"..nick..msg)
					end; user:SendPM(to, na.."/"..n.." active members.")
				elseif cmd == "invite" then
					string.gsub(args, "(%S+)", function(nick)
						if not tmp.members[nick] then
							tmp.members[nick] = 1
							tmp:chat(nick.." has been invited to the room. Type !leave to leave, and !members to see who's invited.", to)
						end
					end); chatrooms:save()
				elseif cmd == "remove" and isowner then
					string.gsub(args, "(%S+)", function(nick)
						if tmp.members[nick] and nick ~= tmp.owner then
							tmp:chat(nick.." has been removed from the room", to)
							tmp.members[nick] = nil
						end
					end); chatrooms:save()
				elseif cmd == "delchat" and isowner then
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
		self.items = dofile("logs/chatrooms.dat") or {}
		for name, room in self.items do
			frmHub:RegBot(name)
			room.chat = botchat
			room:chat("Hello", name)
		end
	end,

	save = function(self)
		local f = io.open("logs/chatrooms.dat", "w+")
		assert(f, "logs/chatrooms.dat")
		f:write("return {\n")
		for name, tmp in self.items do
			f:write(string.format("\t[%q] = {\n\t\tname = %q,\n\t\towner = %q,\n\t\tgroups = {\n", name, tmp.name, tmp.owner))
			for id, stat in tmp.groups do
				f:write(string.format("\t\t\t[%d] = %d,\n", id, stat))
			end;
			f:write("\t\t},\n\t\tmembers = {\n")
			for nick, stat in tmp.members do
				f:write(string.format("\t\t\t[%q] = %d,\n", nick, stat))
			end;
			f:write("\t\t}\n\t},\n")
		end; 
		f:write("}")
		f:close()
	end
}

function verify(filename)
	local f = io.open(filename, "r")
	if f then
		f:close()
		return true
	end
end
