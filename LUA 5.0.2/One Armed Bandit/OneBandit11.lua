--Lua 5 version by jiten
--One Armed Bandit by chill
--Stops on command

bot = "-Bandit-"

BPrefix = "+"
cmd1 = "insert"
cmd2 = "spin"
cmd3 = "stop"
cmd4 = "bstats"

BPlayers = {}
BSpin = {}
BPoints = {}

scount = 0

function Main()
	if loadfile("BPoints.txt") then dofile("BPoints.txt") end
	SetTimer(1000)
	StartTimer()
end

function OnTimer()
	for i,v in BSpin do
		BSpin[i].Time = BSpin[i].Time + 1
		if BSpin[i].Time == 5 then
			doShowSpin(i)
		end
	end
	scount = scount +1
	if scount == 300 then
		WriteTable(BPoints,"BPoints","BPoints.txt")
	end
end

function OnExit()
	WriteTable(BPoints,"BPoints","BPoints.txt")
end

function ChatArrival(curUser,data)
	local data = string.sub(data,1,-2)
	_,_,word1 = string.find(data,"^%b<>%s+(%S+)")
	if word1 and BFUNCS[word1] then
		return BFUNCS[word1](curUser,data), 1
	end
end
--------------------------------------------------------------------------
--	SHOW ONE SPIN
--------------------------------------------------------------------------
function doShowSpin(curNick)
	local num = math.random(table.getn(BSpin[curNick].Wheel))
	local num1 = BSpin[curNick].Wheel[num]
	local num2 = math.random(9)
	for i = 1,table.getn(BSpin[curNick].WheelChar) do
		if i == num1 then
			BSpin[curNick].WheelChar[i] = num2
		end
	end
	curUser = GetItemByName(curNick)
	if curUser then
		curUser:SendData(bot,"\r\n"..
		"\t--------------------------\r\n\r\n"..
		"\t---- "..BSpin[curNick].WheelChar[1].." ---- "..BSpin[curNick].WheelChar[2].." ---- "..BSpin[curNick].WheelChar[3].." ----\r\n\r\n"..
		"\t--------------------------\r\n")
	else
		BSpin[curNick] = nil
		return
	end
	BSpin[curNick].Time = 0
	table.remove(BSpin[curNick].Wheel,num)
	if table.getn(BSpin[curNick].Wheel) == 0 then
		BPoints[curUser.sName] = BPoints[curUser.sName] or 0
		local curSum = {}
		for i = 1,3 do
			if curSum[BSpin[curNick].WheelChar[i]] then
				curSum[BSpin[curNick].WheelChar[i]] = curSum[BSpin[curNick].WheelChar[i]] + 1
			else
				curSum[BSpin[curNick].WheelChar[i]] = 1
			end
		end
		for i,v in curSum do
			if curSum[i] == 2 then
				BPoints[curUser.sName] = BPoints[curUser.sName] + i
				curUser:SendData(bot,"You get "..i.." Point(s).")
			elseif curSum[i] == 3 then
				BPoints[curUser.sName] = BPoints[curUser.sName] + (i*10)
				curUser:SendData(bot,"You get "..(i*10).." Point(s).")
				if i == 9 then
					BPoints[curUser.sName] = BPoints[curUser.sName] + 300
					curUser:SendData(bot,"*****  JAKPOT YOU GET 300 extra Points.")
				end
			end
		end
		BSpin[curNick] = nil
	end
end
--------------------------------------------------------------------------
--	SAVE POINTS
--------------------------------------------------------------------------
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

WriteTable = function(table,tablename,file)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end
--------------------------------------------------------------------------
--	BANDIT FUNCS
--------------------------------------------------------------------------
BFUNCS = {

	[BPrefix..cmd1] = function(curUser,data)
		local _,_,num = string.find(data,"(%d+)$")
		if not BPlayers[curUser.sName] and tonumber(num) and tonumber(num) <= 20 and tonumber(num) > 0 then
			BPlayers[curUser.sName] = tonumber(num)
			curUser:SendData(bot,"You have inserted "..num.." coins.")
		else
			curUser:SendData(bot,"We are no bank.We don't store or give out money.")
		end
	end,

	[BPrefix..cmd2] = function(curUser,data)
		if BPlayers[curUser.sName] and not BSpin[curUser.sName] then
			BPlayers[curUser.sName] = BPlayers[curUser.sName] - 1
			if BPlayers[curUser.sName] == 0 then
				BPlayers[curUser.sName] = nil
			end
			BSpin[curUser.sName] = {
				Wheel = { 1,2,3 },
				WheelChar = { "X","X","X" },
				Time = 0,
			}
			curUser:SendData(bot,"Spinning the Wheel.\r\n\r\n"..
			"\t--------------------------\r\n\r\n"..
			"\t---- X ---- X ---- X ----\r\n\r\n"..
			"\t--------------------------\r\n")
		else
			curUser:SendData(bot,"You need to insert a coin first.")
		end
	end,

	[BPrefix..cmd3] = function(curUser,data)
		if BSpin[curUser.sName] then
			doShowSpin(curUser.sName)
		end
	end,

	[BPrefix..cmd4] = function(curUser,data)
		TCopy = {}

		for i,v in BPoints do

			table.insert(TCopy,{i,v})

		end

		table.sort(TCopy,function(a,b) return(a[2]>b[2]) end)
		local msg = "-- Top Bandits ---\r\n\r\n"
		for i = 1,table.getn(TCopy) do
			msg = msg.."\t# "..i.."  -  "..TCopy[i][1]..",  Points: "..TCopy[i][2].."\r\n"
		end
		curUser:SendData(bot,msg)
	end,
}
