-- Requested by 3lancer and converted to Lua 5 by jiten
-- Made by nErBoS
-- Corrected by NightLitch
-- added endless amount of hubs by plop
-- modded for setting user levels to be redirected by bastya_elvtars (nice crew in here)
-- CheckUserLevel originally by Nathanos
-- CheckUserLevel eliminated by plop

Bot = "Share-Redirecter"

-- biggest hub 1st, share size in GB
tHubs = {
	{ ["share"] = 20,  ["domain"] = "hub4.no-ip.com", ["name"] = "Our 20GB MinShare Hub" },
	{ ["share"] = 15,  ["domain"] = "hub3.no-ip.com", ["name"] = "Our 15GB MinShare Hub" },
	{ ["share"] = 10,  ["domain"] = "hub2.no-ip.com", ["name"] = "Our 10GB MinShare Hub" },
	{ ["share"] = 5, ["domain"] = "hub1.no-ip.com", ["name"] = "Our 5GB MinShare Hub" }
}

function Main()
	frmHub:RegBot(Bot)
end

function NewUserConnected(user, data)
	share = user.iShareSize
	if(tonumber(share)) then
		share = tonumber(share) / (1024*1024*1024)
		for i=1,table.getn(tHubs) do
			if share > tHubs[i]["share"] then
				user:Redirect(tHubs[i]["domain"], tHubs[i]["name"])
			end
		end
	end
end