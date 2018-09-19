--[[

	Anti-Open Hub by Herodes

]]--

tBad = {}
Settings = {
	-- Bot Name
	sBot = frmHub:GetHubBotName(),
	-- How many seconds before disconnecting
	iTimeAfter = 15,
}

Main = function()
	SetTimer(1000); StartTimer()
end

NewUserConnected = function(user)
	if user.iNormalHubs then
		if user.iNormalHubs > 0 then
			tBad[user.sName] = Settings.iTimeAfter
			user:SendData(Settings.sBot,"*** You are in unregistered hubs. This is against our rules. You will be disconnected "..
			"in "..Settings.iTimeAfter.." seconds from now!")
		end
	end
end

OnTimer = function()
	for i,v in ipairs(frmHub:GetOnlineNonOperators()) do
		if v.iNormalHubs and v.iNormalHubs > 0 and not tBad[v.sName] then tBad[v.sName] = Settings.iTimeAfter end
	end
	for nick,v in pairs(tBad) do
		local user = GetItemByName(nick)
		if user.iNormalHubs then
			if user.iNormalHubs == 0 then
				tBad[nick] = nil
				user:SendData(Settings.sBot,"*** Thanks for adjusting your unregistered hubs so that it "..
				"conforms with our rules.")
			elseif user.iNormalHubs > 0 then
				tBad[nick] = tBad[nick] - 1
				if tBad[nick] == 0 then
					tBad[nick] = nil
					user:SendData(Settings.sBot,"*** You are being disconnected because you didn't conform to "..
					"the hub rules. You were in unregistered hubs.")
					user:Disconnect()
				elseif tBad[nick] == math.floor(Settings.iTimeAfter/2) then
					user:SendData(Settings.sBot,"*** You should really disconnect from the hubs that you aren't "..
					"registered. it is not allowed in this hub. You have "..math.floor(Settings.iTimeAfter/2)..
					" seconds left disconnection follows after that.." )
				end
			end
		end
	end
end

UserDisconnected = function(user)
	if tBad[user.sName] then tBad[user.sName] = nil; collectgarbage(); end
end