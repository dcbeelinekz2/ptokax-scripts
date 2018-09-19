-- requested by witch
-- unreg users upload blocker by jiten 
-- modded to LUA 5 by jiten from
-- 100% Blocker by chill
-- Table Load and Save (added by nErBoS)


sBot = "[fow]-Leech"

cmd1 = "!add"
cmd2 = "!del"
cmd3 = "!show"

BlockedNicks = {}
fBlock = "block.dat"

function Main()
	frmHub:RegBot(sBot)
	LoadFromFile(fBlock)
end

function OnExit()
	SaveToFile(fBlock , BlockedNicks , "BlockedNicks")
end

function ConnectToMeArrival(curUser,data)
	if BlockedNicks[string.lower(curUser.sName)] then
		curUser:SendData("*** Unreg users are not authorized to download from this nick.")
		return 1
	end
	local _,_,conNick = string.find(data,"(%S+)|$")
	if BlockedNicks[string.lower(conNick)] then
		if not curUser.bRegistered then
			curUser:SendData("*** The user "..conNick.." you are trying to download from is not authorized to upload to Unreg Users.")
			return 1
		else
		end
	end 
	local _,_,conNick = string.find(string.sub(data,14,string.len(data)),"^(%S+)")
	if BlockedNicks[string.lower(conNick)] then
		if not curUser.bRegistered then
			curUser:SendData("*** The user "..conNick.." you are trying to download from is not authorized to upload to Unreg Users.")
			return 1
		else
		end
	end
end

-- RevConnectToMeArrival = ConnectToMeArrival

function ChatArrival(curUser,data)
	if curUser.bOperator then
		data = string.sub(data,1,string.len(data)-1)
		local _,_,cmd = string.find(data,"%b<>%s+(%S+)")
		local _,_,nick = string.find(data,"%b<>%s+%S+%s+(%S+)")
		if cmd and cmd == cmd2 and nick then
			if BlockedNicks[string.lower(nick)] then
				BlockedNicks[string.lower(nick)] = nil
				curUser:SendPM(sBot, nick.." is now unblocked. Now he can upload to anyone.")
				return 1
			end
		elseif cmd and cmd == cmd1 then
			if BlockedNicks[string.lower(nick)] == 1 then
				curUser:SendPM(sBot, nick.." is already blocked. Use !del <nick> to unblock this user.")
				return 1 
			else
				BlockedNicks[string.lower(nick)] = curUser.sName
				curUser:SendPM(sBot, nick.." is now blocked. Now he only uploads to registered users.") 
				return 1
			end
			OnExit()
			return 1  -- TELLS THE HUB TO STOP PROCESSING THE DATA
		elseif (cmd and cmd == cmd3 and curUser.bOperator) then
			local sTmp,aux,nick = "Upload Blocker Users in this HUB:\r\n\r\n"
			for nick, aux in BlockedNicks do
				sTmp = sTmp.."User:-->> "..nick.."\t Was Blocked by: "..aux.."\r\n"
			end
			curUser:SendPM(sBot, sTmp)
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