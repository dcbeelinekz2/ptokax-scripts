--Made by nErBoS 
--Converted to Lua 5 by jiten

Bot = "Vote-Bot" 

vt = {} 
nr = {} 

votetext = "votepoll.txt" --Will be created in the script folder 
oldpolls = "oldpolls.txt" --Will be created in the script folder 

function Main() 
	frmHub:RegBot(Bot) 
end 

function NewUserConnected(user, data) 
	if (vt[user.sName] == nil) then 
		vt[user.sName] = 0 
	end 
	if (nr[user.sName] == nil) then 
		nr[user.sName] = 0 
	end 
end 

function ChatArrival(user, data) 
	data=string.sub(data,1,string.len(data)-1) 
	s,e,cmd = string.find(data,"%b<>%s+(%S+)") 
	if (cmd=="+votehelp") then 
		local msg = "" 
		if (user.iProfile == 0) then 
			msg = msg.."Commands to the Vote-Poll:\r\n" 
			msg = msg.."\r\n" 
			msg = msg.."+createvote <nr> <q>\tCreates a poll (nr = number to give to poll) (q = Poll question)\r\n" 
			msg = msg.."+stopvote <nr>\t\tWill end the vote-poll\r\n" 
			msg = msg.."+showvote <nr> <old/new>\tShow the vote results of the poll (old = old polls) or (new = polls that haven't been closed)\r\n" 
			msg = msg.."+svmain <nr> <old/new>\tShow the vote results in the mainchat (old = old polls) or (new = polls that haven't been closed)\r\n" 
			msg = msg.."+votelist\t\t\tShow all finished polls\r\n" 
			msg = msg.."+votefor\t\t\tShow the polls that you can vote\r\n" 
			msg = msg.."+vote <nr> <y/n>\t\tTo vote on the poll (y = yes) (n = no) (nr = number of the poll)\r\n" 
			msg = msg.."+delvote <nr>\t\tTo delete old polls (nr = number of the poll)\r\n" 
			msg = msg.."\r\n" 
			user:SendPM(Bot, msg) 
		else 
			msg = msg.."Commands to the Vote-Poll:\r\n" 
			msg = msg.."\r\n" 
			msg = msg.."+votefor\t\t\tShow the polls that you can vote\r\n" 
			msg = msg.."+vote <nr> <y/n>\t\tTo vote on the poll (y = yes) (n = no) (nr = number of the poll)\r\n" 
			msg = msg.."\r\n" 
			user:SendPM(Bot, msg) 
		end 
		return 1 
	elseif (cmd=="+createvote") then 
		if (user.iProfile == 0) then 
			local s,e,number,question = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(.*)") 
			if (tonumber(number) == nil) then 
				user:SendPM(Bot, "Syntax error, +createvote <nr> <q>, nr must be a number.") 
			else 
				number = tonumber(number) 
				if (question == nil or question == "") then 
					user:SendPM(Bot, "Syntax error, +createvote <nr> <q>, you must write a question to the poll.") 
				else 
					if (CreatePoll(user, number, question) == 1) then 
						user:SendPM(Bot, "The Vote-Poll has been created.") 
					else 
						user:SendPM(Bot, "There is a already a Vote-Poll with the number "..number..".") 
					end 
				end 
			end 
		else 
			user:SendPM(Bot, "You don´t have permision to this command.") 
		end 
		return 1 
	elseif (cmd=="+stopvote") then 
		if (user.iProfile == 0) then 
			local s,e,number = string.find(data,"%b<>%s+%S+%s+(.*)") 
			if (tonumber(number) == nil or number == "") then 
				user:SendPM(Bot, "Syntax error, +stopvote <nr>, nr must be a number.") 
			else 
				number = tonumber(number) 
				if (OldPoll(user, number) == 1) then 
					user:SendPM(Bot, "The Vote-Poll has been closed an saved on the Old Polls.") 
				else 
					user:SendPM(Bot, "There is no Vote-Poll with the number "..number..".") 
				end 
			end 
		else 
			user:SendPM(Bot, "You don´t have permision to this command.") 
		end 
		return 1 
	elseif (cmd=="+showvote") then 
		if (user.iProfile == 0) then 
			local s,e,number, opt = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)") 
			if (tonumber(number) == nil) then 
				user:SendPM(Bot, "Syntax error, +showvote <nr> <old/new>, nr must be a number.") 
			else 
				number = tonumber(number) 
				if (opt == "old") then 
					if (CheckPoll(user, number, oldpolls) == "") then 
						user:SendPM(Bot, "There is no Vote-Poll with the number "..number..".") 
					else 
						user:SendPM(Bot, CheckPoll(user, number, oldpolls)) 
					end 
				elseif(opt == "new") then 
					if (CheckPoll(user, number, votetext) == "") then 
						user:SendPM(Bot, "There is no Vote-Poll with the number "..number..".") 
					else 
						user:SendPM(Bot, CheckPoll(user, number, votetext)) 
					end 
				else 
					user:SendPM(Bot, "Syntax error, +showvote <nr> <old/new>, must be (old = old polls) or (new = polls that haven't been closed)") 
				end 
			end 
		else 
			user:SendPM(Bot, "You don´t have permision to this command.") 
		end 
		return 1 
	elseif (cmd=="+svmain") then 
		if (user.iProfile == 0) then 
			local s,e,number, opt = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)") 
			if (tonumber(number) == nil) then 
				user:SendPM(Bot, "Syntax error, +svmain <nr> <old/new>, nr must be a number.") 
			else 
				number = tonumber(number) 
				if (opt == "old") then 
					if (CheckPoll(user, number, oldpolls) == "") then 
						user:SendPM(Bot, "There is no Vote-Poll with the number "..number..".") 
					else 
						SendToAll(Bot, CheckPoll(user, number, oldpolls)) 
					end 
				elseif(opt == "new") then 
					if (CheckPoll(user, number, votetext) == "") then 
						user:SendPM(Bot, "There is no Vote-Poll with the number "..number..".") 
					else 
						SendToAll(Bot, CheckPoll(user, number, votetext)) 
					end 
				else 
					user:SendPM(Bot, "Syntax error, +svmain <nr> <old/new>, must be (old = old polls) or (new = polls that haven't been closed)") 
				end 
			end 
		else 
			user:SendPM(Bot, "You don´t have permision to this command.") 
		end 
		return 1 
	elseif (cmd=="+votelist") then 
		if (user.iProfile == 0) then 
			local l = io.open(oldpolls, "r")
			if (ReadPoll(user, oldpolls) == "") then 
				user:SendPM(Bot, "There is no closed Vote-Polls") 
			else 
				user:SendPM(Bot, ReadPoll(user, oldpolls)) 
			end 
		else 
			user:SendPM(Bot, "You don´t have permision to this command.") 
		end 
		return 1 
	elseif (cmd=="+votefor") then 
		if (ReadPoll(user, votetext) == "") then 
			user:SendPM(Bot, "There is no Vote-Polls") 
		else 
			user:SendPM(Bot, ReadPoll(user, votetext)) 
		end 
		return 1 
	elseif (cmd=="+vote") then 
		local s,e,number,opt = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)") 
		if (tonumber(number) == nil) then 
			user:SendPM(Bot, "Syntax error, +vote <nr> <y/n>, nr must be a number.") 
		else 
			number = tonumber(number) 
			if (opt == nil or opt == "" or opt ~= "n" and opt ~= "y") then 
				user:SendPM(Bot, "Syntax error, +vote <nr> <y/n>, must type (y = yes) or (n = no).") 
		else 
					if (Vote(user, number, opt) == 1) then 
				user:SendPM(Bot, "Your Vote has been registered.") 
					vt[user.sName] = 1 
					nr[user.sName] = number 
				elseif(Vote(user, number, opt) == 2) then 
				user:SendPM(Bot, "You have already made a vote on this Vote-Poll") 
				else 
					user:SendPM(Bot, "There isn´t any Vote-Poll with the number "..number..".") 
				end 
		end 
		end 
		return 1 
	elseif (cmd=="+delvote") then 
		if (user.iProfile == 0) then 
			local s,e,number = string.find(data,"%b<>%s+%S+%s+(%S+)") 
			if (tonumber(number) == nil) then 
				user:SendPM(Bot, "Syntax error, +delvote <nr>, nr must be a number.") 
			else 
				number = tonumber(number) 
				if (DelOldPoll(user, number) == 0) then 
					user:SendPM(Bot, "Ther is no Old Polll wtih the number "..number) 
				else 
					user:SendPM(Bot, "The Old Poll has been deleted.") 
				end 
			end 
		else 
			user:SendPM(Bot, "You don´t have permision to this command.") 
		end 
		return 1 
	end 
end 

ToArrival = ChatArrival 


function CreatePoll(user, number, question) 
	local tmp = "" 
	local time = 0 
	local a = io.open(oldpolls, "r")
	if a then
		while 1 do 
			local line = a:read() 
			if (line == nil) then 
				break 
			else 
				local s,e,num = string.find(line,"Nr:%s+(%S+)%s+") 
				if (tonumber(num) ~= nil and tonumber(num) == number) then 
					time = 2 
				else 
				end 
			end 
		end 
		a:close()
	else 
		dofile(oldpolls) 
--		return a.." doesnt exist"
	end

	local b = io.open(votetext,"r")
	if b then
		while 1 do 
			local line = b:read() 
			if (line == nil) then 
				if (time == 2) then 
					break 
				else 
					tmp = tmp.."Nr: "..number.." Question: "..question.." Yes: 0 No: 0 Active: Yes\r\n" 
					time = 1 
					break 
				end 
			else 
				local s,e,num = string.find(line,"Nr:%s+(%S+)%s+") 
				if (tonumber(num) ~= nil and tonumber(num) == number) then 
					tmp = tmp..line.."\r\n" 
					time = 2 
				else 
					tmp = tmp..line.."\r\n" 
				end 
			end 
		end 
		b:close()
		local l = io.open(votetext,"w+")
		l:write(tmp)
		l:flush()
		l:close()
		return time 
	else 
		dofile(votetext) 
--		return b.." doesnt exist"
	end
	return time 
end 

function OldPoll(user, number) 
	local tmp = "" 
	local tmp2 = "" 
	local time = 0 
	local c = io.open(votetext,"r")
	if c then
		while 1 do 
			local line = c:read() 
			if (line == nil) then 
				break 
			else 
				local s,e, num, question, ny, nn = string.find(line,"Nr:%s+(%S+)%s+(.*)Yes:%s+(%S+)%s+No:%s+(%S+)%s+Active:") 
				if (tonumber(num) ~= nil and tonumber(num) == number) then 
					tmp2 = tmp2.."Nr: "..number.." "..question.."Yes: "..ny.." No: "..nn.." Active: No\r\n" 
					time = 1 
				else 
					tmp = tmp..line.."\r\n" 
				end 
			end 
		end 
		c:close()
		local d = io.open(votetext,"w+")
		d:write(tmp)
		d:flush()
		d:close()
		if (time == 0) then 
		else 
			local e = io.open(oldpolls, "a+") -- "a+"
			e:write(tmp2) 
			e:close()
		end 
		return time 
	else 
		dofile(votetext) 
--		return c.." doesnt exist"
	end
end 

function CheckPoll(user, number, file) 
	local tmp = "" 
	local f = io.open(file,"r")
	if f then
		while 1 do 
			local line = f:read() 
			if (line == nil) then 
				break 
			else 
				local s,e, num, question, ny, nn = string.find(line,"Nr:%s+(%S+)%s+(.*)Yes:%s+(%S+)%s+No:%s+(%S+)%s+Active:") 
				if (tonumber(num) ~= nil and tonumber(num) == number) then 
					tmp = tmp.."\r\n-------------------- Vote Poll --------------------\r\n" 
					tmp = tmp.."Results of Vote-Poll Nr: "..num.."\r\n" 
					tmp = tmp.."Vote "..question.."\r\n" 
					tmp = tmp.."------------------------------\r\n" 
					tmp = tmp.."Yes: "..ny.."\r\n" 
					tmp = tmp.."No: "..nn.."\r\n" 
					tmp = tmp.."------------------------------\r\n" 
					if (tonumber(ny) > tonumber(nn)) then 
						tmp = tmp.."Yes is Winnig." 
					elseif (tonumber(ny) < tonumber(nn)) then 
						tmp = tmp.."No is Winnig." 
					elseif (tonumber(ny) == tonumber(nn)) then 
					tmp = tmp.."Yes and No is equal." 
					end 
					break 
				else 
				end 
			end 
		end
		f:close()
		return tmp 
	else 
		dofile(file) 
--		return f.." doesnt exist"
	end
end 

function ReadPoll(user, file) 
	local tmp = "" 
	local g = io.open(file,"r")
	if g then
		while 1 do 
			local line = g:read() 
			if (line == nil or line == "") then 
				break 
			else 
				local s,e, num, question, ny, nn = string.find(line,"Nr:%s+(%S+)%s+(.*)Yes:%s+(%S+)%s+No:%s+(%S+)%s+Active:") 
				if (num == nil) then 
				else 
					tmp = tmp.."\r\n-------------------- Vote Poll --------------------\r\n" 
					tmp = tmp.."Results of Vote-Poll Nr: "..num.."\r\n" 
					tmp = tmp.."Vote "..question.."\r\n" 
					tmp = tmp.."------------------------------\r\n" 
					tmp = tmp.."Yes: "..ny.."\r\n" 
					tmp = tmp.."No: "..nn.."\r\n" 
					tmp = tmp.."------------------------------\r\n" 
					if (file == oldpolls) then 
						tmp = tmp.."Closed Vote-Poll\r\n" 
					elseif (file == votetext) then 
						tmp = tmp.."Active Vote-Poll\r\n" 
					end 
				end 
			end 
		end 
		g:close()
		return tmp 
	else 
		dofile(file) 
--		return g.." doesnt exist"
	end
end 

function Vote(user, number, opt) 
	local tmp = "" 
	local time = 0 
	if (vt[user.sName] == 1 and nr[user.sName] == number) then 
		time = 2 
	else 

		local h = io.open(votetext,"r")
		if h then
			while 1 do 
				local line = h:read() 
				if (line == nil) then 
					break 
				else 
					local s,e, num, question, ny, nn = string.find(line,"Nr:%s+(%S+)%s+(.*)Yes:%s+(%S+)%s+No:%s+(%S+)%s+Active:") 
					if (tonumber(num) ~= nil and tonumber(num) == number) then 
						if (opt == "y") then 
							ny = tonumber(ny) + 1 
						elseif (opt == "n") then 
							nn = tonumber(nn) + 1 
						end 
						tmp = tmp.."Nr: "..number.." "..question.."Yes: "..ny.." No: "..nn.." Active: Yes\r\n" 
						time = 1 
					else 
						tmp = tmp..line.."\r\n" 
					end 
				end 
			end 
			h:close()
		else 
			dofile(votetext) 
--		return h.." doesnt exist"
		end
		local i = io.open(votetext,"w+")
		i:write(tmp)
		i:flush()
		i:close()
	end 
	return time 
end 

function DelOldPoll(user, number) 
	local tmp = "" 
	local time = 0 

	local j = io.open(oldpolls,"r")
	if j then
		while 1 do 
			local line = j:read() 
			if (line == nil) then 
				break 
			else 
				local s,e, num, question, ny, nn = string.find(line,"Nr:%s+(%S+)%s+(.*)Yes:%s+(%S+)%s+No:%s+(%S+)%s+Active:") 
				if (tonumber(num) ~= nil and tonumber(num) == number) then 
					time = 1 
				else 
					tmp = tmp..line.."\r\n" 
				end 
			end 
		end 
		j:close()
	else 
		dofile(oldpolls) 
--		return j.." doesnt exist"
	end
	local k = io.open(oldpolls,"w+")
	k:write(tmp)
	k:flush()
	k:close()
	return time 
end
