--/---------------------------------------------
-- Get Password v1.0 by jiten (6/27/2005)
--/---------------------------------------------

sBot = frmHub:GetHubBotName()
tPrefixes = {}
AllowedProfiles = {
	[-1] = 0, -- unreg
	[0] = 1, -- master
	[1] = 1, -- operator
	[2] = 0, -- vip
	[3] = 0, -- reg
	[4] = 1, -- moderator
	[5] = 1, -- founder
}

Main = function()
	for a,b in pairs(frmHub:GetPrefixes()) do tPrefixes[b] = 1 end
end

ChatArrival = function(user,data)
	local data = string.sub(data,1,-2)
	local s,e,sPrefix,cmd = string.find(data,"%b<>%s*(%S)(%S+)")
	if sPrefix and tPrefixes[sPrefix] then
		local tCmds = {
		["getpass"] =	
			function(user,data)
				if AllowedProfiles[user.iProfile] == 1 then
					local s,e,nick = string.find(data,"%b<>%s+%S+%s+(%S+)")
					if nick then
						if frmHub:GetUserPassword(nick) then
							user:SendData(sBot,"Nick: "..nick..", Password: "..frmHub:GetUserPassword(nick))
						else
							user:SendData(sBot,"*** Error: "..nick.." isn't registered.")
						end
					else
						user:SendData(sBot,"*** Syntax Error: Type !getpass <nick>")
					end
				else
					user:SendData(sBot,"*** Error: You are not allowed to use this command.")
				end
			end,
		}
		if tCmds[cmd] then return tCmds[cmd](user,data),1 end
	end
end