-- requested by witch
-- unreg users upload blocker by jiten 
-- ideas from 100% Blocker by chill
-- thanks to [UK]Madman for the hint

sBot = frmHub:GetHubBotName()

BlockedNicks = {}
fBlock = "block.dat"

function Main()
	if loadfile(fBlock) then dofile(fBlock) end
end

function OnExit()
	local f = io.open(fBlock,"w+")
	f:write(Serialize(BlockedNicks, "BlockedNicks"))
	f:flush()
	f:close()
end

function ChatArrival(curUser,data)
	if curUser.bOperator then
		data = string.sub(data,1,-2)
		local s,e,cmd = string.find ( data, "%b<>%s+[%!%?%+%#](%S+)" )
		if cmd then
			local tCmds = {
			["del"] =	function(curUser,data)
					local s,e,nick = string.find ( data, "%b<>%s+%S+%s+(%S+)" )
					if BlockedNicks[string.lower(nick)] then
						BlockedNicks[string.lower(nick)] = nil
						curUser:SendPM(sBot, nick.." is now unblocked. Now he can upload to anyone.")
					end
				end,
			["add"] =	function(curUser,data)
					local s,e,nick = string.find ( data, "%b<>%s+%S+%s+(%S+)" )
					if BlockedNicks[string.lower(nick)] == 1 then
						curUser:SendPM(sBot, nick.." is already blocked. Use !del <nick> to unblock this user.")
					else
						BlockedNicks[string.lower(nick)] = curUser.sName
						curUser:SendPM(sBot, nick.." is now blocked. Now he only uploads to registered users.") 
					end
					OnExit()
				end,
			["show"] =	function (curUser,data)
					local sTmp,aux,nick = "Upload Blocker Users in this HUB:\r\n\r\n"
					for nick, aux in BlockedNicks do
						sTmp = sTmp.."User:-->> "..nick.."\t Was Blocked by: "..aux.."\r\n"
					end
					curUser:SendPM(sBot, sTmp)
				end,
			}
			if tCmds[cmd] then 
				return tCmds[cmd](curUser,data), 1
			end
		end
	end
end

ToArrival = ChatArrival

function ConnectToMeArrival(curUser, data)
	data = string.sub(data,1,-2);
	local s,e,nick = string.find(data,"%S+%s+(%S+)");
	nick = GetItemByName(nick);
	if (nick == nil) then return 1; end
	if BlockedNicks[string.lower(nick.sName)] then
		if not curUser.bRegistered then
			curUser:SendData("*** The user "..nick.sName.." you are trying to download from is not authorized to upload to Unreg Users.")
			return 1
		end
	end
end

function RevConnectToMeArrival(curUser,data)
	data = string.sub(data,1,-2);
	local s,e,nick = string.find(data,"%S+%s+%S+%s+(%S+)");
	nick = GetItemByName(nick);
	if (curUser == nil) then return 1; end
	if BlockedNicks[string.lower(nick.sName)] then
		if not curUser.bRegistered then
			curUser:SendData("*** The user "..nick.sName.." you are trying to download from is not authorized to upload to Unreg Users.")
			return 1
		end
	end
end

SearchArrival = ConnectToMeArrival

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
