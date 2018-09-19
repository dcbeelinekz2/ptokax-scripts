-- Profiles not allowed to type in Main
tBlocked = { 
	[-1] = 1,	-- Unreg
	[0] = 0,	-- Master
	[1] = 0,	-- Operator
	[2] = 0,	-- VIP
	[3] = 1,	-- Reg
	[4] = 0,	-- Moderator
	[5] = 0,	-- Founder
}

ChatArrival = function(user,data)
	if tBlocked[user.iProfile] == 1 then
		return user:SendData(frmHub:GetHubBotName(),"*** Error: Main Chat is blocked for your profile!"), 1
	end
end
