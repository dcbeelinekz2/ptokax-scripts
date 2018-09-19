--[[

	Chatrooms v 4.1 - LUA 5.0.2/5.1

	By: jiten and Dessamator

	Based on: Chatrooms v3 by tezlo

	Changelog:

	- Changed: Profile permissions; (requested by GeceBekcisi)
	- Rewritten: Significant code and loops; code is more presentable;
	- Added: Status for each chatroom;
	- Changed: MyINFO handling to avoid flooding;
	- Changed: Other small mods
	- Changed: Updated to LUA 5.1 (3/25/2006)

]]--

tSettings = {
	sTag = "",			-- Set your Chatrooms Tag here. If you don't want it, set it to: sTag = ""
	fChat = "tChatrooms.tbl",	-- Chatrooms' Database
	bAutoLogin = "off",		-- Default AutoLogin Mode (on/off)
	bKey = "on",			-- Default Chatroom Key  (true/false)
	bLocked = "off",		-- Default Locked Mode (on/off) - If on, Room only members selected by owner Allowed.
	tAllowed = {
		-- Profiles allowed to join every chatroom
		[0] = 1, -- master
		[1] = 1, -- operator
		[4] = 1, -- moderator
		[5] = 1, -- founder
	}
}

-- Commands
Commands = {
	MakeChat = "mkchat", Away = "away", Leave = "leave", Members = "members", Invite = "invite", Status = "status",
	Remove = "remove", DelChat = "delchat", AutoLogin = "autologin", Hide = "hide", Lock = "lock", Key = "key",
}

Main = function()
	chatrooms:load()
end

OnExit = function()
	chatrooms:unload()
end

MyINFOArrival = function(user, data)
	for sName,room in pairs(chatrooms.items) do
		if room.name == user.sName then user:Disconnect() return 0 end
		if tFunctions.bMember(room,user) then user:SendData(room.key) end
	end
end

ChatArrival = function(user,data)
	local data = string.sub(data,1,-2)
	local s,e,cmd = string.find(data,"%b<>%s+%!(%S+)")
	if cmd then
		cmd = string.lower(cmd)
		if cmd == Commands.MakeChat and tCmds[Commands.MakeChat] then
			if tCmds[cmd].tLevels[user.iProfile] then
				return tCmds[cmd].tFunc(user,data), 1
			end
		end
	end
end

ToArrival = function(user,data)
	local data = string.sub(data,1,-2)
	local s,e,to,str = string.find(data, "^$To: (%S+) From: %S+ $%b<> (.*)")
	if chatrooms.items[to] then
		local tmp = chatrooms.items[to]
		local s,e,cmd,args = string.find(str, "^%!(%a+)%s*(.*)$")
		if cmd then
			cmd = string.lower(cmd)
			if cmd ~= Commands.MakeChat and tCmds[cmd] then 
				if tCmds[cmd].tLevels[user.iProfile] or (tmp.owner == user.sName) then
					return tCmds[cmd].tFunc(user,data,tmp,to,args), 1
				end
			end
		end
		if tmp.members[user.sName] then
			if tmp.members[user.sName] ~= 1 then 
				tmp.members[user.sName] = 1; tmp:chat("*** "..user.sName.." returned!", to);
			end
			tmp:chat(str, user.sName) 
		else
			local Messager = function()
				if tmp.locked == "off" then
					if tmp.autologin == "on" then
						tmp:chat(str, user.sName)
					else
						tmp.members[user.sName] = 1; tmp:chat("*** "..user.sName.." joined", to);
						tmp:chat(str, user.sName); chatrooms:save()
					end
				else
					user:SendPM(to, "*** Error: You're not a member here.")
				end
			end
			if next(tmp.groups) then
				if tSettings.tAllowed[user.iProfile] or tmp.groups[user.iProfile] == 1 then Messager() else user:SendPM(to, "*** Error: You're not a member here.") end
			else
				Messager()
			end
		end; 
		return 1
	end
end

NewUserConnected = function(user)
	if user.bUserCommand then
		for a,b in pairs(chatrooms.items) do
			if b.groups[user.iProfile] or b.members[user.sName] then
				for i,v in pairs(tCmds) do if(v.tLevels[user.iProfile]) then user:SendData(v.tRC) end end break
			end
		end
	end
end

OpConnected = NewUserConnected

tCmds = {

--[[	Commands Structure:
	[Command] = { 
		tFunc = function,
		tLevels = { [i] = 1 }, -- All i profiles stored here can access Command
		tRc = RightClick Command
	},
]]--

	[Commands.MakeChat] = { 
		tFunc = function(user, data) 
			local s,e,args = string.find(data, "^%b<>%s+%S+%s*(.*)") 
			local s,e,name,profiles = string.find(args,"(%S+)%s*(.*)") 
			if not s then 
				return user:SendData(frmHub:GetHubBotName(),"*** Syntax Error: Type !"..Commands.MakeChat.." <name> [groups]"), 1 
			elseif chatrooms.items[name] then	 
				return user:SendData(frmHub:GetHubBotName(),"*** Error: "..name.." is already a Chatroom."), 1 
			elseif GetItemByName(name) then 
				return user:SendData(frmHub:GetHubBotName(),"*** There is a user with that name."), 1 
			else 
				local tmp = chatrooms:new(tSettings.sTag..name, user.sName, tSettings.bAutoLogin, tSettings.bLocked, tSettings.bKey)
				string.gsub(profiles, "(%S+)", function(profile) 
					profile = tonumber(profile) or GetProfileIdx(profile) 
					if GetProfileName(profile) then tmp.groups[profile] = 1 end 
				end); tmp:chat("*** Hello", tSettings.sTag..name) 
				chatrooms:save() 
			end 
		end, 
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Make$<%[mynick]> !"..Commands.MakeChat.." %[line:Chatroom] %[line:Profile (optional)]&#124;"
	},
	[Commands.Away] = { 
		tFunc = function(user, data, tmp, to, args)
			tmp:chat("*** "..user.sName.." is away."..args, to)
			tmp.members[user.sName] = 0
		end,
		tLevels = {
			[-1] = 1,
			[0] = 1,
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Away$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Away.."&#124;"
	},
	[Commands.Leave] = { 
		tFunc = function(user, data, tmp, to, args)
			if tmp.autologin == "off" then
				tmp:chat("*** "..user.sName.." left. "..args, to)
				tmp.members[user.sName] = nil user:SendData("$Quit "..tmp.name)
				chatrooms:save()
			else
				user:SendPM(to, "*** Command disabled in AutoLogin mode!")
			end
		end,
		tLevels = {
			[-1] = 1,
			[0] = 1,
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Leave$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Leave.."&#124;"
	},
	[Commands.Members] = { 
		tFunc = function(user, data, tmp, to)
			if tmp.autologin == "on" then
				if next(tmp.groups)  then
					user:SendPM(to, "*** This room is reserved for specific profile(s). Use !"..Commands.Status.." for more details.")
				else
					user:SendPM(to, "*** This room is public.")
				end
			else
				local sRep = ":\r\n\t"..string.rep("=",20)
				local n, na, offline, away, on = 0, 0, "Offline"..sRep, "Away"..sRep, "Online"..sRep
				for nick, stat in pairs(tmp.members) do
					if not GetItemByName(nick) then
						offline = offline.."\r\n\t• "..nick
					elseif stat == 0 then
						away = away.."\r\n\t• "..nick
					else
						na = na + 1
						on = on.."\r\n\t• "..nick
					end; 
					n = n + 1
				end; 
				user:SendPM(to, "\r\n\r\n\t"..on.."\r\n\r\n\t"..offline.."\r\n\r\n\t"..away.."\r\n\r\n\t"..na.."/"..n.." active members.")
			end
		end,
		tLevels = {
			[-1] = 1,
			[0] = 1,
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Members$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Members.."&#124;" 
	},
	[Commands.Invite] = { 
		tFunc = function(user, data, tmp, to, args)
			string.gsub(args, "(%S+)", function(nick)
				if not tmp.members[nick] then
					tmp.members[nick] = 1 chatrooms:save()
					if GetItemByName(nick) then 
						GetItemByName(nick):SendData(tmp.key)
						tmp:chat("*** "..nick.." has been invited to the room. Type !leave to leave, and !members to see who's invited.", to)
					end
				end
			end);
		end,
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Invite$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Invite.." %[line:Nick]&#124;"
		
	},
	[Commands.Remove] = { 
		tFunc = function(user, data, tmp, to, args)
			string.gsub(args, "(%S+)", function(nick)
				if tmp.members[nick] and nick ~= tmp.owner then
					tmp:chat("*** "..nick.." has been removed from the room", to)
					tmp.members[nick] = nil; if GetItemByName(nick) then GetItemByName(nick):SendData("$Quit "..tmp.name) end
					chatrooms:save()
				end
			end);
		end,
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Remove$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Remove.." %[line:Nick]&#124;" 
	},
	[Commands.DelChat] = { 
		tFunc = function(user, data, tmp, to)
			tmp:chat("*** End of session.", to)
			tFunctions.MyINFO(tmp,"$Quit "..tmp.name)
			chatrooms.items[to] = nil; chatrooms:save()
		end,
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Delete$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.DelChat.." %[line:Chatroom]&#124;" 
	},
	[Commands.AutoLogin] = {
		tFunc = function(user, data, tmp, to, args)
			local tTable = {
				["on"] = { tFunc = function() tmp.autologin = "on" end, sStatus = "enabled" },
				["off"] = { tFunc = function() tmp.autologin = "off" end, sStatus = "disabled" },
			}
			local args = string.lower(args)
			if tTable[args] then
				tTable[args].tFunc(); chatrooms:save()
				user:SendPM(to, "*** Chatroom's AutoLogin Mode has been "..tTable[args].sStatus..".")
			else
				user:SendPM(to, "*** Syntax Error: Type !"..Commands.AutoLogin.." <on/off>")
			end
		end,
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Set AutoLogin$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.AutoLogin.." %[line:On/Off]&#124;"
	},
	[Commands.Key] = { 
		tFunc = function(user, data, tmp, to, args)
			local tTable = {
				["on"] = { sKey = "$OpList "..to.."$$", sStatus = "enabled" },
				["off"] = { sKey = "$MyINFO $ALL "..to.." ".." ".."$ $".." ".." $".." ".."$".."0".."$", sStatus = "disabled" },
			}
			local args = string.lower(args)
			if tTable[args] then
				tmp.key = tTable[args].sKey; chatrooms:save()
				user:SendPM(to, "*** Chatroom's Key has been "..tTable[args].sStatus..".")
			else
				user:SendPM(to, "*** Syntax Error: Type !"..Commands.Key.." <on/off>")
			end
		end,
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Set Key$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Key.." %[line:On/Off]&#124;"
	},
	[Commands.Lock] = { 
		tFunc = function(user, data, tmp, to, args)
			local tTable = { ["on"] = "enabled", ["off"] = "disabled" }
			local args = string.lower(args)
			if tTable[args] then
				tmp.locked = args
				user:SendPM(to, "*** Chatroom's Locked Mode has been "..tTable[args]..".")
			else
				user:SendPM(to, "*** Syntax Error: Type !"..Commands.Lock.." <on/off>")
			end
		end,
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Set Lock$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Lock.." %[line:On/Off]&#124;"
	},
	[Commands.Hide] = { 
		tFunc = function(user, data, tmp, to, args)
			if args then
				if string.lower(args) == "off" then
					tmp.hide = {}; chatrooms:save(); chatrooms:load()
					user:SendPM(to, "*** Hide Mode deactivated.")
				else
					local Exists = nil
					string.gsub(args, "(%S+)", function(profile) 
						if tmp.groups[profile] then user:SendPM(to, "*** This group is Hide immuned!") return 0 end
						if string.lower(profile) == "unreg" or profile == "-1" then tmp.hide[-1] = 1 Exists = 1 end
						profile = tonumber(profile) or GetProfileIdx(profile) 
						if GetProfileName(profile) then tmp.hide[profile] = 1 Exists = 1 end 
					end)
					if Exists then
						chatrooms:save(); chatrooms:load()
						user:SendPM(to, "*** Profile "..args.." has been added to "..to.."'s Profile Hiding List. Changes will take effect after a reconnect.")
					else
						user:SendPM(to, "*** Error: There isn't such profile.")
					end
				end
			else
				user:SendPM(to, "*** Syntax Error: Type !"..Commands.Hide.." [groups]")
			end
		end,
		tLevels = {
			[0] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Set Hide$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Hide.." %[line:Profiles (e.g. unreg/reg/vip]&#124;" 
	},
	[Commands.Status] = { 
		tFunc = function(user, data, tmp, to)
			local sRep = ":\r\n\t"..string.rep ("=", 20)
			local groups, hide = "Groups"..sRep, "Hide"..sRep
			for v,i in pairs(tmp.groups) do groups = groups.."\r\n\t• "..(GetProfileName(v) or "Unreg") end
			for v,i in pairs(tmp.hide) do hide = hide.."\r\n\t• "..(GetProfileName(v) or "Unreg") end
			user:SendPM(to, "\r\n\r\n\tRoom Name: "..to.."\r\n\r\n\tLock Status: "..tmp.locked.."\r\n\r\n\t"..groups.."\r\n\r\n\t"..hide)
		end,
		tLevels = { 
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		tRC = "$UserCommand 1 3 Chatrooms\\Members$$To: %[line:Chatroom] From: %[mynick] $<%[mynick]> !"..Commands.Status.."&#124;"
	},
}

chatrooms = {
	new = function(self, name, owner, autologin, locked, key)
		local tTable = {
			["on"] = "$OpList "..name.."$$",
			["off"] = "$MyINFO $ALL "..name.." ".." ".."$ $".." ".." $".." ".."$".."0".."$"
		}
		if tTable[key] then key = tTable[key] SendToAll(key) end
		local tmp = {
			name = name, owner = owner, autologin = autologin, key = key, hide = {},
			locked = locked, groups = {}, members = { [owner] = 1 }, chat = tFunctions.botchat
		};
		self.items[name] = tmp return tmp
	end,

	load = function(self) 
		if not loadfile(tSettings.fChat) then 
			local f = io.open(tSettings.fChat, "w+") f:write("return {\n"); f:write("}"); f:close()
		end
		self.items = dofile(tSettings.fChat)
		for sName,room in pairs(chatrooms.items) do
			room.chat = tFunctions.botchat; 
			tFunctions.MyINFO(room,room.key)
		end
	end, 

	unload = function(self)
		for sName,room in pairs(chatrooms.items) do
			tFunctions.MyINFO(room,"$Quit "..room.name)
		end
	end,

	save = function(self)
		local f = io.open(tSettings.fChat, "w+")
		f:write("return {\n");
		for name, tmp in pairs(self.items) do
			f:write(string.format("\t[%q] = {\n\t\tname = %q,\n\t\towner = %q,\n\t\tautologin = %q,\n\t\tlocked = %q,\n\t\tkey = %q,"..
			"\n\t\tgroups = {\n", name, tmp.name, tmp.owner, tmp.autologin,tmp.locked,tmp.key))
			for id, stat in pairs(tmp.groups) do f:write(string.format("\t\t\t[%d] = %d,\n", id, stat)) end; 
			f:write("\t\t},\n\t\tmembers = {\n")
			for nick, stat in pairs(tmp.members) do f:write(string.format("\t\t\t[%q] = %d,\n", nick, stat)) end;
			f:write("\t\t},\n\t\thide = {\n");
			for user, stat in pairs(tmp.hide) do f:write(string.format("\t\t\t[%d] = %d,\n", user, stat)) end;
			f:write("\t\t}\n\t},\n");
		end; 
		f:write("}"); f:close()
	end
}

tFunctions = {}

tFunctions.botchat = function(self, msg, from)
	tStatus = {
		["on"] = function() 
			for _,user in ipairs(frmHub:GetOnlineUsers())do 
				if next(self.groups) then
					if (self.groups[user.iProfile] or self.members[user.sName]) and not self.hide[user.iProfile] and user.sName ~= from and self.members[user.sName] ~= 0 then
						tStatus.tSend(user.sName)
					end
				else
					if user.sName ~= from and self.members[user.sName] ~= 0 and not self.hide[user.iProfile] then
						tStatus.tSend(user.sName)
					end
				end
			end
		end,
		["off"] = function()
			for nick,id in pairs(self.members) do
				if nick ~= from and id == 1 then tStatus.tSend(nick) end
			end
		end,
		tSend = function(user) SendToNick(user, "$To: "..user.." From: "..self.name.." $<"..from.."> "..msg) end,
	}
	if tStatus[self.autologin] then tStatus[self.autologin]() end
end

tFunctions.bMember = function(room,user)
	if (room.groups[user.iProfile]) or (room.owner == user.sName) or (room.members[user.sName]) or (not room.hide[user.iProfile]) then
		return 1
	end
end

tFunctions.MyINFO = function(room,data)
	local tOnline = frmHub:GetOnlineUsers()
	if tOnline then
		for i,v in ipairs(tOnline) do 
			if tFunctions.bMember(room,v) then v:SendData(data) end
		end
	end
end