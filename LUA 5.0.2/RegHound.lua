-- Optimized Lua 5 version by jiten
-- RegHound 1.0 by Mutor The Ugly 7/10/14
--
-- Prompts unregistered users to register on repaeating interval; Hounds in Main Chat, as well as PM
-- User Settings -------------------------------------------------------------------------------------
sBot = frmHub:GetHubBotName()	-- Name for bot[You can use your main bot, if so no need to register this bot. See 'function main'.
Mins =  "1"			-- Interval [in minutes] to PM unregistered users
UnRegMsg = "message goes here"	-- Message to send to unregistered Users
-- End User Settings ---------------------------------------------------------------------------------

Main = function() 
	SetTimer(Mins*60000) StartTimer()
-- 	frmHub:RegBot(sBot) -- If using main bot, remark this line, add -- ie.. --frmHub:RegBot(sBot)
end

OnTimer = function()
	local i,v
	for i,v in frmHub:GetOnlineNonOperators() do
		if v.iProfile == -1 then
			v:SendPM(sBot, UnRegMsg)
			v:SendData(sBot, UnRegMsg)
		end
	end
end