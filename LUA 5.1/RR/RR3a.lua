--[[

	Release/Request Bot v3a - LUA 5.0.2/5.1 by jiten (3/27/2006)

	Thanks to Star for the ideas and bug discovery gift

	Features:
	
	- Switch from Release to Request or other custom Mode; *new*
	- Each mode supports pre-defined categories; *new*
	- Automatic cleaner for each category (optional); *new*
	- Separate dbs/folders for each Mode;
	- Custom separator for entries;
	- Send latest posts on Connect (optional);
	- Custom prefix for each Mode;
	- RighClick sent in alphabetical order
	  Place a number behind the command to customize sending order (Delete --> 1. Category);
	- And much more...

	NOTE:	For those who want to run a Release and Request or Other custom Mode at the same time,
		start the first script and set it to Release Mode.
		Then, open the other one and set it to Request or Other Mode. And voila...
		Remember to verify if the commands are different from each other. 

	Changelog:

	- Changed: Major rewrite to the Code;
	- Removed: Lots of unnecessary code;
	- Added: Comments to the code;
	- Changed: Command parsing and table structure;
	- Removed: Levels table;
	- Changed: RightClick is sent in alphabetical order;
	- Changed: Cleaner;
	- Changed: Other mods.
	- Changed: Bot supports custom Modes besides Release and Request (NEW);
	- Added: Add, Show and Del Categories; Top Voter, Top Poster and Clear Votes commands;
	- Added: Cleaner for each Category;
	- Changed: RightClick is sent in alphabetical order;
	- Changed: Other mods;
	- Fixed: Missing prefix in showcat´s RC and Example;
	- Added: Timed Category content to main in a custom interval;
	- Added: Existing Categories for each command in RightClick - requested by BrotherBear (3/27/2006)

]]--

Settings = {
	-- Default Hub BotName or "custombot"
	sBot = frmHub:GetHubBotName(),
	-- true = Register Bot automatically, false = don't
	bReg = true,
	-- Release = Act as Release bot; Request = Act as Request Bot; Other = Act as Other Bot
	sMode = "Request",
	-- Script Version
	iVer = "3a",
	-- Separator for Release/Request and Type. Default one is "
	sSep = "\"",
	-- true = Start Timer automatically; false = don't
	bTimer = true,
	-- 1 = Send iMax Requests/Releases on connect; 0 = Don't
	bSendOnConnect = false,
	-- Max shown releases/requests
	iMax = 30,
	-- Max shown Filled Requests
	fMax = 30,
	-- Max shown Votes
	vMax = 20,
	-- Max shown Posters
	pMax = 20,
	-- Databases' filename
	fVote = "tVote.tbl",
	fConfig = "tConfig.tbl", 
	fRequest = "tRequest.tbl",
	fRelease = "tRelease.tbl",
	fReqDone = "tFilled.tbl",
	fOffline = "tOffline.tbl",
	-- Category´s Size
	iCatSize = 20,
	-- Release's size
	iRelSize = 90,
	-- Cleaner Checking Delay (in hours)
	iCleanDelay = 12,
	-- true = Sends cleaner actions to all; false = doesn't
	bCleanReport = true,
	-- true: Case-sensitive search; false: not case-sensitive
	bSensitive = false,
	-- true = Send RighClick; false = Don't
	bSendRC = true,
	-- true = Enable Timed Category content to Main, false = disable
	bTimedCat = false,
	-- Message shown below each Timed Category in Main
	sTimedMsg = "your message",
	-- ["time in 24h format"] = "Category" (not case sensitive)
	Times = {
		["12:00"] = "test",
	},
	-- false: Normal commands; true: Commands with Prefix (default)
	bPrefix = true,
	-- Commands
	addCmd = "add", delCmd = "del", showCmd = "show", findCmd = "find",
	delAllCmd = "delall", voteCmd = "vote", TopVotesCmd = "topvoter", 
	clrVotesCmd = "clrvote",  TopPosterCmd = "topposter", helpCmd = "help", rDoneCmd = "done",
	SetupCmd = "setup", addCatCmd = "addcat", delCatCmd = "delcat", showCatCmd = "showcat",
}

tConfig = {}; tFilled = {}; tOffline = {}; tVote = {}; tabTimers = {n=0}; TmrFreq = 60*1000;

-- ATTENTION: Don't change this
tPrefix = ""; 

-- Setup your Prefixes and Folders here
tSetup = { 

--[[

	From now on, you can create your own Mode. Just follow this example:

	-- This should be the same string used in Settings.sMode. It MUST be in lower-case here.
	other = { 

		-- Prefix for its commands
		sPrefix = "other",

		-- Folder where the DBs will be stored
		sFolder = "Others",

		-- Files related to the Mode (First one is the Main DB)
		fDB = { Settings.fRelease, Settings.fConfig, Settings.fVote },
	},

]]--

	-- Release Bot Setup
	release = { 
		-- Prefix for its commands
		sPrefix = "rel",
		-- Folder where the DBs will be stored
		sFolder = "Releases",
		-- Files related to the Mode (First one is the Main DB)
		fDB = { Settings.fRelease, Settings.fConfig, Settings.fVote },
	},
	-- Request Bot Setup
	request = { 
		-- Prefix for its commands
		sPrefix = "req",
		-- Folder where the DBs will be stored
		sFolder = "Requests",
		-- Files related to the Mode (First one is the Main DB)
		fDB = { Settings.fRequest, Settings.fReqDone, Settings.fOffline, Settings.fConfig, Settings.fVote },
	},
}

-- Prefix setup
if Settings.bPrefix then tPrefix = tSetup[string.lower(Settings.sMode)].sPrefix end

Main = function()
	-- Register sBot
	if Settings.bReg then frmHub:RegBot(Settings.sBot) end
	-- Register Timers
	tFunctions.RegTimer(tFunctions.Cleaner, Settings.iCleanDelay*60*60*1000);
	tFunctions.RegTimer(tFunctions.TimedCat, 60*1000);
	-- Set and Start
	SetTimer(TmrFreq); if Settings.bTimer then StartTimer() end;
	-- Create tTable and load its contents
	if tSetup[string.lower(Settings.sMode)] then tTable = {}; tFunctions:load() end
	-- Define cleaner and link status
	tConfig.Cleaner = tConfig.Cleaner or "on"; tConfig.Link = tConfig.Link or "off"
end

ChatArrival = function(user,data)
	-- Parse Main Chat commands
	local data = string.sub(data,1,-2)
	local s,e,msg = string.find(data,"^%b<>%s+[%!%+](.*)")
	if msg then return tFunctions.ParseCommands(user,msg) end
end

ToArrival = function(user,data)
	-- Parse PM commands
	local data = string.sub(data,1,-2)
	local s,e,to,msg = string.find(data, "^%$To:%s+(%S+)%s+From:%s+%S+%s-%$%b<>%s+[%!%+](.*)")
	if to == Settings.sBot and msg then return tFunctions.ParseCommands(user, msg) end
end

tCmds = {
	[Settings.clrVotesCmd] = {
		tFunc = function(user,data)
			-- Empty votes
			tFunctions.Releaser(5); tVote = nil; tVote = {}
			tFunctions:save(tTable); tFunctions:save(tVote,"tVote",Settings.fVote)
			user:SendData(Settings.sBot,"*** All votes have been successfully cleared.")
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Clear all Votes",
		sExample = "\t!"..tPrefix..Settings.clrVotesCmd,
		tRC = "Vote\\Clear$<%[mynick]> !"..tPrefix..Settings.clrVotesCmd },
	[Settings.voteCmd] = {
		tFunc = function(user,data)
			local s,e,cat,i = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep.."%s+(%d+)") 
			-- Typed cat and ID
			if cat and i then
				-- Lower cat
				local Cat = string.lower(cat)
				-- DB contains Cat
				if tTable[Cat] then
					-- Cat contains ID
					if tTable[Cat][tonumber(i)] then
						-- Add Cat to Votes
						tVote[Cat] = tVote[Cat] or {}
						-- Check if IP has voted
						if tVote[Cat][user.sIP] then
							user:SendData(Settings.sBot,"*** Error: You have already voted.")
						else
							-- Add and save vote to Cat
							tVote[Cat][user.sIP] = 1
							tTable[Cat][tonumber(i)]["iVote"] = tTable[Cat][tonumber(i)]["iVote"] + 1; tFunctions:save(tTable); tFunctions:save(tVote,"tVote",Settings.fVote)
							user:SendData(Settings.sBot,"*** You have successfully voted on \""..tTable[Cat][tonumber(i)].sRel.."\" [Category: "..cat.."].")
							SendPmToOps(Settings.sBot,"*** "..user.sName.." voted on \""..tTable[Cat][tonumber(i)].sRel.."\" [Category: "..cat.."].")
						end
					else
						user:SendData(Settings.sBot,"*** Error: There is no ID: "..i.." in "..cat)
					end
				else
					user:SendData(Settings.sBot,"*** Error: There is no Category \""..cat.."\"!")
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..tPrefix..Settings.voteCmd.." <category> <ID>")
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\tVote for a certain "..Settings.sMode,
		sExample = "!"..tPrefix..Settings.voteCmd.." "..Settings.sSep.."Movies"..Settings.sSep.." 1",
		tRC = "Vote\\"..Settings.sMode.."\\{}$<%[mynick]> !"..tPrefix..Settings.voteCmd.." "..Settings.sSep.."{}"..Settings.sSep.." %[line:ID]",
		bExtend = true,
	},
	[Settings.TopVotesCmd] = {
		tFunc = function(user)
			local Voting = {}
			-- Sort Votes
			tFunctions.TopSorting(2,Voting,6,Voting)
			user:SendPM(Settings.sBot,tFunctions.Structure(string.rep("\t",9).."Top "..Settings.vMax.." Votes"..
			string.rep("\t",8).."["..os.date().."]\r\n     "..string.rep("-- --",65)..
			"\r\n     Nr.\tVotes\tDate - Time\t\tPoster\t\t\tCategory\t\t\t"..Settings.sMode.."\r\n",tFunctions.TopContent(1,Settings.vMax,1,1,Voting),Voting))
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
		sDesc = "Top "..Settings.sMode.." Voting",
		sExample = "\t!"..tPrefix..Settings.TopVotesCmd,
		tRC = "Top\\Voters$<%[mynick]> !"..tPrefix..Settings.TopVotesCmd
	},
	[Settings.TopPosterCmd]	=	{
		tFunc = function(user)
			local TopPoster,tCopy = {},{}
			-- Sort Top Posters
			tFunctions.TopSorting(1,TopPoster,2,tCopy)
			user:SendPM(Settings.sBot,tFunctions.Structure(string.rep("\t",8).."Top "..Settings.pMax..
			" Posters - Total "..Settings.sMode.."s: "..tFunctions.Releaser(7)..string.rep("\t",7).."["..os.date()..
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
		sDesc = "Top "..Settings.sMode.." Voting",
		sExample = "\t!"..tPrefix..Settings.TopVotesCmd,
		tRC = "Top\\Posters$<%[mynick]> !"..tPrefix..Settings.TopPosterCmd
	},
	[Settings.addCatCmd] = {
		tFunc = function(user,data)
			local s,e,cat,date = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep.."%s+(%d+)") 
			-- Category and date found
			if cat and date then
				-- Lower category
				local Cat = string.lower(cat)
				-- DB contains it
				if tTable[Cat] then
					user:SendData(Settings.sBot,"*** Error: There is already a Category: \""..cat.."\"")
				else
					-- Check category´s size
					if (string.len(cat) > Settings.iCatSize) then
						user:SendData(Settings.sBot,"*** Error: The Category can't have more than "..Settings.iCatSize.." characters.")
					else
						-- Create and save category
						tTable[Cat] = {}; tTable[Cat].iClean = tonumber(date); tFunctions:save(tTable)
						user:SendData(Settings.sBot,"*** \""..cat.."\" was successfully added to "..Settings.sMode.."s´ categories.")
					end
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..tPrefix..Settings.addCatCmd.." "..Settings.sSep.."category"..Settings.sSep.." <maximum time in days>")
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Add category & time",
		sExample = "\t!"..tPrefix..Settings.addCatCmd.." "..Settings.sSep.."Movies"..Settings.sSep.." 15",
		tRC = "Add\\Category$<%[mynick]> !"..tPrefix..Settings.addCatCmd.." "..Settings.sSep.."%[line:Category]"..Settings.sSep.." %[line:LifeTime in Days]"
	},
	[Settings.delCatCmd] = {
		tFunc = function(user,data)
			local s,e,cat = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep) 
			-- Typed category
			if cat then
				-- Lower it
				local Cat = string.lower(cat)
				-- DB contains it
				if tTable[Cat] then
					-- Delete and save DB
					tTable[Cat] = nil; tFunctions:save(tTable)
					user:SendData(Settings.sBot,"*** \""..cat.."\" was sucessfully deleted from "..Settings.sMode.."s´ categories.")
				else
					user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat.." in "..Settings.sMode..".")
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..tPrefix..Settings.delCatCmd.." <category>")
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\tDeletes a category",
		sExample = "\t!"..tPrefix..Settings.delCatCmd.." "..Settings.sSep.."Movies"..Settings.sSep.."",
		tRC = "Delete\\Category\\{}$<%[mynick]> !"..tPrefix..Settings.delCatCmd.." "..Settings.sSep.."{}"..Settings.sSep,
		bExtend = true,
	},
	[Settings.showCatCmd] =	{
		tFunc = function(user)
			-- tTable table isn`t empty
			if next(tTable) then
				local msg = "\r\n\r\n".."\t"..string.rep("- -",20).."\r\n\t        "..Settings.sMode.."s´ Category List:\r\n\t"..
				string.rep("- -",20).."\r\n"
				-- For each pair in it
				for Cat,i in pairs(tTable) do
					msg = msg.."\t       • "..string.upper(string.sub(Cat,1,1))..string.sub(Cat,2,string.len(Cat)).." ("..i.iClean.." days)\r\n" 
				end
				user:SendData(Settings.sBot,msg) 
			else
				user:SendData(Settings.sBot,"*** Error: There are no "..Settings.sMode.." categories!");
			end
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "Shows categories",
		sExample = "\t!"..tPrefix..Settings.showCatCmd,
		tRC = "Show\\Categories$<%[mynick]> !"..tPrefix..Settings.showCatCmd
	},
	[Settings.addCmd] = {	
		tFunc = function(user,data)
			local s,e,cat,rel = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep.."%s+"..Settings.sSep.."(.+)"..Settings.sSep)
			local s,e,link = string.find(data,"^%S+%s+%S+%s+%S+%s+(.+)") 
			link = link or ""
			if (tConfig.Link == "off") or (tConfig.Link == "on" and link and link ~= "") then
				-- Typed category
				if cat then
					-- Lower it
					local Cat = string.lower(cat)
					-- DB contains it
					if tTable[Cat] then
						if (string.len(rel) > Settings.iRelSize) then
							user:SendData(Settings.sBot,"*** Error: The "..Settings.sMode.."s can't have more than "..Settings.iRelSize.." characters.")
						else
							local Exists = nil
							-- For each pair in the category
							for i,v in ipairs(tTable[Cat]) do
								-- Check if rel doesn´t exist
								if tTable[Cat] and string.lower(v.sRel) == string.lower(rel) then Exists = 1 end
							end
							if Exists then
								user:SendData(Settings.sBot,"*** Error: There's already a "..Settings.sMode.." named: \""..rel.."\".")
							else
								table.insert( tTable[Cat], { sRel = rel, sPoster = user.sName, sLink = link, iTime = os.date(), iVote = 0, } ); tFunctions:save(tTable);
								SendToAll(Settings.sBot,"*** "..user.sName.." added a new "..Settings.sMode..": "..rel..". For more details type: !"..tPrefix..Settings.showCmd)
							end
						end

					else
						user:SendData(Settings.sBot,"*** Error: There is no Category: \""..cat.."\" in "..Settings.sMode.."s!")
					end
				else
					user:SendData(Settings.sBot,"*** Syntax Error: Type !"..tPrefix..Settings.addCmd.." <category> <type>")
				end
			else
				user:SendData(Settings.sBot,"*** Error: Type !"..tPrefix..Settings.addCmd.." "..Settings.sSep..
				"Type"..Settings.sSep.." "..Settings.sSep..Settings.sMode..Settings.sSep.." <link> (Link is required)")
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\tAdds a "..Settings.sMode,
		sExample = "\t!"..tPrefix..Settings.addCmd.." "..Settings.sSep.."Movie"..Settings.sSep.." "..Settings.sSep.."Blade3"..Settings.sSep.." http://www.blade.com",
		tRC = "Add\\"..Settings.sMode.."\\{}$<%[mynick]> !"..tPrefix..Settings.addCmd.." "..Settings.sSep.."{}"..Settings.sSep.." "..Settings.sSep.."%[line:Release]"..Settings.sSep.." %[line:Link]",
		bExtend = true,
	},
	[Settings.delCmd] = {	
		tFunc = function(user,data)
			local s,e,cat,rel = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep.."%s*(.+)") 
			-- Typed cat and rel
			if cat and rel then
				-- Lower cat
				local Cat = string.lower(cat)
				-- Rel is a number
				if tonumber(rel) then
					rel = tonumber(rel) local Deleted = nil
					-- Category contains rel - delete it
					if tTable[Cat] and tTable[Cat][rel] then table.remove(tTable[Cat],rel) Deleted = 1 end
					if Deleted then 
						user:SendData(Settings.sBot,"*** ID: "..rel.." was successfully deleted."); tFunctions:save(tTable)
					else
						user:SendData(Settings.sBot,"*** Error: There is no ID: "..rel..".")
					end
				-- DB contains Cat
				elseif tTable[Cat] then
					local Deleted = nil
					-- Delete each pair in Cat
					for i in ipairs(tTable[Cat]) do
						tTable[Cat][i] = nil; Deleted = 1
					end
					if Deleted then
						user:SendData(Settings.sBot,"Category: \""..cat.."\" was succesfully cleaned up."); tFunctions:save(tTable)
					else
						user:SendData(Settings.sBot,"*** Error: There is no Category: \""..cat.."\"")
					end
				else
					user:SendData(Settings.sBot,"*** Error: There is no ID/Category: \""..cat.."\"")
				end
			else
				user:SendData(Settings.sBot,"*** Syntax Error: Type !"..tPrefix..Settings.delCmd.." "..Settings.sSep.."%[line:{}]"..Settings.sSep.." <ID> / Empty>")
			end
		end, 
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\tDeletes "..Settings.sMode.."s",
		sExample = "\t!"..tPrefix..Settings.delCmd.." "..Settings.sSep.."Category"..Settings.sSep.." ID/Empty",
		tRC = "Delete\\"..Settings.sMode.."\\{}$<%[mynick]> !"..tPrefix..Settings.delCmd.." "..Settings.sSep.."{}"..Settings.sSep.." %[line:ID/Empty]",
		bExtend = true,
	},
	[Settings.showCmd] = { 
		tFunc = function(user,data)
			local s,e,cat = string.find(data,"^%S+%s+(%S+)")
			-- Shows all
			if cat then
				if cat == "all" then
					-- Data sent according to Selected mode and if tFilled isn't empty
					if string.lower(Settings.sMode) == "request" and next(tFilled) then
						user:SendPM(Settings.sBot,tFunctions.Structure(string.rep("\t",9).."Showing all "..Settings.sMode.."s ["..
						tFunctions.Releaser(7).."]"..string.rep("\t",7).."["..os.date()..
						"]\r\n", tFunctions.Releaser(1),tTable)..tFunctions.Structure(string.rep("\t",9)..
						"Showing all Filled Requests"..string.rep("\t",6).."["..
						os.date().."]\r\n",tFunctions.ShowX(tFilled),tFilled))
					else
						user:SendPM(Settings.sBot,tFunctions.Structure(string.rep("\t",9).."Showing all "..Settings.sMode.."s ["..
						tFunctions.Releaser(7).."]"..string.rep("\t",7).."["..os.date()..
						"]\r\n", tFunctions.Releaser(1),tTable))
					end
				-- Show category entries
				elseif tTable[string.lower(cat)] then
					user:SendPM(Settings.sBot,tFunctions.Structure(string.rep("\t",8).."Showing all "..Settings.sMode.."s from \""..cat.."\" "..
					string.rep("\t",7).."["..os.date().."]\r\n",tFunctions.Releaser(4,cat),tTable))
				end
			else
				-- Data sent according to Selected mode and if tFilled isn't empty
				if string.lower(Settings.sMode) == "request" and next(tFilled) then
					user:SendPM(Settings.sBot,tFunctions.Structure(string.rep("\t",9).."Last "..Settings.iMax.." "..Settings.sMode.."s "..
					string.rep("\t",8).."["..os.date().."]\r\n",tFunctions.ShowX(tTable),tTable)..tFunctions.Structure(string.rep("\t",9)..
					"Last "..Settings.fMax.." Filled Requests"..string.rep("\t",7).."["..os.date().."]\r\n",tFunctions.ShowX(tFilled),tFilled))
				else
					user:SendPM(Settings.sBot,tFunctions.Structure(string.rep("\t",8).."Last "..Settings.iMax.." "..Settings.sMode.."s per Category "..
					string.rep("\t",7).."["..os.date().."]\r\n",tFunctions.ShowX(tTable),tTable))
				end
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
		sDesc = "\tLast "..Settings.iMax.."/all "..Settings.sMode.."s",
		sExample = "!"..tPrefix..Settings.showCmd.."; !"..tPrefix..Settings.showCmd.." all; !"..tPrefix..Settings.showCmd.." <category>",
		tRC = "Show\\Last "..Settings.iMax.."/All$<%[mynick]> !"..tPrefix..Settings.showCmd.." %[line:Empty/All/Category]",
	},
	[Settings.findCmd] = { 
		tFunc = function(user,data)
			local s,e,str = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep)
			if str then
				user:SendPM(Settings.sBot,tFunctions.Structure(string.rep("\t",9).."Search Results of: \""..str.."\""..string.rep("\t",7)..
				"["..os.date().."]\r\n",tFunctions.Releaser(2,str),tTable))
			else
				user:SendData(Settings.sBot,"*** Error: Type !"..tPrefix..Settings.findCmd.." "..Settings.sSep.."string"..Settings.sSep)
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
		sDesc = "\tFind a "..Settings.sMode,
		sExample = "\t!"..tPrefix..Settings.findCmd.." "..Settings.sSep.."jiten"..Settings.sSep,
		tRC = "Find\\"..Settings.sMode.."$<%[mynick]> !"..tPrefix..Settings.findCmd.." "..Settings.sSep.."%[line:String]"..Settings.sSep
	},
	[Settings.delAllCmd] = { 
		tFunc = function(user)
			-- Delete all table contents
			tFunctions.Releaser(6)
			user:SendData(Settings.sBot,"All "..Settings.sMode.."s have been deleted successfully!"); tFunctions:save(tTable)
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\tDeletes all "..Settings.sMode.."s",
		sExample = "!"..tPrefix..Settings.delAllCmd,
		tRC = "Delete\\All$<%[mynick]> !"..tPrefix..Settings.delAllCmd
	},
	[Settings.helpCmd] = { 
		tFunc = function(user)
			local sMsg, sRC = "\r\n\t"..string.rep("-", 220).."\r\n\t[Cleaner / Link]: ["..tConfig.Cleaner.." / "..
			tConfig.Link.."]\t\t\tRelease/Request v."..Settings.iVer.." by jiten\t\t\t\t["..Settings.sMode.." Mode]\r\n\t"..
			string.rep("-",220).."\r\n\tCommands:\t\tDescription:\t\t\tExample:".."\r\n\r\n", ""
			-- For each pair in tCmds
			for i,v in pairs(tCmds) do
				-- If user is allowed to use i command
				if v.tLevels[user.iProfile] then
					local sHelp = "\t!"..tPrefix..i.."\t\t"..v.sDesc.."\t\t"..v.sExample.."\r\n"
					if string.lower(Settings.sMode) == "request" then
						sMsg = sMsg..sHelp
					elseif i ~= Settings.rDoneCmd then
						sMsg = sMsg..sHelp
					end
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
		sDesc = "\tDisplays this help.",
		sExample = "\t!"..tPrefix..Settings.helpCmd,
		tRC = "Help$<%[mynick]> !"..tPrefix..Settings.helpCmd
	},
	[Settings.rDoneCmd] = { 
		tFunc = function(user,data)
			local s,e,cat,rel = string.find(data,"^%S+%s+"..Settings.sSep.."(.+)"..Settings.sSep.."%s+(%d+)") 
			if string.lower(Settings.sMode) == "request" then
				if cat and rel then
					-- Lower it
					local Cat, sTmp = string.lower(cat), ""
					rel = tonumber(rel); local Deleted = nil
					-- Category contains rel - delete it
					if tTable[Cat] and tTable[Cat][rel] then
						local tmp = tTable[Cat][rel]
						tFilled[Cat] = tFilled[Cat] or {}; Exists = 1
						table.insert(tFilled[Cat], { sPoster = user.sName, sRel = tmp.sRel, iVote = tmp.iVote, iTime = os.date(), sLink = tmp.sLink } ) 
					end
					if Exists then 
						-- Send/Store tFilled Report
						local tmp = tTable[Cat][rel]
						local msg, nick = "*** Your request \""..tmp.sRel.."\" has been filled by "..user.sName..".", GetItemByName(tmp.sPoster); 
						if nick then nick:SendPM(Settings.sBot,msg) else tOffline[tmp.sPoster] = msg end; table.remove(tTable[Cat],rel); 
						SendToAll(Settings.sBot,"*** "..user.sName.." filled up Request \""..tmp.sRel.."\" [ "..cat.." ]!")
						tFunctions:save(tTable); tFunctions:save(tFilled,"tFilled",Settings.fReqDone); tFunctions:save(tOffline,"tOffline",Settings.fOffline);
					else
						user:SendData(Settings.sBot,"*** Error: There is no ID: "..rel..".")
					end
				else
					user:SendData(Settings.sBot,"*** Error: Type !"..tPrefix..Settings.rDoneCmd.." "..Settings.sSep.."Category"..Settings.sSep.." <ID>")
				end
			else
				user:SendData(Settings.sBot,"*** Error: This command is only available in Request Mode!")
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
		sDesc = "\tFills up a Request",
		sExample = "\t!"..tPrefix..Settings.rDoneCmd.." "..Settings.sSep.."Category"..Settings.sSep.." <ID>",
		tRC = "Fill\\Up Request\\{}$<%[mynick]> !"..tPrefix..Settings.rDoneCmd.." "..Settings.sSep.."{}"..Settings.sSep.." %[line:ID]",
		bExtend = true,
	},
	[Settings.SetupCmd] = { 
		tFunc = function(user,data)
			local s,e,set,value = string.find(data,"^%S+%s+(%S+)%s+(%S+)")
			if set and value then
				local tTable = {
					["cleaner"] = {
						["on"] = { tFunc = function() tConfig.Cleaner = "on"; StartTimer() end, sMode = "enabled" },
						["off"] = { tFunc = function() tConfig.Cleaner = "off"; StopTimer() end, sMode = "disabled" },
						sMsg = "*** The Automatic "..Settings.sMode.." cleaner has been set to "
					},
					["link"] = {
						["on"] = { tFunc = function() tConfig.Link = "on" end, sMode = "not optional" },
						["off"] = { tFunc = function() tConfig.Link = "off" end, sMode = "optional" },
						sMsg = "*** The Link has been set to "
					}
				}
				if tTable[string.lower(set)][string.lower(value)] then
					local tmp = tTable[string.lower(set)]; tmp[string.lower(value)].tFunc(); tFunctions:save(tConfig,"tConfig",Settings.fConfig)
					user:SendData(Settings.sBot,tmp.sMsg..tmp[string.lower(value)].sMode.."!")
				else
					user:SendData(Settings.sBot,"*** Error: Type !"..tPrefix..Settings.SetupCmd.." <link/cleaner> <on/off>")
				end
			else
				user:SendData(Settings.sBot,"*** Error: Type !"..tPrefix..Settings.SetupCmd.." <link/cleaner> <on/off>")
			end
		end,
		tLevels = {
			[0] = 1,
			[1] = 1,
			[4] = 1,
			[5] = 1,
		},
		sDesc = "\tConfigure this bot.",
		sExample = "\t!"..tPrefix..Settings.SetupCmd.." <link/cleaner> <on/off>",
		tRC = "Setup\\Cleaner/Link$<%[mynick]> !"..tPrefix..Settings.SetupCmd.." %[line:cleaner/link] %[line:on/off]"
	},
}

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

NewUserConnected = function(user)
	-- Send Releases/Requests on Connect
	if Settings.bSendOnConnect then
		user:SendPM(Settings.sBot,tFunctions.Structure(string.rep("\t",9).."Last "..Settings.iMax.." "..Settings.sMode.."s per Category "..
		string.rep("\t",6).."["..os.date().."]\r\n",tFunctions.ShowX(tTable),tTable))
	end
	-- Sending RightClick
	if Settings.bSendRC then
		if user.bUserCommand then
			-- Build user-specific temp RC table
			local tRC = {}; tFunctions.GetRC(user,tRC); table.sort(tRC);
			-- Send RC alphabetically sorted
			for i in ipairs(tRC) do 
				user:SendData("$UserCommand 1 3 "..Settings.sMode.." Bot\\"..tRC[i].."&#124;")
			end;
			collectgarbage(); io.flush();
		end
	end
	-- Offline tFilled Report
	if tOffline[user.sName] then user:SendPM(Settings.sBot,tOffline[user.sName]); tOffline[user.sName] = nil end
end

OpConnected = NewUserConnected

tFunctions = {}

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

-- Timed Category
tFunctions.TimedCat = function()
	if Settings.bTimedCat and Settings.Times[os.date("%H:%M")] then
		local TimedMain = function(Category)
			local msg = "\r\n\r\n\t".." Category: "..Category.."\r\n\t"..string.rep("__",55).."\r\n\r\n\t• "
			-- For each pair in tTable
			for Cat,a in pairs(tTable) do
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
			msg = msg.."\r\n\t"..Settings.sTimedMsg.."\r\n\t"..string.rep("__",55).."\r\n"
			return msg
		end
		SendToAll(TimedMain(Settings.Times[os.date("%H:%M")]))
	end
	collectgarbage(); io.flush();
end

-- Category content cleaner
tFunctions.Cleaner = function()
	if (tConfig.Cleaner == "on") then -- RegCleaner based
		-- Actual juliandate
		local juliannow = tFunctions.jdate(tonumber(os.date("%d")), tonumber(os.date("%m")), tonumber(os.date("%Y"))) 
		local chkd, clnd, x = 0, 0, os.clock()
		-- For each pair in tTable
		for Cat,a in pairs(tTable) do
			-- Inverse loop
			for i = table.getn(tTable[Cat]), 1, -1 do
				chkd = chkd + 1 
				-- Parse month, day and year
				local s, e, month, day, year = string.find(tTable[Cat][i].iTime, "(%d+)%/(%d+)%/(%d+)"); 
				-- Respective juliandate
				local julian = tFunctions.jdate( tonumber(day), tonumber(month), tonumber("20"..year) )
				-- Clean if higher than Cat´s expiry date
				if ((julian - juliannow) > tonumber(tTable[Cat].iClean)) then
					clnd = clnd + 1
					table.remove(tTable[Cat],i);
				end; 
			end
		end
		-- Sending Stats
		if clnd ~= 0 and Settings.bCleanReport then 
			SendToAll(Settings.sBot,"*** "..chkd.." "..Settings.sMode.."(s) were processed. "..clnd.." "..Settings.sMode..
			"s were deleted ( "..string.format("%0.2f",(clnd*100/chkd)).."% ) in: "..string.format("%0.4f", os.clock()-x )
			.." seconds."); tFunctions:save(tTable)
		end
	end
end

-- Get user-specific RightClick
tFunctions.GetRC = function(user,tTempTable)
	for i,v in pairs(tCmds) do
		if tCmds[i].tLevels[user.iProfile] then 
			local fExtend = function()
				if v.bExtend then
					for Cat,a in pairs(tTable) do
						local sRC = string.gsub(v.tRC,"{}",Cat)
						table.insert(tTempTable,sRC) 
					end
				else
					table.insert(tTempTable,v.tRC) 
				end
			end
			if string.lower(Settings.sMode) ~= "request" then
				if i ~= Settings.rDoneCmd then fExtend() end
			else
				fExtend()
			end
		end
	end
end

tFunctions.ShowX = function(Table)
	local msg = ""
	for Cat,a in pairs(Table) do
		for v = table.getn(Table[Cat]) - Settings.iMax + 1, table.getn(Table[Cat]), 1 do
			if Table[Cat][v] then
				local tmp = Table[Cat][v]
				local fLink = function()
					local lnk = ""
					if tmp.sLink ~= "" then lnk = "\r\n"..string.rep("\t",11).."[ "..tmp.sLink.." ]" end
					return lnk
				end
				msg = msg.."     "..v..".\t"..tmp.iVote.."\t"..tmp.iTime.."\t\t"..tmp.sPoster..
				tFunctions.DoTabs(tFunctions.CheckSize(tmp.sPoster))..Cat..tFunctions.DoTabs(tFunctions.CheckSize(Cat))..tmp.sRel..fLink().."\r\n"
			end
		end
	end
	return msg
end

-- TopVotes and TopPosters
tFunctions.TopContent = function(Start, End, Order, Mode, Table)
	local msg = ""
	for i = Start, End, Order do
		if Table[i] then
			local tMode = {
			-- Show TopVotes
			[1] = function()
				msg = msg.."     "..Table[i].iID..".\t"..Table[i].iVote.."\t"..Table[i].iTime.."\t\t"..
				Table[i].sPoster..tFunctions.DoTabs(tFunctions.CheckSize(Table[i].sPoster))..Table[i].sCat..tFunctions.DoTabs(tFunctions.CheckSize(Table[i].sCat))..
				Table[i].sRel..tFunctions.DoTabs(tFunctions.CheckSize(Table[i].sRel)).."\r\n"
			end,
			-- Show TopPosters
			[2] = function()
				msg = msg.."     "..i..".\t"..Table[i][1]..tFunctions.DoTabs(tFunctions.CheckSize(Table[i][1]))..
				Table[i][2].." ("..string.format("%0.3f",Table[i][3]*100).."%)\r\n"
			end, }
			if tMode[Mode] then tMode[Mode]() end
		end
	end
	return msg
end

-- Top Sorting
tFunctions.TopSorting = function(Mode,Table,Value,Table1)
	-- For each pair in tTable
	for Cat,a in pairs(tTable) do
		-- For each ipair in a
		for i,v in ipairs(a) do
			if Mode == 1 then
				-- Create TopPoster table
				if Table[v.sPoster] then Table[v.sPoster] = Table[v.sPoster] + 1 else Table[v.sPoster] = 1 end
			elseif Mode == 2 then
				-- If voted
				if v.iVote > 0 then
					-- Insert to TopVoter table
					table.insert(Table,{ iID = i, sPoster = v.sPoster, sCat = Cat, sRel = v.sRel, iTime = v.iTime, iVote = v.iVote })
				end
			end
		end
	end
	if Mode == 1 then
		-- Insert TopPoster data to Table1
		for x, y in pairs(Table) do table.insert(Table1, {x, tonumber(y), y/tonumber(tFunctions.Releaser(7))}) end
	end
	-- Sort Table1
	table.sort(Table1,function(a,b) return (a[Value] > b[Value]) end)
end

tFunctions.ParseCommands = function(user,data)
	local s,e,cmd = string.find(data,"^"..tPrefix.."(%S+)")
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

-- RR core function
tFunctions.Releaser = function(Mode,String)
	local msg = ""
	for Cat,a in pairs(tTable) do
		for i,v in ipairs(a) do
			local fLink = function()
				local tmp = ""
				if v.sLink ~= "" then tmp = "\r\n"..string.rep("\t",11).."[ "..v.sLink.." ]" end
				return tmp
			end
			local sLine = "     "..i..".\t"..v.iVote.."\t"..v.iTime.."\t\t"..v.sPoster..tFunctions.DoTabs(tFunctions.CheckSize(v.sPoster))..Cat..
			tFunctions.DoTabs(tFunctions.CheckSize(Cat))..v.sRel..fLink().."\r\n"
			local tMode = {
			-- Show all entries
			[1] = function ()
				msg = msg..sLine
			end,
			-- Find entries
			[2] = function()
				local tmp, where = v.sRel..v.sPoster..v.sLink..v.iTime..Cat
				if Settings.bSensitive then 
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
				tTable[Cat][i] = nil;
				tFilled = nil tFilled = {};
				tOffline = nil tOffline = {}
			end,
			-- table.getn
			[7] = function()
				if not tonumber(msg) then msg = 0 end
				if tTable[Cat][tonumber(i)] then msg = msg + 1 end
			end, }
			if tMode[Mode] then tMode[Mode]() end
		end
	end
	return msg
end

tFunctions.Structure = function(Header, Content, Table)
	local msg, border = "\r\n".."     ",string.rep("-", 325)
	if Table == tTable or Table == tFilled then 
		msg = msg..border.."\r\n"..Header.."     "..string.rep("-- --",65).."\r\n     "..
		"Nr.\tVotes\tDate - Time\t\tPoster\t\t\tCategory\t\t\t"..Settings.sMode.."\r\n"
	else
		msg = msg..border..Header
	end
	msg = msg.."     "..string.rep("-- --",65).."\r\n"..Content.."     "..border.."\r\n"
	return msg
end

-- Julian data function
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
	local sChar = { "-", " ", "i", "l", "r", "t", "I", "y", "o", }
	while aux < realSize + 1 do
		for i=1, table.getn(sChar) do if (string.sub(String,aux,aux) == sChar[i]) then remove = remove + 0.5 end end
		aux = aux + 1
	end return realSize - remove
end

-- File handling functions
tFunctions.load = function(self)
	local tmp = tSetup[string.lower(Settings.sMode)]
	if tmp then
		for i in ipairs(tmp.fDB) do
			if loadfile(tmp.sFolder.."/"..tmp.fDB[i]) then
				dofile(tmp.sFolder.."/"..tmp.fDB[i]) 
			else
				os.execute("mkdir "..tmp.sFolder); io.output(tmp.sFolder.."/"..tmp.fDB[i])
			end
		end
	end
end

tFunctions.save = function(self,table,tablename,file)
	local tmp = tSetup[string.lower(Settings.sMode)]
	if tmp then 
		file = file or tmp.fDB[1]; tablename = tablename or "tTable"
		local hFile = io.open(tmp.sFolder.."/"..file,"w+") 
		tFunctions.Serialize(table,tablename,hFile); hFile:close()
	end
end

tFunctions.Serialize = function(tTbl,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in pairs(tTbl) do
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