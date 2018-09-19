---------------------------------------------------------------------------------
-- FRESH STUFF BY  C  H  I  L  L  A 	- 
-- Converted to Lua 5 by NightLitch -
---------------------------------------------------------------------------------

curVersion = "V.2.60"

File1 = "FreshStuff.txt"
File2 = "FreshPosters.txt"
File3 = "FreshStuff.ini"
File4 = "FreshRated.txt"
File5 = "FreshHelpUser.txt"
File6 = "FreshHelpOP.txt"
File7 = "FreshRequest.txt"

function loadlua(file,msg)
	local f = assert(loadfile(file), msg)
	return f()
end

loadlua("Fresh-Files/"..File3,"Fresh-Files/"..File3.."  for  FreshStuff-"..curVersion..".lua  not found")
loadlua("Fresh-Files/"..File1,"Fresh-Files/"..File1.."  for  FreshStuff-"..curVersion..".lua  not found")
loadlua("Fresh-Files/"..File2,"Fresh-Files/"..File2.."  for  FreshStuff-"..curVersion..".lua  not found")
loadlua("Fresh-Files/"..File4,"Fresh-Files/"..File4.."  for  FreshStuff-"..curVersion..".lua  not found")
assert(io.input("Fresh-Files/"..File5, "r"),"Fresh-Files/"..File5.."  for  FreshStuff-"..curVersion..".lua  not found")
assert(io.input("Fresh-Files/"..File6, "r"),"Fresh-Files/"..File6.."  for  FreshStuff-"..curVersion..".lua  not found")
loadlua("Fresh-Files/"..File7,"Fresh-Files/"..File7.."  for  FreshStuff-"..curVersion..".lua  not found")

FPrefix = string.gsub(FPrefix, " ", "%%")

AllTypes = ""
for i = 1,table.getn(ItemTypes) do
	AllTypes = AllTypes..ItemTypes[i]..", "
end

addHelp = " If you want to add an item type :\r\n"..
	"\t\t"..cmd1.." YOURITEM  (at least 10 , max 100 characters) or \r\n"..
	"\t\t"..cmd1.." ITEMTYPE YOURITEM  , in one line in main chat.\r\n"..
	"\t\tITEMTYPE's are : "..AllTypes.."\r\n"

function Main()
	SendToAll(FShow)
	frmHub:UnregBot(bot)
	if RegBot then
		frmHub:RegBot(bot)
	end
	TopItems2 = ReadTable(newstuff, 1, Max2)
	TopPosters = ShowPosters(posters, Max3)
	TopRated = ShowRated(rated, Max4)
	Userhelp = ReadHelp(File5)
	Ophelp = ReadHelp(File6)
end

function NewUserConnected(curUser)
	if SendOnConnect then
		curUser:SendData(bot, "\r\n"..
		"\t---------  The "..Max2.." Newest Items  --------\r\n"..
		TopItems2.."\r\n"..
		"\t---------  The "..Max2.." Newest Items  --------")
	end
end

OpConnected = NewUserConnected

function ToArrival(curUser,data)
	local _,_,whoTo,mes = string.find(data,"$To:%s+(%S+)%s+From:%s+%S+%s+$(.*)")
	if (whoTo == bot and string.find(mes,"%b<>%s+(.*)")) then
		data = string.sub(mes,1,string.len(mes)-1)
		HowToSend = "PM"
		if GetCommand(curUser,data)	== 1 then return 1 end
	end
end
function ChatArrival(curUser,data)
	data = string.sub(data,1,string.len(data)-1)
	HowToSend = "Main"
	if GetCommand(curUser,data)	== 1 then return 1 end
end

function GetCommand(curUser,data)	
	local _,_,_,cmd = string.find( data, "%b<>%s(["..FPrefix.."])(%S+)" )
	if not cmd then
		return 0
	elseif (string.lower(cmd) == string.lower(cmd1)) then
		if OnlyOP and not curUser.bOperator then
			return 1
		end
		local _,_,_,item = string.find( data, "%b<>%s+(%S+)%s+(.*)" )
		if ( item and item ~= "" and string.len(item) < 101 and string.len(item) > 9 and not string.find(string.lower(data), string.char(10)) ) then
			data = string.gsub(data, "%c+", " ")
			local _,_,_,type,item2 = string.find( data, "%b<>%s+(%S+)%s+(%S+)%s+(.*)" )
			if type then
				for i = 1,table.getn(ItemTypes) do
					if (string.lower(ItemTypes[i]) == string.lower(type) and string.len(item2) > 10) then
						AddItem(os.date("[%d/%m/%y]"),ItemTypes[i],curUser,item2)
						return 1
					elseif (string.lower(ItemTypes[i]) == string.lower(type) and string.len(item2) < 10) then
						SendToUser(curUser, addHelp)
						return 1
					end
				end
			end
			AddItem(os.date("[%d/%m/%y]"),"Item",curUser,item)
			return 1
		else
			SendToUser(curUser, addHelp)
		end
		return 1

	elseif (string.lower(cmd) == string.lower(cmd2)) then
		local _,_,args = string.find( data, "%b<>%s+(.*)" )
		var1 = 0
		string.gsub(args, "(%S+)", function (w) var1 = var1 + 1 end)
		if var1 == 3 then
			local _,_,_,num1,num2 = string.find( data, "%b<>%s+(%S+)%s+(%S+)%s+(%S+)%s*" )
			num1 = tonumber (num1)
			num2 = tonumber (num2)
			if ( num1 and num2 and num2 > num1 ) then
				Start = num1
				if num2-num1 >= 100 then
					End = num1 + 100
				else
					End = num2
				end
				TopItems1 = ReadTable(newstuff, Start, End)
			else
				SendToUser(curUser, "To show Stuff type, "..cmd2.." [StartNr.] [EndNr.].")
			end
		elseif var1 == 2 then
			local _,_,_,str1 = string.find( data,"%b<>%s+(%S+)%s+(%S+)%s*")
			if tonumber(str1) and tonumber(str1)<101 then
				Start = 1
				End = tonumber (str1)
				TopItems1 = ReadTable(newstuff, Start, End)
			elseif tonumber(str1) and tonumber(str1)>100 then
				Start = 1
				End = 100
				TopItems1 = ReadTable(newstuff, Start, End)
			else
				for i = 1, table.getn(ItemTypes) do
					if (string.lower(ItemTypes[i]) == string.lower(str1)) then
						if (ShowTypes(ItemTypes[i]) ~= "\r\n") then
							SendToUser(curUser,"\r\n"..
							"	----------------   Fresh "..str1.."'s   ----------------\r\n"..
							ShowTypes(str1).."\r\n"..
							"	----------------   Fresh "..str1.."'s   ----------------\r\n")
							return 1
						elseif (ShowTypes(ItemTypes[i]) == "\r\n") then
							SendToUser(curUser, "Sorry no Types found for : "..ItemTypes[i]..".")
							return 1
						end
					end
				end
				SendToUser(curUser,"To show types, type "..cmd2.." [ITEMTYPE]\r\n"..
				"\t\tItemTypes are : "..AllTypes..".")
				return 1
			end
				
		else
			Start = 1
			End = Max1
			TopItems1 = ReadTable(newstuff, Start, End)
		end
		SendToUser(curUser,"\r\n"..
		"\t----------------   Fresh Stuff :	Nr. "..Start.." - "..End.."       \t----------------\r\n"..
		TopItems1.."\r\n"..
		"\t----------------   Fresh Stuff :	"..table.getn(newstuff).."  Items Stored\t----------------\r\n")
		return 1
		
	elseif (string.lower(cmd) == string.lower(cmd3) and curUser.bOperator) then
		local _,_,_,str1 = string.find( data, "%b<>%s+(%S+)%s+(.*)" )
		if str1 and str1~="" then
			if tonumber(str1) and newstuff[tonumber(str1)] then
				local str1 = tonumber(str1)
				local time,type,name,item = newstuff[str1][1],newstuff[str1][2],newstuff[str1][3],newstuff[str1][4]
				table.remove (newstuff, str1)
				WriteFile(newstuff, "newstuff", File1)
				TopItems2 = ReadTable(newstuff, 1, Max2)
				SendToUser(curUser, " Item : "..str1.." - "..time.." added by "..name.."  ::  "..item..", was deleted.")
			elseif tonumber(str1) and newstuff[tonumber(str1)]==nil then
				SendToUser(curUser, " Item Nr. "..str1.." is not in list.")
			else
				for i = 1,table.getn(newstuff) do
					local time,type,name,item = newstuff[i][1],newstuff[i][2],newstuff[i][3],newstuff[i][4]
					if item == str1 then
						table.remove (newstuff, i)
						WriteFile(newstuff, "newstuff", File1)
						TopItems2 = ReadTable(newstuff, 1, Max2)
						SendToUser(curUser, " Item : "..i.." - "..time.." added by "..name.."  ::  "..item..", was deleted.")
						return 1
					end
				end
				str1 = string.format('%q', str1)
				SendToUser(curUser, " Item "..str1.." is not in list.")
			end
		else
			SendToUser(curUser, " To delete an item, type: "..cmd3.." [ITEMNUMBER]/[ITEMNAME].")
		end
		return 1

	elseif (string.lower(cmd) == string.lower(cmd4)) then
		SendToUser(curUser," -= The Top "..Max3.." Releasers =-\r\n"..
		TopPosters)
		return 1

	elseif (string.lower(cmd) == string.lower(cmd5)) then
		_,_,_,num1,num2 = string.find( data, "%b<>%s+(%S+)%s+(%S+)%s+(%S+)%s*" )
		local num1 = tonumber (num1)
		local num2 = tonumber (num2)
		if ( num1 and num2 and newstuff[num1] and 0<num2 and num2<11 ) then
			local item = newstuff[num1][4]
			if rated[item] then
				local xrated,hrated,trated = rated[item][1],rated[item][2],rated[item][3]
				xrated=xrated+1
				trated=num2+trated
				hrated=trated/xrated
				hrated=string.format("%.0f", hrated)
				rated[item]= { xrated,hrated,trated }
				SendToUser(curUser, "Rated [ "..xrated.." ] times with RATE: [ "..hrated.." ] - ITEM  ::  "..item)
			else
				rated[item]= { 1,num2,num2 }
				SendToUser(curUser, "Rated [ 1 ] times with RATE: [ "..num2.." ] - ITEM  ::  "..item)
			end
			TopRated = ShowRated(rated, Max4)
			WriteFile(rated, "rated", File4)				
		else
			SendToUser(curUser, "To Rate an Item type "..cmd5.." [ITEMNUMBER] [RATENUMBER] - The Ratenumber can be form 1 - 10")
		end
		return 1

	elseif (string.lower(cmd) == string.lower(cmd6)) then
		local _,_,_,item = string.find( data, "%b<>%s+(%S+)%s+(.*)" )
		if item and item ~= "" then
			if rated[item] then
				local xrated,hrated = rated[item][1],rated[item][2]
				SendToUser(curUser, "Rated [ "..xrated.." ] times with RATE: [ "..hrated.." ] - ITEM  ::  "..item)
			else
				item = string.format('%q', item)
				SendToUser(curUser, "Sorry your Item  "..item..", has not been rated yet.")
			end
		else
			SendToUser(curUser, "-= Top "..Max4.." Rated Items are =-\r\n"..
			TopRated)
		end
		return 1

	elseif (string.lower(cmd) == string.lower(cmd7)) then
		if curUser.bOperator then
			if RegBot then
				statusreg="ON"
			else
				statusreg="OFF"
			end
			if SendOnConnect then
				statussend="ON"
			else
				statussend="OFF"
			end
			if OnlyOP then
				onlyopstatus = "ON"
			else
				onlyopstatus = "OFF"
			end
			SendToUser(curUser, Ophelp)
			SendToUser(curUser, "\t+"..cmd12.." [on]/[off]\tLets you regg the FreshBot. Status : "..statusreg)
			SendToUser(curUser, "\t+"..cmd13.." [on]/[off]\t Lets you send the 5 newest items on connect. Status : "..statussend)
			SendToUser(curUser, "\t+"..cmd14.." [on]/[off]\t Lets Enable/Disable OnlyOP's posting. Status : "..onlyopstatus.."\r\n"..
			" __________________________________________________________________________\r\n")
		else
			SendToUser(curUser, Userhelp)
		end
		return 1

	elseif (string.lower(cmd) == string.lower(cmd8)) then
		local _,_,_,str1 = string.find( data, "%b<>%s+(%S+)%s+(.*)" )
		if str1 and string.len(str1) > 4 then
			local message, xitems = SearchItems(str1)
			if xitems ~= 0 then
				SendToUser(curUser,"\r\n"..
				"	----------------   FreshSearch for : "..str1.."   ----------------\r\n"..
				message.."\r\n"..
				"	----------------   "..xitems.." Items found   ----------------\r\n")
			else
				SendToUser(curUser,"No matches found for : "..str1..".")
			end
		else
			SendToUser(curUser,"To search the Stuff type "..cmd9.." [SearchString]\r\n"..
			"\t\tThe [SearchString] must be at least 5 chars long.")
		end
		return 1

	elseif (string.lower(cmd) == string.lower(cmd9)) then
		local _,_,_,requestitem = string.find( data, "%b<>%s+(%S+)%s+(.*)" )
		if ( requestitem and requestitem~="" and string.len(requestitem)>5 and string.len(requestitem)<100 ) then
			for i = 1,table.getn(requests) do
				local item = requests[i][3]
				if ( item and string.lower(item) == string.lower(requestitem) ) then
					SendToUser(curUser, "Your Item is already requested.\r\n"..
					"\t\t"..i.." - "..time.." Requested by "..name.."  ::  "..item)
					return 1
				end
			end
			table.insert (requests, 1, { os.date("[%d/%m/%y]"),curUser.sName,requestitem } )
			WriteFile(requests, "requests", File7)
			SendToAll(bot, "User: "..curUser.sName.." added a request  ::  "..requestitem)
		else
			SendToUser(curUser, "To add a request, type: "..cmd9.." [ITEM], the ITEM must be longer than 5 and maximal 100 characters long.")
		end
		return 1

	elseif 	(string.lower(cmd) == string.lower(cmd10)) then
		local _,_,args = string.find( data, "%b<>%s+(.*)" )
		var1 = 0
		string.gsub(args, "(%S+)", function (w) var1 = var1 + 1 end)
		if var1 == 3 then
			local _,_,_,num1,num2 = string.find( data, "%b<>%s+(%S+)%s+(%S+)%s+(%S+)%s*" )
			num1 = tonumber (num1)
			num2 = tonumber (num2)
			if ( num1 and num2 and num2 > num1 ) then
				Start = num1
				if num2-num1 >= 100 then
					End = num1 + 100
				else
					End = num2
				end
			end
		elseif var1 == 2 then
			Start = 1
			local _,_,_,num1 = string.find( data, "%b<>%s+(%S+)%s+(%S+)%s*" )
			if tonumber(num1) and tonumber(num1)<100 then
				End = tonumber(num1)
			else
				End = 100
			end
		else
			Start = 1
			End = Max1
		end
		ShowRequest = ReadRequests(requests, Start, End)
		SendToUser(curUser,"\r\n"..
		"\t----------------   Fresh Requests :	Nr. "..Start.." - "..End.."       \t----------------\r\n"..
		ShowRequest.."\r\n"..
		"\t----------------   Fresh Requests :	"..table.getn(requests).."  Items Stored\t----------------\r\n")
		return 1

	elseif (string.lower(cmd) == string.lower(cmd11)) and curUser.bOperator then
		local _,_,_,str1 = string.find( data, "%b<>%s+(%S+)%s+(.*)" )
		if str1 and str1~="" then
			if tonumber(str1) and requests[tonumber(str1)] then
				local str1 = tonumber(str1)
				local time,name,item = requests[str1][1],requests[str1][2],requests[str1][3]
				table.remove (requests, str1)
				WriteFile(requests, "requests", File7)
				SendToUser(curUser, " Request : "..str1.." - "..time.." requested by "..name.."  ::  "..item..", was deleted.")
			elseif tonumber(str1) and requests[tonumber(str1)]==nil then
				SendToUser(curUser, " Request Nr. "..str1.." is not in list.")
			else
				for i = 1, table.getn(requests) do
					local time,name,item = requests[i][1],requests[i][2],requests[i][3]
					if item == str1 then
						table.remove (requests, i)
						WriteFile(requests, "requests", File7)
						SendToUser(curUser, " Request : "..i.." - "..time.." requested by "..name.."  ::  "..item..", was deleted.")
						return 1
					end
				end
				str1 = string.format('%q', str1)
				SendToUser(curUser, " Request "..str1.." is not in list.")
			end
		else
			SendToUser(curUser, " To delete a Request, type: "..cmd11.." [RequestNUMBER]/[RequestNAME].")
		end
		return 1

	elseif (string.lower(cmd) == string.lower(cmd12)) and curUser.bOperator then
		local _,_,_,onoff = string.find( data,"%b<>%s+(%S+)%s+(%S+)%s*")
		if onoff and string.lower(onoff)=="on" then
			frmHub:RegBot(bot)
			SendToUser(curUser, "Bot "..bot.." has been regged.")
		elseif onoff and string.lower(onoff)=="off" then
			frmHub:UnregBot(bot)
			SendToUser(curUser, "Bot "..bot.." has been unregged.")
		else
			SendToUser(curUser, "To Reg/Unreg the bot type : "..cmd12.." [on]/[off].")
		end
		return 1

	elseif (string.lower(cmd) == string.lower(cmd13)) and curUser.bOperator then
		local _,_,_,onoff = string.find( data,"%b<>%s+(%S+)%s+(%S+)%s*")
		if onoff and string.lower(onoff)=="on" then
			SendOnConnect=1
			SendToUser(curUser, "The 5 newest items will now be sent on connect.")
		elseif onoff and string.lower(onoff)=="off" then
			SendOnConnect=nil
			SendToUser(curUser, "No items are now sent on connect.")
		else
			SendToUser(curUser, "To Send/NotSend the 5 Newest Items on connect type : "..cmd13.." [on]/[off].")
		end
		return 1

	elseif (string.lower(cmd) == string.lower(cmd14)) and curUser.bOperator then
		local _,_,_,onoff = string.find( data,"%b<>%s+(%S+)%s+(%S+)%s*")
		if onoff and string.lower(onoff)=="on" then
			OnlyOP=1
			SendToUser(curUser, "Only OP'S will be able to post new stuff.")
		elseif onoff and string.lower(onoff)=="off" then
			OnlyOP=nil
			SendToUser(curUser, "Everybody will be able to post new stuff.")
		else
			SendToUser(curUser, "To Enable/Disable OnlyOP's posting type : "..cmd14.." [on]/[off].")
		end
		return 1
		
	end		
end
--------------------------------------------------------------------------------------------------------------------------------------------
function AddItem(str1,str2,str3,str4)
	for i = 1,table.getn(newstuff) do
		if ( string.lower(newstuff[i][4]) == string.lower(str4) ) then
			SendToUser(str3, " Sorry your item  "..string.format('%q', str4).."  has already been added.\r\n"..
			"\t\t"..i.." - "..newstuff[i][1].." "..newstuff[i][2].." added by "..newstuff[i][3].."  ::  "..newstuff[i][4])
			return 1
		end
	end
	if posters[str3.sName]==nil then
		posters[str3.sName]=1
		WriteFile(posters, "posters", File2)
		TopPosters = ShowPosters(posters, Max3)
	else
		posters[str3.sName]=posters[str3.sName]+1
		WriteFile(posters, "posters", File2)
		TopPosters = ShowPosters(posters, Max3)
	end
	table.insert ( newstuff, 1, { str1,str2,str3.sName,str4 } )
	WriteFile(newstuff, "newstuff", File1)
	TopItems2 = ReadTable(newstuff, 1, Max2)
	TopPosters = ShowPosters(posters, Max3)
	WriteFile(posters, "posters", File2)
	SendToAll(bot," - "..newstuff[1][1].." "..newstuff[1][2].." added by "..newstuff[1][3].."  ::  "..newstuff[1][4])
end
--------------------------------------------------------------------------------------------------------------------------------------------
function SendToUser(curUser, message)
	if HowToSend == "PM" then
		curUser:SendPM(bot, message)
	elseif HowToSend == "Main" then
		curUser:SendData(bot, message)
	end
end
--------------------------------------------------------------------------------------------------------------------------------------------
function WriteFile(table, tablename, file)
	local handle = io.open("Fresh-Files/"..file, "w")
	Serialize(table, tablename, handle)
  	handle:close()
end
--------------------------------------------------------------------------------------------------------------------------------------------
function Serialize(tTable, sTableName, hFile, sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n" );
	for key, value in tTable do
		local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
		if(type(value) == "table") then
			Serialize(value, sKey, hFile, sTab.."\t");
		else
			local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
			hFile:write(sTab.."\t"..sKey.." = "..sValue);
		end
		hFile:write(",\n");
	end
	hFile:write(sTab.."}");
end
--------------------------------------------------------------------------------------------------------------------------------------------
function ReadTable(table, Start, End)
	local msg ="\r\n"
	for i = Start,End do
		if table[i] then
			msg = msg.."	"..i.." - "..newstuff[i][1].." "..newstuff[i][2].." added by "..newstuff[i][3].."  ::  "..newstuff[i][4].."\r\n"
		end
	end
	return msg
end
--------------------------------------------------------------------------------------------------------------------------------------------
function ReadRequests(table, Start, End)
	local msg ="\r\n"
	for i = Start,End do
		if table[i] then
			msg = msg.."	"..i.." - "..table[i][1].." Requested by "..table[i][2].."  ::  "..table[i][3].."\r\n"
		end
	end
	return msg
end
--------------------------------------------------------------------------------------------------------------------------------------------
function SearchItems(sstring)
	local var1 = 0
	local msg ="\r\n"
	for i = 1,table.getn(newstuff) do
		if ( string.find( string.lower(newstuff[i][4]), string.lower(sstring) ) ) then
			var1 = var1 + 1
			msg = msg.."	"..i.." - "..newstuff[i][1].." "..newstuff[i][2].." added by "..newstuff[i][3].."  ::  "..newstuff[i][4].."\r\n"
		end
	end
	return msg, var1
end
--------------------------------------------------------------------------------------------------------------------------------------------
function ShowTypes(type1)
	local var1 = 0
	local msg ="\r\n"
	for i = 1,table.getn(newstuff) do
		if string.lower(newstuff[i][2]) == string.lower(type1) then
			if var1 == Max5 then
				break
			else
				var1 = var1 + 1
				msg = msg.."	"..i.." - "..newstuff[i][1].." "..newstuff[i][2].." added by "..newstuff[i][3].."  ::  "..newstuff[i][4].."\r\n"
			end
		end
	end
	return msg
end
--------------------------------------------------------------------------------------------------------------------------------------------
function ShowPosters(_table, Max)
	local TCopy = {}
	for i,v in _table do
		table.insert( TCopy, { tonumber(v),i } )
	end
	table.sort( TCopy, function(a, b) return (a[1] > b[1]) end)
	local msg ="\r\n"
	for i = 1,Max do
		if TCopy[i] then
			msg = msg.."\t\t# "..i.." - "..TCopy[i][2].." added "..TCopy[i][1].." Items.\r\n"
		end
	end
	local TCopy = {}
	return msg
end
--------------------------------------------------------------------------------------------------------------------------------------------
function ShowRated(_table, Max)
	local TCopy={}
	for i,v in _table do
		table.insert( TCopy, { tonumber(_table[i][1]), _table[i][2], i } )
	end
	table.sort( TCopy, function(a, b) return (a[1] > b[1]) end)
	local msg ="\r\n"
	for i = 1,Max do	
		if TCopy[i] then
			msg = msg.."	# "..i.." - Rated [ "..TCopy[i][1].." ] times with RATE: [ "..TCopy[i][2].." ] - ITEM :: "..TCopy[i][3].."\r\n"
		end
	end
	local TCopy={}
	return msg
end
--------------------------------------------------------------------------------------------------------------------------------------------
function ReadHelp(file)
	local handle = io.open("Fresh-Files/"..file, "r")
	local contents = string.gsub(handle:read("*a"), string.char(10), "\r\n")
	handle:close()
	return contents
end
--------------------------------------------------------------------------------------------------------------------------------------------