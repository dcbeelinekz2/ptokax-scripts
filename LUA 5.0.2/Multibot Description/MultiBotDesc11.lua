-- Script For Bot Description
-- Converted to lua 5 by Madman
-- Touched a bit by jiten

iDelay = 15 -- Delay between MyINFO Sending

tBots = {
	{ "bot1", "mail1", "desc1<++ V:0.668,M:A,H:0/0/1,S:1>", 1024*1024*1024, },
	{ "bot2", "mail2", "desc2<++ V:0.668,M:A,H:0/1/1,S:1>", 1024*1024*1024, },
	{ "bot3", "mail3", "desc3<++ V:0.668,M:A,H:0/1/1,S:1>", 1024*1024*1024, },
	{ "bot4", "mail4", "desc4<++ V:0.668,M:A,H:0/1/1,S:1>", 1024*1024*1024, },
}

Main = function()
	for i = 1, table.getn(tBots) do
		frmHub:RegBot(tBots[i][1])
		SendToAll("$MyINFO $ALL "..tBots[i][1].." "..tBots[i][3].."$ $"..string.char(1).."$"..tBots[i][2].."$"..tBots[i][4].."$")
	end
	SetTimer(60*1000*iDelay) StartTimer()
end

OnTimer = Main