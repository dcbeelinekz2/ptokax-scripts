-- Conversion to Lua 5 by jiten
--Chat stats by chill
--Serialisation by RabidWombat

----------------------------------------------------------
----------------------------------------------------------
ChatConf = {
	tC = {
		bot = "-ChatStats-",		-- The Name of the bot.
		Max1 = 10,			-- How Many top chatters are shown of each genre.
		howToSort = 2,		-- Stands for the sorting either 1= least first, 2 = highest first.
		howToSend = 1,		-- 1 = Sends to all, 2 = Sends to user, 3 = PM to the user, 4 = PM to the user and regs a bot.
		StatsFile = "ChatStats.txt",	-- The Filename
	},
	tS = {},
}
----------------------------------------------------------
----------------------------------------------------------

---------------------------------------------------------------------------------------

--	MAIN SCRIPT

---------------------------------------------------------------------------------------
----------------------------------------------------------
chatEmotions = {
	[":)"] = 1,
	[":-)"] = 1,
	[":("] = 1,
	[":-("] = 1,
	[";)"] = 1,
	[";-)"] = 1,
	[":-p"] = 1,
	[":p"] = 1,
	[":D"] = 1,
	[":-D"] = 1,
}
----------------------------------------------------------
function Main()
	local f = io.open(ChatConf.tC.StatsFile )
	if f then
		f:close();
		dofile(ChatConf.tC.StatsFile)
	end
	if ChatConf.tC.howToSend == 4 then
		frmHub:RegBot(ChatConf.tC.bot)
	end
	SetTimer(1000*60*5)
	StartTimer()
end
----------------------------------------------------------
function OnTimer()
	local handle = io.open(ChatConf.tC.StatsFile,"w+")
	handle:write(Serialize(ChatConf.tS, "ChatStats")) 
	handle:flush() 
	handle:close() 
end
----------------------------------------------------------
function ChatArrival(curUser,data)

	if not ChatConf.tS[curUser.sName] then
		ChatConf.tS[curUser.sName] = { words = 0, chars = 0, emotions = 0 }
	end

	data1 = string.sub (data,1,-1)
	data = string.sub(data,string.len(curUser.sName)+4,string.len(data)-1)

	string.gsub(data,"(%S+)",function(w)
		ChatConf.tS[curUser.sName].chars = ChatConf.tS[curUser.sName].chars + string.len(w)
		if chatEmotions[w] then
			ChatConf.tS[curUser.sName].emotions = ChatConf.tS[curUser.sName].emotions + 1
		else
			ChatConf.tS[curUser.sName].words = ChatConf.tS[curUser.sName].words + 1
		end
	end)

	local function doSortTable(Table,field)
		if ChatConf.tC.howToSort == 1 then
			if field == "ALL" then
				table.sort(Table, function(a,b) return((a[2].chars + a[2].words + a[2].emotions)  < (b[2].chars + b[2].words + b[2].emotions)) end)
			else
				table.sort(Table, function(a,b) return(a[2][field] < b[2][field]) end)
			end
		elseif ChatConf.tC.howToSort == 2 then
			if field == "ALL" then
				table.sort(Table, function(a,b) return((a[2].chars + a[2].words + a[2].emotions)  > (b[2].chars + b[2].words + b[2].emotions)) end)
			else
				table.sort(Table, function(a,b) return(a[2][field] > b[2][field]) end)
			end
		end
		return Table
	end

	if string.find( data1, "%b<>%s+[%+%!%?%-]showstats" ) then

		local sTable = {}
		table.foreach(ChatConf.tS, function(i,v) table.insert(sTable,{i,v}) end)
		local msg = "-----  Current Chat Stats ------\r\n"

		sTable = doSortTable(sTable,"ALL")
		msg = msg.."\r\n\tTop "..ChatConf.tC.Max1.." Overall Stats\r\n\r\n"
		for i = 1,ChatConf.tC.Max1 do
			if sTable[i] then
				msg = msg.."\t# "..i.."  -  "..sTable[i][1]..", "..(sTable[i][2].chars + sTable[i][2].words + sTable[i][2].emotions).." overall,  "..sTable[i][2].chars.." chars, "..sTable[i][2].words.." words, "..sTable[i][2].emotions.." emotions.\r\n"
			end
		end
		sTable = doSortTable(sTable,"chars")
		msg = msg.."\r\n\tTop "..ChatConf.tC.Max1.." Char Stats\r\n\r\n"
		for i = 1,ChatConf.tC.Max1 do
			if sTable[i] then
				msg = msg.."\t# "..i.."  -  "..sTable[i][1]..", with "..sTable[i][2].chars.." chars.\r\n"
			end
		end
		sTable = doSortTable(sTable,"words")
		msg = msg.."\r\n\tTop "..ChatConf.tC.Max1.." Word Stats\r\n\r\n"
		for i = 1,ChatConf.tC.Max1 do
			if sTable[i] then
				msg = msg.."\t# "..i.."  -  "..sTable[i][1]..", with "..sTable[i][2].words.." words.\r\n"
			end
		end
		sTable = doSortTable(sTable,"emotions")
		msg = msg.."\r\n\tTop "..ChatConf.tC.Max1.." Emotion Stats\r\n\r\n"
		for i = 1,ChatConf.tC.Max1 do
			if sTable[i] then
				msg = msg.."\t# "..i.."  -  "..sTable[i][1]..", with "..sTable[i][2].emotions.." emotions.\r\n"
			end
		end

		if ChatConf.tC.howToSend == 1 then
			SendToAll(ChatConf.tC.bot,msg)
		elseif ChatConf.tC.howToSend == 2 then
			curUser:SendData(ChatConf.tC.bot,msg)
		elseif (ChatConf.tC.howToSend == 3) or (ChatConf.tC.howToSend == 4) then
			curUser:SendPM(ChatConf.tC.bot,msg)
		end
		return 1
	end
end
---------------------------------------------------------------------------------------

--	Write Tables

---------------------------------------------------------------------------------------
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
