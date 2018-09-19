--###############################################--
-- Simple VIP Check -- By NightLitch 2004-12-23 --
-- Updated:
-- - Checks for users that should not have [VIP] or [REG]
--   in the Nickname.
-- Advanced Tags:  [__V--i--P__}, {_V_]i[_P_}
-----
-- Converted to LUA 5 by blackwings
--###############################################--
BotName = "TagCheck"
--###############################################--
function MyINFOArrival(sUser,sData)
	local _,_,sTag = string.find(string.lower(sData), "[%[%{%(](%S+)[%]%}%)]")
	if sTag then
		if string.find(string.lower(sTag), "%p*v%p*i%p*p%p*") and sUser.iProfile ~= 2 then
			sUser:SendData(BotName, "Remove VIP Tag from your nickname! Tag: "..sTag)
			sUser:Disconnect()
		elseif string.find(string.lower(sTag), "%p*r%p*e%p*g%p*") and sUser.iProfile ~= 3 then
			sUser:SendData(BotName, "Remove REG Tag from your nickname! Tag: "..sTag)
			sUser:Disconnect()
		end
	end
end
--###############################################--
--// NightLitch