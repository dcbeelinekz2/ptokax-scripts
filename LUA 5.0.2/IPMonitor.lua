--/------------------------------------------------------------
-- IP Monitoring v1.0 by jiten (5/27/2005)
--/------------------------------------------------------------

sBot = frmHub:GetHubBotName()
wIP = {} IPFile = "IP.tbl"

Main = function()
	if loadfile(IPFile) then dofile(IPFile) end
end

ChatArrival = function(sUser,sData)
	local sData = string.sub(sData, 1, -2)
	local s,e,cmd = string.find(sData,"%b<>%s+[%!%?%+%#](%S+)")
	if cmd then
		local tCmds = {
		["online"] =	function(sUser,sData)
					local s,e,IP,reason = string.find(sData,"%b<>%s+%S+%s+(%S+)%s+(.*)")
					if (IP == nil or reason == nil) then
						sUser:SendData(sBot, "*** Syntax Error: Type !online <IP> <reason>")
					else
						local _,_,a,b,c,d = string.find(IP,"(%d*).(%d*).(%d*).(%d*)")
						if not (a == "" or b == "" or c == "" or d == "") then
							if wIP[IP] == nil then
								wIP[IP] = {} wIP[IP] = reason
								sUser:SendData(sBot,IP.." is being sucessfuly monitored.") SaveToFile(IPFile,wIP,"wIP")
							elseif wIP[IP] ~= nil then
								sUser:SendData(sBot, "*** Error: "..IP.." is already being monitored.")
							end
						else
							sUser:SendData(sBot, "*** Syntax Error: Type !online <IP> <reason>")
						end
					end
				end,
		["ronline"] =	function(sUser,sData)
					local s,e,IP = string.find(sData,"%b<>%s+%S+%s+(%S+)")
					local _,_,a,b,c,d = string.find(IP,"(%d*).(%d*).(%d*).(%d*)")
					if (IP == nil) or (a == "" or b == "" or c == "" or d == "") then
						sUser:SendData(sBot, "*** Syntax Error: Type !ronline <IP>")
					elseif wIP[IP] ~= nil then
						wIP[IP] = nil
						sUser:SendData(sBot,IP.." is no longer being monitored.") SaveToFile(IPFile,wIP,"wIP")
					elseif wIP[IP] == nil then
						sUser:SendData(sBot,"*** Error: "..IP.." isn't being monitored.")
					end
				end,
		["sonline"] =	function(sUser,sData)
					if next(wIP) then
						local msg = "\r\n\r\n".."\t»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«".."\r\n" 
						msg = msg.."\t\tMonitored IPs:\tReason:\r\n" 
						msg = msg.."\t»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«".."\r\n" 
						local i,v for i, v in wIP do msg = msg.."\t\t* "..i.."\t"..v.."\r\n" end 
						sUser:SendData(sBot,msg) 
					else
						sUser:SendData(sBot,"*** Error: The IP monitoring list is empty.")
					end
				end,
		}
		if tCmds[cmd] and sUser.bOperator then return tCmds[cmd](sUser,sData),1 end
	end
end

NewUserConnected = function(sUser,sData)
	for i,v in wIP do
		if i == sUser.sIP then SendPmToOps(frmHub:GetOpChatName(),os.date().." - "..sUser.sName.." is being monitored because: "..v)end
	end
	if sUser.bOperator then 
		sUser:SendData("$UserCommand 1 3 Online\\Monitor IP$<%[mynick]> !online %[line:IP] %[line:Reason]&#124;|")
		sUser:SendData("$UserCommand 1 3 Online\\Remove IP$<%[mynick]> !ronline %[line:IP]&#124;|")
		sUser:SendData("$UserCommand 1 3 Online\\Show IPs$<%[mynick]> !sonline&#124;|")
	end
end

OpConnected = NewUserConnected

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

SaveToFile = function(file,table,tablename)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end