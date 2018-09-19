--[[

	Vote Bot 1.021 - LUA 5.0/5.1 by jiten (7/11/2006)
	ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ

	DESCRIPTION:
	ŻŻŻŻŻŻŻŻŻŻŻŻ
	- Create polls;
	- Add custom options to polls;
	- Vote on a specific pole [a vote per IP and per poll];
	- Change a poll's status [open/close];
	- Show all polls;
	- Show poll's votes;
	- Delete polls.

	CHANGELOG:
	ŻŻŻŻŻŻŻŻŻŻ
	Added: Separator for each option added - requested by TT;
	Added: Some SendToAll's to notify all users about votes and new polls;
	Added: Send all available polls' ID, status and name on connect;
	Added: Option to set bot's description and email; 
	Fixed: Bug when deleting polls - reported by UwV;
	Fixed: Voting only parsed option' first string - reported by TT (7/10/2006); 
	Added: Option to show all polls with its content - requested by TT; 
	Added: Poll options are shown in the Options' Box - requested by (uk)jay;
	Changed: Summary of available polls replaced with all votes per poll on Connect (7/11/2006)
	Fixed: UserCommands weren't fully sent when there were no options in a poll - reported by TT;
	Added: Report when options added didn't contain the separator;
	Added: Vote Ratio per poll - idea by TTB (7/16/2006)

]]--

tVote = {
	-- Bot Name
	sName = "Vote-Bot",

	-- Script Version
	iVersion = "1.021",

	-- Bot Description
	sDescription = "",
	-- Bot Email
	sEmail = "",

	-- RightClick Menu
	sMenu = "Vote Bot",

	-- Separator for each option when using sAddOption. Default one is "
	-- Example: !addoption "yes" "no" "other"
	sSeparator = "\"",

	-- Send all available poll's ID, status and name on connect (true = on; false = off)
	bSendOnConnect = false,
		-- Profiles to which all available Poll's summary is sent (0 = disabled; 1 = enabled)
		tSendProfiles = {
			[-1] = 1,	-- Unreg Users
			[0] = 0,	-- Masters
			[1] = 0,	-- Operators
			[2] = 1,	-- VIPs
			[3] = 1,	-- Regs
			[4] = 0,	-- Moderators
			[5] = 0,	-- NetFounders
		},

	-- Vote Bot DB
	fVote = "tVote.tbl",
	-- Commands
	sHelp = "votehelp", sRemove = "removepoll", sAddPoll = "addpoll", 
	sAddOption = "addoption", sVote = "vote", sSet = "setpoll", sShow = "showpoll"
}

tPoll = {}

Main = function()
	-- Register BotName
	frmHub:RegBot(tVote.sName, 1, tVote.sDescription, tVote.sEmail)
	-- Load DB content
	if loadfile(tVote.fVote) then dofile(tVote.fVote) end
end

ChatArrival = function(user, data)
	local _,_, to = string.find(data,"^$To:%s(%S+)%s+From:")
	local _,_, msg = string.find(data,"%b<>%s(.*)|$") 
	-- Message sent to Vote Bot or in Main
	if (to and to == tVote.sName) or not to then
		-- Parse command
		local _,_, cmd = string.find(msg, "^%p(%S+)")
		-- Exists
		if cmd and tCommands[string.lower(cmd)] then
			cmd, user.SendMessage = string.lower(cmd), user.SendData
			-- PM
			if to == tVote.sName then user.SendMessage = user.SendPM end
			-- If user has permission
			if tCommands[cmd].tLevels[user.iProfile] then
				return tCommands[cmd].fFunction(user, msg), 1
			else
				return user:SendMessage(tVote.sName, "*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

ToArrival = ChatArrival

NewUserConnected = function(user)
	-- Supports UserCommands
	if user.bUserCommand then
		-- Build user-specific temp RC table
		local tTable = {};
		-- For each entry in table
		for i, v in pairs(tCommands) do
			-- If member
			if v.tLevels[user.iProfile] then
				-- For each user command
				for a, b in ipairs(v.tRC) do
					-- Extend Menu
					if v.bExtend then
						-- For each poll
						for iIndex, tValue in pairs(tPoll) do
							local sMsg = ""
							-- For each option
							for sOption in pairs(tValue.tVotes) do
								-- Build
								sMsg = sMsg..sOption.."; "
							end
							-- Insert to temp table
							table.insert(tTable, { i, b[1].."\\"..tValue.sPoll, " "..iIndex..
							string.gsub(b[2], "{}", sMsg) })
						end
					else
						-- Insert to temptable
						table.insert(tTable, { i, b[1], b[2] } )
					end
					-- Collect garbage
					collectgarbage(); io.flush();
				end
			end
		end
		-- Send RC
		for i in ipairs(tTable) do 
			-- Send
			user:SendData("$UserCommand 1 3 "..tVote.sMenu.."\\"..tTable[i][2].."$<%[mynick]> !"..
			tTable[i][1]..tTable[i][3].."&#124;")
		end;
	end
	-- Send OnConnect
	if tVote.bSendOnConnect then
		-- User has permission
		if tVote.tSendProfiles[user.iProfile] and tVote.tSendProfiles[user.iProfile] == 1 then
			-- If send mode doesn't exist
			user.SendMessage = (user.SendMessage or user.SendPM)
			-- Send
			tCommands[tVote.sShow].fFunction(user, "show all")
		end
	end
end

OpConnected = NewUserConnected

tCommands = {
	[tVote.sHelp] = {
		fFunction = function(user)
			-- Header
			local sMsg = "\r\n\r\n\t\t"..string.rep("=", 95).."\r\n"..string.rep("\t", 7).."Vote Bot v."..
			tVote.iVersion.." by jiten\t\t\t\r\n\t\t"..string.rep("-",190).."\r\n\t\t\tAvailable Commands:".."\r\n\r\n"
			-- Loop through table
			for i,v in pairs(tCommands) do
				-- If user has permission
				if v.tLevels[user.iProfile] then
					-- Populate
					sMsg = sMsg.."\t\t\t!"..i.."\t\t"..v.sDesc.."\r\n"
				end
			end
			-- Send
			user:SendMessage(tVote.sName, sMsg.."\t\t"..string.rep("-",190));
		end,
		tLevels = { [-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, },
		sDesc = "\tDisplays this help menu",
		tRC = { { "Help", "" } },
	},
	[tVote.sAddPoll] = {
		fFunction = function(user, data)
			local _,_, poll = string.find(data, "^%S+%s(.+)$") 
			-- Poll found
			if poll then
				local bExists = nil
				-- For each Poll
				for i, v in ipairs(tPoll) do
					-- Found
					if string.lower(v.sPoll) == string.lower(poll) then bExists = 1 end
				end
				-- Exists
				if bExists then
					user:SendMessage(tVote.sName, "*** Error: There is already a Poll named: "..poll)
				else
					-- Add to Database
					table.insert(tPoll, { sPoll = poll, bActive = 1, tVotes = {} })
					-- Save
					SaveToFile(tVote.fVote, tPoll, "tPoll")
					-- Report
					SendToAll(tVote.sName, "*** '"..poll.."' was successfully added to Polls by "..user.sName.."!")
				end
			else
				user:SendMessage(tVote.sName, "*** Syntax Error: Type !"..tVote.sAddPoll.." <Poll>")
			end
		end,
		tLevels = { [0] = 1, [1] = 1, [4] = 1, [5] = 1, },
		sDesc = "\tAdd a poll to the database",
		tRC = { { "Add a poll", " %[line:Poll]" } },
	},
	[tVote.sSet] = {
		fFunction = function(user, data)
			-- Parse ID
			local _,_, i, arg = string.find(data, "^%S+%s(%d+)%s(%S+)$") 
			-- If digit
			if i and tonumber(i) and arg then
				i = tonumber(i)
				-- DB contains it
				if tPoll[i] then
					local tTable = { close = { 0, "closed" }, open = { 1, "opened" } }
					if tTable[string.lower(arg)] then
						-- Set poll's status and save
						tPoll[i].bActive = tTable[string.lower(arg)][1]; SaveToFile(tVote.fVote, tPoll, "tPoll")
					end
					-- Report
					user:SendMessage(tVote.sName, "*** Poll: '"..tPoll[i].sPoll.."' has been "..tTable[string.lower(arg)][2].."!")
				else
					user:SendMessage(tVote.sName, "*** Error: There isn't a Poll with that ID!")
				end
			else
				user:SendMessage(tVote.sName, "*** Syntax Error: Type !"..tVote.sSet.." <Poll ID> <open/close>")
			end
		end,
		sDesc = "\tChange a poll's status [open/close]",
		tLevels = { [0] = 1, [1] = 1, [4] = 1, [5] = 1, },
		tRC = { { "Set a poll's status", " %[line:Poll ID] %[line:<open/close>]" } },
	},
	[tVote.sShow] = {
		fFunction = function(user, data)
			-- Parse ID
			local _,_, i = string.find(data, "^%S+%s(%S+)$") 
			-- If i
			if i then
				-- If digit
				if tonumber(i) then
					i = tonumber(i)
					-- DB contains it
					if tPoll[i] then
						-- If table isn't empty
						if next(tPoll[i].tVotes) then
							-- Send
							user:SendMessage(tVote.sName, PollContent(i, i))
						else
							user:SendMessage(tVote.sName, "*** Error: Poll '"..tPoll[i].sPoll..
							"' is empty!")
						end
					else
						user:SendMessage(tVote.sName, "*** Error: There isn't a Poll with that ID!")
					end
				-- Show Polls and content
				elseif string.lower(i) == "all" then
					user:SendMessage(tVote.sName, PollContent(1, table.getn(tPoll)))
				else
					user:SendMessage(tVote.sName, "*** Syntax Error: Type !"..tVote.sShow.." <Poll ID/all>; !"..tVote.sShow)
				end
			else
				-- Polls exist
				if next(tPoll) then
					-- Header
					local sMsg, tTable = "\r\n\r\n\t"..string.rep("=", 80).."\r\n\tID.\tStatus:\t\tPoll\r\n\t"..
					string.rep("-", 160).."\r\n", { [0] = "*closed*", [1] = "*open*" }
					-- List all polls
					for i, v in ipairs(tPoll) do
						sMsg = sMsg.."\t"..i..".\t"..tTable[v.bActive].."\t\t"..v.sPoll.."\r\n"
					end
					user:SendMessage(tVote.sName, sMsg)
				else
					user:SendMessage(tVote.sName, "*** Error: There are no polls!")
				end
			end
		end,
		tLevels = { [-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, },
		sDesc = "\tShow all available polls; Show a poll's votes; Show all polls' content",
		tRC = { { "Show all polls", "" }, { "Show a poll's votes", " %[line:Poll ID]" }, 
			{ "Show all polls' content", " all" } },
	},
	[tVote.sVote] = {
		fFunction = function(user, data)
			-- Parse ID and option
			local _,_, i, arg = string.find(data,"^%S+%s(%d+)%s(.+)$") 
			-- Exist
			if i and arg then
				local i = tonumber(i)
				-- ID exists
				if tPoll[i] then
					-- Active poll
					if tPoll[i].bActive == 1 then
						-- Option exists
						if tPoll[i].tVotes[string.lower(arg)] then
							local bExists = nil
							-- If IP has voted
							for i, v in pairs(tPoll[i].tVotes) do
								for a, b in ipairs(v) do
									if user.sIP == b then bExists = 1 break end
								end
							end
							-- Voted
							if bExists then
								user:SendMessage(tVote.sName,"*** You have already voted on Poll: '"..
								tPoll[i].sPoll.."'!")
							else
								local tmp = tPoll[i].tVotes[string.lower(arg)]
								-- Add, save and report vote
								table.insert(tmp, user.sIP); SaveToFile(tVote.fVote, tPoll, "tPoll")
								user:SendMessage(tVote.sName,"*** You have successfully voted for '"..
								arg.."' on Poll: '"..tPoll[i].sPoll.."'!")
								SendToAll(tVote.sName,"*** "..user.sName.." voted for '"..arg..
								"' on Poll: '"..tPoll[i].sPoll.."'!")
							end
						else
							user:SendMessage(tVote.sName, "*** Error: Poll '"..tPoll[i].sPoll..
							"' doesn't have the option '"..arg.."'!")
						end
					else
						user:SendMessage(tVote.sName, "*** Error: Poll '"..tPoll[i].sPoll..
						"' is closed for voting!")
					end
				else
					user:SendMessage(tVote.sName, "*** Error: There isn't a Poll with that ID!")
				end
			else
				user:SendMessage(tVote.sName, "*** Syntax Error: Type !"..tVote.sVote.." <Poll ID> <option>")
			end
		end,
		tLevels = { [-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, },
		sDesc = "\tVote on a poll [by ID]",
		tRC = { { "Vote on a poll", " %[line:Options: {}]" } },
		bExtend = true
	},
	[tVote.sRemove] = {
		fFunction = function(user, data)
			local _,_, i = string.find(data, "^%S+%s(%d+)$") 
			-- If digit
			if i and tonumber(i) then
				i = tonumber(i)
				-- DB contains it
				if tPoll[i] then
					-- Delete, save and report
					user:SendMessage(tVote.sName, "*** Poll: '"..tPoll[i].sPoll.."' has been deleted from Database!")
					table.remove(tPoll, i); SaveToFile(tVote.fVote, tPoll, "tPoll")
				else
					user:SendMessage(tVote.sName, "*** Error: There isn't a Poll with that ID!")
				end
			else
				user:SendMessage(tVote.sName, "*** Syntax Error: Type !"..tVote.sRemove.." <Poll ID>")
			end
		end,
		tLevels = { [0] = 1, [1] = 1, [4] = 1, [5] = 1, },
		sDesc = "Delete an existing poll",
		tRC = { { "Delete a Poll", " %[line:Poll ID]" } },
	},
	[tVote.sAddOption] = {
		fFunction = function(user, data)
			-- Parse ID and option(s)
			local _,_, i, args = string.find(data,"^%S+%s(%d+)%s(.+)$") 
			-- Exist
			if i and args then
				local i = tonumber(i)
				-- ID exists in DB
				if tPoll[i] then
					local bFound = nil
					-- Check each option
					string.gsub(args, tVote.sSeparator.."(.-)"..tVote.sSeparator, function(arg)
						bFound = 1
						-- Existing option
						if tPoll[i].tVotes[string.lower(arg)] then
							user:SendMessage(tVote.sName, "*** Error: Poll '"..tPoll[i].sPoll..
							"' already has the option '"..arg.."'!")
						else
							-- Add, save and report option
							tPoll[i].tVotes[string.lower(arg)] = {}; SaveToFile(tVote.fVote, tPoll, "tPoll")
							user:SendMessage(tVote.sName, "*** Option '"..arg.."' has been "..
							"successfully added to Poll '"..tPoll[i].sPoll.."'")
						end
					end)
					if not bFound then
						user:SendMessage(tVote.sName, "*** Error: No option has been added! Did you use the separator? "..
						"Current is: "..tVote.sSeparator)
					end
				else
					user:SendMessage(tVote.sName, "*** Error: There isn't a Poll with that ID!")
				end
			else
				user:SendMessage(tVote.sName, "*** Syntax Error: Type !"..tVote.sAddOption.." <Poll ID> [option1 option2 ... optionN]")
			end
		end,
		tLevels = { [0] = 1, [1] = 1, [4] = 1, [5] = 1, },
		sDesc = "Add option(s) to a Poll",
		tRC = { { "Add Option to a Poll", " %[line:Poll ID] %[line:"..tVote.sSeparator.."Option"..tVote.sSeparator.."]" } },
	},
}

PollContent = function(iBegin, iEnd)
	local tTable, sMsg = { [0] = "closed", [1] = "open" }, ""
	-- For each poll
	for i = iBegin, iEnd, 1 do
		if tPoll[i] then
			local tmp = tPoll[i]
			-- Header
			sMsg = sMsg.."\r\n\r\n\tPoll "..i..". "..string.upper(string.sub(tmp.sPoll, 1, 1))..
			string.sub(tmp.sPoll, 2, string.len(tmp.sPoll)).." ["..tTable[tmp.bActive].."]\r\n\t"..string.rep("=", 40)..
			"\r\n\t\tOption -- Count (Ratio)\r\n\t"..string.rep("-", 80).."\r\n"
			local iTotal = 0
			-- Get total votes from poll
			for i, v in pairs(tmp.tVotes) do iTotal = iTotal + table.getn(tmp.tVotes[i]) end
			-- Populate with Option/Count
			for i, v in pairs(tmp.tVotes) do
				local iCount, sRatio = table.getn(tmp.tVotes[i]), nil
				if iTotal ~= 0 then sRatio = string.format("%0.3f", iCount*100/iTotal) end
				sMsg = sMsg.."\t\t "..string.upper(string.sub(i, 1, 1))..string.sub(i, 2, string.len(i)).." -- "..
				iCount.." ("..(sRatio or 0).."%)\r\n"
			end
		end
	end
	return sMsg
end

Serialize = function(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in pairs(tTable) do
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