-- Timed Anti-openhub-script by jiten

RegCheck = {}

function Main()
	SetTimer(10*60*1000) -- Default Checking Time set for 10 minutes
	StartTimer()
end

function NewUserConnected(user)
	if user.iNormalHubs then
		RegCheck[user.sName] = 1
		if user.iNormalHubs>0 then
			user:SendData( "PtokaX", "You are in unregistered hubs. This is against our rules. You will now be disconnected!")
			user:Disconnect()
		end
	end
end

-- OpConnected = NewUserConnected

function OnTimer()
	for i,v in RegCheck do
		local nick = GetItemByName(i)
		if GetItemByName(i).iNormalHubs > 0 then
			nick:SendData( "PtokaX", "You are in unregistered hubs. This is against our rules. You will now be disconnected!")
			nick:Disconnect()
		end
	end
end

function UserDisconnected(user)
	if user.iNormalHubs and RegCheck[user.sName] ~= nil then
		RegCheck[user.sName] = nil
	end
end

-- OpDisconnected = UserDisconnected