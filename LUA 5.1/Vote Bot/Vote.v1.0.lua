--[[

	Vote Bot 1.0 - LUA 5.0/5.1 by jiten (7/9/2006)
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

	DESCRIPTION:
	¯¯¯¯¯¯¯¯¯¯¯¯
	- Create polls;
	- Add custom options to polls;
	- Vote on a specific pole [a vote per IP and per poll];
	- Change a poll's status [open/close];
	- Show all polls;
	- Show poll's votes;
	- Delete polls.

]]--

tVote = {
	-- BotName
	sName = "Vote-Bot",
	-- Bot Version
	iVersion = "1.0",
	-- RightClick Menu
	sMenu = "Vote Bot",
	-- Vote Bot DB
	fVote = "tVote.tbl",
	-- Commands
	sHelp = "votehelp", sRemove = "removepoll", sAddPoll = "addpoll", 
	sAddOption = "addoption", sVote = "vote", sSet = "setpoll", sShow = "showpoll"
}

tPoll = {}

Main = function()
	-- Register BotName
	frmHub:RegBot(tVote.sName)
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
		-- For each entry in table
		for i,v in pairs(tCommands) do
			-- If member
			if v.tLevels[user.iProfile] then
				-- For each user command
				for a, b in ipairs(v.tRC) do
					-- Send
					user:SendData("$UserCommand 1 3 "..tVote.sMenu.."\\"..b[1].."$<%[mynick]> !"..i..b[2].."&#124;")
				end
			end
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
					user:SendMessage(tVote.sName, "*** '"..poll.."' was successfully added to Polls!")
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
			local _,_, i = string.find(data, "^%S+%s(%d+)$") 
			-- If i
			if i then
				i = tonumber(i)
				-- DB contains it
				if tPoll[i] then
					-- If table isn't empty
					if next(tPoll[i].tVotes) then
						-- Header
						local tmp, tTable = tPoll[i], { [0] = "closed", [1] = "open" }
						local sMsg, tTable = "\r\n\r\n\tPoll "..i..". "..
						string.upper(string.sub(tmp.sPoll, 1, 1))..
						string.sub(tmp.sPoll, 2, string.len(tmp.sPoll))..
						" ["..tTable[tmp.bActive].."]\r\n\t"..string.rep("=", 40)..
						"\r\n\t\tOption (count)\r\n\t"..string.rep("-", 80).."\r\n"
						-- Populate with Option/Count
						for i, v in pairs(tmp.tVotes) do
							sMsg = sMsg.."\t\t• "..string.upper(string.sub(i, 1, 1))..
							string.sub(i, 2, string.len(i)).." ("..
							(table.getn(tmp.tVotes[i]) or 0)..")\r\n"
						end
						-- Send
						user:SendMessage(tVote.sName, sMsg)
					else
						user:SendMessage(tVote.sName, "*** Error: Poll '"..tPoll[i].sPoll..
						"' is empty!")
					end
				else
					user:SendMessage(tVote.sName, "*** Error: There isn't a Poll with that ID!")
				end
			-- Polls exist
			elseif next(tPoll) then
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
		end,
		tLevels = { [-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, },
		sDesc = "\tShow all available polls; Show a poll's votes",
		tRC = { { "Show all polls", "" }, { "Show a poll's votes", " %[line:Poll ID]" } },
	},
	[tVote.sVote] = {
		fFunction = function(user, data)
			-- Parse ID and option
			local _,_, i, arg = string.find(data,"^%S+%s(%d+)%s(%S+)") 
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
								SendPmToOps(tVote.sName,"*** "..user.sName.." voted for '"..arg..
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
		tRC = { { "Vote on a poll", " %[line:Poll ID] %[line:Option]" } },
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
					tPoll[i] = nil; SaveToFile(tVote.fVote, tPoll, "tPoll")
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
			local _,_, i, args = string.find(data,"^%S+%s(%d+)%s(.+)") 
			-- Exist
			if i and args then
				local i = tonumber(i)
				-- ID exists in DB
				if tPoll[i] then
					-- Check each option
					string.gsub(args, "(%S+)", function(arg)
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
				else
					user:SendMessage(tVote.sName, "*** Error: There isn't a Poll with that ID!")
				end
			else
				user:SendMessage(tVote.sName, "*** Syntax Error: Type !"..tVote.sAddOption.." <Poll ID> [option1 option2 ... optionN]")
			end
		end,
		tLevels = { [0] = 1, [1] = 1, [4] = 1, [5] = 1, },
		sDesc = "Add option(s) to a Poll",
		tRC = { { "Add Option to a Poll", " %[line:Poll ID] %[line:Option1 Option2 ... OptionN]" } },
	},
}

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