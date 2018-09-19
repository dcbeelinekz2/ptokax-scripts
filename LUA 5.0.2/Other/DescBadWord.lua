--Modified Description Tag & BadWord in Description Tby (uk)jay 07/5/2005
--My First Attempt at a Script - based on Hawk's Description Tag and plop's wordreplacer
--Thx to jiten for help
--Sets Description Tag 

--Timer In Mins
Mins =  1
iTime = 10000 * Mins

function Main() 
	SetTimer(iTime)
	StartTimer() 
end 

sTables = { 
	tProfiles = {
		[0]  = "{Master}",	--// Set the Master Tag Here Eg.   ["Description"] = "I AM A MASTER",
		[1] = "{Op}",		--// Set the Operator Tag Here
		[2] = "{Vip}",		--// Set the VIP Tag Here
		[3] = "{Reg}",		--// Set the Reg Tag Here
		[4] = "{Net Founder}",	--// Set the NetFounder Tag Here
		[5] = "{Moderator}",	--// Set the Moderator Tag Here
	},
	tBadWords = {
		["fuck"] = "<censored>",
		["bitch"] = "<censored>",
		["piss"] = "<censored>",
		["cunt"] = "<censored>",
		["bastard"] = "<censored>",
		["asshole"] = "<censored>",
		["crap hub"] = "<censored>",
	},
}

function OnTimer()
	for tProfile,tDesc in sTables.tProfiles do
		for i,nick in frmHub:GetOnlineUsers(tProfile) do
			if (nick.sMyInfoString ~= nil) then
				local s,e,name,desc,speed,email,share = string.find(nick.sMyInfoString, "$MyINFO $ALL (%S+)%s+([^$]*)$ $([^$]*)$([^$]*)$([^$]+)")
				local desc = string.gsub(desc, "(%w+)", function(word) return CheckWord(word) end)
				SendToAll( "$MyINFO $ALL "..name.." "..sTables.tProfiles[tProfile].." "..desc.."$ $"..speed.."$"..email.."$"..share.."$")
			end
		end
	end
end

function CheckWord(word)
	local wordl = string.lower(word)
	if sTables.tBadWords[wordl] then
		return sTables.tBadWords[wordl]
	else
		return word
	end
end
