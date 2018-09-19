--[[

	RegCleaner 1.01 - LUA 5.0/5.1 by jiten (10/2/2006)
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	Based on: RegCleaner by plop et al

	DESCRIPTION:
	¯¯¯¯¯¯¯¯¯¯¯¯
	Auto/manual registered user cleaner if user hasn't been in the hub for x weeks

	CHANGELOG:
	¯¯¯¯¯¯¯¯¯¯
	Stripped: Code from artificial insanety bot;
	Updated: To LUA 5 by Pothead;
	Updated: to PtokaX 16.09 by [_XStaTiC_]  Removed the seen part sorry :) i don't use it :);
	Touched: by Herodes (optimisation tsunami, and added !seen again);
		Thx to god for giving TimeTraveler the ability to discover those bugs.. notice the plural? :)
	Changed: To allow different profiles to have a different cleaning time and updated to lua 5.1 by Pothead;
	Changed: Check for & create logs folder if non-existent, added process time for nightshadow by Mutor;
	Corrected: Few ancient spelling errors;

	Rewritten: Almost whole code structure by jiten (9/13/2006)
	Changed: Table structure - lowered nicks to face case-sensitive stuff - requested by speedX;
	Fixed: User's table entry was deleted on connect (10/2/2006)

]]--

tSettings = {
	-- Bot Name
	sBot = frmHub:GetHubBotName(),

	-- Users DB
	fUser = "logs/tUser.tbl",
	-- Immune DB
	fImmune = "logs/tImmune.tbl",

	-- RightClick Menu
	sMenu = "RegCleaner",

	-- Toggle automatic cleaner [true = on; false = off]
	bAuto = true,

	-- Profiles checked and cleaning time (in weeks)
	tProfiles = { [2] = 26, [3] = 2 },
}

tUsers, tImmune = {}, {}

Main = function()
	local f = io.open(tSettings.fUser, "r")
	-- File exists
	if f then
		-- Close
		f:close()
	else
		-- Folder doesn't exist
		if os.execute("dir logs") ~= 0 then
			-- Create and add content
			os.execute("md logs"); tCommands["cleanusers"].fFunction()
		end
	end
	-- Register BotName if not registered
	if tSettings.sBot ~= frmHub:GetHubBotName() then frmHub:RegBot(tSettings.sBot) end
	-- Load file content
	LoadFromFile(tUsers, tSettings.fUser); LoadFromFile(tImmune, tSettings.fImmune)
	-- Set date
	iDay = os.date("%x")
	-- garbagecollect method (Based on Mutor's)
	gc = nil; if string.find(_VERSION, "Lua 5.1") then gc = "collect" end
end

ChatArrival = function(user, data)
	-- Auto cleaner enabled
	if tSettings.bAuto then
		-- Date different than today's
		if iDay ~= os.date("%x") then
			-- Set new and launch cleaner
			iDay = os.date("%x"); tCommands["cleanusers"].fFunction()
		end
	end
	-- Define vars
	local _,_, to = string.find(data, "^$To:%s(%S+)%s+From:")
	local _,_, msg = string.find(data, "%b<>%s(.*)|$") 
	-- Message sent to Bot or in Main
	if (to and to == tSettings.sBot) or not to then
		-- Parse command
		local _,_, cmd = string.find(msg, "^%p(%S+)")
		-- Exists
		if cmd and tCommands[string.lower(cmd)] then
			cmd, user.SendMessage = string.lower(cmd), user.SendData
			-- PM
			if to == tSettings.sBot then user.SendMessage = user.SendPM end
			-- If user has permission
			if tCommands[cmd].tLevels[user.iProfile] and tCommands[cmd].tLevels[user.iProfile] == 1 then
				return tCommands[cmd].fFunction(user, msg), 1
			else
				return user:SendMessage(tSettings.sBot, "*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

ToArrival = ChatArrival

NewUserConnected = function(user)
	-- Supports UserCommands
	if user.bUserCommand then
		-- For each entry in table
		for i, v in pairs(tCommands) do
			-- If member
			if v.tLevels[user.iProfile] then
				-- For each type
				for n in ipairs(v.tRC) do
					-- Send
					user:SendData("$UserCommand 1 3 "..tSettings.sMenu.."\\"..v.tRC[n][1]..
					"$<%[mynick]> !"..i..v.tRC[n][2].."&#124;")
				end
			end
		end
	end
	-- User in DB
	if tUsers[string.lower(user.sName)] then
		-- Delete and save
		tUsers[string.lower(user.sName)] = nil; SaveToFile(tUsers, tSettings.fUser)
	end
end

OpConnected = NewUserConnected

UserDisconnected = function(user)
	-- Checked profile
	if tSettings.tProfiles[user.iProfile] then
		-- Replace and save
		tUsers[string.lower(user.sName)] = os.time(os.date("!*t")); SaveToFile(tUsers, tSettings.fUser)
	end
end

OpDisconnected = UserDisconnected

tCommands = {
	noclean = {
		fFunction = function(user, data)
			-- Parse vars
			local _,_, type, nick = string.find(data, "^%S+%s(%S+)%s(%S+)$")
			-- Exist
			if type and nick then
				-- Regged nick
				if frmHub:isNickRegged(nick) then
					local tTable = {
						add = function()
							-- Nick is immune
							if tImmune[string.lower(nick)] then
								user:SendMessage(tSettings.sBot , "*** Error: "..nick..
								" is already in the Immune list!")
							else
								-- Set, report and save
								tImmune[string.lower(nick)] = 1
								user:SendMessage(tSettings.sBot, "*** "..nick.." was successfully "..
								"added to the Immune list and won't be cleaned!"); 
								SaveToFile(tImmune, tSettings.fImmune)
							end
						end,
						remove = function()
							-- Nick is immune
							if tImmune[string.lower(nick)] then
								-- Remove, report and save
								tImmune[string.lower(nick)] = nil
								user:SendMessage(tSettings.sBot, "*** "..nick.." was successfully "..
								"removed from the Immune list!"); SaveToFile(tImmune, tSettings.fImmune)
							else
								user:SendMessage(tSettings.sBot, "*** Error: "..nick.." isn't in the Immune list!")
							end
						end
					}
					if tTable[string.lower(type)] then
						-- Process if exists
						tTable[string.lower(type)]()
					else
						user:SendMessage(tSettings.sBot, "*** Syntax Error: Type !noclean <add/remove> <nick>")
					end
				else
					user:SendMessage(tSettings.sBot, "*** Error: "..nick.." isn't a Registered user!")
				end
			else
				user:SendMessage(tSettings.sBot, "*** Syntax Error: Type !noclean <add/remove> <nick>")
			end
		end,
		tLevels = {
			[-1] = 0, [0] = 1, [1] = 1, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 1,
		},
		tRC = { { "Add Immune", " add %[line:Nick]" }, { "Del Immune", " remove %[line:Nick]" } }
	},
	seen = {
		fFunction = function(user, data)
			-- Parse var
			local _,_, nick = string.find(data, "^%S+%s(%S+)$")
			-- Exists
			if nick then
				-- User's nick
				if string.lower(nick) == string.lower(user.sName) then
					user:SendMessage(tSettings.sBot, "*** Aren't you online?")
				else
					-- If the other user is online
					if GetItemByName(nick) then
						user:SendMessage(tSettings.sBot, "*** Please open those eyes of yours! "..nick.." is online!")
					else
						-- If in DB
						if tUsers[string.lower(nick)] then
							user:SendMessage(tSettings.sBot, "*** "..nick.." was last seen on: "..os.date("%x %X", tUsers[string.lower(nick)]))
						else
							user:SendMessage(tSettings.sBot, "*** How should I know when "..nick.." was last seen?")
						end
					end
				end
			else
				user:SendMessage(tSettings.sBot, "*** Syntax Error: Type !seen <nick>")
			end
		end,
		tLevels = { 
			[-1] = 0, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [6] = 1,
		},
		tRC = { { "Show when an user was last online", " %[line:Nick]" } }
	},
	cleanusers = {
		fFunction = function()
			-- Set vars
			local iStart, iTotal = os.clock(), 0
			local sMsg = "\r\n\r\n*** The cleaner has just ran!\r\n"
			-- For each profile to be checked
			for prof, v in pairs(tSettings.tProfiles) do
				local iChecked, iCleaned = 0, 0
				-- Build message
				sMsg = sMsg.."\r\nEvery "..GetProfileName(prof).." user who hasn't been in the hub for "..
					tSettings.tProfiles[prof].." weeks will be deleted!"
				-- For each user by profile
				for i, nick in ipairs(GetUsersByProfile(GetProfileName(prof))) do
					iChecked = iChecked + 1
					-- If in DB
					if tUsers[string.lower(nick)] then
						-- If not immune
						if not tImmune[string.lower(nick)] then
							-- Hasn't logged in for more than specified weeks
							if os.time(os.date("!*t")) > tUsers[string.lower(nick)] + tSettings.tProfiles[prof]*7*24*60*60 then
								-- Remove from table and delete account
								tUsers[string.lower(nick)] = nil; DelRegUser(nick); 
								iCleaned = iCleaned + 1
							end
						end
					else
						-- Add to table
						tUsers[string.lower(nick)] = os.time(os.date("!*t"))
					end
					-- Collect garbage
					collectgarbage(gc); io.flush()
				end
				-- Keep building message
				sMsg = sMsg.." "..iChecked.." users were processed, "..iCleaned.." of them were deleted!"
				iTotal = iTotal + iChecked
			end
			sMsg = sMsg.. "\r\n\r\nThis cleanup took: "..string.format("%8.6f seconds", os.difftime(os.clock(), iStart))..
			"\r\n\r\n(Please contact the OP's if your going to be away for a period longer than the one mentioned)\r\n"
			-- Send and save
			SendToAll(tSettings.sBot, sMsg); SaveToFile(tUsers, tSettings.fUser)
		end,
		tLevels = { 
			[-1] = 0, [0] = 1, [1] = 1, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 1,
		},
		tRC = { { "Launch cleaner", "" } }
	},
	shownoclean = {
		fFunction = function(user, data) Show(user) end,
		tLevels = { 
			[-1] = 0, [0] = 1, [1] = 1, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 1,
		},
		tRC = { { "Show Immune users", "" } }
	},
	showusers = {
		fFunction = function(user, data) Show(user, data) end,
		tLevels = { 
			[-1] = 0, [0] = 1, [1] = 1, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 1,
		},
		tRC = { { "Show users with a specific profile", " %[line:Profile Name]" } }
	},
}

Show = function(user, data)
	local tTable, msg
	if data then
		-- Parse profile
		local _,_, iProfile = string.find(data, "^%S+%s+(%S+)$")
		-- Stop if doesn't exist
		if not iProfile then return user:SendMessage(tSettings.sBot, "*** Syntax Error: Type !showusers <Profile Name>"), 0 end
		-- Return vars
		tTable, msg = GetUsersByProfile(iProfile), "registered users with Profile ("..iProfile..")"
	else
		-- Build custom table
		local r = {}; for i, v in pairs(tImmune) do table.insert(r, i) end; tTable, msg = r, "Immune users"
	end
	-- Table isn't empty
	if next(tTable) then
		-- Build content
		local sMsg = "\r\n\r\n\tHere are the "..msg..":\r\n\t"..string.rep("=", 40).."\r\n"
		-- Loop through it
		for i, nick in pairs(tTable) do sMsg = sMsg.."\t• "..nick.."\r\n"; end
		user:SendMessage(tSettings.sBot, sMsg)
	else
		user:SendMessage(tSettings.sBot, "*** Error: The database is empty!")
	end
end

LoadFromFile = function(tTable, sFile)
	local f = io.open(sFile, "r")
	-- Exists
	if f then
		-- For each line
		for line in f:lines() do
			-- Parse vars and add to table
			local _,_, i, v = string.find(line, "(.+)$(.+)"); if i then tTable[i] = v end
		end
		f:close()
	end
end

SaveToFile = function(tTable, sFile)
	local f = io.open(sFile, "w+")
	-- Write while looping
	for i, v in pairs(tTable) do f:write(i.."$"..v.."\n") end; f:close()
end