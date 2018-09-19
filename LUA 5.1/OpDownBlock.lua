--[[

	Operator Download Blocker - LUA 5.0/5.1 by jiten (4/9/2006)

]]--

CTMArrival = function(user,data)
	local sFind
	if string.sub(data,1,4) == "$Rev" then sFind = "(%S+)|$" elseif string.sub(data,1,4) == "$Con" then sFind = "%S+%s+(%S+)" end
	local s,e,nick = string.find(data,sFind)
	local nick = GetItemByName(nick)
	if nick and nick.bOperator then
		return user:SendData(frmHub:GetHubBotName(),"*** Error: You are not authorized to download from an Operator!"), 1
	end
end

ConnectToMeArrival = CTMArrival
RevConnectToMeArrival = CTMArrival