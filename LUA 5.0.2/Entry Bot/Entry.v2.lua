--/----------------------------------------------------------------------------
-- Entry Bot v2 (1/22/2006)
-- For PtokaX 0.3.3.0 build 17.02 or Higher

-- Thanks to Dessamator for the Timed Message efforts

--/ Some Features:
-- Supports categories/sub-categories;
-- Commands to add, delete, show, find, vote for entries; Top Posters/Voters and much more
-- Entries older than x Days are automatically deleted (optional)
-- Ability to send pre-defined category's content to main when desired
-- Includes an optimized RighClick;
--/----------------------------------------------------------------------------

Settings = {
	sBot = frmHub:GetHubBotName(),		-- Default Bot Name or -- sBot = "custombot"
	sMenu = "Entry Bot",			-- RightClick Menu Name
	rFile = "Entry.tbl",			-- File where the Entries are stored
	vFile = "Votes.tbl",			-- File where the Voters are stored
	eFolder = "Entry",			-- Folder where the .tbl files are stored
	iVer = "2",				-- Script Version
	iMax = 5,				-- Maximum entries to be shown per category
	vMax = 20,				-- Maximum votes to be shown
	pMax = 20,				-- Maximum posters to be shown
	SendOnConnect = 0,			-- 1 = Send iMax Entries to every user on connect; 0 = Don't send
	CatSize = 20,				-- Category's size
	SubCatSize = 20,			-- Sub-Category's size
	EntrySize = 80,				-- Entry's size (recommended: 75-80)
	Sensitive = 0,				-- 1 = Searches case-sensitive; 0 = not case-sensitive
	TimedCat = 0,				-- 1 = Send specific category content to main in an interval; 0: not
	TimedMsg = "your message",		-- Message shown below each Timed Category in Main
	Times = {				-- ["time in 24h format"] = { "Category", "Sub-Category" } (not case sensitive)
						-- "Sub-Category is optional
		["12:30"] = { "cat" },
		["14:00"] = { "cat", "subcat" },
	},
	cDelay = 12,				-- Cleaner Checking Delay (in hours)
	pCleaner = 1,				-- 1 = Sends cleaner actions to all; 0 = doesn't
	Cleaner = 1,				-- 1 = Set Automatic Cleaner On; 0 = Automatic Cleaner Off
	SendRC = 1,				-- 1 = Send RighClick; 0 = Don't
	SendTo = {				-- Send RightClick to Profile [x] = (1 = on, 0 = off)
		[0] = 1,				-- Master
		[1] = 1,				-- Operator
		[2] = 1,				-- VIP
		[3] = 1,				-- REG
		[4] = 1,				-- Custom Profile
		[5] = 1,				-- Custom Profile
		[-1] = 0,				-- Unreg
	},
	-- Commands --
	addCatCmd = "addcat", delCatCmd = "delcat", showCatCmd = "showcat", addCmd = "add", TimedCmd = "rotator",
	showCmd = "show", delCmd = "del", delAllCmd = "delall", findCmd = "find", helpCmd = "entryhelp",
	voteCmd = "vote", TopVotesCmd = "topvoter", clrVotesCmd = "clrvote", TopPosterCmd = "topposter",
	--------------
	sChar = { "-", " ", "i", "l", "r", "t", "I", "y", "o", }, -- Don't change this
}

-- If you're using PtokaX's default profiles it should be like this:
-- Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [0] = 5 }
-- If you're using Robocop profiles don't change this.
Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [4] = 5, [0] = 6, [5] = 7, }

Entry = {} tPrefixes = {} Votes = {} tabTimers = {n=0} TmrFreq = 60*1000

Main = function()
	if Settings.sBot ~= frmHub:GetHubBotName() then frmHub:RegBot(Settings.sBot) end
	if loadfile(Settings.eFolder.."/"..Settings.rFile) then dofile(Settings.eFolder.."/"..Settings.rFile) else os.execute("mkdir "..Settings.eFolder) io.output(Settings.eFolder.."/"..Settings.rFile) end
	if loadfile(Settings.eFolder.."/"..Settings.vFile) then dofile(Settings.eFolder.."/"..Settings.vFile) end
	for a,b in pairs(frmHub:GetPrefixes()) do tPrefixes[b] = 1 end
	RegTimer(Cleaner, Settings.cDelay*60*60*1000) RegTimer(TimedCat, 60*1000) SetTimer(TmrFreq) StartTimer()
end

ChatArrival = function(sUser,sData)
	local sData = string.sub(sData,1,-2) 
	local s,e,sPrefix,cmd = string.find(sData,"%b<>%s*(%S)(%S+)")
	if sPrefix and tPrefixes[sPrefix] and tCmds[cmd] then
		if tCmds[cmd][2] <= Levels[sUser.iProfile] then
			return tCmds[cmd][1](sUser,sData), 1
		else
			return sUser:SendData(Settings.sBot,"*** Error: You are not allowed to use this command."), 1
		end
	end
end

ToArrival = ChatArrival

tCmds = {

--	Commands Structure:
--	[Command] = { function, Lowest Profile that can use this command (check Levels table), Description, Example, RightClick Command},

	[Settings.addCatCmd]	=	{
				function(user,data)
					local s,e,cat,subcat,rel
					if string.find(data,"\/") then
						s,e,cat,subcat = string.find(data,"%b<>%s+%S+%s+(%S+)\/(%S+)") 
					else
						s,e,cat,date = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%d+)") 
					end
					subcat = subcat or ""
					if cat and date then
						local Cat, sCat = string.lower(cat), string.lower(subcat)
						if Entry[Cat] then
							if Entry[Cat][sCat] then
								user:SendData(Settings.sBot,"*** Error: There is already a Category: "..cat.."/"..subcat)
							else
								if (string.len(subcat) > Settings.SubCatSize) then
									user:SendData(Settings.sBot,"*** Error: The Sub-Category can't have more than "..Settings.SubCatSize.." characters.")
								else
									Entry[Cat][sCat] = {}
									SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
									user:SendData(Settings.sBot,cat.."/"..subcat.." was successfully added to "..cat..".")
								end
							end
						else
							if (string.len(cat) > Settings.CatSize) then
								user:SendData(Settings.sBot,"*** Error: The Category can't have more than "..Settings.CatSize.." characters.")
							else
								Entry[Cat] = {} 
								Entry[Cat][Cat] = { cTime = tonumber(date) }
								SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
								user:SendData(Settings.sBot,cat.." was successfully added to the Categories.")
							end
						end
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.addCatCmd.." <category/subcategory> <maximum time in days>")
					end
				end, 6, "Add (sub)category and Time", "!"..Settings.addCatCmd.." Movies 15, !"..Settings.addCatCmd.." Movies/Horror",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Add\\Category$<%[mynick]> !"..Settings.addCatCmd.." %[line:Category/Sub-Category] %[line:LifeTime in Days]&#124;" },
	[Settings.delCatCmd]	=	{
				function(user,data)
					local s,e,cat,subcat
					if string.find(data,"\/") then
						s,e,cat,subcat = string.find(data,"%b<>%s+%S+%s+(%S+)\/(%S+)") 
					else
						s,e,cat = string.find(data,"%b<>%s+%S+%s+(%S+)") 
					end
					subcat = subcat or ""
					if cat then
						local Cat, sCat = string.lower(cat), string.lower(subcat)
						if Entry[Cat] then
							local Deleted = nil
							if Entry[Cat][sCat] then
								Entry[Cat][sCat] = nil Deleted = 1
							elseif subcat == "" then
								Entry[Cat] = nil Deleted = 1
							end
							if Deleted then 
								SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
								user:SendData(Settings.sBot,cat.."/"..subcat.." was sucessfully deleted from the Categories.")
							else
								user:SendData(Settings.sBot,"*** There is no Category "..cat.."/"..subcat)
							end
						else
							user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat..".")
						end
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.delCatCmd.." <category/subcategory>")
					end
				end, 6, "Deletes a (sub)category", "!"..Settings.delCatCmd.." Movies, !"..Settings.delCatCmd.." Movies/Horror",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Delete\\Category$<%[mynick]> !"..Settings.delCatCmd.." %[line:Category/Sub-Category]&#124;" },
	[Settings.showCatCmd]	=	{
				function(user)
					if next(Entry) then
						local msg = "\r\n\r\n".."\t"..string.rep("- -",20).."\r\n" 
						msg = msg.."\t\tCategory List:\r\n" 
						msg = msg.."\t"..string.rep("- -",20).."\r\n"
						local tCat = {}
						for Cat,a in Entry do
							for cat,b in a do
								if not tCat[Cat] then
									tCat[Cat] = {} table.insert(tCat[Cat], { cat, Entry[Cat][Cat]["cTime"] })
								elseif tCat[Cat][1] ~= cat then
									table.insert(tCat[Cat], { cat, Entry[Cat][Cat]["cTime"] })
								end
							end
						end
						for Cat,i in pairs(tCat) do
							for a,v in ipairs(i) do
								msg = msg.."\t       • "..string.upper(string.sub(Cat,1,1))..string.sub(Cat,2,string.len(Cat)).." / "..
								string.upper(string.sub(v[1],1,1))..string.sub(v[1],2,string.len(v[1])).." ("..v[2].." days)\r\n" 
							end
						end
						user:SendData(Settings.sBot,msg) 
					else
						user:SendData(Settings.sBot,"*** Error: There are no categories!");
					end
				end, 1, "Shows (sub)categories", "!"..Settings.showCatCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Show\\Categories$<%[mynick]> !"..Settings.showCatCmd.."&#124;" },
	[Settings.addCmd]	=	{
				function(user,data)
					local s,e,cat,subcat,rel
					if string.find(data,"\/") then
						s,e,cat,subcat,rel = string.find(data,"%b<>%s+%S+%s+(%S+)\/(%S+)%s+(.*)") 
					else
						s,e,cat,rel = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(.*)") 
					end
					subcat = subcat or cat
					if cat then
						local Cat, sCat = string.lower(cat), string.lower(subcat)
						if Entry[Cat] and Entry[Cat][sCat] then
							if rel ~= "" then
								local Exists = nil
								for i,v in ipairs(Entry[Cat][sCat]) do
									if Entry[Cat][sCat] and string.lower(v.sRel) == string.lower(rel) then Exists = 1 end
								end
								if Exists then
									user:SendData(Settings.sBot,"*** Error: There's already an Entry \""..rel.."\" in "..cat.."/"..subcat)
								else
									if (string.len(rel) > Settings.EntrySize) then
										user:SendData(Settings.sBot,"*** Error: The Entry can't have more than "..Settings.EntrySize.." characters.")
									else
										table.insert( Entry[Cat][sCat], { sRel = rel, sPoster = user.sName, iTime = os.date(), iVote = 0, } )
										SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
										SendToAll(Settings.sBot,user.sName.." freshened up "..cat.."/"..subcat.." with: "..rel..". For more details type: !"..Settings.showCmd)
									end
								end
							else
								user:SendData(Settings.sBot,"*** Error: Please type an Entry.")
							end
						else
							user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat.."/"..subcat)
						end
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.addCmd.." <category/sub-category> <Entry>")
					end
				end, 3, "Adds entry to (sub)category", "!"..Settings.addCmd.." Movies Matrix Revolutions, !"..Settings.addCmd.." Movies/Horror Matrix Revolutions",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Add\\Entry$<%[mynick]> !"..Settings.addCmd.." %[line:Category/Sub-Category] %[line:Entry]&#124;" },
	[Settings.showCmd]	=	{
				function(user,data)
					local s,e,cat,subcat
					if string.find(data,"\/") then
						s,e,cat,subcat = string.find(data,"%b<>%s+%S+%s+(%S+)\/(%S+)") 
					else
						s,e,cat = string.find(data,"%b<>%s+%S+%s+(%S+)") 
					end
					subcat = subcat or ""
					if cat then
						if string.lower(cat) == "all" then
							user:SendPM(Settings.sBot,ShowEntry(string.rep("\t",9).."Showing all entries ["..EntryContent(7,"")..
							"]"..string.rep("\t",7).."["..os.date().."]\r\n", EntryContent(1,""), Entry))
						elseif Entry[string.lower(cat)] then
							if Entry[string.lower(cat)][string.lower(subcat)] then
								user:SendPM(Settings.sBot,ShowEntry(string.rep("\t",9).."Showing all "..cat.."/"..subcat.." "..
								string.rep("\t",7).."["..os.date().."]\r\n",EntryContent(3,cat,subcat),Entry))
							else
								user:SendPM(Settings.sBot,ShowEntry(string.rep("\t",9).."Showing all "..cat.." "..
								string.rep("\t",7).."["..os.date().."]\r\n",EntryContent(4,cat,subcat),Entry))
							end
						else
							user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat.."/"..subcat)
						end
					else
						user:SendPM(Settings.sBot,ShowEntry(string.rep("\t",8).."Last "..Settings.iMax.." entries per Category/Sub-Category "..
						string.rep("\t",6).."["..os.date().."]\r\n",ShowXEntry(),Entry))
					end
				end, 1, "Shows "..Settings.iMax.."/all/(sub)category", "!"..Settings.showCmd..", !"..Settings.showCmd.." all, !"..
				Settings.showCmd.." Movies, !"..Settings.showCmd.." Movies/Horror",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Show\\"..Settings.iMax.."/All/Category$<%[mynick]> !"..
				Settings.showCmd.." %[line:empty / All / Category/Sub-Category]&#124;" },
	[Settings.delCmd]	=	{
				function(user,data)
					local s,e,cat,subcat,rel
					if string.find(data,"\/") then
						s,e,cat,subcat,rel = string.find(data,"%b<>%s+%S+%s+(%S+)\/(%S+)%s*(.*)") 
					else
						s,e,cat,rel = string.find(data,"%b<>%s+%S+%s+(%S+)%s*(.*)") 
					end
					subcat = subcat or ""
					if cat and rel then
						local Cat, sCat = string.lower(cat), string.lower(subcat)
						if Entry[Cat] then
							if tonumber(rel) then
								if Entry[Cat][sCat] then
									rel = tonumber(rel) local Deleted = nil
									for i,v in ipairs(Entry[Cat][sCat]) do
										table.remove(Entry[Cat][sCat],rel) Deleted = 1 break
									end
									if Deleted then 
										user:SendData(Settings.sBot,"ID "..rel.." was successfully deleted.")
										SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
									else
										user:SendData(Settings.sBot,"*** Error: There is no ID: "..rel..".")
									end
								else
									user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat.."/"..subcat)
								end
							elseif Entry[Cat] then
								local Deleted = nil
								if Entry[Cat][sCat] then
									for i,v in ipairs(Entry[Cat][sCat]) do
										table.remove(Entry[Cat][sCat],i) Deleted = 1
									end
								elseif subcat == "" then
									if EntryContent(6,false) then Deleted = 1 end
								end
								if Deleted then
									SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
									user:SendData(Settings.sBot,"Category: "..cat.."/"..subcat.." was succesfully cleaned up.")
								else
									user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat.."/"..subcat)
								end
							end
						else
							user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat.."/"..subcat)
						end
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.delCmd.." <ID / category/sub-category>")
					end

				end, 4, "Del ID/(sub)category", "!"..Settings.delCmd.." 5; !"..Settings.delCmd.." Movies, !"..Settings.delCmd.." Movies/Horror",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Delete\\ID/(Sub)Category Content$<%[mynick]> !"..Settings.delCmd.." %[line:ID / Category/Sub-Category]&#124;" },
	[Settings.delAllCmd]	=	{
				function(user,data)
					Entry = nil Entry = {} SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
					user:SendData(Settings.sBot,"All entries have been deleted successfully.")
				end, 6, "Deletes all entries", "!"..Settings.delAllCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Delete\\All Entries$<%[mynick]> !"..Settings.delAllCmd.."&#124;" },
	[Settings.findCmd]	=	{
				function(user,data)
					local s,e,str = string.find(data,"%b<>%s+%S+%s+(%S+)")
					if str then
						user:SendPM(Settings.sBot,ShowEntry(string.rep("\t",9).."Search Results of: "..str..string.rep("\t",7)..
						"["..os.date().."]\r\n",EntryContent(2,str),Entry))
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.findCmd.." <string>")
					end
				end, 1, "Finds an entry by any string", "!"..Settings.findCmd.." Matrix",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Find\\All$<%[mynick]> !"..Settings.findCmd.." %[line:String]&#124;" },
	[Settings.TimedCmd]	=	{
				function(user,data)
					local s,e,arg = string.find(data,"%b<>%s+%S+%s+(%S+)")
					if arg then
						if string.lower(arg) == "on" then
							StartTimer() user:SendData(Settings.sBot,"Category rotator has been enabled.")
						elseif string.lower(arg) == "off" then
							StopTimer() user:SendData(Settings.sBot,"Category rotator has been disabled.")
						end
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.TimedCmd.." <on/off>")
					end
				end, 6, "Set Category Rotator status", "!"..Settings.TimedCmd.." <on/off>",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Setup\\Rotator Status$<%[mynick]> !"..Settings.TimedCmd.." %[line:on/off]&#124;" },
	[Settings.voteCmd]	=	{
				function(user,data)
					local s,e,cat,subcat,rel
					if string.find(data,"\/") then
						s,e,cat,subcat,i = string.find(data,"%b<>%s+%S+%s+(%S+)\/(%S+)%s+(%d+)") 
					else
						s,e,cat,i = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%d+)") 
					end
					subcat = subcat or cat
					if cat and i then
						local Cat, sCat = string.lower(cat), string.lower(subcat)
						if Entry[Cat][sCat] then
							if Entry[Cat][sCat][tonumber(i)] then
								if not Votes[Cat] then Votes[Cat] = {} end
								if not Votes[Cat][sCat] then Votes[Cat][sCat] = {} end
								if Votes[Cat][sCat][user.sIP] then
									user:SendData(Settings.sBot,"*** Error: You have already voted.")
								else
									Votes[Cat][sCat][user.sIP] = 1
									Entry[Cat][sCat][tonumber(i)]["iVote"] = Entry[Cat][sCat][tonumber(i)]["iVote"] + 1
									SaveToFile(Settings.eFolder.."/"..Settings.vFile,Votes,"Votes")
									SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
									user:SendData(Settings.sBot,"You have successfully voted on \""..Entry[Cat][sCat][tonumber(i)].sRel.."\" [Category: "..cat.."/"..subcat.."].")
									SendPmToOps(Settings.sBot,user.sName.." voted on \""..Entry[Cat][sCat][tonumber(i)].sRel.."\" [Category: "..cat.."/"..subcat.."].")
								end
							else
								user:SendData(Settings.sBot,"*** Error: There is no ID: "..i.." in "..cat.."/"..subcat)
							end
						else
							user:SendData(Settings.sBot,"*** Error: There is no Category "..cat.."/"..subcat)
						end
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.voteCmd.." <Category/Sub-Category> <ID>")
					end
				end, 1, "Vote for a certain Entry", "!"..Settings.voteCmd.." Movies 1, !"..Settings.voteCmd.." Movies/Horror 1",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Vote\\Entry$<%[mynick]> !"..Settings.voteCmd.." %[line:Category/Sub-Category] %[line:ID]&#124;" },
	[Settings.TopVotesCmd]	=	{
				function(user,data)
					local Voting = {}
					TopSorting(2,Voting,6,Voting)
					user:SendPM(Settings.sBot,ShowEntry(string.rep("\t",9).."Top "..Settings.vMax.." Votes"..
					string.rep("\t",8).."["..os.date().."]\r\n     "..string.rep("-- --",65)..
					"\r\n     Nr.\tVotes\tDate - Time\t\tPoster\t\t\tCategory\t\t\tEntry\r\n",TopContent(1,Settings.vMax,1,1,Voting),Voting))
				end, 1, "Top Entry Voting", "!"..Settings.TopVotesCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Top\\Votes$<%[mynick]> !"..Settings.TopVotesCmd.."&#124;" },
	[Settings.clrVotesCmd]	=	{
				function(user,data)
					EntryContent(5,false)
					Votes = nil Votes = {}
					SaveToFile(Settings.eFolder.."/"..Settings.vFile,Votes,"Votes")
					SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
					user:SendData(Settings.sBot,"All votes have been successfully cleared.")
				end, 6, "Clear all Votes", "!"..Settings.clrVotesCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Vote\\Clear$<%[mynick]> !"..Settings.clrVotesCmd.."&#124;" },
	[Settings.TopPosterCmd]	=	{
				function(user,data)
					local TopPoster,tCopy = {},{}
					TopSorting(1,TopPoster,2,tCopy)
					user:SendPM(Settings.sBot,ShowEntry(string.rep("\t",8).."Top "..Settings.pMax..
					" Posters - Total Entries: "..EntryContent(7,"")..string.rep("\t",7).."["..os.date()..
					"]\r\n     "..string.rep("-- --",65).."\r\n     Nr.\tUser\t\t\tPosts\r\n",TopContent(1,Settings.pMax,1,2,tCopy),tCopy))
				end, 1, "Top Entry Voting", "!"..Settings.TopVotesCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Top\\Posters$<%[mynick]> !"..Settings.TopPosterCmd.."&#124;" },
	[Settings.helpCmd]	=	{
				function(user)
					local sHelpOutput = "\r\n\t"..string.rep("-", 220).."\r\n"..string.rep("\t",7).."Entry Bot v."..
					Settings.iVer.." by jiten\t\t\t\r\n\t"..string.rep("-",220).."\r\n\tAvailable Commands:".."\r\n\r\n"
					for sCmd, tCmd in tCmds do
						if(tCmd[2] <= Levels[user.iProfile]) then
							sHelpOutput = sHelpOutput.."\t!"..sCmd..DoTabs(1,CheckSize("!"..sCmd))..tCmd[3]..
							DoTabs(1,CheckSize(tCmd[3]))..tCmd[4].."\r\n";
						end
					end
					user:SendData(Settings.sBot, sHelpOutput.."\t"..string.rep("-",220));
				end, 1, "\tDisplays this help message", "!"..Settings.helpCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Help$<%[mynick]> !"..Settings.helpCmd.."&#124;" },
}

NewUserConnected = function(sUser)
	if Settings.SendOnConnect == 1 then
		sUser:SendPM(Settings.sBot,ShowEntry(string.rep("\t",8).."Last "..Settings.iMax.." entries per Category/Sub-Category "..
		string.rep("\t",6).."["..os.date().."]\r\n",ShowXEntry(),Entry))
	end
	if Settings.SendTo[sUser.iProfile] == 1 and Settings.SendRC == 1 and sUser.bUserCommand then
		for i,v in tCmds do if(v[2] <= Levels[sUser.iProfile]) then sUser:SendData(v[5]) end end
	end
end

OpConnected = NewUserConnected

OnTimer = function()
	for i in ipairs(tabTimers) do
		tabTimers[i].count = tabTimers[i].count + 1
		if tabTimers[i].count > tabTimers[i].trig then
			tabTimers[i].count=1
			tabTimers[i]:func()
		end
	end
end

RegTimer = function(f, Interval)
	local tmpTrig = Interval / TmrFreq
	assert(Interval >= TmrFreq , "RegTimer(): Please Adjust TmrFreq")
	local Timer = {n=0}
	Timer.func=f
	Timer.trig=tmpTrig
	Timer.count=1
	table.insert(tabTimers, Timer)
end

EntryContent = function(Mode,String,String1)
	local msg = ""
	for Cat,a in pairs(Entry) do
		for cat,b in pairs(a) do
			for i,v in ipairs(b) do
				local sLine = "     "..i..".\t"..v.iVote.."\t"..v.iTime.."\t\t"..v.sPoster..DoTabs(1,CheckSize(v.sPoster))..
				Cat.."/"..cat..DoTabs(1,CheckSize((Cat.."/"..cat)))..v.sRel.."\r\n"
				local tMode = {
				-- Show all entries
				[1] = function ()
					msg = msg..sLine
				end,
				-- Find entries
				[2] = function()
					if Settings.Sensitive == 1 then 
						where = v.sRel..v.sPoster..v.iTime..cat..Cat
					else
						where = string.lower(v.sRel..v.sPoster..v.iTime..cat..Cat) String = string.lower(String)
					end
					if string.find(where,String) then msg = msg..sLine end
				end,
				-- Show entries by sub-category
				[3] = function()
					if string.lower(Cat) == string.lower(String) and string.lower(cat) == string.lower(String1) then msg = msg..sLine end
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
					Entry[Cat][cat][i] = nil
				end,
				-- table.getn
				[7] = function()
					if not tonumber(msg) then msg = 0 end
					if Entry[Cat][cat][tonumber(i)] then msg = msg + 1 end
				end, }
				if tMode[Mode] then tMode[Mode]() end
			end
		end
	end
	return msg
end

ShowXEntry = function()
	local msg = ""
	for Cat,a in pairs(Entry) do
		for cat,b in pairs(a) do
			for v = table.getn(Entry[Cat][cat]) - Settings.iMax + 1, table.getn(Entry[Cat][cat]), 1 do
				if Entry[Cat][cat][v] then
					msg = msg.."     "..v..".\t"..Entry[Cat][cat][v].iVote.."\t"..Entry[Cat][cat][v].iTime.."\t\t"..
					Entry[Cat][cat][v].sPoster..DoTabs(1,CheckSize(Entry[Cat][cat][v].sPoster))..
					Cat.."/"..cat..DoTabs(1,CheckSize((Cat.."/"..cat)))..Entry[Cat][cat][v].sRel.."\r\n"
				end
			end
		end
	end
	return msg
end

TopContent = function(Start, End, Order, Mode, tTable)
	local msg = ""
	for i = Start, End, Order do
		if tTable[i] then
			local tMode = {
			-- Show TopVotes
			[1] = function()
				msg = msg.."     "..tTable[i][1]..".\t"..tTable[i][6].."\t"..tTable[i][5].."\t\t"..
				tTable[i][2]..DoTabs(1,CheckSize(tTable[i][2]))..tTable[i][3]..DoTabs(1,CheckSize(tTable[i][3]))..
				tTable[i][4]..DoTabs(1,CheckSize(tTable[i][4])).."\r\n"
			end,
			-- Show TopPosters
			[2] = function()
				msg = msg.."     "..i..".\t"..tTable[i][1]..DoTabs(1,CheckSize(tTable[i][1]))..
				tTable[i][2].." ("..string.format("%0.3f",tTable[i][3]*100).."%)\r\n"
			end, }
			if tMode[Mode] then tMode[Mode]() end
		end
	end
	return msg
end

TopSorting = function(Mode,Table,Value,tTable)
	for Cat,a in pairs(Entry) do
		for cat,b in pairs(a) do
			for i,v in ipairs(b) do
				if Mode == 1 then
					if Table[v.sPoster] then Table[v.sPoster] = Table[v.sPoster] + 1 else Table[v.sPoster] = 1 end
				elseif Mode == 2 then
					if v.iVote > 0 then
						table.insert(Table,{ i, v.sPoster, Cat.."/"..cat, v.sRel, v.iTime, v.iVote })
					end
				end
			end
		end
	end
	if Mode == 1 then
		for x, y in Table do table.insert(tTable, {x, tonumber(y), y/tonumber(EntryContent(7,false))}) end
	end
	table.sort(tTable,function(a,b) return (a[Value] > b[Value]) end)
end

ShowEntry = function(Header, Content, Table)
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

TimedCat = function()
	if (Settings.TimedCat == 1) and Settings.Times[os.date("%H:%M")] then
		local TimedMain = function(Category,SubCategory)
			SubCategory = SubCategory or ""
			local msg = "\r\n\r\n\t".." Category: "..Category.."/"..SubCategory.."\r\n\t"..string.rep("__",55).."\r\n\r\n\t• "
			for Cat,a in pairs(Entry) do
				for cat,b in pairs(a) do
					for i,v in ipairs(b) do
						local Content = function()
							local sCopy = v.sRel
							while string.len(sCopy) > 120 do
								msg = msg..string.sub(sCopy,1,120).."\r\n\t"
								sCopy  = string.sub(sCopy,121,string.len(sCopy))
							end
							msg = msg..sCopy.."\r\n\t• "
						end
						if SubCategory and SubCategory ~= "" then
							if string.lower(Cat) == string.lower(Category) and string.lower(cat) == string.lower(SubCategory) then
								Content()
							end
						else
							if string.lower(Cat) == string.lower(Category) then
								Content()
							end
						end
					end
				end
			end
			msg = string.sub(msg,1,string.len(msg)-2)
			msg = msg.."\r\n\t"..Settings.TimedMsg.."\r\n\t"..string.rep("__",55).."\r\n"
			return msg
		end
		SendToAll(TimedMain(Settings.Times[os.date("%H:%M")][1],Settings.Times[os.date("%H:%M")][2]))
	end
	collectgarbage(); io.flush();
end

Cleaner = function()
	if (Settings.Cleaner == 1) then -- RegCleaner based
		local juliannow = jdate(tonumber(os.date("%d")), tonumber(os.date("%m")), tonumber(os.date("%Y"))) 
		local chkd, clnd, x = 0, 0, os.clock()
		for Cat,a in pairs(Entry) do
			for cat,b in pairs(a) do
				for i = table.getn(Entry[Cat][cat]), 1, -1 do
					chkd = chkd + 1 
					local s, e, month, day, year = string.find(Entry[Cat][cat][i].iTime, "(%d+)%/(%d+)%/(%d+)"); 
					local julian = jdate( tonumber(day), tonumber(month), tonumber("20"..year) )
					if ((juliannow - julian) > tonumber(Entry[Cat][Cat]["cTime"])) then
						clnd = clnd + 1
						table.remove(Entry[Cat][cat],i)
						SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
					end; 
				end
			end
		end
		if clnd ~= 0 and Settings.pCleaner == 1 then SendToAll(Settings.sBot,"Entry Cleaner: "..chkd..
		" entries were processed and "..clnd.." were deleted. ( "..string.format("%0.2f",((clnd*100)/chkd))..
		"% ) in: "..string.format("%0.4f", os.clock()-x ).." seconds.") end
	end
end

jdate = function(d, m, y)
	local a, b, c = 0, 0, 0 if m <= 2 then y = y - 1; m = m + 12; end 
	if (y*10000 + m*100 + d) >= 15821015 then a = math.floor(y/100); b = 2 - a + math.floor(a/4) end
	if y <= 0 then c = 0.75 end return math.floor(365.25*y - c) + math.floor(30.6001*(m+1) + d + 1720994 + b)
end

-- nErBoS Release bot based
DoTabs = function(Type, size)
	local sTmp = "" 
	if (Type == 1) then
		if (size < 8) then sTmp = "\t\t\t" elseif (size < 16) then sTmp = "\t\t" else sTmp = "\t" end return sTmp
	elseif (Type == 2) then
		if (size < 8) then sTmp = string.rep("\t",12) elseif (size < 16) then sTmp = string.rep("\t",11)  elseif (size < 24) then sTmp = string.rep("\t",10) 
		elseif (size < 32) then sTmp = string.rep("\t",9) elseif (size < 40) then sTmp = string.rep("\t",8) elseif (size < 48) then sTmp = string.rep("\t",7)
		elseif (size < 56) then sTmp = string.rep("\t",6) elseif (size < 64) then sTmp = string.rep("\t",5) elseif (size < 72) then sTmp = "\t\t\t\t"
		elseif (size < 80) then sTmp = "\t\t\t" elseif (size < 88) then sTmp = "\t\t" else sTmp = "\t" end return sTmp
	end
end

-- nErBoS Release bot based
CheckSize = function(String)
	local realSize,aux,remove = string.len(String),1,0
	while aux < realSize + 1 do
		for i=1, table.getn(Settings.sChar) do if (string.sub(String,aux,aux) == Settings.sChar[i]) then remove = remove + 0.5 end end
		aux = aux + 1
	end return realSize - remove
end

Serialize = function(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in tTable do
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