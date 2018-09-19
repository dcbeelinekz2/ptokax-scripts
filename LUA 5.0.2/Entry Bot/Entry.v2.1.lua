--[[

	Entry Bot v2 (3/20/2006) for PtokaX 0.3.3.0 build 17.02 or Higher

	Thanks to Dessamator for the Timed Message efforts

	Some Features:

	- Supports categories;
	- Commands to add, delete, show, find, vote for entries; Top Posters/Voters and much more
	- Entries older than x Days are automatically deleted (optional)
	- Ability to send pre-defined category's content to main when desired
	- Includes an optimized RighClick;
	- Supports RSS feeds (add/show/del); inbuilt queue and cache (concept from st0ne-db`s Console NFO RSS bot)

	ATTENTION: 

	- In order to use use the RSS Mode, you must download the latest PxWSA lib (PxWSA 0.1.0) and unzip it to 
	  your scripts\libs\ folder
	
	Download Link: http://www.thewildplace.dk/#pxwsa

	Changelog:

	- Removed: Sub-category support;
	- Added: RSS Feed support (concept from st0ne-db`s Console NFO RSS bot);
		* Add/Del/Show commands;
		* Inbuild queue and cache.
	- Removed: Unnecessary code;
	- Added: Comments to the code;
	- Changed: Command parsing and table structure;
	- Removed: Levels table;
	- Changed: RightClick is sent in alphabetical order;
	- Changed: Cleaner;
	- Changed: Other mods.
	- Fixed: 1.1 to 1.0 in wCmd (thanks to BrotherBear)

]]--

Settings = {
	sBot = frmHub:GetHubBotName(),		-- Default Bot Name or -- sBot = "custombot"
	-- RSS Settings
	fFeeds = "tRSS.tbl",			-- File where the RSS feeds are stored
	fCache = "tCache.tbl",			-- File where the RSS feed cache is stored
	RSS = 0,				-- RSS Status - 1 = Enabled, 0 - Disabled
	RSSDescSize = 20,			-- RSS Description's Size
	sProt = 0,				-- 0 for TCP, 1 for UDP (mostly it's TCP)
	sPort = 80,				-- WSA lib default port
	-- Entry Bot Settings
	sMenu = "Entry Bot",			-- RightClick Menu Name
	fEntry = "Entry.tbl",			-- File where the Entries are stored
	fVote = "Votes.tbl",			-- File where the Voters are stored
	eFolder = "Entry",			-- Folder where the .tbl files are stored
	iVer = "2.1",				-- Script Version
	iMax = 5,				-- Maximum entries to be shown per category
	vMax = 20,				-- Maximum votes to be shown
	pMax = 20,				-- Maximum posters to be shown
	SendOnConnect = 0,			-- 1 = Send iMax Entries to every user on connect; 0 = Don't send
	CatSize = 20,				-- Category's size
	EntrySize = 80,				-- Entry's size (recommended: 75-80)
	Sensitive = 0,				-- 1 = Searches case-sensitive; 0 = not case-sensitive
	TimedCat = 0,				-- 1 = Send specific category content to main in an interval; 0: not
	TimedMsg = "your message",		-- Message shown below each Timed Category in Main
	Times = {				-- ["time in 24h format"] = "Category" (not case sensitive)
		["12:00"] = "test",
	},
	cDelay = 12,				-- Cleaner Checking Delay (in hours)
	pCleaner = 1,				-- 1 = Sends cleaner actions to all; 0 = doesn't
	Cleaner = 1,				-- 1 = Set Automatic Cleaner On; 0 = Automatic Cleaner Off
	SendRC = 1,				-- 1 = Send RighClick; 0 = Don't
	-- Commands
	addCatCmd = "addcat", delCatCmd = "delcat", showCatCmd = "showcat", addCmd = "add", TimedCmd = "rotator",
	showCmd = "show", delCmd = "del", delAllCmd = "delall", findCmd = "find", helpCmd = "entryhelp",
	voteCmd = "vote", TopVotesCmd = "topvoter", clrVotesCmd = "clrvote", TopPosterCmd = "topposter",
	addRSSCmd = "addrss", delRSSCmd = "delrss", showRSSCmd = "showrss",
	sChar = { "-", " ", "i", "l", "r", "t", "I", "y", "o", }, -- Don't change this
}

-- Init WSA lib
libinit = loadlib("libs/pxwsa.dll", "_libinit")
libinit()

-- Init sockets
WSA.Init()

Entry = {}; Votes = {}; tabTimers = {n=0}; TmrFreq = 1000; RSS = {}; tCache = {}; fData = ""

Main = function()
	-- Register Bot Name
	if Settings.sBot ~= frmHub:GetHubBotName() then frmHub:RegBot(Settings.sBot) end
	-- Load Entry content
	if loadfile(Settings.eFolder.."/"..Settings.fEntry) then dofile(Settings.eFolder.."/"..Settings.fEntry) else os.execute("mkdir "..Settings.eFolder) io.output(Settings.eFolder.."/"..Settings.fEntry) end
	if loadfile(Settings.eFolder.."/"..Settings.fVote) then dofile(Settings.eFolder.."/"..Settings.fVote) end
	-- Load RSS content
	if loadfile(Settings.eFolder.."/"..Settings.fFeeds) then dofile(Settings.eFolder.."/"..Settings.fFeeds) end
	if loadfile(Settings.eFolder.."/"..Settings.fCache) then dofile(Settings.eFolder.."/"..Settings.fCache) end
	-- Register timers
	tFunctions.RegTimer(tFunctions.Cleaner, Settings.cDelay*60*60*1000); tFunctions.RegTimer(tFunctions.TimedCat, 60*1000);
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
		sDesc = "Show RSS/Cache/Queue list",
		sExample = "!"..Settings.showRSSCmd.." <rss/cache/queue>, !"..Settings.showRSSCmd.." <trig>",
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
		sDesc = "Adds a RSS feed",
		sExample = "!"..Settings.addRSSCmd.." nfall www.nforce.nl/rss/rss_all.xml NFOrce All",
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
		sDesc = "Deletes RSS/Cache/Queue",
		sExample = "!"..Settings.delRSSCmd.." rss trig, !"..Settings.delRSSCmd.." cache, !"..Settings.delRSSCmd.." queue 1",
		tRC = "Del\\RSS/Cache/Queue$<%[mynick]> !"..Settings.delRSSCmd.." %[line:RSS/Cache/Queue] %[line:empty/ID/trig]" },
	[Settings.addCatCmd] = {
		tFunc = function(user,data)
			local s,e,cat,date = string.find(data,"^%S+%s+(%S+)%s+(%d+)") 
			-- Category and date found
			if cat and date then
				-- Lower category
				local Cat = string.lower(cat)
				-- DB contains it
				if Entry[Cat] then
					user:SendData(Settings.sBot,"*** Error: There is already a Category: "..cat)
				else
					-- Check category´s size
					if (string.len(cat) > Settings.CatSize) then
						user:SendData(Settings.sBot,"*** Error: The Category can't have more than "..Settings.CatSize.." characters.")
					else
						-- Create and save category
						Entry[Cat] = {}; Entry[Cat].iClean = tonumber(date)
						tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fEntry,Entry,"Entry")
						user:SendData(Settings.sBot,"*** "..cat.." was successfully added to the Categories.")
					end
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.addCatCmd.." <category> <maximum time in days>")
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Add category and Time",
		sExample = "!"..Settings.addCatCmd.." Movies 15, !"..Settings.addCatCmd.." Movies",
		tRC = "Add\\Category$<%[mynick]> !"..Settings.addCatCmd.." %[line:Category] %[line:LifeTime in Days]"
		},
	[Settings.delCatCmd] = {
		tFunc = function(user,data)
			local s,e,cat = string.find(data,"^%S+%s+(%S+)") 
			-- Typed category
			if cat then
				-- Lower it
				local Cat = string.lower(cat)
				-- DB contains it
				if Entry[Cat] then
					-- Delete and save DB
					Entry[Cat] = nil; tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fEntry,Entry,"Entry")
					user:SendData(Settings.sBot,"*** "..cat.." was sucessfully deleted from the Categories.")
				else
					user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat..".")
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.delCatCmd.." <category>")
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Deletes a category",
		sExample = "!"..Settings.delCatCmd.." Movies",
		tRC = "Delete\\Category$<%[mynick]> !"..Settings.delCatCmd.." %[line:Category]" },
	[Settings.showCatCmd] =	{
		tFunc = function(user)
			-- Entry table isn`t empty
			if next(Entry) then
				local msg = "\r\n\r\n".."\t"..string.rep("- -",20).."\r\n\t\tCategory List:\r\n\t"..
				string.rep("- -",20).."\r\n"
				-- For each pair in it
				for Cat,i in pairs(Entry) do
					msg = msg.."\t       • "..string.upper(string.sub(Cat,1,1))..string.sub(Cat,2,string.len(Cat)).." ("..i.iClean.." days)\r\n" 
				end
				user:SendData(Settings.sBot,msg) 
			else
				user:SendData(Settings.sBot,"*** Error: There are no categories!");
			end
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Shows categories",
		sExample = "!"..Settings.showCatCmd,
		tRC = "Show\\Categories$<%[mynick]> !"..Settings.showCatCmd },
	[Settings.addCmd] = {
		tFunc = function(user,data)
			local s,e,cat,rel = string.find(data,"^%S+%s+(%S+)%s+(.*)") 
			-- Typed category
			if cat then
				-- Lower it
				local Cat = string.lower(cat)
				-- DB contains it
				if Entry[Cat] then
					-- Rel isn´t equal to ""
					if rel ~= "" then
						local Exists = nil
						-- For each pair in the category
						for i,v in ipairs(Entry[Cat]) do
							-- Check if rel doesn´t exist
							if Entry[Cat] and string.lower(v.sRel) == string.lower(rel) then Exists = 1 end
						end
						if Exists then
							user:SendData(Settings.sBot,"*** Error: There's already an Entry \""..rel.."\" in "..cat)
						else
							-- Check rel size
							if (string.len(rel) > Settings.EntrySize) then
								user:SendData(Settings.sBot,"*** Error: The Entry can't have more than "..Settings.EntrySize.." characters.")
							else
								-- Insert Entry to category
								table.insert( Entry[Cat], { sRel = rel, sPoster = user.sName, iTime = os.date(), iVote = 0, } )
								tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fEntry,Entry,"Entry")
								SendToAll(Settings.sBot,"*** "..user.sName.." freshened up "..cat.." with: "..rel..". For more details type: !"..Settings.showCmd)
							end
						end
					else
						user:SendData(Settings.sBot,"*** Error: Please type an Entry.")
					end
				else
					user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat)
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.addCmd.." <category> <Entry>")
			end
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Adds entry to category",
		sExample = "!"..Settings.addCmd.." Movies Matrix Revolutions",
		tRC = "Add\\Entry$<%[mynick]> !"..Settings.addCmd.." %[line:Category] %[line:Entry]" },
	[Settings.showCmd] = {
		tFunc = function(user,data)
			local s,e,cat = string.find(data,"^%S+%s+(%S+)") 
			-- Typed category
			if cat then
				-- Show all entries
				if string.lower(cat) == "all" then
					user:SendPM(Settings.sBot,tFunctions.ShowEntry(string.rep("\t",9).."Showing all entries ["..
					tFunctions.EntryContent(7,"").."]"..string.rep("\t",7).."["..os.date()..
					"]\r\n", tFunctions.EntryContent(1,""), Entry))
				-- Show category entries
				elseif Entry[string.lower(cat)] then
					user:SendPM(Settings.sBot,tFunctions.ShowEntry(string.rep("\t",9).."Showing all "..cat.." "..
					string.rep("\t",7).."["..os.date().."]\r\n",tFunctions.EntryContent(4,cat),Entry))
				else
					user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat)
				end
			else
				-- Show last iMax entries per category
				user:SendPM(Settings.sBot,tFunctions.ShowEntry(string.rep("\t",9).."Last "..Settings.iMax.." entries per Category "..
				string.rep("\t",7).."["..os.date().."]\r\n",tFunctions.ShowXEntry(),Entry))
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
		sDesc = "Shows "..Settings.iMax.."/all/category",
		sExample = "!"..Settings.showCmd..", !"..Settings.showCmd.." all, !"..Settings.showCmd.." Movies",
		tRC = "Show\\"..Settings.iMax.."/All/Category$<%[mynick]> !"..Settings.showCmd.." %[line:empty / All / Category]" },
	[Settings.delCmd] = {
		tFunc = function(user,data)
			local s,e,cat,rel = string.find(data,"^%S+%s+(%S+)%s*(.*)") 
			-- Typed cat and rel
			if cat and rel then
				-- Lower cat
				local Cat = string.lower(cat)
				-- Rel is a number
				if tonumber(rel) then
					rel = tonumber(rel) local Deleted = nil
					-- Category contains rel - delete it
					if Entry[Cat] and Entry[Cat][rel] then table.remove(Entry[Cat],rel) Deleted = 1 end
					if Deleted then 
						user:SendData(Settings.sBot,"ID "..rel.." was successfully deleted.")
						tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fEntry,Entry,"Entry")
					else
						user:SendData(Settings.sBot,"*** Error: There is no ID: "..rel..".")
					end
				-- DB contains Cat
				elseif Entry[Cat] then
					local Deleted = nil
					-- Delete each pair in Cat
					for i in ipairs(Entry[Cat]) do
						table.remove(Entry[Cat],i) Deleted = 1
					end
					if Deleted then
						tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fEntry,Entry,"Entry")
						user:SendData(Settings.sBot,"Category: \""..cat.."\" was succesfully cleaned up.")
					else
						user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat)
					end
				else
					user:SendData(Settings.sBot,"*** Error: There is no ID/Category: "..cat)
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.delCmd.." <category> <ID> / category>")
			end

		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Del ID/category",
		sExample = "!"..Settings.delCmd.." 5; !"..Settings.delCmd.." Movies, !"..Settings.delCmd.." Movies",
		tRC = "Delete\\ID/Category Content$<%[mynick]> !"..Settings.delCmd.." %[line:ID / Category]" },
	[Settings.delAllCmd] = {
		tFunc = function(user,data)
			-- Empty and save DB
			Entry = nil Entry = {} tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fEntry,Entry,"Entry")
			user:SendData(Settings.sBot,"*** All entries have been deleted successfully.")
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Deletes all entries",
		sExample = "!"..Settings.delAllCmd,
		tRC = "Delete\\All Entries$<%[mynick]> !"..Settings.delAllCmd },
	[Settings.findCmd] = {
		tFunc = function(user,data)
			local s,e,str = string.find(data,"^%S+%s+(%S+)")
			-- Typed str
			if str then
				user:SendPM(Settings.sBot,tFunctions.ShowEntry(string.rep("\t",9).."Search Results of: "..str..string.rep("\t",7)..
				"["..os.date().."]\r\n",tFunctions.EntryContent(2,str),Entry))
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.findCmd.." <string>")
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
		sDesc = "Finds an entry by any string",
		sExample = "!"..Settings.findCmd.." Matrix",
		tRC = "Find\\All$<%[mynick]> !"..Settings.findCmd.." %[line:String]" },
	[Settings.TimedCmd] = {
		tFunc = function(user,data)
			local s,e,arg = string.find(data,"^%S+%s+(%S+)")
			if arg then
				if string.lower(arg) == "on" then
					StartTimer() user:SendData(Settings.sBot,"*** Category rotator has been enabled.")
				elseif string.lower(arg) == "off" then
					StopTimer() user:SendData(Settings.sBot,"*** Category rotator has been disabled.")
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.TimedCmd.." <on/off>")
			end
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Set Category Rotator status",
		sExample = "!"..Settings.TimedCmd.." <on/off>",
		tRC = "Setup\\Rotator Status$<%[mynick]> !"..Settings.TimedCmd.." %[line:on/off]" },
	[Settings.voteCmd] = {
		tFunc = function(user,data)
			local s,e,cat,i = string.find(data,"^%S+%s+(%S+)%s+(%d+)") 
			-- Typed cat and ID
			if cat and i then
				-- Lower cat
				local Cat = string.lower(cat)
				-- DB contains Cat
				if Entry[Cat] then
					-- Cat contains ID
					if Entry[Cat][tonumber(i)] then
						-- Add Cat to Votes
						Votes[Cat] = Votes[Cat] or {}
						-- Check if IP has voted
						if Votes[Cat][user.sIP] then
							user:SendData(Settings.sBot,"*** Error: You have already voted.")
						else
							-- Add and save vote to Cat
							Votes[Cat][user.sIP] = 1
							Entry[Cat][tonumber(i)]["iVote"] = Entry[Cat][tonumber(i)]["iVote"] + 1
							tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fVote,Votes,"Votes")
							tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fEntry,Entry,"Entry")
							user:SendData(Settings.sBot,"You have successfully voted on \""..Entry[Cat][tonumber(i)].sRel.."\" [Category: "..cat.."].")
							SendPmToOps(Settings.sBot,user.sName.." voted on \""..Entry[Cat][tonumber(i)].sRel.."\" [Category: "..cat.."].")
						end
					else
						user:SendData(Settings.sBot,"*** Error: There is no ID: "..i.." in "..cat)
					end
				else
					user:SendData(Settings.sBot,"*** Error: There is no Category "..cat)
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.voteCmd.." <category> <ID>")
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
		sDesc = "Vote for a certain Entry",
		sExample = "!"..Settings.voteCmd.." Movies 1, !"..Settings.voteCmd.." Movies 1",
		tRC = "Vote\\Entry$<%[mynick]> !"..Settings.voteCmd.." %[line:Category] %[line:ID]" },
	[Settings.TopVotesCmd] = {
		tFunc = function(user,data)
			local Voting = {}
			-- Sort Votes
			tFunctions.TopSorting(2,Voting,6,Voting)
			user:SendPM(Settings.sBot,tFunctions.ShowEntry(string.rep("\t",9).."Top "..Settings.vMax.." Votes"..
			string.rep("\t",8).."["..os.date().."]\r\n     "..string.rep("-- --",65)..
			"\r\n     Nr.\tVotes\tDate - Time\t\tPoster\t\t\tCategory\t\t\tEntry\r\n",tFunctions.TopContent(1,Settings.vMax,1,1,Voting),Voting))
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
		sDesc = "Top Entry Voting",
		sExample = "!"..Settings.TopVotesCmd,
		tRC = "Votes$<%[mynick]> !"..Settings.TopVotesCmd },
	[Settings.clrVotesCmd] = {
		tFunc = function(user,data)
			-- Empty votes
			tFunctions.EntryContent(5,false); Votes = nil; Votes = {}
			tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fVote,Votes,"Votes")
			tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fEntry,Entry,"Entry")
			user:SendData(Settings.sBot,"All votes have been successfully cleared.")
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Clear all Votes",
		sExample = "!"..Settings.clrVotesCmd,
		tRC = "Vote\\Clear$<%[mynick]> !"..Settings.clrVotesCmd },
	[Settings.TopPosterCmd]	=	{
		tFunc = function(user,data)
			local TopPoster,tCopy = {},{}
			-- Sort Top Posters
			tFunctions.TopSorting(1,TopPoster,2,tCopy)
			user:SendPM(Settings.sBot,tFunctions.ShowEntry(string.rep("\t",8).."Top "..Settings.pMax..
			" Posters - Total Entries: "..tFunctions.EntryContent(7,"")..string.rep("\t",7).."["..os.date()..
			"]\r\n     "..string.rep("-- --",65).."\r\n     Nr.\tUser\t\t\tPosts\r\n",tFunctions.TopContent(1,Settings.pMax,1,2,tCopy),tCopy))
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
		sDesc = "Top Entry Voting",
		sExample = "!"..Settings.TopVotesCmd,
		tRC = "Top\\Posters$<%[mynick]> !"..Settings.TopPosterCmd },
	[Settings.helpCmd] = {
		tFunc = function(user)
			local sMsg = "\r\n\t"..string.rep("-", 220).."\r\n"..string.rep("\t",7).."Entry Bot v."..
			Settings.iVer.." by jiten\t\t\t\r\n\t"..string.rep("-",220).."\r\n\tAvailable Commands:".."\r\n\r\n"
			-- For each pair in tCmds
			for i,v in pairs(tCmds) do
				-- If user is allowed to use i command
				if tCmds[i].tLevels[user.iProfile] then
					sMsg = sMsg.."\t!"..i..tFunctions.DoTabs(tFunctions.CheckSize("!"..i))..v.sDesc..
					tFunctions.DoTabs(tFunctions.CheckSize(v.sDesc))..v.sExample.."\r\n";
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
		sDesc = "\tDisplays this help message",
		sExample = "!"..Settings.helpCmd,
		tRC = "Help$<%[mynick]> !"..Settings.helpCmd },
}

NewUserConnected = function(user)
	-- Send Entries on connect
	if Settings.SendOnConnect == 1 then
		user:SendPM(Settings.sBot,tFunctions.ShowEntry(string.rep("\t",8).."Last "..Settings.iMax.." entries per Category "..
		string.rep("\t",6).."["..os.date().."]\r\n",tFunctions.ShowXEntry(),Entry))
	end
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

-- EB core function
tFunctions.EntryContent = function(Mode,String)
	local msg = ""
	for Cat,a in pairs(Entry) do
		for i,v in ipairs(a) do
			local sLine = "     "..i..".\t"..v.iVote.."\t"..v.iTime.."\t\t"..v.sPoster..tFunctions.DoTabs(tFunctions.CheckSize(v.sPoster))..
			Cat..tFunctions.DoTabs(tFunctions.CheckSize(Cat))..v.sRel.."\r\n"
			local tMode = {
			-- Show all entries
			[1] = function ()
				msg = msg..sLine
			end,
			-- Find entries
			[2] = function()
				local tmp, where = v.sRel..v.sPoster..v.iTime..Cat
				if Settings.Sensitive == 1 then 
					where = tmp
				else
					where = string.lower(tmp) String = string.lower(String)
				end
				if string.find(where,String) then msg = msg..sLine end
			end,
			-- Show entries by category
			[4] = function()
				if string.lower(Cat) == string.lower(String) then msg = msg..sLine end
			end,
			-- Clear Votes
			[5] = function()
				if v.iVote > 0 then v.iVote = 0 end
			end,
			-- Delete all category content
			[6] = function()
				Entry[Cat][i] = nil
			end,
			-- table.getn
			[7] = function()
				if not tonumber(msg) then msg = 0 end
				if Entry[Cat][tonumber(i)] then msg = msg + 1 end
			end, }
			if tMode[Mode] then tMode[Mode]() end
		end
	end
	return msg
end

-- Last Entries
tFunctions.ShowXEntry = function()
	local msg = ""
	for Cat,a in pairs(Entry) do
		for v = table.getn(Entry[Cat]) - Settings.iMax + 1, table.getn(Entry[Cat]), 1 do
			if Entry[Cat][v] then
				msg = msg.."     "..v..".\t"..Entry[Cat][v].iVote.."\t"..Entry[Cat][v].iTime.."\t\t"..
				Entry[Cat][v].sPoster..tFunctions.DoTabs(tFunctions.CheckSize(Entry[Cat][v].sPoster))..
				Cat..tFunctions.DoTabs(tFunctions.CheckSize(Cat))..Entry[Cat][v].sRel.."\r\n"
			end
		end
	end
	return msg
end

-- TopVotes and TopPosters
tFunctions.TopContent = function(Start, End, Order, Mode, tTable)
	local msg = ""
	for i = Start, End, Order do
		if tTable[i] then
			local tMode = {
			-- Show TopVotes
			[1] = function()
				msg = msg.."     "..tTable[i][1]..".\t"..tTable[i][6].."\t"..tTable[i][5].."\t\t"..
				tTable[i][2]..tFunctions.DoTabs(tFunctions.CheckSize(tTable[i][2]))..tTable[i][3]..tFunctions.DoTabs(tFunctions.CheckSize(tTable[i][3]))..
				tTable[i][4]..tFunctions.DoTabs(tFunctions.CheckSize(tTable[i][4])).."\r\n"
			end,
			-- Show TopPosters
			[2] = function()
				msg = msg.."     "..i..".\t"..tTable[i][1]..tFunctions.DoTabs(tFunctions.CheckSize(tTable[i][1]))..
				tTable[i][2].." ("..string.format("%0.3f",tTable[i][3]*100).."%)\r\n"
			end, }
			if tMode[Mode] then tMode[Mode]() end
		end
	end
	return msg
end

-- Top Sorting
tFunctions.TopSorting = function(Mode,Table,Value,tTable)
	-- For each pair in Entry
	for Cat,a in pairs(Entry) do
		-- For each ipair in a
		for i,v in ipairs(a) do
			if Mode == 1 then
				-- Create TopPoster table
				if Table[v.sPoster] then Table[v.sPoster] = Table[v.sPoster] + 1 else Table[v.sPoster] = 1 end
			elseif Mode == 2 then
				-- If voted
				if v.iVote > 0 then
					-- Insert to TopVoter table
					table.insert(Table,{ i, v.sPoster, Cat, v.sRel, v.iTime, v.iVote })
				end
			end
		end
	end
	if Mode == 1 then
		-- Insert TopPoster data to tTable
		for x, y in pairs(Table) do table.insert(tTable, {x, tonumber(y), y/tonumber(tFunctions.EntryContent(7,false))}) end
	end
	-- Sort tTable
	table.sort(tTable,function(a,b) return (a[Value] > b[Value]) end)
end

-- Message structure
tFunctions.ShowEntry = function(Header, Content, Table)
	local msg, border = "\r\n".."     ",string.rep("-", 325)
	if Table == Entry then 
		msg = msg..border.."\r\n"..Header.."     "..string.rep("-- --",65).."\r\n     "..
		"Nr.\tVotes\tDate - Time\t\tPoster\t\t\tCategory\t\t\tEntry\r\n"
	else
		msg = msg..border..Header
	end
	msg = msg.."     "..string.rep("-- --",65).."\r\n"..Content.."     "..border.."\r\n"
	return msg
end

-- Timed Category
tFunctions.TimedCat = function()
	if (Settings.TimedCat == 1) and Settings.Times[os.date("%H:%M")] then
		local TimedMain = function(Category)
			local msg = "\r\n\r\n\t".." Category: "..Category.."\r\n\t"..string.rep("__",55).."\r\n\r\n\t• "
			-- For each pair in Entry
			for Cat,a in pairs(Entry) do
				for i,v in ipairs(a) do
					-- Cat equals Category
					if string.lower(Cat) == string.lower(Category) then
						local sCopy = v.sRel
						while string.len(sCopy) > 120 do
							msg = msg..string.sub(sCopy,1,120).."\r\n\t"
							sCopy  = string.sub(sCopy,121,string.len(sCopy))
						end
						msg = msg..sCopy.."\r\n\t• "
					end
				end
			end
			msg = string.sub(msg,1,string.len(msg)-2)
			msg = msg.."\r\n\t"..Settings.TimedMsg.."\r\n\t"..string.rep("__",55).."\r\n"
			return msg
		end
		SendToAll(TimedMain(Settings.Times[os.date("%H:%M")]))
	end
	collectgarbage(); io.flush();
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

-- Entry cleaner
tFunctions.Cleaner = function()
	if (Settings.Cleaner == 1) then -- RegCleaner based
		-- Actual juliandate
		local juliannow = tFunctions.jdate(tonumber(os.date("%d")), tonumber(os.date("%m")), tonumber(os.date("%Y"))) 
		local chkd, clnd, x = 0, 0, os.clock()
		-- For each pair in Entry
		for Cat,a in pairs(Entry) do
			-- Inverse loop
			for i = table.getn(Entry[Cat]), 1, -1 do
				chkd = chkd + 1 
				-- Parse Entry´s month, day and year
				local s, e, month, day, year = string.find(Entry[Cat][i].iTime, "(%d+)%/(%d+)%/(%d+)"); 
				-- Respective juliandate
				local julian = tFunctions.jdate( tonumber(day), tonumber(month), tonumber("20"..year) )
				-- Clean if higher than Cat´s expiry date
				if ((julian - juliannow) > tonumber(Entry[Cat].iClean)) then
					clnd = clnd + 1
					table.remove(Entry[Cat],i)
					tFunctions.SaveToFile(Settings.eFolder.."/"..Settings.fEntry,Entry,"Entry")
				end; 
			end
		end
		-- Send cleaning report
		if clnd ~= 0 and Settings.pCleaner == 1 then SendToAll(Settings.sBot,"Entry Cleaner: "..chkd..
		" entries were processed and "..clnd.." were deleted. ( "..string.format("%0.2f",((clnd*100)/chkd))..
		"% ) in: "..string.format("%0.4f", os.clock()-x ).." seconds.") end
	end
end

-- Juliandate function
tFunctions.jdate = function(d, m, y)
	local a, b, c = 0, 0, 0 if m <= 2 then y = y - 1; m = m + 12; end 
	if (y*10000 + m*100 + d) >= 15821015 then a = math.floor(y/100); b = 2 - a + math.floor(a/4) end
	if y <= 0 then c = 0.75 end return math.floor(365.25*y - c) + math.floor(30.6001*(m+1) + d + 1720994 + b)
end

-- nErBoS Release bot based
tFunctions.DoTabs = function(size)
	local sTmp = "" 
	if (size < 8) then sTmp = "\t\t\t" elseif (size < 16) then sTmp = "\t\t" else sTmp = "\t" end return sTmp
end

-- nErBoS Release bot based
tFunctions.CheckSize = function(String)
	local realSize,aux,remove = string.len(String),1,0
	while aux < realSize + 1 do
		for i=1, table.getn(Settings.sChar) do if (string.sub(String,aux,aux) == Settings.sChar[i]) then remove = remove + 0.5 end end
		aux = aux + 1
	end return realSize - remove
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