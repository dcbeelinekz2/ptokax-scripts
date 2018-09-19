--100% Blocker by chill
-- converted to LUA 5 by jiten
--Table Load and Save (added by nErBoS)


sBot = "[fow]-Leech"

cmd1 = "!block"
cmd2 = "!unblock"
cmd3 = "!laatzien"


BlockedNicks = {}
fBlock = "block.dat"
OpChatName = frmHub:GetOpChatName()	--Use this line for inbuilt Px opchat


--## Configuration ##--

uLaterPtokax = 0	-- Choose 0 if you are using Ptokax Version 0.3.3.0 or higher
			-- Choose 1 if you are using Ptokax Version lower then 0.3.3.0

--## END ##--

function Main()
	frmHub:RegBot(sBot)
	LoadFromFile(fBlock)
end

function OnExit()
	SaveToFile(fBlock , BlockedNicks , "BlockedNicks")
end

BlockTriggs = {
	["$Rev"] = 1,
	["$Con"] = 2,
}

function ConnectToMeArrival(curUser,data)
	local str1 = string.sub(data,1,4)
		if BlockTriggs[str1] then
		if BlockedNicks[string.lower(curUser.sName)] then
			curUser:SendData("*** You are not authorized to download.")
			return 1
		else if BlockTriggs[str1] == 1 then
			local _,_,conNick = string.find(data,"(%S+)|$")
			if BlockedNicks[string.lower(conNick)] then
				curUser:SendData("*** The user "..conNick.." you are trying to download from is not authorized to upload.")
				return 1
			end
		else if BlockTriggs[str1] == 2 then
			local _,_,conNick = string.find(string.sub(data,14,string.len(data)),"^(%S+)")
			if BlockedNicks[string.lower(conNick)] then
				curUser:SendData("*** The user "..conNick.." you are trying to download from is not authorized to upload.")
				return 1
			end
		end
		end
		end
	end
end

RevConnectToMeArrival = ConnectToMeArrival

function ChatArrival(curUser,data)
	if curUser.bOperator then
		data = string.sub(data,1,string.len(data)-1)
		local _,_,cmd = string.find(data,"%b<>%s+(%S+)")
		local _,_,nick = string.find(data,"%b<>%s+%S+%s+(%S+)")
		if cmd and cmd == cmd2 and nick then
			if BlockedNicks[string.lower(nick)] then
				BlockedNicks[string.lower(nick)] = nil
				SendPmToOps(OpChatName, nick.." is now unblocked.")
				return 1
			end
		elseif cmd and cmd == cmd1 then
			if BlockedNicks[string.lower(nick)] == 1 then
				curUser:SendPM(sBot, nick.." is already blocked. Use !unblock <nick> to unblock this user.")
				return 1 
			else
				BlockedNicks[string.lower(nick)] = curUser.sName
				SendPmToOps(OpChatName, nick.." is now blocked.") 
				return 1
			end
			if (uLaterPtokax == 1) then
				OnExit()
			end
				
			return 1  -- TELLS THE HUB TO STOP PROCESSING THE DATA
		elseif (cmd and cmd == cmd3 and curUser.bOperator) then
			local sTmp,aux,nick = "Users Blocked in this HUB:\r\n\r\n"
			for nick, aux in BlockedNicks do
				sTmp = sTmp.."User:-->> "..nick.."\t Was Blocked by: "..aux.."\r\n"
			end
			--curUser:SendPM(sBot, sTmp)
			SendPmToOps(OpChatName, sTmp) 
			return 1		
		end
	end
end

ToArrival = ChatArrival

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