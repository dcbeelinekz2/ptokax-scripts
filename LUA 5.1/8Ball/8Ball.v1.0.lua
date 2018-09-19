--[[

	[8-Ball] 1.0 - LUA 5.0/5.1 version by jiten
	
	Based: on Bonki's [8-Ball]
	
	Changelog:

	- Converted to lua 5 by Madman
	- Some small changes to...
	- Converted to lua 5.1 by TT

	- Rewritten: Code structure;
	- Added: add/del/show support - Requested by TT

]]--

tBall = {
	sName = "ßø†jê",
	sAskPhrase = "botje",
	iInterval = 8*1000,
	sFile = "tBall.tbl",
	sAnswers = {
		"No.",
		"Yes.",
		"NOOOOOOOOOOOOOOOOOOO!",
		"Definitely.",
		"All signs point to yes.",
		"Yeah :)",
		"HELL NO!",
		"No way my friend!",
		"Never ever.",
		"As certain as death!",
		"No...now go and blame bonki!",
		"Don't count on it.",
		"Without a doubt!",
		"My reply is no.",
		"You may rely on it.",
		"I can't predict now, need some food first!",
		"My sources say no...",
		"Yes, most likely.",
		"Concentrate and ask again.",
		"This is very doubtful.",
		"Better not tell you know ;-)",
		"I calculated the probability to 50 percent.",
		"I know but I won't tell you :-)",
		"Pay me and I'm gonna tell you.",
		"Ask your mummy, she knows better !",
		"Are you kidding?",
		"What? Sorry I haven't paid attention, ask again...",
		"Huh?",
		"Blah blahhh blahh...",
		"You must be kidding!",
		"Are you serious?",
		"Haha, I like you...funny guy, you are :-)",
		"Geeeeee...what a stupid question.",
		"Stop doing drugs :-P",
		"How could you think of such things?",
		"How should I know?",
		"And they say there are no stupid questions...",
		"Get a life and leave me alone!",
		"Get some money first.",
		"Ask TiMeTrAVelleR, he'll know for sure :-)", -- honor to whom honor is due! :-)
		"Yes...I mean...No.",
	}
}

Main = function()
	math.randomseed(os.clock()); if loadfile(tBall.sFile) then dofile(tBall.sFile) end; SetTimer(tBall.iInterval);
end

ChatArrival = function(user,data)
	local s,e,to = string.find(data,"^$To:%s(%S+)%s+From:")
	local s,e,cmd = string.find(data,"%b<>%s+(%S+).*|$") 
	if cmd then
		if tCommands[string.lower(cmd)] then
			cmd = string.lower(cmd)
			if to == tBall.sName then user.SendMessage = user.SendPM else user.SendMessage = user.SendData end
			if tCommands[cmd].tLevels[user.iProfile] then
				return tCommands[cmd].tFunc(user,data), 1
			end
		end
	end
end

ToArrival = ChatArrival

NewUserConnected = function(user)
	if user.bUserCommand then
		for i,v in pairs(tCommands) do
			if v.tLevels[user.iProfile] then
				local sRC = string.gsub(v.tRC,"{}",i)
				user:SendData("$UserCommand 1 3 8Ball\\"..sRC.."&#124;")
			end
		end
	end
end

OpConnected = NewUserConnected

tCommands = {
	["!8add"] = {
		tFunc = function(user,data)
			local s,e,args = string.find(data,"^%b<>%s+%S+%s+(.+)|$")
			if args then
				table.insert(tBall.sAnswers,args); SaveToFile(tBall.sFile,tBall.sAnswers,"tBall.sAnswers")
				user:SendMessage(tBall.sName,"*** "..args.." has been successfully added to 8Ball's Answer list!")
			else
				user:SendMessage(tBall.sName,"*** Syntax Error: Type !8add <answer>")
			end
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\t\tAdds an 8Ball answer",
		tRC = "Add an 8Ball answer$<%[mynick]> !{} %[line:Answer]"
	},
	["!8del"] = {
		tFunc = function(user,data)
			local s,e,ID = string.find(data,"^%b<>%s+%S+%s+(%d+)|$")
			if ID then
				if tBall.sAnswers[tonumber(ID)] then
					user:SendMessage(tBall.sName,"*** "..tBall.sAnswers[tonumber(ID)].." has been successfully "..
					"deleted from 8Ball's Answer list")
					table.remove(tBall.sAnswers,ID); SaveToFile(tBall.sFile,tBall.sAnswers,"tBall.sAnswers")
				else
					user:SendMessage(tBall.sName,"*** Error: There is no ID "..ID.." in 8Ball's Answer list!")
				end
			else
				user:SendMessage(tBall.sName,"*** Syntax Error: Type !8del <ID>")
			end
		end,
		tLevels = {
			[0] = 1, [5] = 1,
		},
		sDesc = "\t\tDelete a specific 8Ball answer",
		tRC = "Delete a 8Ball answer$<%[mynick]> !{} %[line:ID]"
	},
	["!8show"] = {
		tFunc = function(user)
			if next(tBall.sAnswers) then
				local sMsg = "\r\n\t"..string.rep("=",105).."\r\n\tID.\tAnswer:\r\n\t"..
				string.rep("-",210).."\r\n"
				for i in ipairs(tBall.sAnswers) do
					sMsg = sMsg.."\t"..i..".\t"..tBall.sAnswers[i].."\r\n"
				end
				user:SendMessage(tBall.sName,sMsg)
			else
				user:SendMessage(tBall.sName,"*** Error: There are no saved 8Ball answers!")
			end
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\t\tShows all 8Ball answers",
		tRC = "Show all 8Ball answers$<%[mynick]> !{}"
	},
	["botje"] = {
		tFunc = function(user, data)
		       local _,_,args = string.find(data,"^%b<>%s+%S+%s*([^%|]*)%|$"); SendToAll(data);
		       -- quick-check whether it COULD be a question somehow
		       if string.find(string.sub(args,-3),"%?") and string.find(args,"%s+") then
				SendToAll(tBall.sName,tBall.sAnswers[math.random(table.maxn(tBall.sAnswers))]);
		       else
				SendToAll(tBall.sName,"Yes?");
		       end
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\t\tAsk a question to "..tBall.sName,
		tRC = "Ask a question$<%[mynick]> !{}"
	},
	["!8help"] = {
		tFunc = function(user)
			local sMsg = "\r\n\t\t"..string.rep("=",75).."\r\n"..string.rep("\t",6).."8Ball by Bonki"..
			"\r\n\t\t"..string.rep("-",150).."\r\n\t\tAvailable Commands:".."\r\n\r\n"
			for i,v in pairs(tCommands) do
				if v.tLevels[user.iProfile] then
					sMsg = sMsg.."\t\t"..i.."\t\t"..v.sDesc.."\r\n"
				end
			end
			user:SendMessage(tBall.sName, sMsg.."\t\t"..string.rep("-",150));
		end,
		tLevels = {
			[-1] = 1, [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1,
		},
		sDesc = "\t\tDisplays this help message",
		tRC = "Show command list$<%[mynick]> !{}"
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