--- BirthdayMan v 3.5
--- by Herodes -- Update 5/10/2004
--- Converted to Lua 5 by jiten (some ideas taken from BirthdayMan v 2.6 LUA_5.0 by TT and Jelf)
--- --- --- --- --- --- 
-- v2.5
--- When Users are connected if there is a birthday it informs
--- When a Birhtday-User connect it plays surprise and informs the Hub
-- v2.6
--- Fix from ... comment for the display age
-- v 3 
--- ability to display the Birthday nicks in the topic of the hub ... ( all of them ... the Ofline ones are in parentheses like (Herodes))
--- added agecmd to get exact age
--- added bhelpcmd 
--- added display of birthdays in the findcmd
--- added ability for pm or main cmds .. ;)
-- v3.5
--- added integration of zodiac signs in various parts of the script 
--- added celebrities birthdays with a switch to load or not the file
--- added celebcmd ,... works like findcmd but for celebrities
--- added switch for displaying birthday in topic
--- --- --- --- --- ---
----- do not edit these four lines
sec = 1000
minutes = 1000*60
hours = 1000*(60^2)
TxtSend = nil
----- Edit at will 
bBot = "Surprise"
timecheck = 12*hours	--- how much time before checking for birthdays ...
TopicShow = 1 			--- to display the birthday nicks in the Hub's Topic ... ( 1/0 : enabled / disabled )

tProfiles = {  ---- profile rights to commands, 0 cant use the bot at all, 1 can use listcmd/addcmd/findcmd/agecmd/agecmd/bhelpcmd , 2 can also use delcmd and addbircmd...	
			["-1"] = 1, 	--- Unregs
			["0"] = 2,  	--- Masters
			["1"] = 2,  	--- Operators
			["2"] = 1, 	--- VIPs
			["3"] = 1, 	--- Regs
			["4"] = 1, 	--- Moderator
			["5"] = 2,	--- NetFounder
}

--- ( carry on typing your profiles in the right format : ["profile_number"] = value (0/1/2) 
addcmd = "!mybirthday"	--- !mybirthday dd/mm/yyyy      dd = day ,   mm = month ,    yyyy = year .... Sets your birthday!
delcmd = "!delbirthday"	--- !delbirthday <nick>     		<nick> is needed ... deletes <nick>'s birthday from the list
listcmd = "!birthdays"		--- !birthdays 				Lists the birthdays stored
addbircmd = "!addbirth"	--- !addbirth <nick> <date>	same as addcmd
findcmd = "!bornon" 		--- !bornon					Shows a nice list of the ppl you share dates with ;)
celebcmd = "!celeb"		--- !celeb					Shows a nice list of celebrities that share the same dates with your birthday :) (only if celebrities are loaded!! )
agecmd = "!myage" 		--- !myage 					Shows you your age :)
bhelpcmd = "!bhelp" 	--- !bhelp 					Shows the cmds for the bot and some short explaination
birthdayfile = "cake.txt"	--- The file that will be displayed on Birthday
oldestyear = 1900		--- <Jesus_Christ> !mybirthday 0/0/0000  situations are avoided ( lol )
allowedage = 6			--- <NewBorn> !mybirthday <today's date> situations are avoided (in years)
titshow = 1				--- Set this to 0 if you dont want to display the birthday ppl in the Hubs Topic
birthlog = "birthdays.tbl"	--- The file where we'll be storing the birthdays ...  << has to be in your scripts folder 
loadcelebs = 1			--- Set this to 0 if you dont want to load the celebrities file ( costs about 2Mbs of mem )
celbirhtfile = "CelebBirths.tbl"

	local f,e = io.open( birthlog, "a+" ) --//Error handle.. makes sure save file and dir exist...
	f,e = io.open( birthlog, "a+" )
	if f then
		f:write("" ) 
		f:close() --// file and path did not exist.. now they do.
	else
		birthlog = "birthdays.tbl"--//this is only if the path provided is invalid to winblows. defaults to a file in the scripts dir.
	end

require(birthlog)

--- // --- Script-Starts
tBirthdays = {}
tCelebs = {}
tCalendar = {
	[1] = { 31, "January", },
	[2] = { 28, "February", },
	[3] = { 31, "March", }, 
	[4] = { 30, "April", },
	[5] = { 31, "May", },
	[6] = { 30, "June", },
	[7] = { 31, "July", },
	[8] = { 31, "August", },
	[9] = { 30, "September", },
	[10] = { 31, "October", },
	[11] = { 30, "November", },
	[12] = { 31, "December", },
	}


function Main()
	dofile(birthlog) 
	if loadcelebs ~= 0 then
		dofile(celbirhtfile)
	else 
		tCelebs = nil
	end
	tCalendar[2][1] = FixFebruary(tonumber(os.date("%Y")))

	local hr = tonumber(os.date("%H"))*60*60*1000
	local mins = 0
	if tonumber(os.date("%M")) == 0 then
		mins = 1 
	else
		mins = tonumber(os.date("%M"))*60*1000
	end
	fixTime(hr+mins)
	frmHub:UnregBot(bBot)
	frmHub:RegBot(bBot)
end

function OnTimer()
	CheckBirthdays()
	TxtSend = nil
end

function NewUserConnected(user)
	for i, v in tBirthdays do
		if tBirthdays[i][2] == tonumber(os.date("%m")) and tBirthdays[i][1] == tonumber(os.date("%d")) then
			if user.sName ~= i then
				local msg = "Its "..i.."'s birhtday today .. ;D Turning "..(tonumber(os.date("%Y"))-tBirthdays[i][3] ).." today,... give a wish :)"
				if GetItemByName(i) then
					user:SendData(bBot, msg)
				else user:SendData(bBot, msg.." when he comes online")
				end
			else
				user:SendData(bBot, "Hey I know !!! YOU HAVE YOUR BIRTHDAY TODAY !!! HAPPIEST OF BIRTHDAYS !!!! ")
				SendToAll(bBot, "Guys !! "..user.sName.." is here! What do we say ?? : )")
			end
		end
	end
end

OpConnected = NewUserConnected

function CheckBirthdays()
tNow = {}
local count = 0
local yeah = nil
for i, v in tBirthdays do
	if tBirthdays[i][2] == tonumber(os.date("%m")) then
		if tBirthdays[i][1] == tonumber(os.date("%d")) then
			if GetItemByName(i) then
				local happy = GetItemByName(i)
				DoHappyBirthday(happy)
				yeah = 1
			end
			count = count + 1
			if yeah == nil then
				tNow[count] = "("..i..")"
			else 
				tNow[count] = i
			end
		end
	end
	yeah = nil
end
if titshow ~= 0 then
	local tit = ""
	local ct = 0
	for i,v in tNow do 
		if ct == 0 then
			tit = " "..v
		else
			tit = tit..", "..v
		end
		ct = ct +1
	end
	if ct > 1 then
		tit = "s "..tit
	end
	topic = frmHub:GetHubName()
	frmHub:SetHubName(topic.." - Today is the birthday of the following user"..tit)
end
end

function FixFebruary(y)
	local value = 0
	if (tonumber(y)/4) - (math.floor(tonumber(y)/4)) == 0 then
		value = 29
	else value = 28
	end
	return value
end

function fixTime(now)
	 if now < timecheck then
		now = timecheck-now
	elseif now > timecheck then
		now = now-timecheck
	else now = timecheck
	end
	SetTimer(now)
	StartTimer()
end

function ChatArrival(user, data)
	prof = user.iProfile
	local how = nil
	if prof == nil then
		prof = "-1"
	end
	if tProfiles[""..prof..""] >= 1 then
		data = string.sub(data, 1, string.len(data)-1)
		s,e,cmd,args = string.find(data, "%b<>%s+(%S+)%s*(.*)")
		if cmd == addcmd then
			CheckBirthdays()
			AddBirthDay(user, args, how)
			return 1
		elseif cmd == addbircmd and tProfiles[""..prof..""] == 2 then
			CheckBirthdays()
			AddBirthDay(user, args, how)
			return 1
		elseif cmd == delcmd and tProfiles[""..prof..""] == 2 then
			DelBirth(user, args, how)
			return 1
		elseif cmd == listcmd then
			ListBirths(user, how)
			return 1
		elseif cmd == findcmd then
			BornOn(user, tBirthdays, "people", how)
			return 1
		elseif cmd == celebcmd then
			if loadcelebs ~= 0 then
				BornOn(user, tCelebs, "celebrities", how)
			else 
				SendBack(" The celebrities file is not loaded.", user, how)
			end
			return 1
		elseif cmd == agecmd then
			ExactAge(user, how)
			return 1
		elseif cmd == bhelpcmd then
			BHelp(user, how)
			return 1
		end
	end
end

ToArrival = ChatArrival

function Zodiac(table)
tZodiacs = {
	[1] = { 21, "Capricorn", "Aquarius" },
	[2] = { 20, "Aquarius", "Pisces" },
	[3] = { 21, "Pisces",  "Aries" },
	[4] = { 21, "Aries", "Taurus" }, 
	[5] = { 22, "Taurus", "Gemini" },
	[6] = { 22, "Gemini", "Cancer" },
	[7] = { 23, "Cancer", "Leo" },
	[8] = { 22, "Leo", "Virgo" },
	[9] = { 24, "Virgo", "Libra" }, 
	[10] = { 24, "Libra", "Scorpio" },
	[11] = { 23, "Scorpio", "Sagittarius" },
	[12] = { 23, "Sagittarius", "Capricorn"},
	}
	if tZodiacs[table[2]][1] > table[1] then
		return tZodiacs[table[2]][2]
	else 
		return tZodiacs[table[2]][3]
	end
end

function BornOn(user, table, what, how)
	if tBirthdays[user.sName] then
		local lmsg = "\r\n These are the "..what.." that are born the same number-day as you\r\n"
		lmsg = lmsg..FindSame(table, tBirthdays[user.sName][1] , "day", user.sName).."\r\n"
		lmsg = lmsg.." These are the "..what.." that are born the same month as you\r\n"
		lmsg = lmsg..FindSame(table, tBirthdays[user.sName][2] , "month", user.sName).."\r\n"
		lmsg = lmsg.." These are the "..what.." that are born the same year as you\r\n"
		lmsg = lmsg..FindSame(table, tBirthdays[user.sName][3] , "year", user.sName).."\r\n"
		lmsg = lmsg.." These are the "..what.." that are born the same month and day with you \r\n"
		lmsg = lmsg..FindSame(table, tBirthdays[user.sName][1].."/"..tBirthdays[user.sName][2] , "monthday", user.sName).."\r\n"
		lmsg = lmsg.." These are the "..what.." that have the same birthday as yours\r\n"
		lmsg = lmsg..FindSame(table, tBirthdays[user.sName][1].."/"..tBirthdays[user.sName][2].." - "..tBirthdays[user.sName][3] , "all", user.sName).."\r\n"
		SendBack(lmsg, user, how) 
	else 
		SendBack("I dont have your birthday,... please use the "..addcmd.." dd/mm/yyyy command to enter your birthday", user, how)
	end
end

function FindSame(tTab, val , var, name)
local tTmp = {}
local msg = ""
	if var == "day" then
		for i, v in tTab do
			if val == v[1] and i ~= name then
				tTmp[i] = v[1].."/"..v[2].." - "..v[3]
			end
		end
	elseif var == "month" then
		for i, v in tTab do
			if val == v[2] and i ~= name then
				tTmp[i] = v[1].."/"..v[2].." - "..v[3]
			end
		end
	elseif var == "year" then
		for i, v in tTab do
			if val == v[3] and i ~= name then
				tTmp[i] = v[1].."/"..v[2].." - "..v[3]
			end
		end
	elseif var == "monthday" then
		for i, v in tTab do
			if val == v[1].."/"..v[2] and i ~= name then
				tTmp[i] = v[1].."/"..v[2].." - "..v[3]
			end
		end
	elseif var == "all" then
		for i, v in tTab do
			if val == v[1].."/"..v[2].." - "..v[3] and i ~= name then
				tTmp[i] = v[1].."/"..v[2].." - "..v[3]
			end
		end
	end 
	for i,v in tTmp do
		msg = msg.."\t - "..i.."\t("..v..")\r\n"
	end
	if msg == "" then
		msg = "\t - noone\r\n"
	end
	return msg
end

function DelBirth(user, args, how)
	if args ~= nil then
		if tBirthdays[args] then
			if GetItemByName(args) then
				GetItemByName(args):SendPM(bBot,  ">>>> "..user.sName.." has deleted your birthday from my list .. ;( <<<<")
			end
			tBirthdays[args] = nil
			SendBack("You deleted "..args.." bithday ...", user, how)
			SaveFile(birthlog, tBirthdays, "tBirthdays")
		else 
			SendBack(args.." is not in my birthday list ...", user, how) 
		end
	else 
		SendBack("You need to give me a name ...", user, how) 
	end
end

function SendBack(what, user, how)
	if how == nil then
		user:SendData(bBot, what)
	else
		user:SendPM(bBot, what)
	end
end

function ListBirths(user, how)
	local str = "The Birthday List of the users of this Hub"
	local msg = "\r\n    ..-*'~ "..str.." ~'*-..\r\n"..string.rep("^", string.len(str)+2).."\r\n\t"
	local c = 0
	local status = ""
	for i, v in tBirthdays do
		if GetItemByName(i) then status = "online" else status = "offline" end
		c = c + 1
		tip = ". - "..tBirthdays[i][1].."/"..tBirthdays[i][2].."/"..tBirthdays[i][3].."\t- \t"..i.."\t"..Zodiac(tBirthdays[i]).."\t ( "..status.." )"
		if tBirthdays[i][1].."/"..tBirthdays[i][2] == os.date("%d/%m") then
			tip = tip.."-+-"
		end
		msg = msg..c..tip.."\r\n\t"
	end
	if loadcelebs ~= 0 then
		for i, v in tCelebs do
			status = ":Celebrity:"
			c = c + 1
			tip = ". - \t"..tCelebs[i][1].."/"..tCelebs[i][2].."/"..tCelebs[i][3].."\t- \t"..i.."\t"..Zodiac(tCelebs[i]).."\t ( "..status.." )"
			if tCelebs[i][1].."/"..tCelebs[i][2] == os.date("%d/%m") then
				tip = tip.."-+-"
			end
			msg = msg..c..tip.."\r\n\t"
		end
	end
	SendBack(msg, user, how) 
end


function AddBirthDay(user, args, how)
	local pers = ""
	if args ~= nil then
		local s,e,name,day,month,year = string.find(args, "(%S+)%s+(%d+)/(%d+)/(%d+)")
		if name == nil then
			name = user.sName
			pers = "you"
			s,e,day,month,year = string.find(args, "(%d+)/(%d+)/(%d+)")
		else pers = name 
		end
		if month ~= nil and day ~= nil and year ~= nil and (tonumber(month) >= 1) and (tonumber(month) <= 12) then
			day = tonumber(day)
			month = tonumber(month)
			year = tonumber(year)
			if year > oldestyear then
				if year < (tonumber(os.date("%Y")) - allowedage) then 
					if month == 2 then
						daylimit = FixFebruary(year)
					else daylimit = tCalendar[month][1]
					end
					if day <= daylimit and day >= 1 then
						if tBirthdays[name] then
							month = tBirthdays[name][2]
							if user.sName == name then
								SendBack("I have your birthday already ... its on the "..tBirthdays[name][1].." of "..tCalendar[month][2], user, how)
							else 
								SendBack("I have "..name.."'s birthday already ... its on the "..tBirthdays[name][1].." of "..tCalendar[month][2] , user, how)
							end
							local profstr = ""
								for i,v in tProfiles do
									if tProfiles[i] == 2 then
										profstr = GetProfileName(tonumber(i)).."s"
										break
									end
								end
							SendBack("If you dont think this is correct ... then talk to one of our "..profstr , user, how)
						else tBirthdays[name] = {}
							tBirthdays[name][1] = day
							tBirthdays[name][2] = month
							tBirthdays[name][3] = year
							SaveFile(birthlog, tBirthdays, "tBirthdays") 
							SendToAll("You Are a "..Zodiac(tBirthdays[name]).."!!!")
							if user.sName == name then
								SendBack("Your birthday is on the "..tBirthdays[name][1].." of "..tCalendar[month][2] , user, how)
								SendBack("I didnt know you are "..FindCorrectAge(tBirthdays[name])..". I'll keep that in mind ;)" , user, how)
							else 
								SendBack(name.."'s birthday is on the "..tBirthdays[name][1].." of "..tCalendar[month][2] , user, how)
								SendBack("I didnt know "..name.." is "..FindCorrectAge(tBirthdays[name])..". I'll keep that in mind ;)" , user, how)
							end
							if user.sName == name then
								SendBack("New birthday added by "..user.sName.." his/her is on the "..tBirthdays[name][1].." of "..tCalendar[month][2].." a "..Zodiac(tBirthdays[name]) , user, how)
							else 
								SendBack(user.sName.." added "..name.."'s birthday, which is on the "..tBirthdays[name][1].." of "..tCalendar[month][2].." a "..Zodiac(tBirthdays[name]) , user, how)
							end
						end
					end
				else 
					SendBack("Come ON! "..pers.." cant be less than "..allowedage.." years old !!!  LIAR >:(" , user, how)
				end
			else SendBack("Come ON! "..pers.." cant be more than "..(year-oldestyear).." years old !!!  LIAR >:(" , user, how)
			end
		else SendBack("The date you provided was not valid ... ( syntax example : 14/5/1981 )" , user, how)
		end
	else SendBack("Please enter your birthday after the command ..." , user, how)
	end
end

function FindCorrectAge(table)
	if table[2] > tonumber(os.date("%m")) then
		return ( tonumber(os.date("%Y")) - table[3] ) - 1
	elseif table[2] < tonumber(os.date("%m")) then
		return tonumber(os.date("%Y")) - table[3]
	elseif table[2] == tonumber(os.date("%m")) then
		if table[1] <= tonumber(os.date("%d")) then
			return tonumber(os.date("%Y")) - table[3]
		else 
			return ( tonumber(os.date("%Y")) - table[3] ) - 1
		end
	end
end

function DoHappyBirthday(nick)
	if TxtSend == nil then
		SendToAll(ReadTextFile(birthdayfile))
		TxtSend = 1
	end
	local age = tonumber(os.date("%Y")) - tBirthdays[nick.sName][3]
	local tSurpises = {
			nick.sName.." is gonna have a PAAARTY, today he is turning "..age.." Happy Birthday !!!!",
			"All of you spam "..nick.sName.." with Birthday messages ;), ...turning "..age.." today !!!",
			"Who's turning "..age.." today ?? :D... The day AND the night belongs to "..nick.sName,
			"Happy Birthday to you, Happy Birthday dear "..nick.sName..", we all wish you your "..age.." will be better than your "..(age-1).." !! :)",
			" I think Mr"..nick.sName.." has his/her birthday today ... he/she should be turning "..age.." today ;D",
			"A "..Zodiac(tBirthdays[nick.sName]).." is turning "..age.." today!!! ... it's "..nick.sName.."'s birthday!!!"
			};
	SendToAll( bBot , tSurpises[math.random(1, table.getn(tSurpises)) ] )
end

function ExactAge(user, how)
	local table = tBirthdays[user.sName]
	if table == nil then
		SendBack("I dont have your birthday,... please use the "..addcmd.." dd/mm/yyyy command to enter your birthday", user, how)
		return 1
	else
		local curAge = FindCorrectAge(table)
		local finMonth = 0
		if tonumber(os.date("%m")) < table[2] then
			finMonth = 12 - ( table[2] - tonumber(os.date("%m")) )
		elseif tonumber(os.date("%m")) > table[2] then
			finMonth = ( tonumber(os.date("%m")) - table[2] )
		end

		local finDays = 0
		if tonumber(os.date("%d")) < table[1] then
			finMonth = finMonth - 1
			local tempMonth = table[2] - 1
			finDays = ( tCalendar[tempMonth][1] + ( tonumber(os.date("%d")) - table[1] ) )
			if tonumber(os.date("%d")) > tCalendar[tonumber(os.date("%m"))][1] then
				finMonth = finMonth + 1
				finDays = tCalendar[tonumber(os.date("%m"))][1] - finDays
			end
		else 
			finDays = tonumber(os.date("%d")) - table[1]
		end
		
		if finMonth <= 0 then
			finMonth = 12 + finMonth 
			if curAge == tonumber(os.date("%Y")) - table[3] then
				SendToAll("yeah")
				curAge = curAge - 1
			end
		end 
		if finMonth == 12 then
			curAge = curAge + 1
			finMonth = 0
		end
		SendBack("You are "..curAge.." years, "..finMonth.." months and "..finDays.." days old (that according to the Hub's clock :)", user, how)
	end
end

function BHelp(user, how)
	if tProfiles[""..prof..""] ~= 0 then
		local msg = "\r\n\t\t You can use the following commands for "..bBot.."\r\n"
		if tProfiles[""..prof..""] >= 1 then
				msg = msg.."\t - "..bhelpcmd.." \t\t\t\t- this text :)\r\n"
				msg = msg.."\t - "..listcmd.." \t\t\t- this will list the birthdays in store\r\n"
				msg = msg.."\t - "..addcmd.." dd/mm/yyyy \t\t- put your own birthday :)\r\n"
				msg = msg.."\t - "..findcmd.." \t\t\t- this will display the people that have similar birthday to yours\r\n"
				if loadcelebs ~= 0 then
					msg = msg.."\t - "..celebcmd.." \t\t\t\t- this will display the celebrities that have similar birthday to yours\r\n"
				end
				msg = msg.."\t - "..agecmd.." \t\t\t\t- this shows you your exact age ( days months years )\r\n"
			if tProfiles[""..prof..""] == 2 then
				msg = msg.."\t - "..delcmd.." <user>\t\t- this deletes the birthday of <user>\r\n"
				msg = msg.."\t - "..addbircmd.." <user> dd/mm/yyyy \t- this adds the birthday of <user>"
			end
		end
		SendBack(msg, user, how)
	end
end

--- // --- Table Serialization --- Thanks NL
function Serialize(tTable, sTableName, sTab)

        assert(tTable, "tTable equals nil");
        assert(sTableName, "sTableName equals nil");

        assert(type(tTable) == "table", "tTable must be a table!");
        assert(type(sTableName) == "string", "sTableName must be a string!");

        sTab = sTab or "";
        sTmp = ""

        sTmp = sTmp..sTab..sTableName.." = {\n"

        for key, value in tTable do
                local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);

                if(type(value) == "table") then
                        sTmp = sTmp..Serialize(value, sKey, sTab.."\t");
                else
                        local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
                        sTmp = sTmp..sTab.."\t"..sKey.." = "..sValue
                end

                sTmp = sTmp..",\n"
        end

        sTmp = sTmp..sTab.."}"
        return sTmp
end

---------------------------
function LoadFile(file)
	local handle = io.open(file,"r")
	if (handle ~= nil) then
		loadstring(handle:read("*all"))
		handle:flush()
		handle:close()
	end
end
----------------------------
function SaveFile(file , table , tablename)
	local handle = io.open(file,"w+")
	handle:write(Serialize(table, tablename))
	handle:flush()
	handle:close()
end

function ReadTextFile(file)
	local message = "\r\n"
	local handle = io.open(file,"r")
	if (handle ~= nil) then
		while 1 do
			local line = handle:read()
			if ( line == nil ) then
				break
			else 
				message = message.."\t"..line.."\r\n"
			end
		end
		handle:close()
		return message
	else
	end
end