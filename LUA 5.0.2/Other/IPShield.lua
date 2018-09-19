-------------------------------------------------------------------------------------------
-- Lua 5 version by Dessamator
-- File handling fixed by jiten
-- IP-Shield / Version: 1.0 / By: NightLitch / 2004-03-09
-------------------------------------------------------------------------------------------
-- Example to add a range:
-- !addrange 192.168.0.1-192.168.0.255 Local
-------------------------------------------------------------------------------------------
BotName = "-IP-Shield-"
Prefix = "!"
-------------------------------------------------------------------------------------------
AllowRange = {}
AllowFile = "Ranges/Ranges.dat"
-------------------------------------------------------------------------------------------
function Main()
	frmHub:RegBot(BotName)
	if loadfile(AllowFile) then dofile(AllowFile) end
end
-------------------------------------------------------------------------------------------
function ComputeIP(curIP)
	local _,_,a,b,c,d = string.find(curIP, "(%d+).(%d+).(%d+).(%d+)")
	return a*16777216 + b*65536 + c*256 + d
end
-------------------------------------------------------------------------------------------
function GetRange(ip,table)
	local _,_,a,b,c,d = string.find(ip, "(%d*).(%d*).(%d*).(%d*)")
	if ( tonumber(a) and tonumber(b) and tonumber(c) and tonumber(d) ) then
		local uip = ComputeIP(ip)
		if uip then
			local c = ""
			for r,i in table do 
				local _,_,range1,range2 = string.find(r, "(.*)-(.*)")
				range1 = ComputeIP(range1)
				range2 = ComputeIP(range2)
				if uip>=range1 and uip<=range2 then
					c = "1"
					return 1,r
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------
function NewUserConnected(curUser,data)
	curUser:SendData(BotName,"Running IP-Shield 1.0 By: NightLitch")
	local Allow,Range,Network = GetRange(curUser.sIP,AllowRange),""
	if Allow==1 then 
		curUser:SendData(BotName,"Your IP is Allowed here...")
		return 1
	else
		curUser:SendData(BotName,"Your IP is not Allowed here...")
		curUser:Disconnect()
		return 1
	end
end
-------------------------------------------------------------------------------------------
function ToArrival(curUser, data)
	local s,e,to,from,text = string.find(data, "%$To:%s(%S+)%sFrom:%s(%S+)%s$(.*)$")
	if to == BotName then
		data = text
		data = string.sub(data,1,string.len(data)-1)
		if (GetCom(curUser,data) == 1) then
			return 0
		else
			return 0
		end
	end
end
-------------------------------------------------------------------------------------------
function GetCom(curUser,data)
	local _,_,cmd = string.find(data,"^%b<>%s+%"..Prefix.."(%S+)")
	if cmd then
		if IPCommand[cmd] and curUser.iProfile==0 then
			local Com = IPCommand[cmd](curUser,data)
			return 1
		end
	end
end
-------------------------------------------------------------------------------------------
IPCommand = {
["addrange"] =	function(curUser,data) 
			local _,_,range,network = string.find(data,"%b<>%s+%S+%s+(%S+-%S+)%s+(%S+)")
			if range==nil or network==nil then
				curUser:SendPM(BotName,"Syntax: "..Prefix.."addrange <range> <network>")
				return 1
			end
			if AllowRange[range] then
				curUser:SendPM(BotName,range.." is already in Allow File...")
				return 1
			end
			AllowRange[range] = {["NETWORK"] = network,["TAG"] = {"["..network.."]"}}
			SaveToFile(AllowFile , AllowRange , "AllowRange")
			curUser:SendPM(BotName,"Range: ( "..range.." ) - Network: "..network.." is added to Allow File")
			return 1
		end,
["delrange"] =	function(curUser,data)
			local _,_,range = string.find(data,"%b<>%s+%S+%s+(%S+-%S+)")
			if range==nil then
				curUser:SendPM(BotName,"Syntax: "..Prefix.."delrange <range>")
				return 1
			end
			if AllowRange[range] then
				AllowRange[range] = nil
				SaveToFile(AllowFile , AllowRange , "AllowRange")
				curUser:SendPM(BotName,"Range: ( "..range.." ) is deleted from Allow File.")
				return 1
			else
				curUser:SendPM(BotName,"Range: ( "..range.." ) is not found in Allow File.")
				return 1
			end
		end,
["show"] =	function(curUser,data)
			local Network,border = "",string.rep("-",15)..string.rep("=",100)..string.rep("-",15)
			local Msg = "\r\n\r\n"
			Msg = Msg .. "\r\n	Allow Range's "
			Msg = Msg .. "\r\n "..border..""
			Msg = Msg .. "\r\n	    Network			Range	"
			Msg = Msg .. "\r\n"
			local Nr = 0
			for Range,Index in AllowRange do
				local Network = ""
				local ISP = ""
				local tmp = AllowRange[Range]
				if tmp then
					Network = tmp["NETWORK"]
					Nr = Nr +1
					Msg = Msg .. "\r\n	 "..Network.." "..string.rep("\t", 45/(8+string.len(Network))).." "..Range.." "
				end
			end
			Msg = Msg .. "\r\n "
			Msg = Msg .. "\r\n	Total "..Nr.." Range(s)"
			Msg = Msg .. "\r\n "..border..""
			curUser:SendPM(BotName,Msg)
			return 1
		end,
["findip"] =	function(curUser,data)
			local _,_,GetIP = string.find(data,"%b<>%s+%S+%s+(%S+)")
			if GetIP==nil then
				curUser:SendPM(BotName,"Syntax: "..Prefix.."findip <IP>")
				return 1
			end
			if loadfile(AllowFile) then dofile(AllowFile) end
			local Msg = "\r\n\r\n"
			Msg = Msg .. "\r\n	Result on IP ( "..GetIP.." ) :\r\n"
			local Allow,Range = GetRange(GetIP,AllowRange)
			local Network = ""
			if Allow==1 then
				local tmp = AllowRange[Range]
				if tmp then
					Network = tmp["NETWORK"]
				end
				Msg = Msg .. "\r\n	Range: "..Range..""
				Msg = Msg .. "\r\n	Network: "..Network.." \r\n\r\n"
				curUser:SendPM(BotName,Msg)
			else
				curUser:SendPM(BotName,"Syntax: IP not found...")
				return 1
			end
		end,
["whois"] =	function(curUser,data)
			local _,_,_,str1 = string.find( data,"%b<>%s+(%S+)%s+(%S+)%s*")
			if (str1 == nil or str1 == "") then 
				curUser:SendPM(BotName,"Syntax: "..Prefix.."whois <nick/ip>")
				return 1
			end
			if str1 and GetItemByName(str1) then
				str1 = GetItemByName(str1).sIP
			elseif str1 and not GetItemByName(str1) then
				local _,_,a,b,c,d = string.find(str1,"(%d*).(%d*).(%d*).(%d*)")
				if (a == "" or b == "" or c == "" or d == "") then
					curUser:SendPM(BotName,"Syntax: "..Prefix.."whois <nick/ip>")
					return 1
				end
			else
				curUser:SendPM(BotName,"Syntax: "..Prefix.."whois <nick/ip>")
				return 1
			end
			local socket,err,Database = "","",""
			Database = "RIPE"
			socket, err = connect("whois.ripe.net", 43)
			curUser:SendPM(BotName,"Checking the "..Database.."-Database for  "..str1.."  ...")
			local msg = "\r\n"
			if not err then
				local line = ""
				socket:timeout(2)
				err = socket:send(str1..string.char(13, 10))
				while not err do
					line, err = socket:receive("*l")
					if (line ~= "" and string.sub(line, 1, 1) ~= "%" and string.sub(line,string.len(line),string.len(line)) ~= string.char(124)) then
						msg = msg.."\t"..line.."\r\n"
					end
				end socket:close()
			end
			msg = msg.."\r\n\tDone...\r\n"
			curUser:SendPM(BotName,"\r\n"..msg)
		end,
["help"] =	function(curUser,data)
			local Msg,border = "\r\n\r\n",string.rep("-",15)..string.rep("=",100)..string.rep("-",15)
			Msg = Msg .. "\r\n				 IP-Shield Command Help "
			Msg = Msg .. "\r\n "..border..""
			Msg = Msg .. "\r\n "
			Msg = Msg .. "\r\n	"..Prefix.."help					-	Show this Help"
			Msg = Msg .. "\r\n	"..Prefix.."addrange <range> <network> 	-	Add Range"
			Msg = Msg .. "\r\n	"..Prefix.."delrange <range> 			-	Del Range"
			Msg = Msg .. "\r\n	"..Prefix.."show					-	Show Ranges "
			Msg = Msg .. "\r\n	"..Prefix.."findip <ip>				-	Find IP in Range File"
			Msg = Msg .. "\r\n	"..Prefix.."whois <nick/ip>				-	Whois RIPE.NET Database"
			Msg = Msg .. "\r\n "
			Msg = Msg .. "\r\n "..border..""
			Msg = Msg .. "\r\n\r\n "
			curUser:SendPM(BotName,Msg)
			return 1
		end,
}
-------------------------------------------------------------------------------------------
function Serialize(tTable, sTableName, hFile, sTab)
	assert(tTable, "tTable equals nil");
	assert(sTableName, "sTableName equals nil");
	assert(hFile, "hFile equals nil");

	assert(type(tTable) == "table", "tTable must be a table!");
	assert(type(sTableName) == "string", "sTableName must be a string!");

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
-------------------------------------------------------------------------------------------
function SaveToFile(file , table , tablename)
	local hFile = io.open(file, "w+");
	Serialize(table, tablename, hFile);
	hFile:close();
end
-------------------------------------------------------------------------------------------
-- By: NightLitch 2004-03-09