--## Most recent changes & fixes on : 10/01/2005
--## Commands:
sec=1000
min=sec*60

Alarm = {}
alerts = {}
fAlarm = "fAlarm.dat"
extrareminders = 3 -- write here how many extra reminders 
--## Configuration ##--
sBot = frmHub:GetHubBotName()   -- Automatic bot name finder,
--## END ##--

function Main()
	frmHub:RegBot(sBot)
	LoadFromFile(fAlarm)
	SetTimer(min);
	StartTimer()
end

function OnExit()
	SaveToFile(fAlarm , Alarm , "Alarm")
end

-- right clicks command
function NewUserConnected(User) 
User:SendData("$UserCommand 0 3 |") 
User:SendData("$UserCommand 1 3 Reminders\\Set Reminder$<%[mynick]> !alarm %[line:time ex.:20:20] %[line:Reminder]&#124;|")
User:SendData("$UserCommand 1 3 Reminders\\Remove Reminder$<%[mynick]> !delalarm %[line:Reminder <id> ex.: 1]&#124;|")
User:SendData("$UserCommand 1 3 Reminders\\View Reminder$<%[mynick]> !aread&#124;|")

end
OpConnected=NewUserConnected
--
function ChatArrival(user, data)
		data = string.sub(data,1,string.len(data)-1)
		s,e,cmd = string.find(data, "%b<>%s+(%S+)")
	if string.lower(cmd) == "!alarm" then
		setAlarm(user, data)
		return 1
	elseif string.lower(cmd) == "!aread" then
		ReadPost(user)
		return 1	
	elseif string.lower(cmd) == "!delalarm" then
		DoDelPost(user,data)
		return 1	
	end
end
ToArrival=ChatArrival
--------->>>>> Write & Read functions
function setAlarm(user, data)
local s,e,time,Reminder =  string.find(data,"%b<>%s+%S+%s+(%S+)%s+(.*)")
	if not(time == nil) and not(Reminder==nil) then -- and(Checkpost(user, data)) == false and  not(string.len(Reminder)>300) then
		local pos = GetPosition(Alarm)
		Alarm[pos] = {}
		Alarm[pos]["Reminder"] = Reminder
		Alarm[pos]["by"] = user.sName
		Alarm[pos]["ctime"] = os.date("%X")
		local secs= string.sub(time,7,8)
		local hour= string.sub(time,2,2)
if hour==":" and secs== "" then
		Alarm[pos]["atime"] = "0"..time..":00"
elseif secs== ""  then
		Alarm[pos]["atime"] = time..":00"
elseif hour==":" then
		Alarm[pos]["atime"] = "0"..time
else
		Alarm[pos]["atime"] = time	
end
		Alarm[pos]["date"] = os.date("%d/%m/%Y")
		user:SendPM(sBot, "Your Reminder has been set.")
elseif 		not(Checkpost(user, data) == false) then
		user:SendPM(sBot,"The Reminder already exists")
else		
		user:SendPM(sBot, "Syntax Error, !Alarm <time: ex.: 19:19><reminder>, you must write a reminder.")
	  end

end

function ReadPost(user)
	local sTmp,pos,table = "\r\n\Your reminder(s) :\r\n"
	for pos, table in Alarm do
			 if Alarm[pos]["by"] == user.sName then
				sTmp = sTmp.."\t ________________\r\n"
			  	sTmp = sTmp.."ID: "..pos.."\r\n"
				sTmp = sTmp.."By: "..table.by.."\r\n"
				sTmp = sTmp.."Creation   Time: "..table.ctime.."\r\n"
				sTmp = sTmp.."Schedule Time: "..table.atime.."\r\n"
				sTmp = sTmp..table.Reminder.."\r\n"
				sTmp = sTmp.."\t ________________\r\n\r\n"
	
	end
end	
if sTmp == "Your reminders :\r\n\r\n"  then
	user:SendPM(sBot, "You have no Scheduled Appointments")
else
	user:SendPM(sBot, sTmp)

end
	end

-------->>>>End write & read Functions

------->>>>Del Functions
function DoDelPost(user,data)
local s,e,id = string.find(data, "%b<>%s+%S+%s+(.+)")
	if id == nil or tonumber(id)==nil then
		 user:SendPM(sBot, "Syntax Error, !delalarm <id> , the id must be specified!")
	elseif (Alarm[tonumber(id)] == nil) then
		 user:SendPM(sBot, "That post doesnt exist!")
	elseif  (Alarm[tonumber(id)]["by"]==user.sName) then
		 Alarm[tonumber(id)] = nil
		 user:SendPM(sBot, "The post has been deleted!")
	else
		user:SendPM(sBot, "You are not authorized to delete the post !")	
	end
end
----------->>>End del Functions
------->>> ARITHMETIC AND BOOLEAN FUNCTIONS <<----------------
function WorkTime(string1, string2)
if not(string1 == nil) then
	local hour1,min1,sec1 = string.sub(string1,1,2),string.sub(string1,4,5),string.sub(string1,7,8)
	local hour2,min2,sec2 = string.sub(string2,1,2),string.sub(string2,4,5),string.sub(string2,7,8)
        local hour = tonumber(hour2) - tonumber(hour1)
  	local min = tonumber(min2) - tonumber(min1)
	local sec = tonumber(sec2) - tonumber(sec1)
	hour = hour*60*60
	min  = min*60
	local time = hour + min + sec
	return time
	
    end
end
---------->Checks for duplicate Posts<---------------
function Checkpost(user, data)
local pos,aux,check
local s,e,Reminder = string.find(data, "%b<>%s+%S+%s+(.+)")
for pos, aux in Alarm do
	if (Alarm[pos]["Reminder"] == Reminder) then
		check = "false"
		return check
		end
	end
end

---------------------->><<---------------------------
------>Tables Processing functions<------------------
function GetPosition(table)
	local pos = 0
	while 1 do
		if (table[pos] == nil) then
			return pos
		else
			pos = pos + 1
		end
	end
end

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

function SaveToFile(file , table , tablename)
	local handle = io.open(file,"w+")
        handle:write(Serialize(table, tablename))
	handle:flush()
        handle:close()
end
function LoadFromFile(file)
local handle = io.open(file,"r")
        if (handle ~= nil) then
                dofile(file)
handle:flush()
handle:close()
        end

end
--------------------------><---------------------------------
---------------------Ontimer---------------------------------
function OnTimer()
local sec,min = 1,60
	if 	not(Alarm == nil) then
	local today,pos,aux = os.date("%X")
		for	pos, table in Alarm do
	local Nick = Alarm[pos]["by"]
	Name = GetItemByName(Nick)
	worktime=WorkTime(Alarm[pos]["atime"], today)
	sTemp = "\r\n\Your Reminder : \r\n"
	sTemp = sTemp.."\t ________________\r\n\r\n"
	sTemp = sTemp.."Reminder ID: "..pos.."\r\n"
	sTemp = sTemp.."Creation   Time: "..table.ctime.."\r\n"
	sTemp = sTemp.."Schedule Time: "..table.atime.."\r\n"
	sTemp = sTemp..table.date.."\r\n"
	sTemp = sTemp.."Reminder :"..table.Reminder.."\r\n"
	sTemp = sTemp.."\t ________________\r\n\r\n"
			if not(Name == nil) and (math.floor(worktime/min)>=0) then -- extra reminder using 1 min intervals --ps floor function rounds up a number
	SendPmToNick(Nick, sBot,sTemp)
				if alerts[pos]==nil then 
	alerts[pos]="1"
elseif 	alerts[pos]==extrareminders then -- after x alerts it stops sending pvts
	Alarm[pos] = nil
	alerts[pos]=nil
else
	alerts[pos]=alerts[pos]+1

				end		
			end
		end
	end
end	
