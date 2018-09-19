-- Script For Bot Description
-- Converted to lua 5 by Madman
-- Touched a bit by jiten

iDelay = 15 -- Delay between MyINFO Sending

tBots = {
	{ Name = "bot1", Email = "mail1", Descr = "desc1", Share = 1024*1024*1024, },
	{ Name = "bot2", Email = "mail2", Descr = "desc2", Share = 1024*1024*1024, },
	{ Name = "bot3", Email = "mail3", Descr = "desc3", Share = 1024*1024*1024, },
	{ Name = "bot4", Email = "mail4", Descr = "desc4", Share = 1024*1024*1024, },
}

Main = function()
	for i = 1, table.getn(tBots) do
		frmHub:RegBot(tBots[i]["Name"])
		SendToAll("$MyINFO $ALL "..tBots[i]["Name"].." "..tBots[i]["Descr"].."$ $"..string.char(1).."$"..tBots[i]["Email"].."$"..tBots[i]["Share"].."$")
	end
	SetTimer(60*1000*iDelay) StartTimer()
end

OnTimer = Main