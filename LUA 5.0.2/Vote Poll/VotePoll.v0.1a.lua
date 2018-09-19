-- Requested by TTB
-- Fast Lua 5 version by jiten (6/12/2005)

-- Vote-Poll made by nErBoS
-- Creates Vote Poll with Yes and No or add Option by Master's
-- User´s Can only vote one time in a Poll
-- Option to have Old Polls saved
-- Option to show old and new Poll on the main-chat to every one
-- +votehelp Shows All Vote Commands

Bot = "Vote-Bot"

oldpoll = {}
poll = {}
make = {}
timepoll = {}
clockpoll = {}
pollsv = "pollsv.dat"
makesv = "makesv.dat"
oldpollsv = "oldpollsv.dat"
timepollsv = "timepollsv.dat"
clockpollsv = "clockpollsv.dat"
changed = 0
min = 60

function Main()
	frmHub:RegBot(Bot)
	StartTimer()
end

function OnExit()
	Refresh()
	SaveToFile(pollsv , poll , "poll")
	SaveToFile(makesv , make , "make")
	SaveToFile(oldpollsv , oldpoll , "oldpoll")
	SaveToFile(timepollsv , timepoll , "timepoll")
	SaveToFile(clockpollsv , clockpoll , "clockpoll")
end

function OnTimer()
	for np, clc in clockpoll do
		if (os.clock() >= clc) then
			CheckPoll(Bot, np, "new", "all")
			clockpoll[np] = os.clock() + timepoll[np]
		end
	end
end

function ChatArrival(user, data)
	if (string.sub(data,1,1)=="<") or (string.sub(data,1,5+string.len(Bot))=="$To: "..Bot) then
		local data = string.sub(data,1,-2)
		local s,e,cmd = string.find(data,"%b<>%s+(%S+)")
		if (cmd=="+votehelp") then 
			local sMsg = ""
			if (user.iProfile == 0) then
				sMsg = sMsg.."Commands to the Vote-Poll:\r\n"
				sMsg = sMsg.."\r\n"
				sMsg = sMsg.."+createvote <question>\t\t\tCreates and Open the Poll with a question\r\n"
				sMsg = sMsg.."+addopt <poll-number> <option>\t\tAdd's a option to be voted on the poll choosed\r\n"
				sMsg = sMsg.."+endopt <poll-number>\t\t\tClose the Poll and is ready to start with Votes\r\n"
				sMsg = sMsg.."+stopvote <poll-number>\t\t\tWill end the Vote-Poll and will be saved in the Old-Poll\r\n"
				sMsg = sMsg.."+showvote <poll-number> <old/new>\tShow the vote results of the poll (old = old polls) or (new = polls are closed for vote)\r\n"
				sMsg = sMsg.."+svmain <poll-number> <old/new>\t\tShow the vote results in the mainchat (old = old polls) or (new = polls are closed for vote)\r\n"
				sMsg = sMsg.."+votelist\t\t\t\t\tShow all Old Polls\r\n"
				sMsg = sMsg.."+votefor\t\t\t\t\tShow the polls that you can vote\r\n"
				sMsg = sMsg.."+vote <poll-number> <opt>\t\tChoose a poll number and a opt number to vote\r\n"
				sMsg = sMsg.."+votetimer <poll-number> <time>\t\tChoose a poll number and a time (in minutes) to be show in the main\r\n"
				sMsg = sMsg.."+stoptimer <poll-number>\t\t\tChoose a poll number to stop the Timer on here of show in Main\r\n"
			sMsg = sMsg.."+delvote <poll-number>\t\t\tChoose a Old Poll number to delete\r\n"
				sMsg = sMsg.."\r\n"
				user:SendPM(Bot, sMsg)
			else
				sMsg = sMsg.."Commands to the Vote-Poll:\r\n"
				sMsg = sMsg.."\r\n"
				sMsg = sMsg.."+votefor\t\t\t\tShow the polls that you can vote\r\n"
				sMsg = sMsg.."+showvote <poll-number>\t\tShow the vote results of the poll \r\n"
				sMsg = sMsg.."+vote <poll-number> <opt>\tChoose a poll number and a opt number to vote\r\n"
				sMsg = sMsg.."\r\n"
				user:SendPM(Bot, sMsg)
			end
			return 1
		elseif (cmd=="+createvote") then
			if (user.iProfile == 0) then
				local s,e,question = string.find(data,"%b<>%s+%S+%s+(.*)")
				if (question == "") then
					user:SendPM(Bot, "Syntax error, +createvote <question>, you must write a question to the poll.")
				else
					number = CreatePoll(question)
					user:SendPM(Bot, "The Vote-Poll has been created with the number "..number..".")
				end
			else
				user:SendPM(Bot, "You don´t have permision to this command.")
			end
			return 1
		elseif (cmd=="+addopt") then
			if (user.iProfile == 0) then
				local s,e,number,option = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(.*)")
				if (number == nil or tonumber(number) == nil) then
					user:SendPM(Bot, "Syntax error, +addopt <poll-number> <option>, you must write a poll-number.")
				elseif (option == "") then
					user:SendPM(Bot, "Syntax error, +addopt <poll-number> <option>, you must write a option to the poll.")
				else
					AddPollOpt(user, number, option)
				end
			else
				user:SendPM(Bot, "You don´t have permision to this command.")
			end
			return 1
		elseif (cmd=="+endopt") then
			if (user.iProfile == 0) then
				local s,e,number= string.find(data,"%b<>%s+%S+%s+(%S+)")
				if (number == nil or tonumber(number) == nil) then
					user:SendPM(Bot, "Syntax error, +addopt <poll-number> <option>, you must write a poll-number.")
				else
					EndPollOpt(user, number)
				end
			else
				user:SendPM(Bot, "You don´t have permision to this command.")
			end
			return 1
		elseif (cmd=="+stopvote") then
			if (user.iProfile == 0) then
				local s,e,number = string.find(data,"%b<>%s+%S+%s+(.*)")
				if (tonumber(number) == nil or number == "") then
					user:SendPM(Bot, "Syntax error, +stopvote <poll-number>, you must write a poll-number.")
				else
					StopVotePoll(user, number)
				end
			else
				user:SendPM(Bot, "You don´t have permision to this command.")
			end
			return 1
		elseif (cmd=="+showvote") then
			if (user.iProfile == 0) then
				local s,e,number, opt = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)")
				if (number == nil or tonumber(number) == nil) then
					user:SendPM(Bot, "Syntax error, +showvote <poll-number> <old/new>, you must write a poll-number.")
				else
					if (string.lower(opt) == "old") then
						CheckPoll(user, number, "old", "pm")
					elseif(string.lower(opt) == "new") then
						CheckPoll(user, number, "new", "pm")
					else
						user:SendPM(Bot, "Syntax error, +showvote <poll-number> <old/new>, you must write (old = old polls) or (new = polls are closed for vote)")
					end
				end
			else
				local s,e,number = string.find(data,"%b<>%s+%S+%s+(%S+)")
				if (number == nil or tonumber(number) == nil) then
					user:SendPM(Bot, "Syntax error, +showvote <poll-number>, you must write a poll-number.")
				else
					CheckPoll(user, number, "new", "pm")
				end
			end
			return 1
		elseif (cmd=="+svmain") then
			if (user.iProfile == 0) then
				local s,e,number, opt = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)")
				if (number == nil or tonumber(number) == nil) then
					user:SendPM(Bot, "Syntax error, +svmain <poll-number> <old/new>, you must write a poll-number.")
				else
					if (string.lower(opt) == "old") then
						CheckPoll(user, number, "old", "all")
					elseif(string.lower(opt) == "new") then
						CheckPoll(user, number, "new", "all")
					else
						user:SendPM(Bot, "Syntax error, +svmain <poll-number> <old/new>, you must write (old = old polls) or (new = polls are closed for vote)")
					end
				end
			else
				user:SendPM(Bot, "You don´t have permision to this command.")
			end
			return 1
		elseif (cmd=="+votelist") then
			if (user.iProfile == 0) then
				SeePoll(user, "old")
			else
				user:SendPM(Bot, "You don´t have permision to this command.")
			end
			return 1
		elseif (cmd=="+votefor") then
			SeePoll(user, "new")
			return 1
		elseif (cmd=="+vote") then
			local s,e,number,opt = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)")
			if (number == nil or tonumber(number) == nil) then
				user:SendPM(Bot, "Syntax error, +vote <poll-number> <opt>, you must write a poll-number.")
			else
				if (opt == nil or tonumber(opt) == nil) then
					user:SendPM(Bot, "Syntax error, +vote <poll-number> <opt>, you must write a option number that you want to vote.")
				else
					VotePoll(user, number, opt)
				end
			end
			return 1
		elseif (cmd=="+delvote") then
			if (user.iProfile == 0) then
				local s,e,number = string.find(data,"%b<>%s+%S+%s+(%S+)")
				if (number == nil or tonumber(number) == nil) then
					user:SendPM(Bot, "Syntax error, +delvote <poll-number>, you must write a poll-number.")
				else
					DelOldPoll(user, number)
				end
			else
				user:SendPM(Bot, "You don´t have permision to this command.")
			end
			return 1
		elseif (cmd=="+votetimer") then
			if (user.iProfile == 0) then
				local s,e,number,time = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)")
				if (number == nil or tonumber(number) == nil) then
					user:SendPM(Bot, "Syntax error, +votetimer <poll-number> <time>, you must write a poll-number.")
				elseif (time == nil or tonumber(time) == nil) then
					user:SendPM(Bot, "Syntax error, +votetimer <poll-number> <time>, you must write a number in time (minutes).")
				else
					TimerVote(user, number, time)
				end
			else
				user:SendPM(Bot, "You don´t have permision to this command.")
			end
			return 1
		elseif (cmd=="+stoptimer") then
			if (user.iProfile == 0) then
				local s,e,number = string.find(data,"%b<>%s+%S+%s+(%S+)")
				if (number == nil or tonumber(number) == nil) then
					user:SendPM(Bot, "Syntax error, +votetimer <poll-number> <time>, you must write a poll-number.")
				else
					StopTimerVote(user, number)
				end
			else
				user:SendPM(Bot, "You don´t have permision to this command.")
			end
			return 1			
		end
	end
end

ToArrival = ChatArrival

--## Opens and Creates a New Poll ##--
function CreatePoll(question)
	local pos = 0
	Refresh()
	for i=1, table.getn(poll) do
		if (poll[i] == "free") then
			pos = i-1
			break
		end
		pos = i
	end
	poll[pos+1] = question
	make[pos+1] = "open"
	pos = pos+1

	-- Create the poll file --
	io.output(pos..".npoll")
	-- Create the poll vote users --
	io.output(pos..".vot")
	return pos
end

--## Add's a Option to an Open and Created Poll ##--
function AddPollOpt(user, number, option)
	local sTmp = ""
	local nOpt = 1
	number = tonumber(number)
	Refresh()
	if (poll[number] == nil or poll[number] == "free") then
		sTmp = "The Poll with the number "..number.." doesn't exist."
	elseif (make[number] == "closed") then
		sTmp = "The Poll with the number "..number.." is already closed."
	else
		local f = io.open(number..".npoll","r")
		if f then
			while 1 do
				local line = f:read()
				if (line == nil) then
					sTmp = sTmp..nOpt..". "..option.." (Voted: 0)"
					break
				else
					local s,e,num = string.find(line, "(%d+)%.%s+.*")
					if (num ~= nil and tonumber(num) ~= nil) then
						nOpt = tonumber(num) + 1
					end
					sTmp = sTmp..line.."\r\n"
				end
			end
			f:close()
		end
		local g = io.open(number..".npoll","w+")
		g:write(sTmp)
		g:flush()
		g:close()
		make[number] = "opt"
		sTmp = "Option Sucessfuly added."
	end
	user:SendPM(Bot, sTmp)
end

--## Closes the New Poll and makes it avaible for Vote ##--
function EndPollOpt(user, number)
	local sTmp = ""
	number = tonumber(number)
	Refresh()
	if (poll[number] == nil or poll[number] == "free") then
		sTmp = "The Poll with the number "..number.." doesn't exist."
	elseif (make[number] == "closed") then
		sTmp = "The Poll with the number "..number.." is already closed."
	elseif (make[number] == "open") then
		local f = io.open(number..".npoll","w+")
		f:write("1. Yes (Voted: 0)\r\n2. No (Voted: 0)")
		f:flush() f:close()
		make[number] = "closed"
		sTmp = "The Poll as been closed, and is ready to be voted."
	else
		make[number] = "closed"
		sTmp = "The Poll as been closed, and is ready to be voted."
	end
	user:SendPM(Bot, sTmp)
end

--## Will Stop Vote Poll and save it in Old Poll ##--
function StopVotePoll(user, number)
	local sTmp = ""
	number = tonumber(number)
	local pos = 0
	Refresh()
	if (poll[number] == nil or poll[number] == "free") then
		sTmp = "The Poll with the number "..number.." doesn't exist."
	elseif (make[number] ~= "closed") then
		sTmp = "The Poll with the number "..number.." isn´t closed, you must close it first for stop it."
	else
		for i=1, table.getn(oldpoll) do
			if (oldpoll[i] == "free") then
				pos = i-1
				break
			end
			pos = i
		end
		pos = pos+1
		oldpoll[pos] = poll[number]
		poll[number] = "free"
		make[number] = "free"
		local f = io.open(number..".npoll")
		if f then
			for line in io.lines(number..".npoll") do
				sTmp = sTmp..line.."\r\n"
			end
			f:close()
		end
		local g = io.open(pos..".opoll")
		g:write(sTmp)
		g:flush() g:close()
		os.remove(number..".npoll")
		os.remove(number..".vot")
		sTmp = "The Poll number "..number.." as been stoped and save in the Old Poll number "..pos.."."
	end
	user:SendPM(Bot, sTmp)	
end

--## Shows Old or New Polls ##--
function CheckPoll(user, number, opt, text)
	local sTmp = ""
	number = tonumber(number)
	Refresh()
	if (opt == "new") then
		if (poll[number] == nil or poll[number] == "free" or make[number] ~= "closed") then
			sTmp = "The Poll number "..number.." doesn´t existes."
		else
			sTmp = sTmp.."\r\n-------------------- Vote Poll --------------------\r\n\r\n"
			sTmp = sTmp.."Results of Vote-Poll Nr: "..number.."\r\n"
			sTmp = sTmp.."Topic: "..poll[number].."\r\n\r\n"
			local f = io.open(number..".npoll","r")
			if f then
				for line in io.lines(number..".npoll") do
					sTmp = sTmp..line.."\r\n"
				end
				f:close()
			end
		end
	elseif (opt == "old") then
		if (oldpoll[number] == nil or oldpoll[number] == "free") then
			sTmp = "The Poll number "..number.." doesn´t existes."
		else
			sTmp = sTmp.."\r\n-------------------- Vote Poll --------------------\r\n\r\n"
			sTmp = sTmp.."Results of Closed Vote-Poll Nr: "..number.."\r\n"
			sTmp = sTmp.."Topic: "..oldpoll[number].."\r\n\r\n"
			local f = io.open(number..".opoll","r")
			if f then
				for line in io.lines(number..".opoll") do
					sTmp = sTmp..line.."\r\n"
				end
				f:close()
			end
		end
	end
	if (text == "pm") then
		user:SendPM(Bot, sTmp)
	elseif (text == "all") then
		SendToAll(Bot, sTmp)
	end
end

--## Show All Polls to Vote or Finished ##--
function SeePoll(user, opt)
	local sTmp = ""
	local accept = 0
	Refresh()
	if (opt == "new" or not user.bOperator) then
		sTmp = sTmp.."All Polls that are in Vote:\r\n\r\n"
		for i=1, table.getn(poll) do 
			if (make[i] == "closed") then
				sTmp = sTmp..i..". "..poll[i].."\r\n"
				accept = 1
			end
		end
		if (accept == 0) then
			sTmp = "There aren't any Poll to be Voted."
		end
	elseif (opt == "old") then
		sTmp = sTmp.."All Old Polls:\r\n\r\n"
		for i=1, table.getn(oldpoll) do 
			if (oldpoll[i] ~= "free") then
				sTmp = sTmp..i..". "..oldpoll[i].."\r\n"
				accept = 1
			end
		end
		if (accept == 0) then
			sTmp = "There aren't any Old Poll."
		end
	end
	user:SendPM(Bot, sTmp)			
end

--## Makes a Vote in a Poll ##--
function VotePoll(user, number, opt)
	local sTmp = ""
	local accept = 0
	local voted = 0
	number = tonumber(number)
	Refresh()
	if (poll[number] == nil or poll[number] == "free" or make[number] ~= "closed") then
		sTmp = sTmp.."The Poll number "..number.." doesn't existes."
	else
		local f = io.open(number..".vot","r")
		if f then
			for line in io.lines(number..".vot") do
				local s,e,usr = string.find(line, "(%S+)")
				if (usr ~= nil and string.lower(usr) == string.lower(user.sName)) then
					voted = 1
				end
			end
			f:close()
		end
		if (voted == 1) then
			sTmp = "You have already made a vote to this Poll."
		else
			local f = io.open(number..".npoll","r")
			if f then
				for line in io.lines(number..".npoll") do
					local s,e,nopt,vp,nvote = string.find(line, "(%d+)%.%s+(.*)%s+%S+Voted:%s+(%d+)")
					if (nopt ~= nil and tonumber(nopt) == tonumber(opt)) then
						nvote = tonumber(nvote) + 1
						accept = 1
						sTmp = sTmp..nopt..". "..vp.." (Voted: "..nvote..")\r\n"
					else
						sTmp = sTmp..line.."\r\n"
					end
				end
				f:close()
			end
			local g = io.open(number..".npoll","w+")
			g:write(sTmp)
			g:flush() g:close()
			if (accept == 0) then
				sTmp = "The opt number "..opt.." doesn´t exists in the Poll number "..number.."."
			else
				sTmp = "Your Vote as been sucessfuly register. Thank you."
				local sWrt = ""
				local f = io.open(number..".vot","r")
				if f then
					while 1 do
						local line = f:read()
						if (line == nil) then
							local usr = string.lower(user.sName)
							sWrt = sWrt..usr
							break
						else
							sWrt = sWrt..line.."\r\n"
						end
					end
					f:close()
				end
				local g = io.open(number..".vot","w+")
				g:write(sWrt)
				g:flush() g:close()
			end
		end
	end
	user:SendPM(Bot, sTmp)
end

--## Delete Olp Poll ##--
function DelOldPoll(user, number)
	local sTmp = ""
	number = tonumber(number)
	Refresh()	
	if (oldpoll[number] == nil or oldpoll[number] == "free") then
		sTmp = "The Old Poll number "..number.." doesn't exists."
	else
		oldpoll[number] = "free"
		os.remove(number..".opoll")
		sTmp = "The Poll has been deleted for ever."
	end
	user:SendPM(Bot, sTmp)
end

--## Puts a Vote-Poll to be Show in Main by a Timer ##--
function TimerVote(user, number, time)
	local sTmp = ""
	number = tonumber(number)
	Refresh()
	if (poll[number] == nil or poll[number] == "free" or make[number] ~= "closed") then
		sTmp = "The Poll number "..number.." doesn't existes."
	else
		time = tonumber(time)
		timepoll[number] = time*min
		clockpoll[number] = os.clock() + time*min
		sTmp = "The Poll number "..number.." going to be showed every "..time.." minutes."
		changed = 1
	end
	user:SendPM(Bot, sTmp)
end

--## Stops the Timer of a Vote-Poll ##--
function StopTimerVote(user, number)
	local sTmp = ""
	number = tonumber(number)
	Refresh()
	if (poll[number] == nil or poll[number] == "free" or make[number] ~= "closed") then
		sTmp = "The Poll number "..number.." doesn't existes."
	else
		timepoll[number] = nil
		clockpoll[number] = nil
		sTmp = "The Poll number "..number.." has been stoped."
		changed = 1
	end
	user:SendPM(Bot, sTmp)
end

--## Check For Save Table ##--
function Refresh()
	if (poll[1] == nil and loadfile(pollsv)) then
		dofile(pollsv)
	end
	if (make[1] == nil and loadfile(makesv)) then
		dofile(makesv)
	end
	if (oldpoll[1] == nil and loadfile(oldpollsv)) then
		dofile(oldpollsv)
	end
	if (changed == 0 and loadfile(timepollsv)) then
		dofile(timepollsv)
	end
	if (changed == 0 and loadfile(clockpollsv)) then
		dofile(clockpollsv)
		changed = 1
	end
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
