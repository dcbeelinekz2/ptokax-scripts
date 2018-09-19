--[[ 

	Redirect Array by nErBoS

	LUA 5.0/5.1 version by jiten

	CHANGELOG:

	- Corrected by NightLitch
	- Added: Endless amount of hubs by plop
	- Changed: For setting user levels to be redirected by bastya_elvtars (nice crew in here)
	- Changed: CheckUserLevel originally by Nathanos
	- Changed: CheckUserLevel eliminated by plop

]]--

-- Biggest hub 1st, share size in GB
tHubs = {
	{ iShare = 20,  sDomain = "hub4.no-ip.com", sName = "Our 20GB MinShare Hub" },
	{ iShare = 15,  sDomain = "hub3.no-ip.com", sName = "Our 15GB MinShare Hub" },
	{ iShare = 10,  sDomain = "hub2.no-ip.com", sName = "Our 10GB MinShare Hub" },
	{ iShare = 5, sDomain = "hub1.no-ip.com", sName = "Our 5GB MinShare Hub" }
}

MyINFOArrival = function(user, data)
	local iShareSize = user.iShareSize
	if tonumber(iShareSize) then
		iShareSize = (tonumber(iShareSize)/(1024^3))
		for i in ipairs(tHubs) do
			if iShareSize > tHubs[i].iShare then
				user:Redirect(tHubs[i].sDomain, tHubs[i].sName); break
			end
		end
	end
end