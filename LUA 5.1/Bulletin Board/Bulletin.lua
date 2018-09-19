--[[

	Bulletin Board v1.0 - LUA 5.0/5.1 by jiten (6/4/2006)
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	Based on: Release/Request Bot v.4.04

]]--

Settings = {
	-- Default Hub BotName or "custombot"
	sBot = frmHub:GetHubBotName(),
	-- true = Register Bot automatically, false = don't
	bReg = true,
	-- Script Version
	iVer = "1.0",
	-- Rightclick Menu
	sMenu = "Bulletin Board",
	-- Separator for each post. Default one is "
	sSep = "\"",
	-- Thread Name's Size
	iCatSize = 80,
	-- Release's size
	iPostSize = 250,
	-- Max shown Posters
	pMax = 20,
	-- Max shown Posts
	iMax = 5,
	-- Databases' filename
	fThread = "tThreads.tbl",
	fBulletin = "tBulletin.tbl",
	-- true = Send RighClick; false = Don't
	bSendRC = true,
	-- true: Case-sensitive search; false: not case-sensitive
	bSensitive = false,
	-- 1 = Send iMax Requests/Releases on connect; 0 = Don't
	bSendOnConnect = false,
	-- Commands
	addCmd = "bbadd", delCmd = "bbdel", showCmd = "bbshow", findCmd = "bbfind",
	TopPosterCmd = "bbtopposter", helpCmd = "bbhelp", setCmd = "bbsetup",
	addthread = "addthread", delthread = "delthread", showthread = "showthread",
}

tThread = {}; tBulletin = {}

Main = function()
	-- Register sBot
	if (Settings.sBot ~= frmHub:GetHubBotName()) or Settings.bReg then 
		frmHub:RegBot(Settings.sBot, 1, "Bulletin Board v."..Settings.iVer.." for PtokaX by jiten", "")
	end
	-- string.gmatch/gfind and garbagecollect method (Based on Mutor's)
	fMatch, gc = string.gfind, nil
	if _VERSION == "Lua 5.1" then fMatch = string.gmatch; gc = "collect" end
	-- Load file content
	if loadfile(Settings.fThread) then dofile(Settings.fThread) end
	-- Build table content
	local x = os.clock(); local f = io.open(Settings.fBulletin, "r")
	if f then
		for line in f:lines() do
			for thread, user, time, post in fMatch(line,"(.+)%$(.+)%$(.+)%$(.+)%$") do
				tBulletin[thread] = tBulletin[thread] or {}
				table.insert(tBulletin[thread], { sName = user, iTime = time, sPost = post })
			end
		end
	end
	-- Report
	SendToOps(Settings.sBot,"*** Bulletin Board Posts loaded in "..string.format("%0.4f", os.clock()-x ).." seconds.")
end

ChatArrival = function(user,data)
	-- Parse Main Chat commands
	local data = string.sub(data,1,-2)
	local s,e,msg = string.find(data,"^%b<>%s+[%!%+](.*)")
	if msg then return ParseCommands(user, msg) end
end

ToArrival = function(user,data)
	-- Parse PM commands
	local data = string.sub(data,1,-2)
	local s,e,to,msg = string.find(data, "^%$To:%s+(%S+)%s+From:%s+%S+%s-%$%b<>%s+[%!%+](.*)")
	if to == Settings.sBot and msg then return ParseCommands(user, msg) end
end

NewUserConnected = function(user)
	-- Send Posts on Connect
	if Settings.bSendOnConnect then
		user:SendPM(Settings.sBot,Structure(string.rep("\t",9).."Last "..Settings.iMax.." Posts per Thread "..
		string.rep("\t",6).."\r\n", ShowX(tBulletin), tBulletin))
	end
	-- Sending RightClick
	if Settings.bSendRC then
		if user.bUserCommand then
			-- Build user-specific temp RC table
			local tRC = {}; GetRC(user,tRC); table.sort(tRC);
			-- Send RC alphabetically sorted
			for i in ipairs(tRC) do 
				user:SendData("$UserCommand 1 3 "..Settings.sMenu.."\\"..tRC[i].."&#124;")
				collectgarbage(); io.flush();
			end;
		end
	end
end

OpConnected = NewUserConnected

OnExit = function()
	-- Convert table structure to flat line ($)
	local f = io.open(Settings.fBulletin, "w")
	for Cat,a in pairs(tBulletin) do
		-- For each ipair in a
		for i,v in ipairs(a) do
			-- Write
			f:write(Cat.."$"..v.sName.."$"..v.iTime.."$"..v.sPost.."$\n")
		end
	end
	-- Flush and close
	f:flush(); f:close()
end

tCommands = {
	[Settings.addthread] = {
		tFunc = function(user,data)
			local s,e,cat = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep) 
			-- Thread found
			if cat then
				-- Lower Thread
				local Cat = string.lower(cat)
				-- DB contains it
				if tThread[Cat] then
					user:SendData(Settings.sBot,"*** Error: There is already a Thread: '"..cat.."'")
				else
					-- Check Thread´s size
					if (string.len(cat) > Settings.iCatSize) then
						user:SendData(Settings.sBot,"*** Error: The Thread can't have more than "..Settings.iCatSize.." characters.")
					else
						-- Create and save thread
						tThread[Cat] = 1; SaveToFile(Settings.fThread, tThread, "tThread")
						user:SendData(Settings.sBot,"*** '"..cat.."' was successfully added to Bulletin Board's threads.")
					end
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.addthread.." "..Settings.sSep.."Thread"..Settings.sSep)
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Add a Thread",
		sExample = "\t!"..Settings.addthread.." "..Settings.sSep.."Thread"..Settings.sSep,
		tRC = "Add\\Thread$<%[mynick]> !{} "..Settings.sSep.."%[line:Thread]"..Settings.sSep
	},
	[Settings.delthread] = {
		tFunc = function(user,data)
			local s,e,cat = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep) 
			-- Typed Thread
			if cat then
				-- Lower it
				local Cat = string.lower(cat)
				-- DB contains it
				if tThread[Cat] then
					-- Delete and save DB
					tThread[Cat] = nil; SaveToFile(Settings.fThread, tThread, "tThread")
					user:SendData(Settings.sBot,"*** '"..cat.."' was sucessfully deleted from Bulletin Board´s threads.")
				else
					user:SendData(Settings.sBot,"*** Error: There is no Thread: '"..cat.."' in Bulletin Board.")
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.delthread.." "..Settings.sSep.."Thread"..Settings.sSep)
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\tDeletes a Thread",
		sExample = "\t!"..Settings.delthread.." "..Settings.sSep.."Thread"..Settings.sSep.."",
		tRC = "Delete\\Thread\\{}$<%[mynick]> !"..Settings.delthread.." "..Settings.sSep.."{}"..Settings.sSep,
		bExtend = true,
	},
	[Settings.showthread] = {
		tFunc = function(user)
			-- tThread table isn`t empty
			if next(tThread) then
				local msg, tTable = "\r\n\r\n".."\t"..string.rep("=",80).."\r\n\t\t\t\tCurrently Available Threads:"..
				"\r\n\t"..string.rep("-",160).."\r\n", { [0] = "closed", [1] = "open" }
				-- For each pair in it
				for i,v in pairs(tThread) do
					msg = msg.."\t       • "..string.upper(string.sub(i,1,1))..string.sub(i,2,string.len(i))..
					" *"..tTable[v].."*\r\n" 
				end
				user:SendData(Settings.sBot,msg) 
			else
				user:SendData(Settings.sBot,"*** Error: There are no Threads!");
			end
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Shows Threads",
		sExample = "\t!"..Settings.showthread,
		tRC = "Show\\Threads$<%[mynick]> !"..Settings.showthread
	},
	[Settings.addCmd] = {	
		tFunc = function(user,data)
			local s,e,cat,rel = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep.."%s+"..Settings.sSep.."(.+)"..Settings.sSep)
			-- Typed Thread
			if cat and rel then
				if string.find(cat, "$", 1, true) or string.find(rel, "$", 1, true) then
					user:SendData(Settings.sBot,"*** Error: Threads and Posts must not contain dollar signs ($)!")
				else
					-- Lower it
					local Cat = string.lower(cat)
					-- DB contains it
					if tThread[Cat] then
						if tThread[Cat] == 1 then
							if (string.len(rel) > Settings.iPostSize) then
								user:SendData(Settings.sBot,"*** Error: The Posts can't have more than "..Settings.iRelSize.." characters.")
							else
								local Exists = nil
								tBulletin[Cat] = tBulletin[Cat] or {}
								-- For each pair in the Thread
								for i,v in ipairs(tBulletin[Cat]) do
									-- Check if rel doesn´t exist
									if tBulletin[Cat] and string.lower(v.sPost) == string.lower(rel) then Exists = 1 end
								end
								if Exists then
									user:SendData(Settings.sBot,"*** Error: There's already a Post: '"..rel.."'.")
								else
									table.insert( tBulletin[Cat], { sPost = rel, sName = user.sName, iTime = os.date() } );
									SendToAll(Settings.sBot,"*** "..user.sName.." added a new Post: "..rel..". For more details type: !"..Settings.showCmd)
								end
							end
						else
							user:SendData(Settings.sBot,"*** Error: '"..cat.."' is currently locked!")
						end
					else
						user:SendData(Settings.sBot,"*** Error: There is no Thread: '"..cat.."'!")
					end
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.addCmd.." "..Settings.sSep.."Thread"..Settings.sSep.." "..Settings.sSep.."Post"..Settings.sSep.."")
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\tPost in a Thread",
		sExample = "\t!"..Settings.addCmd.." "..Settings.sSep.."Thread"..Settings.sSep.." "..Settings.sSep.."Post"..Settings.sSep,
		tRC = "Add\\Post\\{}$<%[mynick]> !"..Settings.addCmd.." "..Settings.sSep.."{}"..Settings.sSep.." "..Settings.sSep.."%[line:Post]"..Settings.sSep,
		bExtend = true,
	},
	[Settings.delCmd] = {	
		tFunc = function(user,data)
			local s,e,cat,rel = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep.."%s*(.*)") 
			-- Typed cat and rel
			if cat then
				-- Lower cat
				local Cat = string.lower(cat)
				-- Rel is a number
				if tonumber(rel) then
					rel = tonumber(rel) local Deleted = nil
					-- Thread contains rel - delete it
					if tBulletin[Cat] and tBulletin[Cat][rel] then table.remove(tBulletin[Cat],rel) Deleted = 1 end
					if Deleted then 
						user:SendData(Settings.sBot,"*** Post '"..rel.."' was successfully deleted from '"..cat.."'.");
					else
						user:SendData(Settings.sBot,"*** Error: There is no Post ID: '"..rel.."' in '"..cat.."'.");
					end
				-- DB contains Cat
				elseif tBulletin[Cat] then
					local Deleted = nil
					-- Delete each pair in Cat
					for i in ipairs(tBulletin[Cat]) do
						tBulletin[Cat][i] = nil; Deleted = 1
					end
					if Deleted then
						user:SendData(Settings.sBot,"*** Thread '"..cat.."' was succesfully cleaned up.");
					else
						user:SendData(Settings.sBot,"*** Error: There is no Thread: '"..cat.."'")
					end
				else
					user:SendData(Settings.sBot,"*** Error: There is no Post ID/Thread : '"..cat.."'")
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.delCmd.." "..Settings.sSep.."Thread"..Settings.sSep.." <ID/Empty>")
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\tDeletes Post/Thread content",
		sExample = "!"..Settings.delCmd.." "..Settings.sSep.."Thread"..Settings.sSep.." ID; !"..Settings.delCmd.." "..Settings.sSep.."Thread"..Settings.sSep,
		tRC = "Delete\\Post or Thread\\{}$<%[mynick]> !"..Settings.delCmd.." "..Settings.sSep.."%[line:Thread]"..Settings.sSep.." %[line:ID/Empty]",
		bExtend = true,
	},
	[Settings.showCmd] = { 
		tFunc = function(user,data)
			local s,e,cat = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep)
			-- Shows all
			if cat then
				if cat == "all" then
					user:SendPM(Settings.sBot, Structure(string.rep("\t",9).."Showing all Posts ["..
					Releaser("getn").."]"..string.rep("\t",7).."\r\n", Releaser("show"), tBulletin))
				-- Show Thread entries
				elseif tBulletin[string.lower(cat)] then
					user:SendPM(Settings.sBot, Structure(string.rep("\t",7).."Showing all Posts from '"..cat.."' "..
					string.rep("\t",5).."\r\n", Releaser("thread", cat), tBulletin, true))
				end
			else
				user:SendPM(Settings.sBot, Structure(string.rep("\t",9).."Last "..Settings.iMax.." Posts per Thread "..
				string.rep("\t",7).."\r\n", ShowX(tBulletin), tBulletin))
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
		sDesc = "\tLast "..Settings.iMax.."/all Posts",
		sExample = "\t!"..Settings.showCmd.."; !"..Settings.showCmd.." "..Settings.sSep.."all"..Settings.sSep.."; !"..
		Settings.showCmd.." "..Settings.sSep.."Thread"..Settings.sSep.."",
		tRC = "Show\\Last "..Settings.iMax.."/All$<%[mynick]> !"..Settings.showCmd.." %[line:Empty/All/Thread]",
	},
	[Settings.findCmd] = { 
		tFunc = function(user,data)
			local s,e,str = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep)
			if str then
				user:SendPM(Settings.sBot,Structure(string.rep("\t",9).."Search Results of: '"..str.."'"..string.rep("\t",7)..
				"\r\n", Releaser("find", str), tBulletin))
			else
				user:SendData(Settings.sBot,"*** Error: Type !"..Settings.findCmd.." "..Settings.sSep.."string"..Settings.sSep)
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
		sDesc = "\tFind a Post",
		sExample = "\t!"..Settings.findCmd.." "..Settings.sSep.."jiten"..Settings.sSep,
		tRC = "Find\\Post$<%[mynick]> !"..Settings.findCmd.." "..Settings.sSep.."%[line:String]"..Settings.sSep
	},
	[Settings.setCmd] = { 
		tFunc = function(user,data)
			local s,e,set,value = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep.."%s+(%w+)")
			if set and value then
				-- Thread exists
				if tThread[string.lower(set)] then
					local tTable = { ["lock"] = 0, ["unlock"] = 1 }
					-- Mode exists
					if tTable[string.lower(value)] then
						-- Set and Save
						tThread[string.lower(set)] = tTable[string.lower(value)];
						SaveToFile(Settings.fThread, tThread, "tThread")
						user:SendData(Settings.sBot, "*** Thread '"..set.."' has been "..value.."ed!")
					else
						user:SendData(Settings.sBot, "*** Syntax Error: Type !"..Settings.setCmd..
						" "..Settings.sSep.."Thread"..Settings.sSep.." <lock/unlock>")
					end
				else
					user:SendData(Settings.sBot, "*** Error: There isn't a thread named: '"..set.."'!")
				end
			else
				user:SendData(Settings.sBot, "*** Syntax Error: Type !"..Settings.setCmd.." "..Settings.sSep..
				"Thread"..Settings.sSep.." <lock/unlock>")
			end
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\tLock/Unlock Thread",
		sExample = "\t!"..Settings.setCmd,
		tRC = "Un/Lock\\Thread\\{}$<%[mynick]> !"..Settings.setCmd.." "..Settings.sSep.."{}"..Settings.sSep.." %[line:<lock/unlock>]",
		bExtend = true
	},
	[Settings.TopPosterCmd]	=	{
		tFunc = function(user)
			local TopPoster, tCopy = {}, {}
			-- For each pair in tBulletin
			for Cat,a in pairs(tBulletin) do
				-- For each ipair in a
				for i,v in ipairs(a) do
					-- Create TopPoster table
					if TopPoster[v.sName] then TopPoster[v.sName] = TopPoster[v.sName] + 1 else TopPoster[v.sName] = 1 end
				end
			end
			-- Insert TopPoster data to Table1
			for x, y in pairs(TopPoster) do table.insert(tCopy, {x, tonumber(y), y/tonumber(Releaser("getn"))}) end
			-- Sort Table1
			table.sort(tCopy, function(a,b) return (a[Value] > b[Value]) end)
			local sMsg = ""
			for i = 1, Settings.pMax, 1 do
				if tCopy[i] then
					sMsg = sMsg .."\t"..i..".\t"..tCopy[i][1]..DoTabs(CheckSize(tCopy[i][1]))..
					tCopy[i][2].." ("..string.format("%0.3f",tCopy[i][3]*100).."%)\r\n"
				end
			end
			user:SendPM(Settings.sBot, Structure(string.rep("\t",9).."Top "..Settings.pMax..
			" Posters - Total Posts: "..Releaser("getn")..string.rep("\t",7)..
			"\r\n\t"..string.rep("-",300).."\r\n\tNr.\tUser\t\t\tPosts\r\n", sMsg))
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
		sDesc = "Top Poster",
		sExample = "\t!"..Settings.TopPosterCmd,
		tRC = "Top\\Posters$<%[mynick]> !"..Settings.TopPosterCmd
	},
}

-- RR core function
Releaser = function(Mode,String)
	local msg = ""
	for Cat,a in pairs(tBulletin) do
		for i,v in ipairs(a) do
			local sLine = "\t"..i..".\t"..v.iTime.."\t\t"..v.sName..DoTabs(CheckSize(v.sName))..Cat..
			DoTabs(CheckSize(Cat))..v.sPost.."\r\n"
			local tMode = {
			-- Show all entries
			show = function ()
				msg = msg..sLine
			end,
			-- Find entries
			find = function()
				local tmp, where = v.sPost..v.sName..v.iTime..Cat
				if Settings.bSensitive then 
					where = tmp
				else
					where = string.lower(tmp) String = string.lower(String)
				end
				if string.find(where,String) then msg = msg..sLine end
			end,
			-- Show entries by Thread
			thread = function()
				if string.lower(Cat) == string.lower(String) then 
					msg = msg.."\t"..i..".\t"..v.iTime.."\t\t"..v.sName..DoTabs(CheckSize(v.sName))..v.sPost.."\r\n"
				end
			end,
			-- Delete all Thread content
			delete = function()
				tBulletin[Cat][i] = nil;
			end,
			-- table.getn
			getn = function()
				if not tonumber(msg) then msg = 0 end
				if tBulletin[Cat][tonumber(i)] then msg = msg + 1 end
			end, }
			if tMode[Mode] then tMode[Mode]() end
		end
	end
	return msg
end

Structure = function(Header, Content, Table, bThread)
	local msg, border = "\r\n\r\n\t", string.rep("=", 150)
	if Table == tBulletin then 
		local sThread = ""; if not bThread then sThread = "\t\t\tThread" end
		msg = msg..border.."\r\n"..Header.."\t"..string.rep("-", 300).."\r\n\t"..
		"Nr.\tDate - Time\t\tPoster"..sThread.."\t\t\tPost\r\n"
	else
		msg = msg..border..Header
	end
	msg = msg.."\t"..string.rep("-", 300).."\r\n"..Content.."\t"..border.."\r\n"
	return msg
end

-- Get user-specific RightClick
GetRC = function(user, tTempTable)
	for i,v in pairs(tCommands) do
		if tCommands[i].tLevels[user.iProfile] then 
			if v.bExtend then
				for Cat,a in pairs(tBulletin) do
					local sRC = string.gsub(v.tRC, "{}", Cat)
					table.insert(tTempTable, sRC) 
				end
			else
				table.insert(tTempTable, v.tRC)
			end
		end
	end
end

ShowX = function(Table)
	local msg = ""
	for Cat,a in pairs(Table) do
		for v = table.getn(Table[Cat]) - Settings.iMax + 1, table.getn(Table[Cat]), 1 do
			if Table[Cat][v] then
				local tmp = Table[Cat][v]
				msg = msg.."\t"..v..".\t"..tmp.iTime.."\t\t"..tmp.sName..
				DoTabs(CheckSize(tmp.sName))..Cat..DoTabs(CheckSize(Cat))..tmp.sPost.."\r\n"
			end
		end
	end
	return msg
end

ParseCommands = function(user, data)
	local s,e,cmd = string.find(data,"^(%S+)")
	-- If cmd and tCommands contains it
	if cmd and tCommands[string.lower(cmd)] then
		-- Lower it
		cmd = string.lower(cmd)
		-- If user is allowed to use
		if tCommands[cmd].tLevels[user.iProfile] then
			return tCommands[cmd].tFunc(user, data), 1
		else
			return user:SendData(Settings.sBot,"*** Error: You are not allowed to use this command."), 1
		end
	end
end

-- nErBoS Release bot based
DoTabs = function(size)
	local sTmp = "" 
	if (size < 8) then sTmp = "\t\t\t" elseif (size < 16) then sTmp = "\t\t" else sTmp = "\t" end return sTmp
end

-- nErBoS Release bot based
CheckSize = function(String)
	local realSize,aux,remove = string.len(String),1,0
	local sChar = { "-", " ", "i", "l", "r", "t", "I", "y", "o", }
	while aux < realSize + 1 do
		for i=1, table.getn(sChar) do if (string.sub(String,aux,aux) == sChar[i]) then remove = remove + 0.5 end end
		aux = aux + 1
	end return realSize - remove
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
