--AdTimer 1.1c for LUA 5
--Debugged by jiten
--
--by Mutor
--Optimized by Optimus, thx
--
--Yet another Hub Advert script
--Sends hub Advert on timer or by command
--
--
--User Settings-------------------------------------------------------------------------------------
Bot = "HubAd"						-- Name for Bot
Mins = 180 						-- Interval [in minutes] between Ads
Webaddy = "http://yourwebserver.no-ip.com"	-- Hubs website address or other url
HubOwner = "YourName"					-- Duh?
Prefix = "+"						-- Set Command Prefix
AdComm = "ad"						-- Command to send Ad immediately
TZone = " -5 GMT"					-- Time Zone hub resides in
-- Additional notices/info to be sent with ad
Notice1 = ""
Notice2 = ""
Notice3 = ""
--End User Settings----------------------------------------------------------------------------------

function Main()
	SetTimer(Mins*60000) StartTimer()
end

ChatArrival = function(user, data)
	local s,e,cmd = string.find(data, "%b<>%s+(%S+)(%S+)")
	if (cmd==Prefix..AdComm) and user.bOperator then OnTimer() return 1 end
end

OnTimer = function()
	StopTimer()
	if (string.len(frmHub:GetHubName()) <= 40) then tabspace = "\t" else tabspace = "" end local tmp
	local GetStatus = function(status) if status == 1 then status = "on" else status = "off" end return status end
	tmp = "\r\n\r\n\t---<>-------------------------------------------------------------------------------------------<>---\r\n"
	tmp = tmp.."\t"..tabspace.."[ "..frmHub:GetHubName().." ]\r\n"
	tmp = tmp.."\t---<>-------------------------------------------------------------------------------------------<>---\r\n"
	tmp = tmp.."\tHub topic.pic: \t"..(frmHub:GetHubTopic() or "There is no current topic.").."\r\n"
	tmp = tmp.."\tHub Owner: \t"..HubOwner.."\r\n"
	tmp = tmp.."\tHub Addy: \t"..frmHub:GetHubAddress().."\t port: "..frmHub:GetHubPort().."\r\n"
	tmp = tmp.."\tHub Stats: \t"..Webaddy.."\r\n"
	tmp = tmp.."\tHub Time: \t( "..os.date("%B %d %Y %X ").." ) - "..TZone .."\r\n"
	tmp = tmp.."\tHub Desc: \t"..frmHub:GetHubDescr().."\r\n"
	tmp = tmp.."\tBot Name: \t"..frmHub:GetHubBotName().."\r\n"
	tmp = tmp.."\tSec. Alias: \t"..GetStatus(frmHub:GetHubSecAliasName()).."\r\n"
	tmp = tmp.."\tOps Chat: \t"..frmHub:GetOpChatName().."\r\n"
	tmp = tmp.."\tRedirect To: \t"..(frmHub:GetRedirectAddress() or "None").."\r\n"
	tmp = tmp.."\tReg Server: \t"..frmHub:GetRegServer().."\r\n"
	tmp = tmp.."\tRedirect All: \t"..GetStatus(frmHub:GetRedirectAll()).."\r\n"
	tmp = tmp.."\tRedirect Full: \t"..GetStatus(frmHub:GetRedirectFull()).."\r\n"
	tmp = tmp.."\tMin Slots: \t"..frmHub:GetMinSlots().." per user.\r\n"
	tmp = tmp.."\tMax Slots: \t"..frmHub:GetMaxSlots().." per user.\r\n"
	tmp = tmp.."\tSlot Ratio: \t"..frmHub:GetSlotRatio().." slot per "..frmHub:GetHubRatio().." hub(s).\r\n"
	tmp = tmp.."\tMax Hubs: \t"..frmHub:GetMaxHubs().." per user.\r\n"
	tmp = tmp.."\tMax Users: \t"..frmHub:GetMaxUsers().."\r\n"
	tmp = tmp.."\tMax Logins: \t"..frmHub:GetMaxLogins().."\r\n"
	tmp = tmp.."\tMin Share: \t"..string.format("%.2f GB",frmHub:GetMinShare()/1024).."\r\n"
	tmp = tmp.."\tHub Share: \t"..string.format("%.2f TB",frmHub:GetCurrentShareAmount()/(1024 * 1024 * 1024 * 1024)).."\r\n"
	tmp = tmp.."\tMasters Online: \t"..cProfile("Master").."\r\n"
	tmp = tmp.."\tOps Online: \t"..cProfile("Operator").."\r\n"
	tmp = tmp.."\tVips Online: \t"..cProfile("VIP").."\r\n"
	tmp = tmp.."\tRegs Online: \t"..cProfile("REG").."\r\n"
	tmp = tmp.."\t---<>-------------------------------------------------------------------------------------------<>---\r\n"
	tmp = tmp.."\tTotal Online:\t\t"..(table.getn(frmHub:GetOnlineUsers()) or 0).."\r\n"
	tmp = tmp.."\t---<>-------------------------------------------------------------------------------------------<>---\r\n"
	tmp = tmp.."\tNotice(s):\r\n"
	tmp = tmp.."\t-- "..Notice1.."\r\n"
	tmp = tmp.."\t-- "..Notice2.."\r\n"
	tmp = tmp.."\t-- "..Notice3.."\r\n"
	tmp = tmp.."\t---<>-------------------------------------------------------------------------------------------<>---\r\n"
	SendToAll(tmp) collectgarbage() io.flush() StartTimer()
end

--// Profile Counter
cProfile = function(what)
	local disp = ""
	local table,online,offline = GetUsersByProfile(what),0,0
	for i, User in table do if GetItemByName(User) then online = online + 1 else offline = offline + 1 end end
	if (string.len(online) < 2) then spacer = "\t\t\t" else spacer = "\t\t" end
	disp = disp.."Online: "..online..spacer.."Offline: "..offline return disp
end
