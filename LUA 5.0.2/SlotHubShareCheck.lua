--$Rev Blocker by jiten
--restriction for MinSlots, MinShare and MaxHubs
--some ideas taken from leech bot and ShaveShare v4.8 by Herodes

MinShare = 500*mb -- in MBs
MinSlots = 3
MaxHubs = 5

DoShareUnits = function(intSize)				--- Thanks to kepp and NotRambitWombat 
	if intSize ~= 0 then 
		local tUnits = { "Bytes", "KB", "MB", "GB", "TB" } 
		intSize = tonumber(intSize); 
		local sUnits; 
		for index = 1, table.getn(tUnits) do 
			if(intSize < 1024) then sUnits = tUnits[index]; break; else intSize = intSize / 1024; end 
		end 
		return string.format("%0.1f %s",intSize, sUnits); 
	else 
		return "nothing" 
	end 
end 

ConnectToMeArrival = function(curUser,data)
	if curUser.iShareSize < MinShare then
		return curUser:SendData("*** You have to share at least "..DoShareUnits(MinShare).." to be able to download."),1
	elseif curUser.iSlots < MinSlots then
		return curUser:SendData("*** You must have "..MinSlots.." open slots to be able do download."),1
	elseif curUser.iHubs > MaxHubs then
		return curUser:SendData("*** You can't be in more than "..MaxHubs.." hubs to be able do download."),1
	end
end

RevConnectToMeArrival = ConnectToMeArrival