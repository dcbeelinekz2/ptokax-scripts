-- Kick/Warn v1.0 by jiten
-- with:
-- Immune Profiles/Allowed Profiles
-- Kick/Warn Limit and Timeban

tConf = { -- Script settings
	mSet = {
		sBot = frmHub:GetHubBotName(), -- bot name
		iTimeBan = 10, -- in minutes
		kLimit = 3, -- kick limit
		wLimit = 3, -- warn limit
	},
	tKick = {},
	tWarn = {},
}

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
	data=string.sub(data,1,-2) 
	local s,e,cmd = string.find ( data, "%b<>%s+[%!%?%+%#](%S+)" )
	if cmd then
		local s,e,usr,reason = string.find( data, "%b<>%s+%S+%s+(%S+)%s*(.*)" )
		local tCmds = { 
		["warn"] =	function(user,data)
			if AllowedProfiles[user.iProfile] == 1 then
				if usr == nil or reason == nil then
					user:SendData(tConf.mSet.sBot, "*** Syntax Error: Type !warn <nickname> <reason>")
				else
					local victim = GetItemByName(usr)
					if (victim == nil) then
						user:SendData(tConf.mSet.sBot, "The user "..usr.." is not online.")
					else
						if ImmuneProfiles[victim.iProfile] ~= 1 then
							if tConf.tWarn[victim.sName] == nil then
								tConf.tWarn[victim.sName] = {}
								tConf.tWarn[victim.sName]["Warned"] = {}
								tConf.tWarn[victim.sName]["Warned"] = 1
							else
								tConf.tWarn[victim.sName]["Warned"] = tConf.tWarn[victim.sName]["Warned"] + 1
							end
						else
							user:SendData(tConf.mSet.sBot,"*** Error: You can't warn Immune Profile Users.")
							return 0
						end
						if (tConf.tWarn[victim.sName]["Warned"] == tConf.mSet.wLimit) then
							victim:SendPM(tConf.mSet.sBot, "You are being warned and disconnected because: "..reason)
							SendToAll(tConf.mSet.sBot, "User "..victim.sName.." was kicked by "..user.sName.." because: "..reason)
							tConf.tWarn[victim.sName] = nil
							victim:TempBan()
							victim:Disconnect()
						else
							victim:SendPM(tConf.mSet.sBot, "You are being warned because: "..reason)
							SendToAll(tConf.mSet.sBot, "User "..victim.sName.." was warned by "..user.sName.." because: "..reason)
						end
					end
				end
			else
				user:SendData(tConf.mSet.sBot,"*** Error: You are not allowed to use this command.")
			end
		end,
		["kick"] =	function(user,data)
			if AllowedProfiles[user.iProfile] == 1 then
				if usr == nil or reason == nil then
					user:SendData(tConf.mSet.sBot, "*** Syntax Error: Type !kick <nickname> <reason>")
				else
					local victim = GetItemByName(usr)
					if (victim == nil) then
						user:SendData(tConf.mSet.sBot, "The user "..usr.." is not online.")
					else
						if ImmuneProfiles[victim.iProfile] ~= 1 then
							if tConf.tWarn[victim.sName] == nil then
								tConf.tWarn[victim.sName] = {}
								tConf.tWarn[victim.sName]["Kicked"] = {}
								tConf.tWarn[victim.sName]["Kicked"] = 1
							else
								tConf.tWarn[victim.sName]["Kicked"] = tConf.tWarn[victim.sName]["Kicked"] + 1
							end
						else
							user:SendData(tConf.mSet.sBot,"*** Error: You can't kick Immune Profile users.")
							return 0
						end
						if (tConf.tWarn[victim.sName]["Kicked"] == tConf.mSet.kLimit) then
							SendToAll(tConf.mSet.sBot, victim.sName.." has been timebanned for "..tConf.mSet.iTimeBan.." minutes by "..user.sName.." because : "..reason)
							victim:SendPM(tConf.mSet.sBot, "You've been timebanned for "..tConf.mSet.iTimeBan.." minutes by "..user.sName.." because: "..reason)
							tConf.tWarn[victim.sName] = nil
							victim:TimeBan(tConf.mSet.iTimeBan)
						else
							SendToAll(tConf.mSet.sBot, victim.sName.." has been kicked by "..user.sName.." because : "..reason)
							victim:SendPM(tConf.mSet.sBot, "You've been kicked by "..user.sName.." because: "..reason)
							victim:TempBan()
							victim:Disconnect()
						end
					end
				end
			else
				user:SendData(tConf.mSet.sBot,"*** Error: You are not allowed to use this command.")
			end
		end,
		}
		if tCmds[cmd] then 
			return tCmds[cmd](user,data), 1
		end
	end
end