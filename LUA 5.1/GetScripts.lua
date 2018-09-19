--[[

	Get Scripts 1.0 - LUA 5.1 by jiten (4/12/2006)

]]--


ChatArrival = function(user, data) 
	local s,e,cmd = string.find(data,"^%b<>%s+[%!%+](%S+).*|$") 
	if cmd then
		if tCommands[string.lower(cmd)] then
			cmd = string.lower(cmd)
			if tCommands[cmd].tLevels[user.iProfile] then
				return tCommands[cmd].tFunc(user, data), 1
			else
				return user:SendData(frmHub:GetHubBotName(),"*** Error: You are not allowed to use this command!"), 1
			end
		end
	end
end

tCommands = {
	showscripts = {
		tFunc = function(user)
			local sMsg, sTmp = nil, ""
			local f = io.open(frmHub:GetPtokaXLocation().."\\cfg\\Scripts.xml")
			if f then sMsg = f:read("*all"); f:close(); end
			if sMsg then
				sMsg = string.gsub(sMsg,string.char(13,10),""); 
				local tTable = { [0] = "Disabled", [1] = "Enabled" }
				for sScript,iStatus in string.gmatch(sMsg,"<Name>(.-)</Name>%s+<Enabled>(.-)</Enabled>") do
					sTmp = sTmp.."\t* "..tTable[tonumber(iStatus)].." *\t\t"..sScript.."\r\n"
				end
			end
			user:SendData(frmHub:GetHubBotName(),"\r\n\r\n\t"..string.rep("=",80).."\r\n\tStatus:\t\t\tScript:\r\n\t"..
			string.rep("-",160).."\r\n"..sTmp)
		end,
		tLevels = {
			[0] = 1, [1] = 1, [4] = 1, [5] = 1,
		},
		tRC = "Get Scripts$<%[mynick]> !{}"
	},
}

NewUserConnected = function(user)
	for i,v in pairs(tCommands) do
		local sRC = string.gsub(v.tRC,"{}",i)
		user:SendData("$UserCommand 1 3 "..sRC.."&#124;")
	end
end

OpConnected = NewUserConnected