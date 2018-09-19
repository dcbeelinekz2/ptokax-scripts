--[[

	Chatrooms v 4.14 - LUA 5.0/5.1

	By: jiten and Dessamator

	Based on: Chatrooms v3 by tezlo

	Changelog:

	- Changed: Profile permissions; (requested by GeceBekcisi)
	- Rewritten: Significant code and loops; code is more presentable;
	- Added: Status for each chatroom;
	- Changed: MyINFO handling to avoid flooding;
	- Changed: Other small mods
	- Changed: Updated to LUA 5.1 (3/25/2006)
	- Changed: DC away messages aren't sent anymore to rooms - reported by CrazyGuy;
	- Changed: Show members when autologin is enabled - requested by CrazyGuy;
	- Changed: tAllowed value structure - requested by CrazyGuy;
	- Fixed: RightClick commands - reported by osse; (5/23/2006)
	- Fixed: ToArrival locked permissions - reported by CrazyGuy; (5/24/2006)
	- Changed: MyINFO is sent on Op/UserConnected - reported by CrazyGuy;
	- Changed: string.lower comparison between connecting user and existing rooms (5/28/2006)
	- Changed: New save function;
	- Fixed: !members command when autologin is disabled - reported by CrazyGuy;
	- Added: Toggle reset away status on connect - requested by shamu (9/15/2006)
	- Fixed: !leave only removes rooms from userlist when hide mode is enabled;
	- Changed: Rightclick commands don't need rooms to be typed - just click on them in the userlist;
	- Added: !help and custom message on connect - requested by speedX;
	- Added: Leaviathan profiles support (9/30/2006)

]]--

tSettings = {

	-- Script Version
	iVersion = "4.14",

	-- RightClick Menu
	sMenu = "Chatrooms",

	-- Set your Chatrooms Tag here. If you don't want it, set it to: sTag = ""
	sTag = "",

	-- Chatrooms' Database
	fChat = "tChatrooms.tbl",

	-- Default AutoLogin Mode (on/off)
	bAutoLogin = "off",

	-- Default Chatroom Key  (on/off)
	bKey = "on",

	-- Default Locked Mode (on/off) - If on, only members/groups selected by owner are allowed.
	bLocked = "off",

	-- Reset away status on connect (on/off)
	bResetAwayOnConnect = "off",

	tAllowed = {
		-- Profiles allowed to join every chatroom (0 = off; 1 = on)
		[0] = 1, -- Master
		[1] = 1, -- Operator
		[4] = 1, -- Moderator
		[5] = 1, -- Founder
		[6] = 1, -- Owner
	}
}

-- Commands
Commands = {
	MakeChat = "mkchat", Away = "away", Leave = "leave", Members = "members", Invite = "invite", Status = "status",
	Remove = "remove", DelChat = "delchat", AutoLogin = "autologin", Hide = "hide", Lock = "lock", Key = "key", Help = "roomhelp"
}

Main = function()
	chatrooms:load()
end

OnExit = function()
	chatrooms:unload()
end

MyINFOArrival = function(user, data)
	for sName,room in pairs(chatrooms.items) do
		if string.lower(room.name) == string.lower(user.sName) then user:Disconnect() return 0 end
	end
end

ChatArrival = function(user,data)
	local data = string.sub(data,1,-2)
	local s,e,cmd = string.find(data,"%b<>%s+%!(%S+)")
	if cmd then
		cmd = string.lower(cmd)
		if cmd == Commands.MakeChat and tCommands[Commands.MakeChat] then
			if tCommands[cmd].tLevels[user.iProfile] then
				return tCommands[cmd].fFunction(user,data), 1
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
			if cmd ~= Commands.MakeChat and tCommands[cmd] then 
				if tCommands[cmd].tLevels[user.iProfile] or (tmp.owner == user.sName) then
					return tCommands[cmd].fFunction(user,data,tmp,to,args), 1
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
				if tmp.autologin == "on" then
					tmp:chat(str, user.sName)
				else
					tmp.members[user.sName] = 1; user:SendPM(to, "*** Type !"..Commands.Leave..
					" to leave, and !"..Commands.Members.." to see who's invited! For more details, use: !"..
					Commands.Help)
					tmp:chat("*** "..user.sName.." joined", to);
					tmp:chat(str, user.sName); chatrooms:save()
				end
			end
			if next(tmp.groups) then
				if (tSettings.tAllowed[user.iProfile] and tSettings.tAllowed[user.iProfile] == 1) or tmp.groups[user.iProfile] == 1 then
					Messager()
				else 
					user:SendPM(to, "*** Error: You're not a member here.")
				end
			else
				if tmp.locked == "off" then
					Messager()
				else
					user:SendPM(to, "*** Error: You're not a member here.")
				end
			end
		end; 
		return 1
	end
end

NewUserConnected = function(user)
	for sName,room in pairs(chatrooms.items) do
		if tFunctions.bMember(room,user) then user:SendData(room.key) end
		if tSettings.bResetAwayOnConnect == "on" then 
			if room.members[user.sName] and room.members[user.sName] ~= 1 then
				room.members[user.sName] = 1
			end
		end
	end
	if user.bUserCommand then
		if next(chatrooms.items) then
			for a,b in pairs(chatrooms.items) do
				if (b.groups[user.iProfile] or b.members[user.sName]) or (tSettings.tAllowed[user.iProfile] and tSettings.tAllowed[user.iProfile] == 1) then
					for i,v in pairs(tCommands) do
						if v.tLevels[user.iProfile] then
							user:SendData("$UserCommand 1 3 "..tSettings.sMenu.."\\"..v.tRC[1]..
							"$$To: %[nick] From: %[mynick] $<%[mynick]> !"..i..v.tRC[2].."&#124;")
						end
					end
					break
				end
			end
		elseif tCommands[Commands.MakeChat].tLevels[user.iProfile] then
			user:SendData("$UserCommand 1 3 "..tSettings.sMenu.."\\"..tCommands[Commands.MakeChat].tRC[1]..
			"$<%[mynick]> !"..Commands.MakeChat..tCommands[Commands.MakeChat].tRC[2].."&#124;")
		end
	end
end

OpConnected = NewUserConnected

tCommands = {

--[[	Commands Structure:
	[Command] = { 
		fFunction = function,
		tLevels = { [i] = 1 }, -- All i profiles stored here can access Command
		tRc = RightClick Command
	},
]]--

	[Commands.MakeChat] = { 
		fFunction = function(user, data) 
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
		tLevels = { [0] = 1, [5] = 1, [6] = 1, },
		tRC = { "Create Room", " %[line:Room] %[line:Profile (optional)]" }
	},
	[Commands.Away] = { 
		fFunction = function(user, data, tmp, to, args)
			tmp:chat("*** "..user.sName.." is away."..args, to)
			tmp.members[user.sName] = 0; chatrooms:save()
		end,
		tLevels = { [-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1, },
		tRC = { "Set yourself away", "" }
	},
	[Commands.Leave] = { 
		fFunction = function(user, data, tmp, to, args)
			if tmp.autologin == "off" then
				tmp:chat("*** "..user.sName.." left. "..args, to); tmp.members[user.sName] = nil 
				if tmp.hide[user.iProfile] then user:SendData("$Quit "..tmp.name) end; chatrooms:save()
			else
				user:SendPM(to, "*** Command disabled in AutoLogin mode!")
			end
		end,
		tLevels = { [-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1, },
		tRC = { "Leave room", "" }
	},
	[Commands.Members] = { 
		fFunction = function(user, data, tmp, to)
			local sType = ""
			if tmp.autologin == "on" then
				if next(tmp.groups)  then
					sType = sType.."This room is reserved for specific profile(s). Use !"..Commands.Status..
					" for more details."
				else
					sType = sType.."This room is public."
				end
			else
				sType = sType.."This room is private."
			end
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
			user:SendPM(to,"\r\n\r\n\t"..on.."\r\n\r\n\t"..offline.."\r\n\r\n\t"..away..
			"\r\n\r\n\t"..na.."/"..n.." active members.\r\n\tNote: "..sType)
		end,
		tLevels = { [-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1, },
		tRC = { "Show room members", "" }
	},
	[Commands.Invite] = { 
		fFunction = function(user, data, tmp, to, args)
			string.gsub(args, "(%S+)", function(nick)
				if not tmp.members[nick] then
					tmp.members[nick] = 1 chatrooms:save()
					if GetItemByName(nick) then 
						GetItemByName(nick):SendData(tmp.key)
						tmp:chat("*** "..nick.." has been invited to the room. Type !"..Commands.Leave..
						" to leave, and !"..Commands.Members.." to see who's invited.", to)
					end
				end
			end);
		end,
		tLevels = { [0] = 1, [5] = 1, [6] = 1, },
		tRC = { "Invite someone to room", " %[line:Nick]" }
	},
	[Commands.Remove] = { 
		fFunction = function(user, data, tmp, to, args)
			string.gsub(args, "(%S+)", function(nick)
				if tmp.members[nick] and nick ~= tmp.owner then
					tmp:chat("*** "..nick.." has been removed from the room", to)
					tmp.members[nick] = nil; if GetItemByName(nick) then GetItemByName(nick):SendData("$Quit "..tmp.name) end
				end
			end);
			chatrooms:save()
		end,
		tLevels = { [0] = 1, [5] = 1, [6] = 1, },
		tRC = { "Remove someone from room", "%[line:Nick]" }
	},
	[Commands.DelChat] = { 
		fFunction = function(user, data, tmp, to)
			tmp:chat("*** End of session.", to)
			tFunctions.MyINFO(tmp,"$Quit "..tmp.name)
			chatrooms.items[to] = nil; chatrooms:save()
		end,
		tLevels = { [0] = 1, [5] = 1, [6] = 1 },
		tRC = { "Delete room", "" }
	},
	[Commands.AutoLogin] = {
		fFunction = function(user, data, tmp, to, args)
			local tTable = {
				["on"] = { fFunction = function() tmp.autologin = "on" end, sStatus = "enabled" },
				["off"] = { fFunction = function() tmp.autologin = "off" end, sStatus = "disabled" },
			}
			local args = string.lower(args)
			if tTable[args] then
				tTable[args].fFunction(); chatrooms:save()
				user:SendPM(to, "*** Chatroom's AutoLogin Mode has been "..tTable[args].sStatus..".")
			else
				user:SendPM(to, "*** Syntax Error: Type !"..Commands.AutoLogin.." <on/off>")
			end
		end,
		tLevels = { [0] = 1, [5] = 1, [6] = 1, },
		tRC = { "Enable/disable autologin mode", " %[line:on/off]" }
	},
	[Commands.Key] = { 
		fFunction = function(user, data, tmp, to, args)
			local tTable = {
				["on"] = { sKey = "$OpList "..to.."$$", sStatus = "enabled" },
				["off"] = { sKey = "$MyINFO $ALL "..to.." $ $$$0$", sStatus = "disabled" },
			}
			local args = string.lower(args)
			if tTable[args] then
				tmp.key = tTable[args].sKey; chatrooms:save()
				user:SendPM(to, "*** Chatroom's Key has been "..tTable[args].sStatus..". Please restart your scripts!")
			else
				user:SendPM(to, "*** Syntax Error: Type !"..Commands.Key.." <on/off>")
			end
		end,
		tLevels = { [0] = 1, [5] = 1, [6] = 1, },
		tRC = { "Enable/disable key", " %[line:on/off]" }
	},
	[Commands.Lock] = { 
		fFunction = function(user, data, tmp, to, args)
			local tTable = { ["on"] = "enabled", ["off"] = "disabled" }
			local args = string.lower(args)
			if tTable[args] then
				tmp.locked = args; chatrooms:save()
				user:SendPM(to, "*** Chatroom's Locked Mode has been "..tTable[args]..".")
			else
				user:SendPM(to, "*** Syntax Error: Type !"..Commands.Lock.." <on/off>")
			end
		end,
		tLevels = { [0] = 1, [5] = 1, [6] = 1, },
		tRC = { "Enable/disable lock mode", " %[line:on/off]" }
	},
	[Commands.Hide] = { 
		fFunction = function(user, data, tmp, to, args)
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
		tLevels = { [0] = 1, [5] = 1, [6] = 1, },
		tRC = { "Hide room from profiles", " %[line:Profiles (e.g. unreg/reg/vip]" }
	},
	[Commands.Status] = { 
		fFunction = function(user, data, tmp, to)
			local sRep = ":\r\n\t"..string.rep ("=", 20)
			local groups, hide = "Groups"..sRep, "Hide"..sRep
			for v,i in pairs(tmp.groups) do groups = groups.."\r\n\t• "..(GetProfileName(v) or "Unreg") end
			for v,i in pairs(tmp.hide) do hide = hide.."\r\n\t• "..(GetProfileName(v) or "Unreg") end
			user:SendPM(to, "\r\n\r\n\tRoom Name: "..to.."\r\n\r\n\tLock Status: "..tmp.locked.."\r\n\r\n\t"..groups.."\r\n\r\n\t"..hide)
		end,
		tLevels = { [0] = 1, [1] = 1, [4] = 1, [5] = 1, [6] = 1, },
		tRC = { "Show room's details", "" }
	},
	[Commands.Help] = { 
		fFunction = function(user, data, tmp, to)
			-- Header
			local sMsg = "\r\n\r\n\t\t\t"..string.rep("=", 75).."\r\n"..string.rep("\t", 6).."Chatrooms v."..
			tSettings.iVersion.." by jiten; Based on tezlo's\t\t\t\r\n\t\t\t"..string.rep("-", 150)..
			"\r\n\t\t\tAvailable Commands:\r\n\r\n"
			-- Loop through table
			for i, v in pairs(tCommands) do
				-- If user has permission
				if v.tLevels[user.iProfile] then
					-- Populate
					sMsg = sMsg.."\t\t\t!"..i.."\t\t"..v.tRC[1].."\r\n"
				end
			end
			-- Send
			user:SendPM(to, sMsg.."\t\t\t"..string.rep("-", 150));
		end,
		tLevels = { [-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1, },
		tRC = { "Help menu", "" }
	},
}

chatrooms = {
	new = function(self, name, owner, autologin, locked, key)
		local tTable = {
			["on"] = "$OpList "..name.."$$",
			["off"] = "$MyINFO $ALL "..name.." $ $$$0$"
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
		Serialize = function(tTable, sTableName, hFile, sTab)
			sTab = sTab or "";
			hFile:write(sTab..sTableName.." {\n");
			for key,value in pairs(tTable) do
				if (type(value) ~= "function") then
					local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
					if(type(value) == "table") then
						Serialize(value, sKey.." =", hFile, sTab.."\t");
					else
						local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
						hFile:write(sTab.."\t"..sKey.." = "..sValue);
					end
					hFile:write(",\n");
				end
			end
			hFile:write(sTab.."}");
		end
		local hFile = io.open(tSettings.fChat, "w+"); Serialize(self.items, "return", hFile); hFile:close() 
	end
}

tFunctions = {}

tFunctions.botchat = function(self, msg, from)
	tStatus = {
		on = function() 
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
		off = function()
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