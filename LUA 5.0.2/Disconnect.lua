-- Disconnect v1.0 by jiten (6/13/2005)
-- with: Immune Profiles/Allowed Profiles
-- based on Kick & Warn 1.0

sBot = frmHub:GetHubBotName() -- bot name

AllowedProfiles = {
	[-1] = 0, -- unreg
	[0] = 1, -- master
	[1] = 1, -- operator
	[2] = 0, -- vip
	[3] = 0, -- reg
	[4] = 1, -- moderator
	[5] = 1, -- founder
}

ImmuneProfiles = {
	[-1] = 0, -- unreg
	[0] = 1, -- master
	[1] = 0, -- operator
	[2] = 0, -- vip
	[3] = 0, -- reg
	[4] = 0, -- moderator
	[5] = 1, -- founder
}

function ChatArrival (user,data) 
	local data=string.sub(data,1,-2) 
	local s,e,cmd = string.find ( data, "%b<>%s+[%!%?%+%#](%S+)" )
	if cmd then
		local s,e,usr,reason = string.find( data, "%b<>%s+%S+%s+(%S+)%s*(.*)" )
		local tCmds = { 
		["disc"] =	function(user,data)
			if AllowedProfiles[user.iProfile] == 1 then
				if usr == nil or reason == nil then
					user:SendData(sBot, "*** Syntax Error: Type !disc <nickname> <reason>")
				else
					local victim = GetItemByName(usr)
					if (victim == nil) then
						user:SendData(sBot, "The user "..usr.." is not online.")
					else
						if ImmuneProfiles[victim.iProfile] ~= 1 then
							victim:SendPM(sBot, "You are being disconnected because: "..reason)
							victim:Disconnect()
						else
							user:SendData(sBot,"*** Error: You can't disconnect Immune Profile Users.")
							return 0
						end
					end
				end
			else
				user:SendData(sBot,"*** Error: You are not allowed to use this command.")
			end
		end,
		}
		if tCmds[cmd] then 
			return tCmds[cmd](user,data), 1
		end
	end
end