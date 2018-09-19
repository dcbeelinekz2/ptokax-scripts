--/----------------------------------------------------------------------------
-- Password Bot by ??
-- Lua 5 version by jiten (12/6/2005)
--/----------------------------------------------------------------------------

-- Set a Bot Name
sBot = "Password"

-- Commands
sCOM1 = "mypass"
sCOM2 = "repass"
sCOM3 = "changepass"
sCOM4 = "getpass"
sCOM5 = "passwordlist"

AllowedProfiles = { -- Set 1 To Allow Command sCOM 3-5
	[0] = 1,	-- Masters
	[1] = 0,	-- Operators
	[2] = 0,	-- VIP
	[3] = 0,	-- Reg
	[4] = 0,	-- Moderator
	[5] = 1,	-- NetFounder
}
-----------------------------------------------------------------------------------
tPassword = {}; tProfiles = {}; tPrefixes = {};
-----------------------------------------------------------------------------------
function Main()
	for a,b in pairs(frmHub:GetPrefixes()) do tPrefixes[b] = 1 end
	for i,v in GetProfiles() do
		tProfiles[v] = GetProfileIdx(v)
		for a,b in GetUsersByProfile(v) do
			tPassword[b] = { Profile = GetUserProfile(b), Password = frmHub:GetUserPassword(b) }
		end
	end
end
-----------------------------------------------------------------------------------
ChatArrival = function(user,sData)
	local sData = string.sub(sData,1,-2) 
	local s,e,sPrefix,cmd = string.find(sData,"%b<>%s*(%S)(%S+)")
	if sPrefix and tPrefixes[sPrefix] then
		local cmd = string.lower(cmd)
		local tCmds = {
			[sCOM1] = {
			function(user,data)
				if user.bRegistered then
					if (tPassword[user.sName]) then
						user:SendData(sBot,"Your password is: \""..tPassword[user.sName].Password.."\". Keep it in a safe place!")
					else
						user:SendData(sBot,"*** Error: For some reason you could not be found!")
					end
				else
					user:SendData(sBot,"*** Error: You aren't registered!")
				end
			end, },
			[sCOM2] = {
			function(user,data)
				if user.bRegistered then
					local s,e,sPass = string.find(data,"^%b<>%s+%S+%s+(%S+)")
					if sPass and string.len(sPass) >= 4 then
						AddRegUser(user.sName,sPass,user.iProfile)
						user:SendData(sBot,"You have sucessfully changed your password to: \""..sPass.."\"")
					else
						user:SendData(sBot,"*** Error: Either you didn't enter a password or it was too short. Password must be at least 4 characters!")
					end
				else
					user:SendData(sBot,"*** Error: You aren't registered!")
				end
			end, },
			[sCOM3] = {
			function(user,data)
				if AllowedProfiles[user.iProfile] == 1 then
					local s,e,Name,Pass = string.find(data,"^%b<>%s+%S+%s+(%S+)%s*(%S+)")
					if Name then
						if Pass and string.len(Pass) >= 4 then
							if tPassword[Name] then
								Profile = tPassword[Name].Profile
								AddRegUser(Name,Pass,Profile)
								user:SendData(sBot,"You have sucessfully changed "..Name.."'s password to \""..Pass.."\"")
							else
								user:SendData(sBot,"*** Error: \""..Name.."\" isn't registered on this hub!")
							end
						else
							user:SendData(sBot,"*** Error: Either you didn't enter a password or it was too short. Password must be at least 4 characters!")
						end
					else
						user:SendData(sBot,"*** Syntax Error: Type "..sPrefix..sCOM3.." <Nick> <Password>")
					end
				end
			end, },
			[sCOM4] = {
			function(user,data)
				if AllowedProfiles[user.iProfile] == 1 then
					local s,e,Name = string.find(data,"^%b<>%s+%S+%s+(%S+)")
					if Name then
						if (tPassword[Name]) then
							user:SendData(sBot,"\""..Name.."\"'s Password is : \""..tPassword[Name].Password.."\"")
						else
							user:SendData(sBot,"*** Error: \""..Name.."\" isn't registered in this hub!")
						end
					else
						user:SendData(sBot,"*** Syntax Error: Type "..sPrefix..sCOM4.." <Nick>")
					end
				end
			end, },
			[sCOM5] = {
			function(user,data)
				if AllowedProfiles[user.iProfile] == 1 then
					local s,e,sPro = string.find(data,"^%b<>%s+%S+%s+(%S+)")
					if sPro then
						if (tProfiles[sPro]) then
							sMsg = ""
							for i,v in GetUsersByProfile(sPro) do
								sMsg = sMsg.."\t"..v.."\t\t"..tPassword[v].Password.."\r\n"
							end
							if sMsg ~= "" then
								local border = string.rep ("-", 100)
								user:SendData(sBot,"\r\n\t"..border.."\r\n\tNick\t\tPassword\r\n\t"..border.."\r\n"..sMsg.."\t"..border)
							else
								user:SendData(sBot,"*** Error: There aren't registered users with Profile "..sPro.." in this hub.")
							end
						else
							user:SendData(sBot,"\""..sPro.."\" isn't a valid Profile Name!")
						end
					else
						user:SendData(sBot,"*** Syntax Error: Type "..sPrefix..sCOM5.." <Profile Name> (case-sensitive)")
					end
				end
			end, }
		}
		if tCmds[cmd] then return tCmds[cmd][1](user,sData),1 end
	end
end