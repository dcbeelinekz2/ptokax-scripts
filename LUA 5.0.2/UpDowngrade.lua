--/--------------------------------------------------------------------------------------------
-- Upgrade and Downgrade v1.0 by jiten
-- Small optimization in the error msgs
--/--------------------------------------------------------------------------------------------

sBot = frmHub:GetHubBotName()

-- Profiles allowed to use !upgrade command ([x] = 1 (allowed) or 0 (not))
AllowedProfiles = { [-1] = 0, [1] = 1, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [0] = 1, }

-- Profile order (higher value means has more power)
Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [4] = 5, [0] = 6, [5] = 7, }

ChatArrival = function(user,data)
	local data = string.sub(data, 1, -2)
	local s,e,cmd = string.find(data,"%b<>%s+[%!%?%+%#](%S+)")
	if cmd then
		local tCmds = {
		["upgrade"]	= function(user,data)
			s,e,nick,number = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%d+)") 
			if nick == nil or number == nil then
				user:SendData(sBot,"*** Syntax Error: Type !upgrade <nick> <profile number>")
			elseif nick == user.sName then
				user:SendData(sBot,"*** Error: You can't upgrade yourself.")
			else
				for i, profile in GetProfiles() do
					if Levels[user.iProfile] >= Levels[GetItemByName(nick).iProfile] then cUp = 1
						if string.lower(number) == string.lower(GetProfileIdx(profile)) then pExists = 1 
							if frmHub:isNickRegged(nick) then
								AddRegUser(nick, frmHub:GetUserPassword(nick), number) isRegged = 1
								user:SendData(sBot,nick.." was successfully upgraded by "..user.sName.." to "..GetProfileName(number).." status.")
								SendPmToNick(nick,sBot,user.sName.." upgraded your status to "..GetProfileName(number).." profile!");
								break
							end
						end
					end
				end
				if cUp == nil then
					user:SendData(sBot,"*** Error: You can't upgrade profiles higher than yours.")
				elseif pExists == nil then
					user:SendData(sBot,"*** Error: That profile doesn't exist.")
				elseif isRegged == nil then
					user:SendData(sBot,"*** Error: You can't upgrade unreg users.")
				end
			end
		end,
		}
		if tCmds[cmd] and AllowedProfiles[user.iProfile] == 1 then
			return tCmds[cmd](user,data), 1
		else
			return user:SendData(sBot,"*** Error: You are not allowed to use this command."), 1
		end
	end
end
-----------------------------------------------------------------------------------------------