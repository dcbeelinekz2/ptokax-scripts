--#-- GraphBot by Herodes
-- Working Version (but after repeating the cmd x 5 times u don't get any refresh on the tables ...)
-- fixed correction of kb, mb, gb, tb display
-- now the user count centers on top of the column...
-- input from NotRambitWombat made it even shorter.. :)
-- Tried to get the extra tables working but I couldn't .. :(
-- Making progress on this ... Added tables tried to get them to work again ..
-- It gets the values to the tables but it has an error (indicated in script) [ 8:20 pm 30-5-2004 ]
-- After heavy tutoring session with plop, The Script is working as Intented !
--##-- thanx to All the ppl who helped ... bonus to plop  5:02 am 3-6-2004
--- Returns a graph of the present user count along with the present share and the time
--- Remembers up to three previous graphs and displays simultaneously
---** Trying the command while you are the only user turns up with error (fixed //  1:29 pm 3-6-2004 // )
---** ...  no worries wait for someone to join and then try it again ... (fixed //  1:29 pm 3-6-2004 // )
--** conv. to LUA 5 for ptokax by UwV
-- Added Timed Sending of Graph by jiten

gBot = "CountGraphula"		-- you may edit the bot to whatever u want
graphcmd = "graph"		-- you may edit the command to whatever u want
fullcell = "   :¦:\t"
emptycell = "\t"
count = 0
tTab = { [1] = "\t", [2] = "\t", [3] = "\t", [4] = "\t", [5] = "\t", [6] = "\t", [7] = "\t", [8] = "\t", [9] = "\t", [10] = "\t", [11] = "\t", [12] = "\t", };
tTable = { [1] = "\t", [2] = "\t", [3] = "\t", [4] = "\t", [5] = "\t", [6] = "\t", [7] = "\t", [8] = "\t", [9] = "\t", [10] = "\t", [11] = "\t", [12] = "\t", };
tCol1= { [1] = "\t", [2] = "\t", [3] = "\t", [4] = "\t", [5] = "\t", [6] = "\t", [7] = "\t", [8] = "\t", [9] = "\t", [10] = "\t", [11] = "\t", [12] = "\t", };
tCol2= { [1] = "\t", [2] = "\t", [3] = "\t", [4] = "\t", [5] = "\t", [6] = "\t", [7] = "\t", [8] = "\t", [9] = "\t", [10] = "\t", [11] = "\t", [12] = "\t", };
tCol3= { [1] = "\t", [2] = "\t", [3] = "\t", [4] = "\t", [5] = "\t", [6] = "\t", [7] = "\t", [8] = "\t", [9] = "\t", [10] = "\t", [11] = "\t", [12] = "\t", };
iDelay = 20 -- Delay in minutes

Main = function()
	SetTimer(iDelay*60*1000) StartTimer()
end
----------------------------------------------------------------------- the command
function ChatArrival(user, data)
	local data=string.sub(data,1,string.len(data)-1)
	local s,e,cmd = string.find(data,"%b<>%s+[%!%?%+%#](%S+)")
	if cmd and cmd == graphcmd then
		if (frmHub:GetUsersCount() == 1) then user:SendData(gBot, "Where did everybody go ?") else TransferAll() end
	end
end
----------------------------------------------------------------------- place the values in table and return table
AddValues = function()
	tTable = {} GetNumbers()
	if usrC > 1 then
		local pivot = 11 - math.floor(usrC / maxU * 10)
		for i = 1,10 do
			if ( i < pivot ) then
				tTable[i] = emptycell
			elseif ( i == pivot ) then
				tTable[i] = userCount
			else 
				tTable[i] = fullcell 
			end
		end
	end
	if usrC == 1 then SendToAll(gBot, "Where did everybody go ?") end
	tTable[11] = Time tTable[12] = hubshrS return tTable
end
----------------------------------------------------------------------- push the values in a > b 
FixTable = function(table1, table2)
	for i, v in table1 do i = tonumber(i) if i == nil then i = 1 end table2[i]= v end
end
----------------------------------------------------------------------- logical route for handling the tables ..
TransferAll = function()
	if count == 1 then 
		FixTable(tCol2, tCol3) 
		FixTable(tCol1, tCol2) 
		FixTable(tTable, tCol1)
		AddValues()
		GiveGraph()
	else
		DoTranferTab()
		AddValues() 
		GiveGraph()
	end
end
----------------------------------------------------------------------- straigth run ¦ pushing the tables .. 
DoTranferTab = function()
	if tTable[11] ~= "\t" then
		if tCol3[11] == "\t"then 
			FixTable(tCol2, tCol3) 
			FixTable(tCol1, tCol2) 
			FixTable(tTable, tCol1)
		elseif tCol2[11] == "\t" then
			FixTable(tCol1, tCol2) 
			FixTable(tTable, tCol1)
		elseif tCol1[11] == "\t" and count == 1 then 
			FixTable(tTable, tCol1)
			count = 0
		end
	end
	count = count +1
end
----------------------------------------------------------------------- the graph showing the values of all tables
GiveGraph = function()
	if frmHub:GetUsersCount() > 1 then
		tMsg = "\r\n\t\t\t- "..frmHub:GetHubName().." - User Count Graph -"
		tMsg = tMsg.."\r\n - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -o-0-o- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
		tMsg = tMsg.."\r\n -> Share\t:\t"..tTable[12].."\t\t"..tCol1[12].."\t\t"..tCol2[12].."\t\t"..tCol3[12]
		tMsg = tMsg.."\r\n 100% ("..maxU..")\t\t"..tTable[1].."\t"..tCol1[1].."\t"..tCol2[1].."\t"..tCol3[1]
		tMsg = tMsg.."\r\n --- - -  -   -\t\t"..tTable[2].."\t"..tCol1[2].."\t"..tCol2[2].."\t"..tCol3[2]
		tMsg = tMsg.."\r\n --- - -  -   -\t\t"..tTable[3].."\t"..tCol1[3].."\t"..tCol2[3].."\t"..tCol3[3]
		tMsg = tMsg.."\r\n --- - -  -   -\t\t"..tTable[4].."\t"..tCol1[4].."\t"..tCol2[4].."\t"..tCol3[4]
		tMsg = tMsg.."\r\n --- - -  -   -\t\t"..tTable[5].."\t"..tCol1[5].."\t"..tCol2[5].."\t"..tCol3[5]
		tMsg = tMsg.."\r\n 50% ("..midU..")\t\t"..tTable[6].."\t"..tCol1[6].."\t"..tCol2[6].."\t"..tCol3[6]
		tMsg = tMsg.."\r\n --- - -  -   -\t\t"..tTable[7].."\t"..tCol1[7].."\t"..tCol2[7].."\t"..tCol3[7]
		tMsg = tMsg.."\r\n --- - -  -   -\t\t"..tTable[8].."\t"..tCol1[8].."\t"..tCol2[8].."\t"..tCol3[8]
		tMsg = tMsg.."\r\n --- - -  -   -\t\t"..tTable[9].."\t"..tCol1[9].."\t"..tCol2[9].."\t"..tCol3[9]
		tMsg = tMsg.."\r\n --- - -  -   -\t\t"..tTable[10].."\t"..tCol1[10].."\t"..tCol2[10].."\t"..tCol3[10]
		tMsg = tMsg.."\r\n- 0% (0). . . . . . . . . . \t. .:¦:. . . . . . . . . . . . .\t. .:¦:. . . . . . . . . . . . .\t. .:¦:. . . . . . . . . . . . .\t. .:¦:. . . . . . . . . . . . ."
		tMsg = tMsg.."\r\n ->  Time\t:            "..tTable[11].."\t             "..tCol1[11].."\t             "..tCol2[11].."\t             "..tCol3[11]
		SendToAll(gBot, tMsg)
	end
end
----------------------------------------------------------------------- get the data (numbers) needed, string.format and return them
GetNumbers = function()
	Time, userCount, maxU, hubshare = "\t"
	Time = os.date("%H")..":"..os.date("%M")..":"..os.date("%S")
	usrC = frmHub:GetUsersCount() userCount = AddSpacesToKey(usrC) maxU = frmHub:GetMaxUsers() midU = maxU/2
	local thubshare = string.format("%0.1f", ( frmHub:GetCurrentShareAmount() / 1024))
	hubshrS = thubshare.." kb"
	if tonumber(thubshare) >= 1024 and tonumber(thubshare) < (1024^2) then
		hubshrS = string.format("%0.1f", ( frmHub:GetCurrentShareAmount() / (1024^2))).." mb"
	elseif tonumber(thubshare) >= (1024^2) and tonumber(thubshare) < (1024^3) then
		hubshrS = string.format("%0.1f", ( frmHub:GetCurrentShareAmount() / (1024^3))).." gb"
	elseif tonumber(thubshare) >= (1024^3) then
		hubshrS = string.format("%0.1f", ( frmHub:GetCurrentShareAmount() / (1024^4))).." tb"
	end
	return Time, userCount, maxU, midU, hubshare, usrC, hubshrS
end

----------------------------------------------------------------------- adding appropriate number of spaces to a string
AddSpacesToKey = function(data)
	local ratio = (5 - string.len(data)) local tcell = string.rep(" ", ratio)..data.."\t" return tcell
end

OnTimer = function()
	TransferAll()
end