------------------------------------------------------------------------
------
--// Send Random Text Line every x minute // By NightLitch
-- little mod by Dessamator, added memlines and memory
------------------------------------------------------------------------------
cBotName = "botnamehere" -- enter botname
cFilename = "memories.txt" -- enter filename
cTime = 10 -- enter time in minutes
------------------------------------------------------------------------------
lineTable = {n=0}

function Main()
frmHub:RegBot(cBotName)
GetLines(cFilename)
SetTimer(cTime*60000)
StartTimer()
end


function OnTimer()
	SendStuff()
end

function GetLines(filename)
local file = io.open(filename, "r")
		for line in file:lines() do
			table.insert(lineTable, line)
		end
file:close()
end

function ChatArrival(curUser, sdata)

	local s, e, cmd, args = string.find(sdata, "^%b<> %!(%a+)%s*(.*)|$")
	if curUser.bOperator then
		if cmd == "memories" then
			SendStuff()
			return 1
		elseif cmd == "memaddline"  then
			addline("memories.txt", args)
			curUser:SendData(cBotName,"Done ,memory added")
			return 1
		end
	end
end 

function SendStuff()
	GetLines(cFilename)
	local message = lineTable[math.random(1,table.getn(lineTable))]
	SendToAll(cBotName, message)
         return message
end

function addline(filename,msg)
local file = io.open(filename, "a+")
file:write("\n"..msg)
file:close()
end
