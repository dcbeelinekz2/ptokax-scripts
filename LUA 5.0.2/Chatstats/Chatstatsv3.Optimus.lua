-- ChatStats v3 Made By Optimus
-- Based on Tezlo chats
-- Added Send Commands By TiMeTrAVelleR
-- Madman fixed some in commands
-- Converted to lua5 by Madman with very little help by Jelf
-- with some help by ?
-- fixed stats saving on exit by jiten
---- Modded by Madman
-- Added so it's creates ChatStatsFile, if it's missing
-- Fixed so it dont counts commands
-- Added a IgnoreTable, users in that wont be counted
---- Touched by Herodes
-- addded : Averaging statistics for words per posts and chars per posts.
-- changed: ChatArrival parsing
-- changed: display of mychatstat
---
-- fixed: sorting problem.
-- added: max name showing.
-- some small optimisations.

sBot = "Chatstats"		-- Name of Bot
SendComm = 1 			-- Send UserCommands 1 = On  0 = Off
pMenu = "-=( ChatStats )=-" 	-- Name of Menu
ChatStatsTo = "user" -- Send TopChatters to? user or all
iHowManyToShow = 25
Chatstats = {}

Sortstats = 2	-- 1:words / 2:posts / 3:happy smilies / 4:sad smilies

ChatStatsFile = "chatstats.tbl"

IgnoreTable = {
-- 0=dont ignore/1=ignore
	["Madman"] = 0,
	["-=FakeKiller=-"] = 1,
}

EnableChatStats = {
	[0] = 1, -- Master
	[1] = 1, -- Operators
	[2] = 1, -- Vips
	[3] = 1, -- Regs
	[4] = 1, -- Moderators
	[5] = 1, -- NetFounders
	[-1] = 1, -- Users (UnRegged)
}

AllowedProfiles = {
	[0] = 1,   -- Masters
	[1] = 1,   -- Operators
	[2] = 0,   -- VIPs
	[3] = 0,   -- Regs
	[4] = 0,   -- Moderator
	[5] = 0,   -- NetFounder
	[-1] = 0,  -- Unregged
}

function Main()
	frmHub:RegBot(sBot)
	local file = io.open(ChatStatsFile, "r")
	if file then
		file:close()
	else
		local file = io.open(ChatStatsFile, "w+")
		file:write()
		file:close()
	end
	dofile(ChatStatsFile)
end

function NewUserConnected(user)
	if ( (SendComm == 1) and (EnableChatStats[user.iProfile] == 1) ) then
		if (Chatstats[user.sName]) then
			user:SendData(sBot, "---===[ Your Chat Stats:  You Made "..Chatstats[user.sName]["post"].." Posts In Main Used "..Chatstats[user.sName]["chars"].."  Characters, And "..Chatstats[user.sName]["words"].." Words ]===---")
		end
		if (user.bUserCommand) then
			user:SendData("$UserCommand 1 3 "..pMenu.."\\TopChatters$<%[mynick]> !topchatters&#124;|")
			user:SendData("$UserCommand 1 3 "..pMenu.."\\My Chat Stat$<%[mynick]> !mychatstat&#124;|")
			if (AllowedProfiles[user.iProfile] == 1) then
				user:SendData("$UserCommand 1 3 "..pMenu.."\\Del Chatter$<%[mynick]> !delchatter %[line:Nick]&#124;|")
				user:SendData("$UserCommand 1 3 "..pMenu.."\\Clear Chat Stats$<%[mynick]> !clearchatstats&#124;|")
			end
		end
	end
end

OpConnected = NewUserConnected

function OnExit()
	if next(Chatstats) then
		SaveToFile(ChatStatsFile, Chatstats, "Chatstats")
	end
end

function ChatArrival(user, data)

	local data = string.sub( data , 1, -2 )
	local s,e, cmd = string.find ( data, "%b<>%s+[%!%?%+%#](%S+)" )
	if cmd then
		local tCmds = {

		["mychatstat"] = function (user, data)
			if Chatstats[user.sName] then
				user:SendData(sBot, StatsToString( Chatstats[user.sName], user.sName ))
			else
				user:SendData(sBot, "*** No chat statics found!")
			end
			return 1
		end,

		["topchatters"] = function ( user, data )
			if AllowedProfiles[user.iProfile] == 1 then
				local tCopy={}
				if Chatstats then
					for i,v in Chatstats do
						table.insert( tCopy, { i, v.post, v.chars, v.words, v.smileys} )
					end
					local t = { [1] = "words", [2] = "posts", [3] = "smileys.happy", [4] = "smileys.sad" }; t = t[Sortstats];
					table.sort( tCopy, function(a, b) return (a[t] > b[t]) end)
					local m = "Current Top Chatters:\r\n\r\n"
					m = m.."\t ------------------------------------------------------------------------------------------------------------\r\n"
					m = m.."\t Nr.\tPosts:\tChars:\tWords:\tHappy:\tSad:\tName:\r\n"
					m = m.."\t ------------------------------------------------------------------------------------------------------------\r\n"
					for i = 1, iHowManyToShow do
						if tCopy[i] then
	--											Nr:			Posts:				Chars:				Words:				Name:
							m = m.."\t "..i..".\t "..tCopy[i][2].."\t "..tCopy[i][3].."\t "..tCopy[i][4].."\t "..tCopy[i][5].happy.."\t "..tCopy[i][5].sad.."\t"..tCopy[i][1].."\r\n"
						end
					end
					if ChatStatsTo == "user" then
						user:SendData( sBot, m )
					elseif ChatStatsTo == "all" then
						SendToAll( sBot, m )
					end
					tCopy = nil
				end
			end
			return 1
		end,

		["delchatter"] = function (user, data)
			if AllowedProfiles[user.iProfile] == 1 then
				local s,e,cmd,name = string.find( data, "%b<>%s+(%S+)%s+(%S+)" )
				if not name then user:SendData(sBot, "*** Usage: !delchatter <name>"); return 1; end;
				if not Chatstats[name] then user:SendData(sBot, "*** Chatstats from user "..name.." not found!"); return 1; end;

				Chatstats[name] = nil
				user:SendData(sBot, "Chatstats from user "..name.." are now removed!")
				SaveToFile(ChatStatsFile, Chatstats, "Chatstats")
			end
			return 1
		end,

		["clearchatstats"] = function (user, data)
			if AllowedProfiles[user.iProfile] == 1 then
				Chatstats = {}
				SaveToFile(ChatStatsFile, {}, "Chatstats")
				user:SendData(sBot, "Chatstats are cleared by "..user.sName)
			end
			return 1
		end,

		}
		if tCmds[cmd] then return tCmds[cmd](user, data); end;
	end

	if EnableChatStats[user.iProfile] == 1 and not IgnoreTable[user.sName] then

		local s,e,str = string.find(data, "^%b<> (.*)%|$")
		if str then
			local function cntargs(str, rule) local s,n = string.gsub(str, rule, "");return n;end;
			local u = Chatstats[user.sName] or {["post"]=0, ["chars"]=0, ["words"]=0, ["time"]=os.date("%x"), ["smileys"] = { ["happy"] = 0, ["sad"] = 0,}, }
			u.post = u.post + 1
			u.chars = u.chars + string.len(str)
			t.words = u.words + cntargs( str, "(%a+)")
			u.smileys.happy = u.smileys.happy + cntargs( str, "%s-(%:%-?%))")
			u.smileys.sad = u.smileys.sad + cntargs( str, "%s-(%:%-?%()")
			u.time = os.date("%x")

			Chatstats[user.sName] = u
			SaveToFile( ChatStatsFile, Chatstats, "Chatstats" )
		end
	end
end


function StatsToString( tTable, nick )
	local function doRatio( val, max ) if (max==0) then max=1;end;return string.format("%0.3f",(val/max));end;
	local function doPerc ( val, max ) if (max==0) then max=1;end;return string.format("%0.2f",((val*100)/max));end;

	local sMsg = "\r\n\t\t\tHere are the stats for "..nick
	sMsg = sMsg.."\r\n\t--------------------------------------------------------------------------------------------------------------------------------------------------"
	sMsg = sMsg.."\r\n\tPosts in MainChat :\t\t "..tTable.post
	sMsg = sMsg.."\r\n\tWords in Posts :\t\t "..tTable.words.." [ "..doRatio( tTable.words, tTable.post ).." words per post ]"
	sMsg = sMsg.."\r\n\tCharasters in Posts :\t "..tTable.chars.." [ "..doRatio( tTable.chars, tTable.post ).." chars per post ]"
	sMsg = sMsg.."\r\n\t--------------------------------------------------------------------------------------------------------------------------------------------------"
	sMsg = sMsg.."\r\n\t\tYou were happy in "..doPerc(tTable.smileys.happy, tTable.post).."% of your posts, and sad in "..doPerc(tTable.smileys.sad, tTable.post).."% of them."
	return sMsg
end
----------------------------------------------
-- load & save Tables
----------------------------------------------
function Serialize(tTable, sTableName, sTab)
	assert(tTable, "tTable equals nil");
	assert(sTableName, "sTableName equals nil");
	assert(type(tTable) == "table", "tTable must be a table!");
	assert(type(sTableName) == "string", "sTableName must be a string!");
	sTab = sTab or "";
	sTmp = ""
	sTmp = sTmp..sTab..sTableName.." = {\n"
	for key, value in tTable do
		local sKey = (type(key) == "string") and string.format("[%q]", string.gsub(key, "\"", "\"") ) or string.format("[%d]",key);
		if(type(value) == "table") then
			sTmp = sTmp..Serialize(value, sKey, sTab.."\t");
		else
			local sValue = (type(value) == "string") and string.format("%q",string.gsub(value, "\"", "\"") ) or tostring(value);
			sTmp = sTmp..sTab.."\t"..sKey.." = "..sValue
		end
		sTmp = sTmp..",\n"
	end
	sTmp = sTmp..sTab.."}"
	return sTmp
end
-----------------------------------------------------------
function SaveToFile(file, table, tablename)
	local handle = io.open(file,"w+")
	handle:write(Serialize(table, tablename))
	handle:close()
end
-----------------------------------------------------------
function LoadFromFile(file)
	local handle = io.open(file,"r")
	if handle then
		loadstring(handle:read("*all"))
		handle:close()
	end
end