--/----------------------------------------------------------------------------
-- Entry Bot v1.2 (7/4/2005)
-- For PtokaX 0.3.3.0 build 17.02 or Higher

-- Thanks to Dessamator for the Timed Message efforts

--/ Some Features:
-- Supports pre-defined categories;
-- Commands to add, delete, show, find entries and much more;
-- Entries older than x Days are automatically deleted (optional)
-- Ability to send pre-defined category's content to main when desired
-- Includes an optimized RighClick;
--/----------------------------------------------------------------------------

Settings = {
	sBot = frmHub:GetHubBotName(),		-- Default Bot Name or -- sBot = "custombot"
	sMenu = "Entry Bot",			-- RightClick Menu Name
	cFile = "Category.tbl",			-- File where the Categories are stored
	rFile = "Entry.tbl",			-- File where the Entries are stored
	vFile = "Votes.tbl",			-- File where the Voters are stored
	eFolder = "Entry",			-- Folder where the .tbl files are stored
	iVer = "1.2",				-- Script Version
	iMax = 30,				-- Maximum entries to be shown
	vMax = 20,				-- Maximum votes to be shown
	pMax = 20,				-- Maximum posters to be shown
	SendOnConnect = 0,			-- 1 = Send iMax Entries to every user on connect; 0 = Don't send
	CatSize = 20,				-- Category's size
	EntrySize = 80,				-- Entry's size (recommended: 75-80)
	Sensitive = 0,				-- 1 = Searches case-sensitive; 0 = not case-sensitive
	TimedCat = 0,				-- 1 = Send specific category content to main in an interval; 0: not
	TimedMsg = "your message",		-- Message shown below each Timed Category in Main
	Times = {				-- ["time in 24h format"] = "Category" (not case sensitive)
		["12:30"] = "cat1",
		["13:00"] = "cat2",
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
	voteCmd = "vote", TopVotesCmd = "topvote", clrVotesCmd = "clrvote", TopPosterCmd = "topposter",
	--------------
	sChar = { "-", " ", "i", "l", "r", "t", "I", "y", "o", }, -- Don't change this
}

-- If you're using PtokaX's default profiles it should be like this:
-- Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [0] = 5 }
-- If you're using Robocop profiles don't change this.
Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [4] = 5, [0] = 6, [5] = 7, }

Category = {} Entry = {} tPrefixes = {} Votes = {} tabTimers = {n=0} TmrFreq = 60*1000

Main = function()
	if Settings.sBot ~= frmHub:GetHubBotName() then frmHub:RegBot(Settings.sBot) end
	if loadfile(Settings.eFolder.."/"..Settings.cFile) then dofile(Settings.eFolder.."/"..Settings.cFile) else os.execute("mkdir "..Settings.eFolder) end
	if loadfile(Settings.eFolder.."/"..Settings.rFile) then dofile(Settings.eFolder.."/"..Settings.rFile) else io.output(Settings.eFolder.."/"..Settings.rFile) end
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

--		Commands Structure:
--		[Command] = { function, Lowest Profile that can use this command (check Levels table), Description, Example, RightClick Command},

	[Settings.addCatCmd]	=	{
				function(user,data)
					local s,e,cat,date = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%d+)")
					if cat and date then
						if Category[string.lower(cat)] == nil then
							if (string.len(cat) > Settings.CatSize) then
								user:SendData(Settings.sBot,"*** Error: The Category can't have more than "..Settings.CatSize.." characters.")
							else
								Category[string.lower(cat)] = date
								SaveToFile(Settings.eFolder.."/"..Settings.cFile,Category,"Category")
								user:SendData(Settings.sBot,cat.." was successfully added to the Categories.")
							end
						else
							user:SendData(Settings.sBot,"*** Error: There is already a Category: "..cat)
						end
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.addCatCmd.." <category> <maximum time in days>")
					end
				end, 6, "Add category and delete Time", "!"..Settings.addCatCmd.." Movies 15",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Add\\Category$<%[mynick]> !"..Settings.addCatCmd.." %[line:Category] %[line:LifeTime in Days]&#124;" },
	[Settings.delCatCmd]	=	{
				function(user,data)
					local s,e,cat = string.find(data,"%b<>%s+%S+%s+(%S+)")
					if cat then
						if Category[string.lower(cat)] then
							Category[string.lower(cat)] = nil ShowEntry(1,table.getn(Entry),1,4,cat,"",Entry)
							SaveToFile(Settings.eFolder.."/"..Settings.cFile,Category,"Category")
							user:SendData(Settings.sBot,cat.." was sucessfully deleted from the Categories.")
						else
							user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat)
						end
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.delCatCmd.." <category>")
					end
				end, 6, "Deletes an existing category", "!"..Settings.delCatCmd.." Movies",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Delete\\Category$<%[mynick]> !"..Settings.delCatCmd.." %[line:Category]&#124;" },
	[Settings.showCatCmd]	=	{
				function(user)
					if next(Category) then
						local msg = "\r\n\r\n".."\t"..string.rep("- -",20).."\r\n" 
						msg = msg.."\t\tCategory List:\r\n" 
						msg = msg.."\t"..string.rep("- -",20).."\r\n"
						local i,v for i, v in Category do msg = msg.."\t       • "..string.upper(string.sub(i,1,1))..string.sub(i,2,string.len(i)).." ("..v.." days)\r\n" end
						user:SendData(Settings.sBot,msg) 
					else
						user:SendData(Settings.sBot,"*** Error: There are no categories!");
					end
				end, 1, "Shows categories", "!"..Settings.showCatCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Show\\Categories$<%[mynick]> !"..Settings.showCatCmd.."&#124;" },
	[Settings.addCmd]	=	{
				function(user,data)
					local s,e,cat,rel = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(.*)") 
					if cat then
						if Category[string.lower(cat)] then
							if rel ~= "" then
								local Exists = nil
								for i = 1, table.getn(Entry) do
									if string.lower(Entry[i][2]) == string.lower(cat) and string.lower(Entry[i][3]) == string.lower(rel) then
										Exists = 1
									end
								end
								if Exists == 1 then
									user:SendData(Settings.sBot,"*** Error: There's already an Entry "..rel.." in "..cat..".")
								else
									if (string.len(rel) > Settings.EntrySize) then
										user:SendData(Settings.sBot,"*** Error: The Entry can't have more than "..Settings.EntrySize.." characters.")
									else
										cat = string.lower(cat)
										table.insert( Entry, { user.sName, cat, rel, os.date(), 0, } )
										SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
										SendToAll(Settings.sBot,user.sName.." freshened up "..cat.." with: "..rel..". For more details type: !"..Settings.showCmd)
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
				end, 3, "Adds an entry to a category", "!"..Settings.addCmd.." Movies Matrix Revolutions",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Add\\Entry$<%[mynick]> !"..Settings.addCmd.." %[line:Category] %[line:Entry]&#124;" },
	[Settings.showCmd]	=	{
				function(user,data)
					local s,e,cat = string.find(data,"%b<>%s+%S+%s+(%S+)") 
					if cat then
						if Category[string.lower(cat)] then
							user:SendPM(Settings.sBot,ShowEntry(1, table.getn(Entry), 1, 3, cat, string.rep("\t",9).."Showing all "..cat.." "..string.rep("\t",7).."["..os.date().."]\r\n",Entry))
						elseif string.lower(cat) == "all" then
							user:SendPM(Settings.sBot,ShowEntry(1, table.getn(Entry), 1, 1, false, string.rep("\t",9).."Showing all entries ["..table.getn(Entry).."]"..string.rep("\t",7).."["..os.date().."]\r\n",Entry))
						else
							user:SendData(Settings.sBot,"*** Error: There is no Category: "..cat)
						end
					else
						user:SendPM(Settings.sBot,ShowEntry(table.getn(Entry) - Settings.iMax + 1, table.getn(Entry), 1, 1, false, string.rep("\t",9).."Last "..Settings.iMax.." entries "..string.rep("\t",8).."["..os.date().."]\r\n",Entry))
					end
				end, 1, "Shows "..Settings.iMax.."/all/category entries", "!"..Settings.showCmd..", !"..Settings.showCmd.." all, !"..Settings.showCmd.." Movies",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Show\\"..Settings.iMax.."/All/Category$<%[mynick]> !"..Settings.showCmd.." %[line:empty/All/Category]&#124;" },
	[Settings.delCmd]	=	{
				function(user,data)
					local s,e,rel = string.find(data,"%b<>%s+%S+%s+(.*)")
					if rel then
						if tonumber(rel) then
							rel = tonumber(rel) local Deleted = nil
							for i = 1, table.getn(Entry), 1 do
								if Entry[rel] then
									table.remove(Entry,rel) Deleted = 1 break
								end
							end
							if Deleted == 1 then 
								user:SendData(Settings.sBot,"ID "..rel.." was successfully deleted.")
								SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
							else
								user:SendData(Settings.sBot,"*** Error: There is no ID: "..rel..".")
							end
						elseif Category[string.lower(rel)] then
							if ShowEntry(1,table.getn(Entry),1,4,rel,"",Entry) == nil then
								ShowEntry(table.getn(Entry),1,-1,4,rel,"",Entry)
								SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
								user:SendData(Settings.sBot,"Category: "..rel.." was succesfully cleaned up.")
							else
								user:SendData(Settings.sBot,"*** Error: There is no Category: "..rel)
							end
						else
							if ShowEntry(1,table.getn(Entry),1,6,rel,"",Entry) == nil then
								ShowEntry(1,table.getn(Entry),1,6,rel,"",Entry)
								SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
								user:SendData(Settings.sBot,"Entry: "..rel.." was succesfully deleted.")
							else
								user:SendData(Settings.sBot,"*** Error: There is no Entry: "..rel)
							end
						end
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.delCmd.." <entry/ID/category>")
					end
				end, 4, "Deletes entry/ID/by category", "!"..Settings.delCmd.." Matrix Revolutions; !"..Settings.delCmd.." 5; !"..Settings.delCmd.." Movies",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Delete\\Entry/ID/Category Content$<%[mynick]> !"..Settings.delCmd.." %[line:Entry/ID/Category Name]&#124;" },
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
						user:SendPM(Settings.sBot,ShowEntry(1, table.getn(Entry), 1, 2, str, string.rep("\t",9).."Search Results of: "..str..string.rep("\t",7).."["..os.date().."]\r\n",Entry))
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
					local s,e,i = string.find(data,"%b<>%s+%S+%s+(%d+)")
					if i then
						if Entry[tonumber(i)] then
							if not Votes[Entry[tonumber(i)][2]] then Votes[Entry[tonumber(i)][2]] = {} end
							if Votes[Entry[tonumber(i)][2]][user.sIP] then
								user:SendData(Settings.sBot,"*** Error: You have already voted.")
							else
								Votes[Entry[tonumber(i)][2]][user.sIP] = 1
								Entry[tonumber(i)][5] = Entry[tonumber(i)][5] + 1
								SaveToFile(Settings.eFolder.."/"..Settings.vFile,Votes,"Votes")
								SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
								user:SendData(Settings.sBot,"You have successfully voted on "..Entry[tonumber(i)][3].." [Category: "..Entry[tonumber(i)][2].."].")
								SendPmToOps(Settings.sBot,user.sName.." voted on "..Entry[tonumber(i)][3].." [Category: "..Entry[tonumber(i)][2].."].")
							end
						else
							user:SendData(Settings.sBot,"*** Error: There is no ID: "..i..".")
						end
					else
						user:SendData(Settings.sBot,"*** Syntax Error: Type !"..Settings.voteCmd.." <ID>")
					end
				end, 1, "Vote for a certain Entry", "!"..Settings.voteCmd.." <ID>",
				"$UserCommand 1 3 "..Settings.sMenu.."\\Vote\\Entry$<%[mynick]> !"..Settings.voteCmd.." %[line:ID]&#124;" },
	[Settings.TopVotesCmd]	=	{
				function(user,data)
					local Voting = {}
					for i = 1, Settings.vMax do
						if Entry[i] and Entry[i][5] > 0 then
							table.insert(Voting,{ i, Entry[i][1], Entry[i][2], Entry[i][3], Entry[i][4], Entry[i][5] })
						end
					end
					table.sort(Voting,function(a,b) return (a[6] > b[6]) end)
					user:SendPM(Settings.sBot,ShowEntry(1,Settings.vMax,1,5,false,string.rep("\t",9).."Top "..Settings.vMax.." Votes"..string.rep("\t",8).."["..os.date().."]\r\n     "..string.rep("-- --",65).."\r\n     Nr.\tVotes\tDate - Time\t\tPoster\t\t\tCategory\t\t\tEntry\r\n",Voting))
				end, 1, "Top Entry Voting", "!"..Settings.TopVotesCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Top\\Votes$<%[mynick]> !"..Settings.TopVotesCmd.."&#124;" },
	[Settings.clrVotesCmd]	=	{
				function(user,data)
					for i = 1, table.getn(Entry) do
						if Entry[i] then
							Entry[i][5] = 0
						end
					end
					Votes = nil Votes = {}
					SaveToFile(Settings.eFolder.."/"..Settings.vFile,Votes,"Votes")
					SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
					user:SendData(Settings.sBot,"All votes have been successfully cleared.")
				end, 6, "Clear all Votes", "!"..Settings.clrVotesCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Vote\\Clear$<%[mynick]> !"..Settings.clrVotesCmd.."&#124;" },
	[Settings.TopPosterCmd]	=	{
				function(user,data)
					local TopPoster = {}
					for i = 1, table.getn(Entry) do
						if TopPoster[Entry[i][1]] then TopPoster[Entry[i][1]] = TopPoster[Entry[i][1]] + 1 else TopPoster[Entry[i][1]] = 1 end
					end
					local tCopy = {}
					for x, y in TopPoster do
						table.insert(tCopy, {x, tonumber(y), y/table.getn(Entry)})
					end
					table.sort(tCopy, function(a,b) return (a[2] > b[2]) end)
					user:SendPM(Settings.sBot,ShowEntry(1,Settings.pMax,1,7,false,string.rep("\t",8).."Top "..Settings.pMax.." Posters - Total Entries: "..table.getn(Entry)..string.rep("\t",7).."["..os.date().."]\r\n     "..string.rep("-- --",65).."\r\n     Nr.\tUser\t\t\tPosts\r\n",tCopy))
				end, 1, "Top Entry Voting", "!"..Settings.TopVotesCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Top\\Posters$<%[mynick]> !"..Settings.TopPosterCmd.."&#124;" },
	[Settings.helpCmd]	=	{
				function(user)
					local sHelpOutput = "\r\n\t"..string.rep("-", 220).."\r\n"..string.rep("\t",7).."Entry Bot v."..Settings.iVer.." by jiten\t\t\t\r\n\t"..string.rep("-",220).."\r\n\tAvailable Commands:".."\r\n\r\n"
					for sCmd, tCmd in tCmds do
						if(tCmd[2] <= Levels[user.iProfile]) then
							sHelpOutput = sHelpOutput.."\t!"..sCmd..DoTabs(1,CheckSize("!"..sCmd))..tCmd[3]..DoTabs(1,CheckSize(tCmd[3]))..tCmd[4].."\r\n";
						end
					end
					user:SendData(Settings.sBot, sHelpOutput.."\t"..string.rep("-",220));
				end, 1, "Displays this help message", "!"..Settings.helpCmd,
				"$UserCommand 1 3 "..Settings.sMenu.."\\Help$<%[mynick]> !"..Settings.helpCmd.."&#124;" },
}

NewUserConnected = function(sUser)
	if Settings.SendOnConnect == 1 then
		sUser:SendPM(Settings.sBot,ShowEntry(table.getn(Entry) - Settings.iMax + 1, table.getn(Entry), 1, 1, false, string.rep("\t",9).."Last "..Settings.iMax.." entries "..string.rep("\t",8).."["..os.date().."]\r\n",Entry))
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

Cleaner = function()
	if (Settings.Cleaner == 1) then -- RegCleaner based
		local juliannow = jdate(tonumber(os.date("%d")), tonumber(os.date("%m")), tonumber(os.date("%Y"))) 
		local chkd, clnd, x = 0, 0, os.clock()
		for i = table.getn(Entry), 1, -1 do
			chkd = chkd + 1 
			for v,oldest in Category do
				local s, e, month, day, year = string.find(Entry[i][4], "(%d+)%/(%d+)%/(%d+)"); 
				local julian = jdate( tonumber(day), tonumber(month), tonumber("20"..year) )
				if ((juliannow - julian) > tonumber(oldest)) and Entry[i][2] == v then
					clnd = clnd + 1
					table.remove(Entry,i)
					SaveToFile(Settings.eFolder.."/"..Settings.rFile,Entry,"Entry")
				end; 
			end
		end
		if clnd ~= 0 and Settings.pCleaner == 1 then SendToAll(Settings.sBot,"Entry Cleaner: "..chkd.." entries were processed and "..clnd.." were deleted. ( "..string.format("%0.2f",((clnd*100)/chkd)).."% ) in: "..string.format("%0.4f", os.clock()-x ).." seconds.") end
	end
end

TimedCat = function()
	if (Settings.TimedCat == 1) and Settings.Times[os.date("%H:%M")] then
		local TimedMain = function(cat)
			local msg = "\r\n\r\n\t".." Category: "..cat.."\r\n\t"..string.rep("__",55).."\r\n\r\n\t• "
			for i in ipairs(Entry) do
				if Entry[i] and string.lower(Entry[i][2]) == string.lower(cat) then
					local sCopy = Entry[i][3] 
					while string.len(sCopy) > 120 do
						msg = msg..string.sub(sCopy,1,120).."\r\n\t"
						sCopy  = string.sub(sCopy,121,string.len(sCopy))
					end
					msg = msg..sCopy.."\r\n\t• "
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

jdate = function(d, m, y)
	local a, b, c = 0, 0, 0 if m <= 2 then y = y - 1; m = m + 12; end 
	if (y*10000 + m*100 + d) >= 15821015 then a = math.floor(y/100); b = 2 - a + math.floor(a/4) end
	if y <= 0 then c = 0.75 end return math.floor(365.25*y - c) + math.floor(30.6001*(m+1) + d + 1720994 + b)
end

ShowEntry = function(Start,End,Order,Mode,String,Header,Table)
	local msg, border = "\r\n",string.rep("-", 325)
	if Table == Entry then 
		msg = msg.."     "..border.."\r\n"..Header.."     "..string.rep("-- --",65).."\r\n     Nr.\tVotes\tDate - Time\t\tPoster\t\t\tCategory\t\t\tEntry\r\n"
	else
		msg = msg.."     "..border..Header
	end
	msg = msg.."     "..string.rep("-- --",65).."\r\n"
	for i = Start, End, Order do
		if Table[i] then
			if Mode == 1 then
				msg = msg.."     "..i..".\t"..Table[i][5].."\t"..Table[i][4].."\t\t"..Table[i][1]..DoTabs(1,CheckSize(Table[i][1]))..Table[i][2]..DoTabs(1,CheckSize(Table[i][2]))..Table[i][3].."\r\n"
			elseif Mode == 2 then
				if Settings.Sensitive == 1 then 
					where = Table[i][1]..Table[i][2]..Table[i][3]..Table[i][4]
				else
					where = string.lower(Table[i][1]..Table[i][2]..Table[i][3]..Table[i][4]) String = string.lower(String)
				end
				if string.find(where,String) then msg = msg.."     "..i..".\t"..Table[i][5].."\t"..Table[i][4].."\t\t"..Table[i][1]..DoTabs(1,CheckSize(Table[i][1]))..Table[i][2]..DoTabs(1,CheckSize(Table[i][2]))..Table[i][3].."\r\n" end
			elseif Mode == 3 then
				if string.lower(Table[i][2]) == string.lower(String) then msg = msg.."     "..i..".\t"..Table[i][5].."\t"..Table[i][4].."\t\t"..Table[i][1]..DoTabs(1,CheckSize(Table[i][1]))..Table[i][2]..DoTabs(1,CheckSize(Table[i][2]))..Table[i][3].."\r\n" end
			elseif Mode == 4 then
				if string.lower(Table[i][2]) == string.lower(String) then table.remove(Table,i) return nil end
			elseif Mode == 5 then
				msg = msg.."     "..Table[i][1]..".\t"..Table[i][6].."\t"..Table[i][5].."\t\t"..Table[i][2]..DoTabs(1,CheckSize(Table[i][2]))..Table[i][3]..DoTabs(1,CheckSize(Table[i][3]))..Table[i][4]..DoTabs(1,CheckSize(Table[i][4])).."\r\n"
			elseif Mode == 6 then
				if string.lower(Table[i][3]) == string.lower(String) then table.remove(Table,i) return nil end
			elseif Mode == 7 then
				msg = msg.."     "..i..".\t"..Table[i][1]..DoTabs(1,CheckSize(Table[i][1]))..Table[i][2].." ("..string.format("%0.3f",Table[i][3]*100).."%)\r\n"
			end
		end
	end
	msg = msg.."     "..border.."\r\n" return msg
end

DoTabs = function(Type, size) -- nErBoS Release bot based
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

CheckSize = function(String) -- nErBoS Release bot based
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
--/----------------------------------------------------------------------------