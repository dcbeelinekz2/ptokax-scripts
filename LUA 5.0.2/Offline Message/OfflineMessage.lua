tOffline = {}

ChatArrival = function(user,data)
	local s,e,cmd = string.find(data, "^%b<>%s+%!(%S+).*|$")
	if cmd and string.lower(cmd) == "offline" then
		local s,e,msg = string.find(data,"^%b<>%s+%S+%s+(.*)")
		if msg then
			tOffline = { sUser = user.sName, sMsg = msg }
			user:SendData(frmHub:GetHubBotName(),"*** Your message has been stored and will be sent to users on connect!")
		end
		return 1
	end
end

NewUserConnected = function(user)
	if next(tOffline) then user:SendPM(tOffline.sUser,"*** Offline Message: "..tOffline.sMsg) end
end