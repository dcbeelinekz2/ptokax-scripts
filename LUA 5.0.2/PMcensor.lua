-- PM Blocker by jiten (6/13/2005)

AllowedProfiles = { -- Profiles Allowed to use PMs
	[-1] = 0, -- unreg
	[0] = 1, -- master
	[1] = 1, -- operator
	[2] = 1, -- vip
	[3] = 1, -- reg
	[4] = 1, -- moderator
	[5] = 1, -- founder
}

ToArrival = function(user, data)
	if AllowedProfiles[user.iProfile] ~= 1 then
		return 1
	end
end
