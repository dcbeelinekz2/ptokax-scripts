-- Lua 5 version by jiten
--//HubJump

sBot = frmHub:GetHubBotName()

tHubs = {
	{ ["domain"] = "hub1.no-ip.com", ["desc"] = "[D@] G€®M@N FØ®©€ N®W!", ["cmd"] = "cmd1" },
	{ ["domain"] = "hub2.dyn.dns", ["desc"] = "[D@] G€®M@N FØ®©€ Pf@lz", ["cmd"] = "cmd2" },
	{ ["domain"] = "hub3.orgdns.org", ["desc"] = "[D@] G€®M@N FØ®©€ B@y€rn", ["cmd"] = "cmd3" },
	{ ["domain"] = "hub4.no-ip.com:777", ["desc"] = "[D@] G€®M@N FØ®©€ B@d€n", ["cmd"] = "cmd4" },
}

function ChatArrival(user, data) 
	local data = string.sub(data,1,-2) 
	local s,e,cmd = string.find (data, "%b<>%s+[%!%?%+%#](%S+)" )
	local border,msg = "\r\n\t"..string.rep("-",80).."\r\n\t",""
	if string.lower(cmd) == "jump" then 
		msg = msg..border.."Hub Affiliates Of 420 £ñ+érÞ®¡šè§™"..border.."Type These Commands In Main Chat:"..border
		for i=1,table.getn(tHubs) do
			msg = msg..tHubs[i]["cmd"].." - let's U connect to "..tHubs[i]["domain"].." - "..tHubs[i]["desc"].."\r\n\t"
		end
		msg = msg..border return user:SendData(sBot, msg),1
	end 
	for i,v in tHubs do if string.lower(cmd) == string.lower(v.cmd) then user:Redirect(v.domain,v.desc) end end
end