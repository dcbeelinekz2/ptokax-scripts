-- Converted to Lua5 By Jelf 12/03/05 With thanks to kepp
-- modded by jiten
-- Fixed: answer showing before bot message and other small bugs
-- Added: Gag users with a streak of 12 (!ungag will undo it)
-- Trivia Ex V 0.681 by chill
-- Serialisation by RabidWombat, modded to exclude functions

-- This script is opensource, that means that anybody may edit/copy this code
-- and I will not come and cry for money, if you take bits to make a even more useless script
-- then leave a note over it with my name, would be cool :).

-- Lucida Console, Courier New


--------
-- PTOKAX FUNCS
--------
function Main()
	TrivEx:Main()
end
-------------------
function OnExit()
	TrivEx:OnExit()
end
------------------
function ChatArrival(curUser,data)
	if TrivEx:ParseData("main",curUser,data) == 1 then
		return 1
	end
end
----------------------
function ToArrival(curUser,data)
	local _,_,whoTo,mes = string.find(data,"$To:%s+(%S+)%s+From:%s+%S+%s+$(.*)$")
	if (whoTo == TrivEx._Sets.bot) then
		TrivEx:ParseData("pm",curUser,mes)
	end
end
-----------------------
function NewUserConnected(curUser)
	TrivEx:NewUserConnected(curUser)
end
OpConnected = NewUserConnected
-----------------------
function UserDisconnected(curUser)
	TrivEx:UserDisconnected(curUser)
end
OpDisconnected = UserDisconnected
--------------------
function OnTimer()
	TrivEx:OnTimer()
end
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
--				GLOBALS						     --
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Main Table

sGag = {}

TrivEx = {}

TrivEx._Profiles = {}

TrivEx._Profiles.Normal = {
	[0] = "Master",
	[1] = "Operator",
	[2] = "VIP",
	[3] = "Reg",
	[-1] = "Noobs",
}

TrivEx._Profiles.Config = {
	[0] = "Master",
	[1] = "Operator",
	[2] = "VIP",
	[3] = "Reg",
}

TrivEx._Profiles["Config+"] = {
	[0] = "Master",
	[1] = "Operator",
}

---------------------------------------------------------------------------------------
--	TRIVIA EX SETTINGS
---------------------------------------------------------------------------------------
TrivEx._Sets = {}

TrivEx._Sets.Version = 	0.68					-- Script Version

TrivEx._Sets.StartOnMain = 0					-- 1 = Trivia starts on Main(), 0 = Trivia doesn't start on Main()

TrivEx._Sets.bot = "•bot•"					-- The botname
TrivEx._Sets.regbot = 1						-- 0 = do not reg bot, 1 = reg bot

TrivEx._Sets.questionfile = "TriviaEx.Questions-1.txt"		-- The name of the Questionfile Questiondefaultformat = category$questions$answer
TrivEx._Sets.addquestionfile = "AddQuesFile.txt"		-- The name of the file where ops can add a question

TrivEx._Sets.dividechar = "$"					-- The Divied Char whitch divides the Category,Questions and Answer, (Only one character, Questionfile specific)
TrivEx._Sets.quesmode = 1					-- 1 = Gets "Category,Question,Answer", 2 = Only Gets "Question,Answer" (Questionfile specific)

TrivEx._Sets.revealchar = "@"					-- The revealchar: 149,164,1

TrivEx._Sets.prefixes = "%+%-%!"				-- TriviaPrefix

TrivEx._Sets.savestats = 30					-- Time in minutes between each score and player saving, 0 = never save stats only OnExit()

--------------------------------------------------------------

TrivEx._Sets.folder = "TRIVIA"					-- The name of the Folder, for the Questionfile.

TrivEx._Sets.showcorrectanswer = 1				-- 1 = shows detailed stuff, 2 = only shows that it was the right answer
TrivEx._Sets.showquestion = 1					-- 1 = Shows "Question Number,Category,Question,Answer", 2 = Shows "Question Number,Question,Answer", 3 = Shows "Question,Answer"
TrivEx._Sets.revealques = 2					-- 1 = Random displaying of hints, 2 = Displays the first letters of the hint first (Grands Trivia).
TrivEx._Sets.trivshowhint = 2					-- 1 = reveal by number of chars 2 = reveal by number of hints

TrivEx._Sets.autostop = 10					-- nil when no autostop, 1 - endless, when you want the script to stop after a certain number of unanswered questions

TrivEx._Sets.splitques = 90					-- After how many chars the question is splitted

TrivEx._Sets.memques = 50					-- How many questions are loaded into Memory
TrivEx._Sets.breaktime = 5					-- Trivia Break Time in minutes
TrivEx._Sets.timebreak = 20					-- Time in minutes till Trivia Break
TrivEx._Sets.dobreak = 1					-- 1 = do a triviabreak between 'TrivEx._Sets.timebreak' Minutes, 0 = no triviabreak

TrivEx._Sets.showques = 15					-- Time between each hint in seconds

TrivEx._Sets.displscorers = 100					-- The number of trivia scorers shown
TrivEx._Sets.displtoptrivs = 10					-- Number of top trivias shown

TrivEx._Sets.revealedchars = 2					-- Stands for how many chars are revealed per hint.
TrivEx._Sets.shownhints = 4					-- Stands for how many Hints are displayed (May not be totally accurate)
TrivEx._Sets.solveques = 2					-- The Question will be solved when there are only 'TrivEx._Sets.solveques' unrevealed chars left

--------------------------------------------------------------

TrivEx._Sets.botmyinfo = "$MyINFO $ALL "..TrivEx._Sets.bot.." TrivHelp: +trivhelp, -trivhelp, !trivhelp$ $TRIVIA$$0$"



--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
--//			MAIN SCRIPT
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
--	NO EDITING PAST THIS POINT UNLESS YOU KNOW WHAT YOU ARE DOING
---------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------
--	Adjust Timers to seconds
---------------------------------------------------------------------------------------
TrivEx._Sets.breaktime = TrivEx._Sets.breaktime * 60
TrivEx._Sets.timebreak = TrivEx._Sets.timebreak * 60


TrivEx._Sets.TrivConfigFile = "TriviaExConfig.txt"

TrivEx._Sets.ScoresFile = "TriviaExScores.txt"
TrivEx._Sets.PMPlayersFile = "TriviaExPMPlayers.txt"

TrivEx._datamode = ""

TrivEx._Questions = {n=0}

-- Scores
TrivEx._Scores = {}

local f,e = io.open(TrivEx._Sets.folder.."/"..TrivEx._Sets.ScoresFile, "a+" ) --//Error handle.. makes sure save file and dir exist...
f,e = io.open(TrivEx._Sets.folder.."/"..TrivEx._Sets.ScoresFile, "a+" )
if f then
	f:write("" ) 
	f:close() --// file and path did not exist.. now they do.
end
require(TrivEx._Sets.folder.."/"..TrivEx._Sets.ScoresFile)

-- PM Players
TrivEx._PMPlayers = {}

local f,e = io.open(TrivEx._Sets.folder.."/"..TrivEx._Sets.PMPlayersFile, "a+" ) --//Error handle.. makes sure save file and dir exist...
f,e = io.open(TrivEx._Sets.folder.."/"..TrivEx._Sets.PMPlayersFile, "a+" )
if f then
	f:write("" ) 
	f:close() --// file and path did not exist.. now they do.
end

require(TrivEx._Sets.folder.."/"..TrivEx._Sets.PMPlayersFile)
os.remove(TrivEx._Sets.folder.."/"..TrivEx._Sets.PMPlayersFile)

---------------------------------------------------------------------------------------
--	TRIVIA EX CONFIG
---------------------------------------------------------------------------------------
TrivEx._Config = {}

TrivEx._Config.mode = 		"main"				-- "main" = Trivia is played in MainChat, "pm" = Trivia is played in PM
TrivEx._Config.showquesmode = 	1				-- Questions Mode 1 = Random, 2 = Sequential (e.g. 1,2,3)
TrivEx._Config.trivskip = 	0				-- 1 = trivskip enabled, 0 = disabled
TrivEx._Config.trivhint = 	0				-- 1 = trivhint enabled, 0 = disabled
TrivEx._Config.sequentialnum = 	0

local f,e = io.open(TrivEx._Sets.folder.."/"..TrivEx._Sets.TrivConfigFile, "a+" ) --//Error handle.. makes sure save file and dir exist...
f,e = io.open(TrivEx._Sets.folder.."/"..TrivEx._Sets.TrivConfigFile, "a+" )
if f then
	f:write("" ) 
	f:close() --// file and path did not exist.. now they do.
end

require(TrivEx._Sets.folder.."/"..TrivEx._Sets.TrivConfigFile)

---------------------------------------------------------------------------------------
--	TRIVIA Data
---------------------------------------------------------------------------------------
TrivEx.Data = {}

TrivEx.Data.HelpNormal = "-- Trivia Ex V."..TrivEx._Sets.Version.." by chill --\r\n\r\n\tPrefixes: ! + -\r\n"..
	"\t------------------------\r\n"..
	"\ttrivhelp   - This Text\r\n"..
	"\t------------------------\r\n"..
	"\ttrivscore   - Shows the top "..TrivEx._Sets.displscorers.." scorers\r\n"..
	"\ttrivmyscore   - Shows your score\r\n"..
	"\ttrivstats   - Shows the top "..TrivEx._Sets.displtoptrivs.." player stats\r\n"..
	"\ttrivplayers   - Shows you the Trivia Players, if played in PM\r\n"..
	"\ttrivskip   - Lets you skipp the current question, if enabled\r\n"..
	"\ttrivhint   - Gives you a hint, if enabled\r\n"..
	"\tlogin   - Logs you in\r\n"..
	"\tlogout   - Log you out\r\n"..
	"\t------------------------\r\n"

TrivEx.Data.HelpConfig = TrivEx.Data.HelpNormal..
	"\ttrivstart  - Start the Trivia\r\n"..
	"\ttrivstop   - Stop the Trivia\r\n"..
	"\ttrivquestion <QuestionNr.>   - Starts with questionNr.\r\n"
	if (TrivEx._Sets.quesmode == 1) then
		TrivEx.Data.HelpConfig = TrivEx.Data.HelpConfig.."\ttrivaddquestion <Category/Question/Answers>   - Lets you add a question\r\n"
	elseif (TrivEx._Sets.quesmode == 2) then
		TrivEx.Data.HelpConfig = TrivEx.Data.HelpConfig.."\ttrivaddquestion <Question/Answers>   - Lets you add a question\r\n"
	end
	TrivEx.Data.HelpConfig = TrivEx.Data.HelpConfig.."\t------------------------\r\n"

TrivEx.Data["HelpConfig+"] = TrivEx.Data.HelpConfig..
	"\ttriviaskip   - Enables/Disables TriviaSkip\r\n"..
	"\ttriviahint   - Enables/Disables TrivHint\r\n"..
	"\ttriviamain   - Plays Trivia in Main Chat\r\n"..
	"\ttriviapm   - Plays Trivia in PM to the bot\r\n"..
	"\ttriviascorereset   - Lets you reset all scores\r\n"..
	"\ttriviachangemode   - Changes the Questionmode\r\n"..
	"\t------------------------\r\n"

---------------------------------------------------------------------------------------
--	TRIVIA FUNCTIONS
---------------------------------------------------------------------------------------

function TrivEx:Main()

	if (self:GetPlayMode() == "pm") then
		frmHub:RegBot(self._Sets.bot)
		SendToAll(self._Sets.botmyinfo)
		
		table.foreach(self._PMPlayers,function(nick,_)
			if not GetItemByName(nick) then
				self._PMPlayers[nick] = nil
			end
		end)
	elseif (self._Sets.regbot == 1) then
		frmHub:RegBot(self._Sets.bot)
		SendToAll(self._Sets.botmyinfo)
	elseif (self._Sets.regbot == 0) then
		frmHub:UnregBot(TrivEx._Sets.bot)
	end
	curTriv.totalques = TrivEx:GetTotalQues()
	SetTimer(1*1000)
	if (self._Sets.StartOnMain == 1) then
		StartTimer()
	end
end
----------------------------------
function TrivEx:GetTotalQues()
	local handle = io.open(self._Sets.folder.."/"..self._Sets.questionfile,"r")
	local count = 0
	if handle then
		local line = handle:read()
		while line do
			count = count + 1
			line = handle:read()
		end
		handle:close()
	end
	return(count)
end
----------------------------------
function TrivEx:OnExit()
	self:WriteTable(self._Scores,"TrivEx._Scores",self._Sets.folder.."/"..TrivEx._Sets.ScoresFile)
	self:WriteTable(self._Config,"TrivEx._Config",self._Sets.folder.."/"..self._Sets.TrivConfigFile)
	if (self:GetPlayMode() == "pm") then
		self:WriteTable(self._PMPlayers,"TrivEx._PMPlayers",self._Sets.folder.."/"..TrivEx._Sets.PMPlayersFile)
	end
end
-----------------------------------
function TrivEx:ParseData(mode,curUser,data)

	self._datamode = mode
	data = string.sub(data,1,string.len(data)-1)
	local _,_,sdata = string.find( data, "^%b<>%s(.*)$")
	local _,_,cmd = string.find( data, "^%b<>%s["..self._Sets.prefixes.."](%w+)")
	if cmd then
		cmd = string.lower(cmd)
		if self._Cmds[cmd] then
			self._Cmds[cmd](self,curUser,data)
			return 1
		end
	elseif sdata then
		local corrans = table.foreachi(curTriv.ans, function(_,v)
			if string.lower(sdata) == string.lower(v) then
				return (v)
			end
		end)
		if sGag[curUser.sName] == 1 then
			return 1
		end
		if corrans and (not curTriv:GetGetQues()) then
			-- SetGetQues
			curTriv:SetGetQues(1)
			local ansTime = string.format("%.2f",(os.clock()-curTriv.start)) -- Get Answering Time in sec.
			if (TrivEx._Sets.showcorrectanswer == 1) then
				-- Show right answer
				local talked = nil
				if string.find( sdata, corrans ) then
					talked = corrans
				end
				if talked then
					if not (self:GetPlayMode() == "pm") then
						SendToAll(curUser.sName,corrans)
					end
					self:SendToPlayers("Correct "..curUser.sName.." the answer was \""..corrans.."\", You get "..curTriv.points.." Point(s). Answer solved in "..ansTime.." sec.")
					-- Show other answeres if present
					if curTriv.availans > 1 then
						curTriv:ShowAnswer()
					end
					-- Update Scores
					if self._Scores[curUser.sName] then
						self._Scores[curUser.sName].Score = self._Scores[curUser.sName].Score + curTriv.points
						self._Scores[curUser.sName].AvTime[1] = self._Scores[curUser.sName].AvTime[1] + ansTime
						self._Scores[curUser.sName].AvTime[2] = self._Scores[curUser.sName].AvTime[2] + 1
						self._Scores[curUser.sName].AvTime[3] = tonumber(string.format("%.2f",self._Scores[curUser.sName].AvTime[1]/self._Scores[curUser.sName].AvTime[2]))
					else
						self._Scores[curUser.sName] = {}
						self._Scores[curUser.sName].Score = curTriv.points
						self._Scores[curUser.sName].Streak = 1
						self._Scores[curUser.sName].AvTime = { tonumber(ansTime),1,tonumber(ansTime) }
					end
					if (self._Sets.showcorrectanswer == 1) then
						self:SendToPlayers(curUser.sName.."'s Stats, Score: "..self._Scores[curUser.sName].Score.." Point(s), Answerd Questions: "..self._Scores[curUser.sName].AvTime[2]..", Average Answering Time: "..string.format("%.2f",self._Scores[curUser.sName].AvTime[3]).." sec.")
					end
					-- Check for Streak
					curTriv.streak:UpdStreak(curUser)
					return 1
				end
			elseif (TrivEx._Sets.showcorrectanswer == 2) then
				-- Show right answer
				local talked = nil
				if string.find( sdata, corrans ) then
					talked = corrans
				end
				if talked then
					if not (self:GetPlayMode() == "pm") then
						SendToAll(curUser.sName,corrans)
					end
					self:SendToPlayers("Correct "..curUser.sName.." the answer was \""..corrans.."\", You get "..curTriv.points.." Point(s).")
					-- Show other answeres if present
					if curTriv.availans > 1 then
						curTriv:ShowAnswer()
					end
					-- Update Scores
					if self._Scores[curUser.sName] then
						self._Scores[curUser.sName].Score = self._Scores[curUser.sName].Score + curTriv.points
						self._Scores[curUser.sName].AvTime[1] = self._Scores[curUser.sName].AvTime[1] + ansTime
						self._Scores[curUser.sName].AvTime[2] = self._Scores[curUser.sName].AvTime[2] + 1
						self._Scores[curUser.sName].AvTime[3] = tonumber(string.format("%.2f",self._Scores[curUser.sName].AvTime[1]/self._Scores[curUser.sName].AvTime[2]))
					else
						self._Scores[curUser.sName] = {}
						self._Scores[curUser.sName].Score = curTriv.points
						self._Scores[curUser.sName].Streak = 1
						self._Scores[curUser.sName].AvTime = { tonumber(ansTime),1,tonumber(ansTime) }
					end
					if (self._Sets.showcorrectanswer == 1) then
						self:SendToPlayers(curUser.sName.."'s Stats, Score: "..self._Scores[curUser.sName].Score.." Point(s), Answerd Questions: "..self._Scores[curUser.sName].AvTime[2]..", Average Answering Time: "..string.format("%.2f",self._Scores[curUser.sName].AvTime[3]).." sec.")
					end
					-- Check for Streak
					curTriv.streak:UpdStreak(curUser)
					return 1
				end
			end

		elseif (self:GetPlayMode() == "pm") then
			self:SendToPlayers(data,curUser)
		end

	end

end
--------------------
function TrivEx:NewUserConnected(curUser)
	if (self:GetPlayMode() == "pm") or (self._Sets.regbot == 1) then
		curUser:SendData(self._Sets.botmyinfo)
	end
end
---------------------
function TrivEx:UserDisconnected(curUser)
	if (self:GetPlayMode() == "pm") and self._PMPlayers[curUser.sName] then
		self._PMPlayers[curUser.sName] = nil
	end
end
--------------------
function TrivEx:OnTimer()

	-- Load Questions if needed
	if (table.getn(self._Questions) == 0) then
		self:LoadQuestions()
	end
	-- Check if Trivia should be paused
	if (self._Sets.dobreak == 1) then
		if (not curTriv:Pause()) then
			-- Update TimeBreak
			TrivTimers.timebreak = TrivTimers.timebreak + 1
			if (TrivTimers.timebreak >= self._Sets.timebreak) and curTriv:GetGetQues() then
				curTriv:SetPause(1)
				TrivTimers.timebreak = 0
				TrivTimers.breaktime = 0
				self:SendToPlayers("Short Trivia break for "..(self._Sets.breaktime/60).." min.")
			end
		end
		if curTriv:Pause() then
			-- Update BreakTime
			TrivTimers.breaktime = TrivTimers.breaktime + 1
			if (TrivTimers.breaktime >= self._Sets.breaktime) then
				curTriv:SetPause(0)
				TrivTimers.timebreak = 0
				TrivTimers.breaktime = 0
				TrivTimers.showques = 0
			end
		end
	end
	-- Check if Trivia should be Autostoped
	if curTriv:GetGetQues() then
		if self._Sets.autostop and (curTriv.unansques == self._Sets.autostop) then
			StopTimer()
			curTriv:SetGetQues(1)
			self:WriteTable(self._Scores,"TrivEx._Scores",self._Sets.folder.."/"..TrivEx._Sets.ScoresFile)
			self:SendToPlayers("Trivia stopped due to Autostop, "..self._Sets.autostop.." questions weren't answered in a row.")
			return
		end
	end
	if (not curTriv:Pause()) then
		--Update ShowQuestion Time
		TrivTimers.showques = TrivTimers.showques + 1
		if (TrivTimers.showques == self._Sets.showques) then
			TrivTimers.showques = 0
			-- Check if to get new question
			if curTriv:GetNewQues() then
				curTriv:SendQuestion()
				-- Count unsanswered questions one up
				curTriv.unansques = curTriv.unansques + 1
			else
				curTriv:UpdHint()
				if curTriv:GetGetQues() then
					-- Show the Answer
					curTriv:ShowAnswer()
					-- Check for Streak
					curTriv.streak:UpdStreak()
				else
					curTriv:SendQuestion()
				end
			end
		end
	end
	if (self._Sets.savestats ~= 0) then
		TrivTimers.savestats = TrivTimers.savestats + 1
		if TrivTimers.savestats >= self._Sets.savestats then
			TrivTimers.savestats = 0
			if (curTriv.streak.write_scores == 1) then
				self:WriteTable(self._Scores,"TrivEx._Scores",self._Sets.folder.."/"..TrivEx._Sets.ScoresFile)
				curTriv.streak.write_scores = 0
			end
		end
	end
end
-------------------------
function TrivEx:SendToUser(curUser,data)
	if (self._datamode == "main") then
		curUser:SendData(TrivEx._Sets.bot,data)
	else
		curUser:SendPM(TrivEx._Sets.bot,data)
	end
end
--------------------------
function TrivEx:SendToPlayers(data,curUser)
	if (self:GetPlayMode() == "main") then
		SendToAll(self._Sets.bot,data)
	else
		local snick = ""
		if curUser then
			snick = curUser.sName
		else
			data = "<"..self._Sets.bot.."> "..data
		end
		for i,_ in self._PMPlayers do
			local user = GetItemByName(i)
			if user then
				if (i ~= snick) then
					user:SendData("$To: "..i.." From: "..self._Sets.bot.." $"..data)
				end
			else
				self._PMPlayers[i] = nil
			end
		end
	end
end
---------------------------
function TrivEx:AllowedProf(status,curUser)
	if self._Profiles[status] and self._Profiles[status][curUser.iProfile] then
		return 1
	end
end
----------------------------
function TrivEx:SetPlayMode(mode)
	if (mode == "main") then 
		self._PMPlayers = {}
		if (self._Sets.regbot == 0) then
			frmHub:UnregBot(self._Sets.bot)
		end
		self:WriteTable(self._Config,"TrivEx._Config",self._Sets.folder.."/"..self._Sets.TrivConfigFile)
		StartTimer()
		curTriv:SetGetQues(1)
		self._Config.mode = mode
	elseif (mode == "pm") then
		self._PMPlayers = {}
		frmHub:RegBot(self._Sets.bot)
		SendToAll(self._Sets.botmyinfo)
		self:WriteTable(self._Config,"TrivEx._Config",self._Sets.folder.."/"..self._Sets.TrivConfigFile)
		self._Config.mode = mode
	end
end
------------------------------
function TrivEx:GetPlayMode()
	return self._Config.mode
end
------------------------------
function TrivEx:LoadQuestions(getques)
	self._Questions = {n = 0}
	local howmany = self._Sets.memques
	if (self._Config.showquesmode == 1) and (not getques) then
		local getlines = {}
		for _ = 1,howmany do
			getlines[math.random(curTriv.totalques)] = 1
		end
		local handle = io.open(self._Sets.folder.."/"..self._Sets.questionfile,"r")
		if handle then
			local curTrivQuestions = {}
			local slinecount = 0
			local line = handle:read()
			while line do
				slinecount = slinecount + 1
				if getlines[slinecount] then
					local cat,ques,ans = self:SplitLine(line)
					if (cat and ques and ans) then
						table.insert(curTrivQuestions,{cat,ques,ans,slinecount})
					end
				end
				line = handle:read()
			end
			handle:close()
			for _ = 1,table.getn(curTrivQuestions) do
				local num = math.random(table.getn(curTrivQuestions))
				table.insert(self._Questions,curTrivQuestions[num])
				table.remove(curTrivQuestions,num)
			end					
		end
	elseif (self._Config.showquesmode == 2) or (getques) then
		self._Config.sequentialnum = self._Config.sequentialnum or 0
		local getlines = {}
		for _ = 1,howmany do
			self._Config.sequentialnum = self._Config.sequentialnum + 1
			if (self._Config.sequentialnum <= curTriv.totalques) then
				getlines[self._Config.sequentialnum] = 1
				if getques then
					break
				end
			else
				self._Config.sequentialnum = 0
			end
		end
		local handle = io.open(self._Sets.folder.."/"..self._Sets.questionfile,"r")
		if handle then
			local slinecount = 0
			local line = handle:read()
			while line do
				slinecount = slinecount + 1
				if getlines[slinecount] then
					local cat,ques,ans = self:SplitLine(line)
					if (cat and ques and ans) then
						table.insert(self._Questions,{cat,ques,ans,slinecount})
					end
				end
				line = handle:read()
			end
			handle:close()
		end
		if (not getques) then
			TrivEx:WriteTable(self._Config,"TrivEx._Config",self._Sets.folder.."/"..TrivEx._Sets.TrivConfigFile)
		end
	end	
end
-----------------------------
function TrivEx:SplitLine(line,dividechar)

	local dividechar = dividechar or self._Sets.dividechar
	local set,cat,ques,ans = {0,1},"","",{n=0}
	for i = 1,string.len(line) do
		if (string.sub(line,i,i) == dividechar) then
			if (self._Sets.quesmode == 1) then
				if (set[1] == 0) then
					cat = string.sub(line,set[2],(i-1))
					set = { 1,(i+1) }
				elseif (set[1] == 1) then
					ques = string.sub(line,set[2],(i-1))
					ans = string.sub(line,(i+1),string.len(line))
					ans = self:SplitAnswer(ans,dividechar)
					return cat,ques,ans
				end
			elseif (self._Sets.quesmode == 2) then
				ques = string.sub(line,1,(i-1))
				ans = string.sub(line,(i+1),string.len(line))
				ans = self:SplitAnswer(ans,dividechar)
				return cat,ques,ans
			end
		end
	end
end
----------------------------
function TrivEx:SplitAnswer(ans,dividechar)
	local set1,anst = 1,{n=0}
	for i = 1,string.len(ans) do
		if (string.sub(ans,i,i) == dividechar) then
			table.insert(anst,string.sub(ans,set1,(i-1)))
			set1 = (i+1)
		elseif i == string.len(ans) then
			table.insert(anst,string.sub(ans,set1,string.len(ans)))
		end
	end
	return anst
end
--------------------------------------------
function TrivEx:WriteTable(table,tablename,file)
	local hFile = io.open(file,"w+")
	self:Serialize(table,tablename,hFile);
	hFile:close()
end
-------------------------------------------
function TrivEx:Serialize(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in tTable do
		if (type(value) ~= "function") then
			local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
			if(type(value) == "table") then
				self:Serialize(value,sKey,hFile,sTab.."\t");
			else
				local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
				hFile:write(sTab.."\t"..sKey.." = "..sValue);
			end
			hFile:write(",\n");
		end
	end
	hFile:write(sTab.."}");
end
--------------------------------------------
function TrivEx:TrivHelp(curUser)
	if (self:AllowedProf("Config+",curUser)) then
		self:SendToUser(curUser,TrivEx.Data["HelpConfig+"])
	elseif self:AllowedProf("Config",curUser) then
		self:SendToUser(curUser,TrivEx.Data.HelpConfig)
	elseif self:AllowedProf("Normal",curUser) then
		self:SendToUser(curUser,TrivEx.Data.HelpNormal)
	end
end
----------------------------------
function TrivEx:TrivScore(curUser)
	if self:AllowedProf("Normal",curUser) then
		local TCopy = {}
		table.foreach(self._Scores, function(i,v) table.insert(TCopy, {i,v}) end)
		table.sort(TCopy,function(a,b) return(a[2].Score>b[2].Score) end)
		local msg = " -- Top "..self._Sets.displscorers.." Trivia Scorers --\r\n\r\n"
		for i = 1,TrivEx._Sets.displscorers do
			if TCopy[i] then
				msg = msg.."\t# "..i.."  -  "..TCopy[i][1]..",  Points: "..TCopy[i][2].Score.."\r\n"
			end
		end
		self:SendToUser(curUser,msg)
	end
end
------------------------------------
function TrivEx:TrivMyScore(curUser)
	if self:AllowedProf("Normal",curUser) then
		if self._Scores[curUser.sName] then
			local TCopy = {}
			table.foreach(self._Scores, function(i,v) table.insert(TCopy, {i,v}) end)
			table.sort(TCopy,function(a,b) return(a[2].Score>b[2].Score) end)
			for i = 1,table.getn(TCopy) do
				if TCopy[i][1] == curUser.sName then
					local msg = ""
					if TCopy[(i+1)] and TCopy[(i-1)] then
						msg = "\r\n\r\n\t\t# "..(i-1).." - "..TCopy[(i-1)][1]..",  Points: "..TCopy[(i-1)][2].Score..".  Diff = "..(TCopy[(i-1)][2].Score-TCopy[i][2].Score).." Point(s)."..
						"\r\n\t---->\t# "..i.." - "..TCopy[i][1]..",  Points: "..TCopy[i][2].Score.."."..
						"\r\n\t\t# "..(i+1).." - "..TCopy[(i+1)][1]..",  Points: "..TCopy[(i+1)][2].Score..".  Diff = "..(TCopy[(i+1)][2].Score-TCopy[i][2].Score).." Point(s)."
					elseif TCopy[(i-1)] then
						msg = "\r\n\r\n\t\t# "..(i-1).." - "..TCopy[(i-1)][1]..",  Points: "..TCopy[(i-1)][2].Score..".  Diff = "..(TCopy[(i-1)][2].Score-TCopy[i][2].Score).." Point(s)."..
						"\r\n\t--->\t# "..i.." - "..TCopy[i][1]..",  Points: "..TCopy[i][2].Score.."."
					elseif TCopy[(i+1)] then
						msg = "\r\n\r\n\t--->\t# "..i.." - "..TCopy[i][1]..",  Points: "..TCopy[i][2].Score.."."..
						"\r\n\t\t# "..(i+1).." - "..TCopy[(i+1)][1]..",  Points: "..TCopy[(i+1)][2].Score..".  Diff = "..(TCopy[(i+1)][2].Score-TCopy[i][2].Score).." Point(s)."
					end
					self:SendToUser(curUser,"------ "..curUser.sName.."'s Player Stats. Total Players = "..table.getn(TCopy).." ------"..msg.."\r\n\r\n"..
					"\t\t"..curUser.sName.."'s longest run = "..TCopy[i][2].Streak..".\r\n")
				end
			end
		else
			self:SendToUser(curUser,"Your current score is : 0 Point(s).")
		end
	end
end
--------------------------------		 
function TrivEx:TrivStats(curUser)
	if self:AllowedProf("Normal",curUser) then
		local TCopy = {}
		table.foreach(self._Scores, function(i,v) table.insert(TCopy, {i,v}) end)
		table.sort(TCopy,function(a,b) return(a[2].Score>b[2].Score) end)
		local msg = "----- Top "..self._Sets.displtoptrivs.." Player Stats -----\r\n\r\n\tTop "..self._Sets.displtoptrivs.." Scorers.\r\n\r\n"
		for i = 1,self._Sets.displtoptrivs do
			if TCopy[i] then
				msg = msg.."\t# "..i.."  -  "..TCopy[i][1]..",  Points: "..TCopy[i][2].Score.."\r\n"
			end
		end

		table.sort(TCopy,function(a,b) return(a[2].Streak>b[2].Streak) end)
		local msg = msg.."\r\n\tTop "..self._Sets.displtoptrivs.." Runners.\r\n\r\n"
		for i = 1,self._Sets.displtoptrivs do
			if TCopy[i] then
				msg = msg.."\t# "..i.."  -  "..TCopy[i][1]..",  Run: "..TCopy[i][2].Streak.."\r\n"
			end
		end

		table.sort(TCopy,function(a,b) return(a[2].AvTime[3]<b[2].AvTime[3]) end)
		local msg = msg.."\r\n\tTop "..self._Sets.displtoptrivs.." Typos.\r\n\r\n"
		for i = 1,self._Sets.displtoptrivs do
			if TCopy[i] then
				msg = msg.."\t# "..i.."  -  "..TCopy[i][1]..", Average Answering Time: "..TCopy[i][2].AvTime[3].." sec.\r\n"
			end
		end

		table.sort(TCopy,function(a,b) return(a[2].AvTime[2]>b[2].AvTime[2]) end)
		local msg = msg.."\r\n\tTop "..self._Sets.displtoptrivs.." Wizos.\r\n\r\n"
		for i = 1,self._Sets.displtoptrivs do
			if TCopy[i] then
				msg = msg.."\t# "..i.."  -  "..TCopy[i][1]..", Answered Questions: "..TCopy[i][2].AvTime[2].."\r\n"
			end
		end
		self:SendToUser(curUser,msg)
	end
end
----------------------------
function TrivEx:Login(curUser)
	if self:AllowedProf("Normal",curUser) then
		if (self:GetPlayMode() == "pm") then
			if not self._PMPlayers[curUser.sName] then
				self._PMPlayers[curUser.sName] = 1
				self:SendToPlayers("\""..curUser.sName.."\" has joined the Trivia.")
			else
				self:SendToUser(curUser,"You are already loged into Trivia.")
			end
		else
			self:SendToUser(curUser,"Trivia is played in Main Chat. You don't need to login.")
		end
	end
end
------------------------------
function TrivEx:Logout(curUser)
	if self:AllowedProf("Normal",curUser) then
		if (self:GetPlayMode() == "pm") then
			if self._PMPlayers[curUser.sName] then
				self:SendToPlayers("\""..curUser.sName.."\" has parted the trivia..")
				self._PMPlayers[curUser.sName] = nil
			else
				self:SendToUser(curUser,mode,"You are not loged into Trivia.")
			end
		else
			self:SendToUser(curUser,"Trivia is played in Main Chat. You don't need to logout.")
		end
	end
end
-------------------------------
function TrivEx:ShowTrivPlayers(curUser)
	if self:AllowedProf("Normal",curUser) then
		if (self:GetPlayMode() == "pm") then
			local players = ""
			for i,_ in self._PMPlayers do
				players = players.."\r\n\t-  "..i
			end
			self:SendToUser(curUser,"Currently Loged In:\r\n"..players.."\r\n")
		else
			self:SendToUser(curUser,"Trivia is played in Main Chat. Everybody is a player.")
		end
	end
end
-----------------------------------
function TrivEx:DoTrivSkip(curUser)
	if self:AllowedProf("Normal",curUser) then
		if (self._Config.trivskip == 1) then
			if not curTriv:GetGetQues() then
				self:SendToPlayers("\""..curUser.sName.."\" has skipped this question.")
				curTriv:SetGetQues(1)
			else
				self:SendToUser(curUser,"No question to skip")
			end
		else
			self:SendToUser(curUser,"TriviaSkip is currently disabled.")
		end
	end
end
-------------------------------------
function TrivEx:DoTrivHint(curUser)
	if self:AllowedProf("Normal",curUser) then
		if (self._Config.trivhint == 1) then
			if not curTriv:GetGetQues() then
				self:SendToPlayers("\""..curUser.sName.."\" needs a hint.")
				curTriv:UpdHint()
				if curTriv:GetGetQues() then
					curTriv:ShowAnswer()
				else
					curTriv:SendQuestion()
				end
			else
				self:SendToUser(curUser,"No question given")
			end
		else
			self:SendToUser(curUser,"TriviaHint is currently disabled.")
		end
	end
end
------------------------
function TrivEx:TrivStart(curUser)
	if self:AllowedProf("Config",curUser) then
		curTriv.unansques = 0
		curTriv:SetGetQues(1)
		StartTimer()
		self:SendToUser(curUser,"Trivia is started.")
		self:SendToPlayers("Trivia was started by "..curUser.sName)
	end
end
-----------------------------
function TrivEx:TrivStop(curUser)
	if self:AllowedProf("Config",curUser) then
		StopTimer()
		curTriv:SetGetQues(1)
		self:WriteTable(self._Scores,"TrivEx._Scores",self._Sets.folder.."/"..self._Sets.ScoresFile)
		self:SendToUser(curUser,"Trivia is stoped.")
		self:SendToPlayers("Trivia was stoped by "..curUser.sName)
	end
end
--------------------------------
function TrivEx:LoadQuestion(curUser,data)
	if self:AllowedProf("Config",curUser) then
		local _,_,arg1 = string.find(data,"^%b<>%s+%S+%s+(%d+)")
		local num = tonumber(arg1) or 1
		self._Config.sequentialnum = num-1
		self:LoadQuestions(1)
		curTriv:SetGetQues(1)
		self:SendToUser(curUser,"Trying to load QuestionNr. "..num)
	end
end
--------------------------------
function TrivEx:UnGag(curUser,data)
	if self:AllowedProf("Config+",curUser) then
		local s,e,v = string.find(data,"%b<>%s+%S+%s+(%S+)") 
		local victim = GetItemByName(v) 
		if victim == nil then 
			self:SendToUser(curUser,"User is not in the hub.") 
		else 
			if sGag[victim.sName] == 1 then 
				sGag[victim.sName] = nil; 
				TrivEx:SendToPlayers(victim.sName.." was ungagged for knowing all the answers by heart.")
				TrivEx:WriteTable(sGag,"sGag","gagged.tbl")
			else
				self:SendToUser(curUser,victim.sName.." wasn´t gagged.") 
			end
		end 
	end
end	
-----------------------------------
function TrivEx:AddQuestion(curUser,data)
	if self:AllowedProf("Config",curUser) then
		local _,_,newquestion = string.find(data,"^%b<>%s+%S+%s+(.*)")
		if newquestion then
			local Cat,Ques,tAns = self:SplitLine(newquestion,"/")
			if Ques and Ques ~= "" then
				local handle = io.open(self._Sets.folder.."/"..self._Sets.addquestionfile,"a")
				if (self._Sets.quesmode == 1) then
					local msg = ""
					msg = msg.."Category: "..Cat..", Question: "..Ques..", Answers: "
					handle:write(Cat..self._Sets.dividechar..Ques)
					for i = 1,table.getn(tAns) do
						msg = msg..tAns[i]..", "
						handle:write(self._Sets.dividechar..tAns[i])
					end
					handle:write("\n")
					self:SendToUser(curUser,"Added Question: "..msg)
				elseif (self._Sets.quesmode == 2) then
					local msg = ""
					local handle = io.open(self._Sets.folder.."/"..self._Sets.addquestionfile,"a")
					msg = msg.."Question: "..Ques..", Answers: "
					handle:write(Ques)
					for i = 1,table.getn(tAns) do
						msg = msg..tAns[i]..", "
						handle:write(self._Sets.dividechar..tAns[i])
					end
					handle:write("\n")
					self:SendToUser(curUser,"Added Question: "..msg)
				end
				handle:close()
			else
				self:SendToUser(curUser,"Couldn't parse Question: "..newquestion)
			end
		else
			self:SendToUser(curUser,"No Question given!")
		end
	end
end
-----------------------
function TrivEx:ConfTrivSkip(curUser)
	if self:AllowedProf("Config+",curUser) then
		if (self._Config.trivskip == 1) then
			self._Config.trivskip = 0
			self:WriteTable(self._Config,"TrivEx._Config",self._Sets.folder.."/"..self._Sets.TrivConfigFile)
			self:SendToUser(curUser,"TriviaSkip is now disabled.")
		elseif (self._Config.trivskip == 0) then
			self._Config.trivskip = 1
			self:WriteTable(self._Config,"TrivEx._Config",self._Sets.folder.."/"..self._Sets.TrivConfigFile)
			self:SendToUser(curUser,"TriviaSkip is now enabled.")
		end
	end
end
---------------------------------
function TrivEx:ConfTrivHint(curUser)
	if self:AllowedProf("Config+",curUser) then
		if (self._Config.trivhint == 1) then
			self._Config.trivhint = 0
			self:WriteTable(self._Config,"TrivEx._Config",self._Sets.folder.."/"..self._Sets.TrivConfigFile)
			self:SendToUser(curUser,"TriviaHint is now disabled.")
		elseif (self._Config.trivhint == 0) then
			self._Config.trivhint = 1
			self:WriteTable(self._Config,"TrivEx._Config",self._Sets.folder.."/"..self._Sets.TrivConfigFile)
			self:SendToUser(curUser,"TriviaHint is now enabled.")
		end
	end
end
--------------------------------------
function TrivEx:PlayTrivMain(curUser)
	if self:AllowedProf("Config+",curUser) then
		self:SetPlayMode("main")
		self:SendToUser(curUser,"Trivia is now played in MainChat.")
	end
end
--------------------------------------
function TrivEx:PlayTrivPM(curUser)
	if self:AllowedProf("Config+",curUser) then
		self:SetPlayMode("pm")
		self:SendToUser(curUser,"Trivia is now played in PM.")
	end
end
-----------------------------------------
function TrivEx:ResetScore(curUser)
	if self:AllowedProf("Config+",curUser) then
		self._Scores = {}
		self:WriteTable(self._Scores,"TrivEx._Scores",self._Sets.folder.."/"..self._Sets.ScoresFile)
		self:SendToUser(curUser,"The scores have been reset.")
	end
end
--------------------------------------
function TrivEx:ChangeQuesMode(curUser)
	if self:AllowedProf("Config+",curUser) then
		if (self._Config.showquesmode == 1) then
			self._Config.showquesmode = 2
			self:LoadQuestions()
			self:SendToUser(curUser,"Questionmode is set to Sequential.")
		elseif (self._Config.showquesmode == 2) then
			self._Config.showquesmode = 1
			self:LoadQuestions()
			self:SendToUser(curUser,"Questionmode is set to Random.")
		end
		self:WriteTable(self._Scores,"TrivEx._Scores",self._Sets.folder.."/"..self._Sets.ScoresFile)
	end
end
---------------------------------------------------------------------------------------
--	TRIVIA EX COMMANDS
---------------------------------------------------------------------------------------
TrivEx._Cmds = {}

-- Normal Commands

TrivEx._Cmds.trivhelp = TrivEx.TrivHelp			-- Trivia Help
TrivEx._Cmds.trivscore = TrivEx.TrivScore		-- Shows the Ranking of the best Trivias
TrivEx._Cmds.trivmyscore = TrivEx.TrivMyScore		-- Shows only your score
TrivEx._Cmds.trivstats = TrivEx.TrivStats		-- Shows the top "TrivEx._Sets.displtoptrivs" player stats.
TrivEx._Cmds.login = TrivEx.Login			-- Allows you to login to Trivia
TrivEx._Cmds.logout = TrivEx.Logout			-- Allows you to logout of Trivia
TrivEx._Cmds.trivplayers = TrivEx.ShowTrivPlayers	-- Show's the Trivia Players
TrivEx._Cmds.trivskip =	TrivEx.DoTrivSkip		-- Lets you skip a question, trivskip
TrivEx._Cmds.trivhint =	TrivEx.DoTrivHint		-- Gives you a Hint

-- Configure Commands

TrivEx._Cmds.trivstart = TrivEx.TrivStart		-- Strats Trivia
TrivEx._Cmds.trivstop =	TrivEx.TrivStop			-- Stops Trivia
TrivEx._Cmds.trivquestion = TrivEx.LoadQuestion		-- Expects a number as argument, e.g. +trivquestion 111
TrivEx._Cmds.trivaddquestion = TrivEx.AddQuestion	-- Lets you add a question to a file

-- Configure+ Commands

TrivEx._Cmds.triviaskip = TrivEx.ConfTrivSkip		-- Enables/Disables triviaskip
TrivEx._Cmds.triviahint = TrivEx.ConfTrivHint		-- Enables/Disables triviahint
TrivEx._Cmds.triviamain = TrivEx.PlayTrivMain		-- Allows you to play in Main
TrivEx._Cmds.triviapm = TrivEx.PlayTrivPM		-- Allows you to play in PM, implements the regging of a bot
TrivEx._Cmds.triviascorereset =	TrivEx.ResetScore	-- Resets the Trivia Score
TrivEx._Cmds.triviachangemode = TrivEx.ChangeQuesMode	-- Chages the Question Mode
TrivEx._Cmds.iungag = TrivEx.UnGag			-- Ungags a user


---------------------------------------------------------------------------------------
--	TRIVIA GAME
---------------------------------------------------------------------------------------


-- Timers
TrivTimers = {}
TrivTimers.timebreak = 0
TrivTimers.breaktime = 0
TrivTimers.showques = 0
TrivTimers.savestats = 0

UnRevealed = {}
FirstLetters = {}

-- Current TriviaGame
curTriv = {}

curTriv.unansques = 0

curTriv.totalques = 0
curTriv.pause = 0
curTriv.getques = 1

curTriv.quesnum = 0
curTriv.cat = ""
curTriv.ques = ""
curTriv.ans = {}
curTriv.availans = 0
curTriv.points = 0
curTriv.hint = ""

curTriv.unrevealed = {}
curTriv.unrevealed.fl = {n = 0}
curTriv.unrevealed.ol = {n = 0}

curTriv.revealnum = 0

curTriv.streak = {}
curTriv.streak.nick = ""
curTriv.streak.streak = 0
curTriv.streak.write_scores = 0
-------------------------------------
-- funcs curTriv.streak
curTriv.streak.UpdStreak = function(self,curUser)

	if curUser then
		-- Write Scores by next saving
		curTriv.streak.write_scores = 1
		-- Set Unanswered Questions to zero
		curTriv.unansques = 0
		local nick = curUser.sName
		if (self.nick == nick) then
			self.streak = self.streak + 1
			if (self.streak > TrivEx._Scores[curUser.sName].Streak)  then
				TrivEx:SendToPlayers(nick..", you broke your current run of "..TrivEx._Scores[curUser.sName].Streak..".")
				TrivEx._Scores[curUser.sName].Streak = self.streak
			end
			if (self.streak == 12) then
				if sGag[nick] == nil then 
					sGag[nick] = 1 
					TrivEx:SendToPlayers(nick.." was gagged for knowing all the answers by heart.")
					TrivEx:WriteTable(sGag,"sGag","gagged.tbl")
				end
			elseif (self.streak == 9) then
				TrivEx:SendToPlayers("ey "..nick.."Warning No 2") 
			elseif (self.streak == 6) then
				TrivEx:SendToPlayers("And the miracle continues, "..nick.." that makes "..self.streak.." runs in a row now.")
			elseif (self.streak == 5) then
				TrivEx:SendToPlayers("ey "..nick.."Warning No 1") 
			elseif (self.streak == 3) then
				TrivEx:SendToPlayers(nick..", that makes "..self.streak.." runs in a row.")
			end
		else
			if (self.streak >= 12) then
				TrivEx:SendToPlayers("And "..nick.." ends "..self.nick.." miracle of "..self.streak.." runs in a row. Ole!")
			elseif (self.streak >= 9) then
				TrivEx:SendToPlayers(nick.." *applause*, was about time to break, "..self.nick.."'s "..self.streak.." runs in a row.")
			elseif (self.streak >= 6) then
				TrivEx:SendToPlayers("Beat it "..self.nick..", "..nick.." just set and end to your "..self.streak.." runs in a row.")
			elseif (self.streak >= 3) then
				TrivEx:SendToPlayers("There goes "..self.nick.."'s run of "..self.streak)
			end
			self.nick = nick
			self.streak = 1
		end
	else
		if (self.nick ~= "") then
			if (self.streak >= 12) then
				TrivEx:SendToPlayers("Well that was obvious, that this questions would end "..self.nick.."'s run of "..self.streak.." ;)")
			elseif (self.streak >= 9) then
				TrivEx:SendToPlayers(self.nick.." say 'good bye' to your run of "..self.streak)
			elseif (self.streak >= 3) then
				TrivEx:SendToPlayers("There goes "..self.nick.."'s run of "..self.streak)
			end
		end
		self.nick = ""
		self.streak = 0
	end
end
-------------------------------
-- funcs curTriv
function curTriv:Pause()
	if (self.pause == 1) then
		return 1
	end
end
------------------------------
function curTriv:SetPause(arg)
	self.pause = arg
end
-----------------------------
function curTriv:GetNewQues()
	if (self.getques == 1) then
		self:GetQuestion()
		return 1
	end
end
------------------------------
function curTriv:GetQuestion()

	self.quesnum = TrivEx._Questions[1][4]
	self.cat = TrivEx._Questions[1][1]
	self.ques = TrivEx._Questions[1][2]
	self.ans = TrivEx._Questions[1][3]
	self.availans = table.getn(self.ans)
	table.remove(TrivEx._Questions,1)
	self.points = 0
	self.hint = string.gsub(self.ans[1],"(%S)",function (w)  self.points = self.points + 1 return(TrivEx._Sets.revealchar) end)
	self.unrevealed.fl = {n = 0}
	self.unrevealed.ol = {n = 0}
	for i = 1,string.len(self.hint) do
		if (string.sub(self.hint,i,i) == TrivEx._Sets.revealchar) then
			if (TrivEx._Sets.revealques == 2) and ((i == 1) or (string.sub(self.hint,(i-1),(i-1)) == " ")) then
				table.insert(self.unrevealed.fl,i)
			else
				table.insert(self.unrevealed.ol,i)
			end
		end
	end
	if (TrivEx._Sets.trivshowhint == 2) then
		if ((self.points/TrivEx._Sets.shownhints - math.floor(self.points/TrivEx._Sets.shownhints)) >= 0.5) then
			self.revealnum = math.floor(self.points/TrivEx._Sets.shownhints) + 1
		elseif (math.floor(self.points/TrivEx._Sets.shownhints) == 0) then
			self.revealnum = 1
		else
			self.revealnum = math.floor(self.points/TrivEx._Sets.shownhints)
		end
	else
		self.revealnum = TrivEx._Sets.revealedchars
	end
	self.start = os.clock()
	self:SetGetQues(0)
end
----------------------------------
function curTriv:SetGetQues(arg)
	TrivTimers.showques = 0
	self.getques = arg
end
----------------------------------
function curTriv:GetGetQues()
	if (self.getques == 1) then	
		return 1
	end
end
-----------------------------------
function curTriv:SendQuestion()
	if (TrivEx._Sets.showquestion == 1) then
		TrivEx:SendToPlayers("QUESTION - Nr. "..self.quesnum.." from "..self.totalques.." Questions.\r\n"..
		"\t----------------------------------------------------------------------\r\n"..
		"\t> Category: "..self.cat.." - Point(s): "..self.points.." - Total Answers: "..self.availans.."\r\n"..
		"\t"..self:doSplitQuestion("QUESTION: "..self.ques).."\r\n"..
		"\tHINT:  "..self.hint.."\r\n"..
		"\t----------------------------------------------------------------------")
	elseif (TrivEx._Sets.showquestion == 2) then
		TrivEx:SendToPlayers("QUESTION - Nr. "..self.quesnum.." from "..self.totalques.." Questions.\r\n"..
		"\t----------------------------------------------------------------------\r\n"..
		"\t> Point(s): "..self.points.." - Total Answers: "..self.availans.."\r\n"..
		"\t"..self:doSplitQuestion("QUESTION: "..self.ques).."\r\n"..
		"\tHINT:  "..self.hint.."\r\n"..
		"\t----------------------------------------------------------------------")
	elseif (TrivEx._Sets.showquestion == 3) then
		TrivEx:SendToPlayers("\r\n"..
		"\r\n"..
		"\t"..self:doSplitQuestion("QUESTION: "..self.ques).."\r\n"..
		"\tHINT:  "..self.hint.."\r\n"..
		"")
	end
end
-----------------------------------
function curTriv:doSplitQuestion(sQues)
	for i = TrivEx._Sets.splitques,string.len(sQues) do
		if (string.sub(sQues,i,i) == " ") then
			local srest = string.sub(sQues,(i+1),string.len(sQues))
			srest = self:doSplitQuestion(srest)
			return (string.sub(sQues,1,(i-1)).."\r\n\t "..srest)
		end
	end
	return(sQues)
end
--------------------------------------
function curTriv:UpdHint()
	local thint = self:toTable(self.hint)
	if (TrivEx._Sets.revealques == 1) then
		for _ = 1,curTriv.revealnum do
			if (table.getn(curTriv.unrevealed.ol) ~= 0) then
				local rannum = math.random(table.getn(curTriv.unrevealed.ol))
				local strnum = curTriv.unrevealed.ol[rannum]
				thint[strnum] = string.sub(self.ans[1],strnum,strnum)
				curTriv.points = curTriv.points - 1
				table.remove(curTriv.unrevealed.ol,rannum)
			end
		end
	elseif(TrivEx._Sets.revealques == 2) then
		for _ = 1,curTriv.revealnum do
			if (table.getn(curTriv.unrevealed.fl) ~= 0) then
				local rannum = math.random(table.getn(curTriv.unrevealed.fl))
				local strnum = curTriv.unrevealed.fl[rannum]
				thint[strnum] = string.sub(self.ans[1],strnum,strnum)
				curTriv.points = curTriv.points - 1
				table.remove(curTriv.unrevealed.fl,rannum)
			elseif (table.getn(curTriv.unrevealed.ol) ~= 0) then
				local rannum = math.random(table.getn(curTriv.unrevealed.ol))
				local strnum = curTriv.unrevealed.ol[rannum]
				thint[strnum] = string.sub(self.ans[1],strnum,strnum)
				curTriv.points = curTriv.points - 1
				table.remove(curTriv.unrevealed.ol,rannum)
			end
		end
	end
	self.hint = self:toString(thint)
	if ((table.getn(curTriv.unrevealed.fl)+table.getn(curTriv.unrevealed.ol)) <= TrivEx._Sets.solveques) then
		self.hint = self.ans[1]
		self:SetGetQues(1)
	end
end
----------------------------------
function curTriv:toTable(String)
	local Table = {n = 0}
	for i = 1,string.len(String) do
		table.insert(Table,string.sub(String,i,i))
	end
	return Table
end
-----------------------------------
function curTriv:toString(Table)
	local String = ""
	for i = 1,table.getn(Table) do
		String = String..Table[i]
	end
	return(String)
end
-------------------------------------
function curTriv:ShowAnswer()
	TrivEx:SendToPlayers("The answer is:  "..curTriv.ans[1])
	if curTriv.availans > 1 then
		local msg = ""
		for i = 2,curTriv.availans do
			msg = msg..curTriv.ans[i]..", "
		end
		msg = string.sub(msg,1,string.len(msg)-2)
		curTriv:SendToPlayers("Other answers were: "..msg..".")
	end
end