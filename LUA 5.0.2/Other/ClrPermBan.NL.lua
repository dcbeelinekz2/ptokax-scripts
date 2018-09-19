--//+++++++++++++++++++++++++++++++++++++++++++++++++++++++
--// Clear PermBanList by NightLitch
--// Version: 
--//     0.1 - Created Bot
--//     0.2 - Added Unban mode. Unban Nick(s) or IP(s)
--//+++++++++++++++++++++++++++++++++++++++++++++++++++++++
interval_time = 1 -- enter a number
interval_value  = "month" -- enter sec, min, hour, day, week, month, year
unban_mode = 1 -- 1 = unban IPs  /  0 = unban Nicks
--//+++++++++++++++++++++++++++++++++++++++++++++++++++++++
sTime = {}
sTime["sec"]  = 1000
sTime["min"]  = 60*sTime.sec
sTime["hour"] = 60*sTime.min
sTime["day"]  = 24*sTime.hour
sTime["week"]  = 7*sTime.day
sTime["month"]  = 30*sTime.day
sTime["year"]  = 365*sTime.day
--//+++++++++++++++++++++++++++++++++++++++++++++++++++++++
function Main()
--	SetTimer(tonumber(interval_time) * sTime[string.lower(interval_value)])
	SetTimer(1000)
	StartTimer()
end
--//+++++++++++++++++++++++++++++++++++++++++++++++++++++++
function OnTimer()
	local c = 0
	local list = frmHub:GetPermBanList()
	for i = 1,table.getn(list) do
		if tonumber(unban_mode) == 1 and string.find(list[i].sIP, "%d+%.%d+%.%d+%.%d+") then
			c = c + 1
			SendToAll(list[i].sIP)
			--Unban(list[i].sIP)
		elseif tonumber(unban_mode) == 0 and not string.find(list[i].sIP, "%d+%.%d+%.%d+%.%d+") then
			c = c + 1
			Unban(list[i].sIP)
		end
	end
	if tonumber(unban_mode) == 1 then
		SendToOps(frmHub:GetHubBotName(), "*** "..c.." IP(s) have been unbanned from Banlist")
	elseif tonumber(unban_mode) == 0 then
		SendToOps(frmHub:GetHubBotName(), "*** "..c.." Nick(s) have been unbanned from Banlist")
	end
end
--//+++++++++++++++++++++++++++++++++++++++++++++++++++++++
--// NightLitch
