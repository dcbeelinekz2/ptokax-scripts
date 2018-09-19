--[[

	RSS Bot v1.0 - LUA 5.0.2 by jiten (3/25/2006)

	Some Features:

	- Supports RSS feeds (add/show/del); inbuilt queue and cache (concept from st0ne-db`s Console NFO RSS bot)

	ATTENTION: 

	- In order to use use the RSS Mode, you must download the latest PxWSA lib (PxWSA 0.1.0) and unzip it to 
	  your scripts\libs\ folder
	
	Download Link: http://www.thewildplace.dk/#pxwsa

	Changelog:

	- Added: RSS Feed support (concept from st0ne-db`s Console NFO RSS bot);
		* Add/Del/Show commands;
		* Inbuild queue and cache.
	- Added: Comments to the code;

]]--

Settings = {
	sBot = frmHub:GetHubBotName(),		-- Default Bot Name or -- sBot = "custombot"
	-- RSS Settings
	fFeeds = "tRSS.tbl",			-- File where the RSS feeds are stored
	fCache = "tCache.tbl",			-- File where the RSS feed cache is stored
	RSS = 1,				-- RSS Status - 1 = Enabled, 0 - Disabled
	RSSDescSize = 20,			-- RSS Description's Size
	sProt = 0,				-- 0 for TCP, 1 for UDP (mostly it's TCP)
	sPort = 80,				-- WSA lib default port
	sLibFolder = "libs",			-- PxWSA lib folder
	sMenu = "RSS Bot",			-- RightClick Menu Name
	eFolder = "RSS",			-- Folder where the .tbl files are stored
	iVer = "1.0",				-- Script Version
	SendRC = 1,				-- 1 = Send RighClick; 0 = Don't
	-- Commands
	helpCmd = "rsshelp", addRSSCmd = "addrss", delRSSCmd = "delrss", showRSSCmd = "showrss",
}

-- Init WSA lib
libinit = loadlib(Settings.sLibFolder.."/pxwsa.dll", "_libinit")
libinit()

-- Init sockets
WSA.Init()

tabTimers = {n=0}; TmrFreq = 1000; RSS = {}; tCache = {}; fData = ""

Main = function()
	-- Register Bot Name
	if Settings.sBot ~= frmHub:GetHubBotName() then frmHub:RegBot(Settings.sBot) end
	-- Load RSS content
	if loadfile(Settings.eFolder.."/"..Settings.fFeeds) then dofile(Settings.eFolder.."/"..Settings.fFeeds) end
	if loadfile(Settings.eFolder.."/"..Settings.fCache) then dofile(Settings.eFolder.."/"..Settings.fCache) end
	-- Register timers
	tFunctions.RegTimer(tFunctions.ConnectToHost, 30*1000); tFunctions.RegTimer(tFunctions.GetRequest, 1000);
	-- Set and Start timer
	SetTimer(TmrFreq) StartTimer()
end

ChatArrival = function(user,data)
	-- Parse Main Chat commands
	local s,e,msg = string.find(data,"^%b<>%s+[%!%+](.*)|$")
	if msg then return tFunctions.ParseCommands(user,msg) end
end

ToArrival = function(user,data)
	-- Parse PM commands
	local s,e,to,msg = string.find(data, "^%$To:%s+(%S+)%s+From:%s+%S+%s-%$%b<>%s+[%!%+](.*)|$")
	if to == Settings.sBot and msg then return tFunctions.ParseCommands(user, msg) end
end

tCmds = {

--	Commands Structure:
--	[Command] = { function, Lowest Profile that can use this command (check Levels table), Description, Example, RightClick Command},

	[Settings.showRSSCmd] =	{
		tFunc = function(user,data)
			if Settings.RSS == 1 then
				local s,e,cat= string.find(data,"^%S+%s+(%S+)") 
				if cat and cat ~= "" then
					cat = string.upper(string.sub(cat,1,1))..string.lower(string.sub(cat,2,string.len(cat)))
					local msg, Exists = "", nil
					-- for RSS's content
					for i,v in pairs(RSS) do
						-- Create messages according to each category
						local tString = "\t • [ "..i.." ] -\t"..v.sDesc.."\r\n\t\t\tLink: "..v.sHost
						local tTable = { 
							["rss"] = { RSS, function () msg = msg..tString.."\r\n" end },
							["cache"] = { v.Cache, function() msg = msg..tString.."\r\n" end },
							["queue"] = { v.Queue, function() for a,b in pairs(v.Queue) do msg = msg..tString.."\r\n\t\t\tUser: "..a.." - #"..b.."\r\n" end end }, 
						}
						-- If typed category exists
						if tTable[string.lower(cat)] then
							-- Process data
							if next(tTable[string.lower(cat)][1]) then tTable[string.lower(cat)][2]() Exists = 1 end
						end
					end
					if Exists then
						user:SendPM(Settings.sBot,"\r\n\r\n".."\t"..string.rep("- -",50).."\r\n".."\t\t\t\t\t"..cat..
						" List:\r\n\t"..string.rep("- -",50).."\r\n"..msg)
					elseif RSS[string.lower(cat)] then
						cat = string.lower(cat)
						-- If feed's queue isn't empty
						if next(RSS[cat].Queue) then
							user:SendData(Settings.sBot,"*** Error: Someone has already requested this feed. Wait a minute and try again.")
						else
							local sMsg = ""
							-- If feed's cache isn't empty
							if next(RSS[cat].Cache) then
								-- If RSS is cached
								if tCache[RSS[cat].sHost] then
									-- If RSS is less than one hour old
									if RSS[cat]["Cache"].iTime + 60*60 > os.clock() then
										for i,v in ipairs(tCache[RSS[cat].sHost]) do
											sMsg = sMsg..v
										end
										user:SendData(Settings.sBot,"*** Request to "..RSS[cat].sHost.." [ Local Cache ] sent!")
										user:SendPM(Settings.sBot,"\r\n\r\n"..string.rep("- -",80)..
										"\r\nFeed [ Local Cache ] : "..RSS[cat].sHost.."\r\n"..sMsg.."\r\n"..
										string.rep("- -",80).."\r\n")
										return 0
									else
										-- Empty RSS and cache tables
										RSS[cat].Cache = {}
										tCache[RSS[cat].sHost] = {}
									end
								end
							end
							-- Add user's request to queue
							local ID = tonumber(tFunctions.RSSQueue(2) or 1)
							RSS[cat]["Queue"][user.sName] = ID
							-- Queue report
							user:SendData(Settings.sBot,"*** Your request has been placed in queue. Your queue number is: "..ID)
							-- Save RSS and Cache file
							tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fFeeds,RSS,"RSS")
							tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fCache,tCache,"tCache")
						end
					else
						user:SendData(Settings.sBot,"*** Error: "..cat.." is empty!")
					end
				else
					user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.showRSSCmd.." <rss/cache/queue>")
				end
			else
				user:SendData(Settings.sBot,"*** Error: RSS Mode has been disabled!")
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
		sDesc = "\t\tShow RSS/Cache/Queue list",
		sExample = "\t\t!"..Settings.showRSSCmd.." <rss/cache/queue>, !"..Settings.showRSSCmd.." <trig>",
		tRC = "Show\\RSS/Cache/Queue$<%[mynick]> !"..Settings.showRSSCmd.." %[line:RSS/Cache/Queue]" },
	[Settings.addRSSCmd] = {
		tFunc = function(user,data)
			if Settings.RSS == 1 then
				local s,e,trig,host,desc = string.find(data,"^%S+%s+(%S+)%s+(%S+)%s+(.*)") 
				if trig and host and desc then
					if desc ~= "" then
						local t, h, Exists = string.lower(trig), string.lower(host), nil
						-- Loop through RSS table for same host
						for i,v in pairs(RSS) do
							if v.sHost == h then Exists = 1 end
						end
						-- If RSS trig or host exists in the database
						if RSS[t] or Exists then
							user:SendData(Settings.sBot,"*** Error: There's already a RSS Entry \""..trig.."\" ("..host..").")
						else
							-- Check desc length
							if (string.len(desc) > Settings.RSSDescSize) then
								user:SendData(Settings.sBot,"*** Error: The RSS Description can't have more than "..Settings.RSSDescSize.." characters.")
							elseif string.find(host,"%.") and string.find(host,"\/") then
								-- Add and save RSS to table
								RSS[t] = { sHost = host, sDesc = desc, Queue = {}, Cache = {} }
								tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fFeeds,RSS,"RSS")
								SendToAll(Settings.sBot,"*** "..user.sName.." freshened up RSS feeds with: "..trig.." [ "..host.." ]. For more details type: !"..Settings.showRSSCmd.." <cache/queue/rss>")
							else
								user:SendData(Settings.sBot,"*** Error: The host you typed is invalid.")
							end
						end
					else
						user:SendData(Settings.sBot,"*** Error: Please type a description.")
					end
				else
					user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.addRSSCmd.." <trigger> <host> <description>")
				end
			else
				user:SendData(Settings.sBot,"*** Error: RSS Mode has been disabled!")
			end
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\t\tAdds a RSS feed",
		sExample = "\t\t\t!"..Settings.addRSSCmd.." nfall www.nforce.nl/rss/rss_all.xml NFOrce All",
		tRC = "Add\\RSS$<%[mynick]> !"..Settings.addRSSCmd.." %[line:Trigger] %[line:Host] %[line:Description]" },
	[Settings.delRSSCmd] = {
		tFunc = function(user,data)
			if Settings.RSS == 1 then
				local s,e,cat,trig = string.find(data,"^%S+%s+(%S+)%s*(.*)") 
				if cat and trig then
					local tTable = {
					["rss"] =
						function()
							-- If RSS table contains trig
							if RSS[string.lower(trig)] then
								-- Delete and save
								RSS[string.lower(trig)] = nil tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fFeeds,RSS,"RSS")
								user:SendData(Settings.sBot,"*** "..trig.." was sucessfully deleted from the RSS feeds.")
							else
								user:SendData(Settings.sBot,"*** Error: There is no RSS feed: "..trig..".")
							end
						end,
					["cache"] =
						function()
							local Deleted = nil
							-- For each pair in RSS table
							for i,v in pairs(RSS) do
								-- if v.Cache contains values
								if next(v.Cache) then
									-- Empty
									v.Cache = {} tCache = {}
									Deleted = 1
								end
							end
							if Deleted then
								-- Save
								tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fFeeds,RSS,"RSS")
								tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fCache,tCache,"tCache")
								user:SendData(Settings.sBot,"*** RSS Feeds' cache was sucessfully cleared.")
							else
								user:SendData(Settings.sBot,"*** Error: RSS Feeds' cache is empty.")
							end
						end,
					["queue"] = 
						function()
							-- Clear queue if exists
							if tFunctions.RSSQueue(1,trig) then
								-- Save
								tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fFeeds,RSS,"RSS")
								user:SendData(Settings.sBot,"*** ID: \""..trig.."\" has been successfully removed from the Queue list.")
							else
								user:SendData(Settings.sBot,"*** Error: There is no ID \""..trig.."\" in the Queue list.")
							end
						end,
					}
					-- If tTable contains typed command
					if tTable[string.lower(cat)] then 
						-- Process data
						return tTable[string.lower(cat)]()
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.delRSSCmd.." <rss/cache/queue> <empty/ID/trig>")
					end
				else
					user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.delRSSCmd.." <rss/cache/queue> <empty/ID/trig>")
				end
			else
				user:SendData(Settings.sBot,"*** Error: RSS Mode has been disabled!")
			end
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\t\tDeletes RSS/Cache/Queue",
		sExample = "\t\t!"..Settings.delRSSCmd.." rss trig, !"..Settings.delRSSCmd.." cache, !"..Settings.delRSSCmd.." queue 1",
		tRC = "Del\\RSS/Cache/Queue$<%[mynick]> !"..Settings.delRSSCmd.." %[line:RSS/Cache/Queue] %[line:empty/ID/trig]" },
	[Settings.helpCmd] = {
		tFunc = function(user)
			local sMsg = "\r\n\t"..string.rep("-", 220).."\r\n"..string.rep("\t",7).."RSS Bot v."..
			Settings.iVer.." by jiten\t\t\t\r\n\t"..string.rep("-",220).."\r\n\tAvailable Commands:".."\r\n\r\n"
			-- For each pair in tCmds
			for i,v in pairs(tCmds) do
				-- If user is allowed to use i command
				if tCmds[i].tLevels[user.iProfile] then
					sMsg = sMsg.."\t!"..i..v.sDesc..v.sExample.."\r\n";
				end
			end
			user:SendData(Settings.sBot, sMsg.."\t"..string.rep("-",220));
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
		sDesc = "\t\tDisplays this help message",
		sExample = "\t\t!"..Settings.helpCmd,
		tRC = "Help$<%[mynick]> !"..Settings.helpCmd },
}

NewUserConnected = function(user)
	-- If SendRC is enabled and bUserCommand
	if Settings.SendRC == 1 then
		if user.bUserCommand then
			-- Build user-specific temp RC table
			local tRC = {}; tFunctions.GetRC(user,tRC); table.sort(tRC);
			-- Send RC alphabetically sorted
			for i in ipairs(tRC) do 
				user:SendData("$UserCommand 1 3 "..Settings.sMenu.."\\"..tRC[i].."&#124;")
			end;
			collectgarbage(); io.flush();
		end
	end
end

OpConnected = NewUserConnected

OnTimer = function()
	-- For each ipair in table
	for i in ipairs(tabTimers) do
		tabTimers[i].count = tabTimers[i].count + 1
		if tabTimers[i].count > tabTimers[i].trig then
			tabTimers[i].count=1
			tabTimers[i]:func()
		end
	end
end

OnExit = function()
	-- Terminate use of WSA lib
	WSA.Dispose()
	-- RSS Feeder
	if Settings.RSS == 1 then
		-- For each pair in RSS table - Empty Cache and Queue
		for i,v in pairs(RSS) do
			-- Empty
			v.Cache = {} v.Queue = {} tCache = {}
		end
		-- Save RSS and Cache file
		tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fFeeds,RSS,"RSS")
		tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fCache,tCache,"tCache")
	end
end

tFunctions = {}

-- Command Parser
tFunctions.ParseCommands = function(user,data)
	local s,e,cmd = string.find(data,"^(%S+)")
	-- If cmd and tCmds contains it
	if cmd and tCmds[string.lower(cmd)] then
		-- Lower it
		cmd = string.lower(cmd)
		-- If user is allowed to use
		if tCmds[cmd].tLevels[user.iProfile] then
			return tCmds[cmd].tFunc(user,data), 1
		else
			return user:SendData(Settings.sBot,"*** Error: You are not allowed to use this command."), 1
		end
	end
end

-- Get user-specific RightClick
tFunctions.GetRC = function(user,tTable)
	for i,v in pairs(tCmds) do
		if tCmds[i].tLevels[user.iProfile] then table.insert(tTable,v.tRC) end
	end
	-- If RSS Feeder is enabled
	if Settings.RSS == 1 then
		if tCmds[Settings.showRSSCmd].tLevels[user.iProfile] then
			for i,v in pairs(RSS) do
				table.insert(tTable,"RSS\\"..v.sDesc.."$<%[mynick]> !"..Settings.showRSSCmd.." "..i)
			end
		end
	end
end

-- MultiTimer Regger
tFunctions.RegTimer = function(f, Interval)
	local tmpTrig = Interval / TmrFreq
	assert(Interval >= TmrFreq , "RegTimer(): Please Adjust TmrFreq")
	local Timer = {n=0}
	Timer.func=f
	Timer.trig=tmpTrig
	Timer.count=1
	table.insert(tabTimers, Timer)
end

-- RSS Connector
tFunctions.ConnectToHost = function()
	-- RSS Feeder
	if Settings.RSS == 1 then
		-- If not connected to any socket
		if not bConnected then
			-- Get Link from #1 in Queue
			local sLink, nick, trig = tFunctions.RSSQueue(3)
			-- If Queue isn't empty
			if sLink then
				nick = GetItemByName(nick)
				-- Parse Host and File from sLink
				local s,e,sHost,sFile = string.find(sLink,"^(.-)(\/.*)")
				if sHost and sFile then
					-- Create a socket according to what we have above
					s,e,sock = WSA.NewSocket(Settings.sProt)
					-- Try connection to host
					local errorCode, errorStr = WSA.Connect(sock,sHost,Settings.sPort)
					-- Connection failed
					if errorCode then
						-- Connection Report
						if nick then nick:SendData(Settings.sBot,"*** Error: Connection to "..sHost.." failed!") end
						-- Mark as not connected
						bConnected = false
						-- Remove first user from queue, Save RSS file
						tFunctions.Queuer()
					else
						if nick then nick:SendData(Settings.sBot,"*** Connected") end
						-- Mark as connected
						bConnected = true
						-- Mark non-blocking socket
						local sError, Str = WSA.MarkNonBlocking(sock)
						-- Error
						if sError then
							-- Socket Error Marking Report
							if nick then nick:SendData(Settings.sBot,"*** Error: Could not mark non-blocking socket.") end
							-- Remove first user from queue, Save RSS file
							tFunctions.Queuer()
						else
							if nick then nick:SendData(Settings.sBot,"*** Socket Marked") end
							-- Send Request
							local wCmd = "GET "..sFile.." HTTP/1.0\r\nHost: "..sHost.."\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)\r\n"..string.char(13,10)
							-- Send the request
							local _ErrorCode, _ErrorStr, bytesSent = WSA.Send(sock,wCmd)
							-- Connection failed
							if _ErrorCode then
								-- Mark as not connected
								bConnected = false
								-- Report Error
								if nick then nick:SendData(Settings.sBot,"*** Error: Connection Failed - ".._ErrorStr) end
								-- Close existing socket
								WSA.Close(sock)
								-- Remove first user from queue, Save RSS file
								tFunctions.Queuer()
							else
								-- Connection Report
								if nick then nick:SendData(Settings.sBot,"*** Request to "..sHost.." sent!") end
							end
						end
					end
				end
			end
		end
	end
	collectgarbage(); io.flush();
end

-- Receive request
tFunctions.GetRequest = function()
	if bConnected then
		-- Wait for the request response
		local errorCode, errorStr, sData, bytesRead = WSA.Receive(sock)
		if errorCode then
			-- Connection gracefully closed
			if errorCode == 0 then
				-- Close existing socket
				WSA.Close(sock)
				-- Mark as connected
				bConnected = false
				-- Parse received buffer
				tFunctions.RSSParser(fData)
				-- Empty receive buffer
				fData = ""
			-- Non-critical error
			elseif (errorCode == 10035) then
			-- Receive failed
			else
				-- Close existing socket
				WSA.Close(sock)
				-- Mark as not connected
				bConnected = false
				-- Empty receive buffer
				fData = ""
			end
		else
			-- Merge to receive buffer
			fData = fData..sData
		end
	end
end

-- RSS Queue core function
tFunctions.RSSQueue = function(Mode,iPos)
	local var1, var2, var3 = nil, nil, nil
	for i,v in pairs(RSS) do
		for c,d in pairs(v.Queue) do
			local tTable = {
			[1] = function()
				if tonumber(iPos) then
					-- If d ID is the same as requested
					if not var1 and tonumber(d) == tonumber(iPos) then
						-- Delete iPos
						v.Queue[c] = nil var1 = 1
					end
					-- If queue isn't empty
					if next(v.Queue) then
						-- Queue position - 1
						if v.Queue[c] > tonumber(iPos) then
							v.Queue[c] = v.Queue[c] - 1
						end
					end
				end
			end,
			[2] = function()
				-- Sum items in Queue + 1
				var1 = (var1 or 1) + 1
			end,
			[3] = function()
				-- Capture Host/File, Trig and Username of #1 in Queue
				if tonumber(d) == 1 then
					var1 = v.sHost
					var2 = c
					var3 = i
				end
			end,
			}
			if tTable[Mode] then tTable[Mode]() end
		end
	end
	return var1, var2, var3
end

-- Queue remover and saver
tFunctions.Queuer = function()
	-- Remove first user from queue
	tFunctions.RSSQueue(1,1)
	-- Save RSS file
	tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fFeeds,RSS,"RSS")
end

-- RSS data parser
tFunctions.RSSParser = function(rFeed)
	-- Get Link and User from #1 in Queue
	local Host, sUser, trig = tFunctions.RSSQueue(3)
	-- If found
	if sUser and Host and trig and rFeed then
		local sLine, sContent = "", ""
		local tTable= {
		[1] = {
			["/a&gt;"] = "", ["&lt;"] = "", ["b&gt;"] = "",
			["/b&gt;"] = "", ["&gt;"] = "", ["br /"] = "", 
			["/ br"] = "", ["a href="] = "", ["&apos;"] = "",
			["&quot;"] = "", ["&lt;/a"] = "", ["<%!%[CDATA%["] = "",
			["</(.-)>"] = "", ["<(.-)>"] = "", ["]]>"] = "", ["\t"] = "",
			["&#%d%d%d;"] = "", 
			},
		[2] = { 
			["<item>"] = "</item>", ["<item%s.->"] = "</item>",
			},
		}	
		-- Create/Clear Host Cache
		tCache[Host] = {}
		-- For each pair in sub-table
		for a,b in pairs(tTable[2]) do
			-- Extract content between <item> and </item>
			for sItem in string.gfind(rFeed,a.."(.-)"..b) do
				-- string.gsub unwanted chars
				for i,v in pairs(tTable[1]) do sItem = string.gsub(sItem,i,v) end
				-- Insert sItem in Cache file
				table.insert(tCache[Host],sItem)
			end
		end
		-- Save Cache file
		tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fCache,tCache,"tCache")
		local user = GetItemByName(sUser)
		-- Write os.clock to RSS Cache
		RSS[trig]["Cache"].iTime = os.clock()
		-- Remove first user from queue, Save RSS file
		tFunctions.Queuer()
		-- If Host is cached
		if next(tCache[Host]) then
			-- Loop through specific host RSS feeds
			for i,v in ipairs(tCache[Host]) do sContent = sContent..v end
			-- If sUser is online
			if user then
				-- Send it
				user:SendData(Settings.sBot,"*** Your request for "..Host.." has been completed!")
				user:SendPM(Settings.sBot,"\r\n\r\n"..string.rep("- -",80).."\r\nFeed: "..Host.."\r\n"..sContent..
				"\r\n"..string.rep("- -",80).."\r\n")
			end
		else
			user:SendData(Settings.sBot,"*** Error: An error occured. Check your RSS please.")
		end
	end
end

-- File handling
tFunctions.Serialize = function(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in pairs(tTable) do
		if (type(value) ~= "function") then
			local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
			if(type(value) == "table") then
				tFunctions.Serialize(value,sKey,hFile,sTab.."\t");
			else
				local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
				hFile:write(sTab.."\t"..sKey.." = "..sValue);
			end
			hFile:write(",\n");
		end
	end
	hFile:write(sTab.."}");
end

-- File handling
tFunctions.SaveToFile = function(file,table,tablename)
	local hFile = io.open(file,"w+") tFunctions.Serialize(table,tablename,hFile); hFile:close() 
end