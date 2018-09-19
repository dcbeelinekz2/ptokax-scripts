-- Lua 5 version by jiten
-- Shows ISP on login (12/13/2005)

-- Made by nErBoS

sBot = frmHub:GetHubBotName()

arrISP = {
	["217.70.64.0-217.70.79.255"] = "[PT] Braga Tel",
	["213.138.224.0-213.138.255.255"] = "[PT] TV Madeira",
	["213.190.192.0-213.190.223.255"] = "[PT] TV Madeira",
	["213.228.128.0-213.228.191.255"] = "[PT] Net Visão",
	["217.129.0.0-217.129.255.255"] = "[PT] Net Visão",
	["194.117.0.0-194.117.49.255"] = "[PT] CCFCUL",
	["194.117.48.0-194.117.49.255"] = "[PT] CCFCUL",
	["217.23.0.0-217.23.15.255"] = "[PT] ID Centre",
	["194.38.128.0-194.38.159.255"] = "[PT] Com Nexo",
	["213.146.192.0-213.146.223.255"] = "[PT] Com Nexo",
	["195.8.0.0-195.8.31.255"] = "[PT] Marconi",
	["195.245.128.0-195.245.191.255"] = "[PT] Oni",
	["213.58.0.0-213.58.255.255"] = "[PT] Oni",
	["80.172.0.0-80.172.255.255"] = "[PT] Via Net",
	["195.22.0.0-195.22.31.255"] = "[PT] Via Net",
	["80.79.0.0-80.79.15.255"] = "[PT] Guião",
	["212.48.64.0-212.48.95.255"] = "[PT] HLC",
	["194.79.64.0-194.79.95.255"] = "[PT] Novis",
	["195.23.0.0-195.23.255.255"] = "[PT] Novis",
	["212.0.160.0-212.0.191.255"] = "[PT] Novis",
	["213.205.64.0-213.205.95.255"] = "[PT] Novis",
	["212.54.128.0-212.54.159.255"] = "[PT] IT Net",
	["213.63.0.0-213.63.255.255"] = "[PT] Jazz Tel",
	["213.141.0.0-213.141.31.255"] = "[PT] Jazz Tel",
	["193.126.0.0-193.126.255.255"] = "[PT] KPN Quest",
	["212.113.128.0-212.113.159.255"] = "[PT] Maxi Tel",
	["82.140.192.0-82.140.255.255"] = "[PT] Média Capital",
	["213.129.128.0-213.129.159.255"] = "[PT] Net Way",
	["81.92.192.0-81.92.223.255"] = "[PT] NFSI",
	["82.102.0.0-82.102.63.255"] = "[PT] NFSI",
	["212.13.32.0-212.13.63.255"] = "[PT] Norte Net",
	["80.90.192.0-80.90.223.255"] = "[PT] Oni Way",
	["62.169.64.0-62.169.127.255"] = "[PT] Optimus",
	["83.144.128.0-83.144.191.255"] = "[PT] Pluri Canal",
	["62.48.128.0-62.48.255.255"] = "[PT] Telecom Prime",
	["193.136.0.0-193.137.255.255"] = "[PT] FCCN",
	["193.236.0.0-193.236.255.255"] = "[PT] FCCN",
	["194.210.0.0-194.210.255.255"] = "[PT] FCCN",
	["195.138.0.0-195.138.31.255"] = "[PT] Sibs",
	["212.18.160.0-212.18.191.255"] = "[PT] Telecel",
	["213.30.0.0-213.30.127.255"] = "[PT] Telecel",
	["81.193.0.0-81.193.255.255"] = "[PT] Telepac",
	["82.154.0.0-82.155.255.255"] = "[PT] Telepac",
	["194.65.0.0-194.65.255.255"] = "[PT] Telepac",
	["212.55.128.0-212.55.191.255"] = "[PT] Telepac",
	["212.16.128.0-212.16.159.255"] = "[PT] Teleweb",
	["212.251.128.0-212.251.255.255"] = "[PT] Teleweb",
	["81.84.0.0-81.84.255.255"] = "[PT] Net Cabo",
	["83.132.0.0-83.132.255.255"] = "[PT] Net Cabo",
	["212.113.160.0-212.113.191.255"] = "[PT] Net Cabo",
	["213.22.0.0-213.22.255.255"] = "[PT] Net Cabo",
	["62.249.0.0-62.249.31.255"] = "[PT] UU Net",
	["217.112.192.0-217.112.207.255"] = "[PT] Wireless TS",
}	-- Use this table to insert the ranges an the country name to be count

NewUserConnected = function(user)
	user:SendData(sBot,ShowRange(user.sIP))
end

OpConnected = NewUserConnected

ShowRange = function(IP) 
	local range,country,userIP
	local s,e,ip1,ip2,ip3,ip4 = string.find(IP, "(%d+)%.(%d+)%.(%d+)%.(%d+)") 
	local userIP = Addzero(ip1)..Addzero(ip2)..Addzero(ip3)..Addzero(ip4) 
	userIP = tonumber(userIP) 
	for range, country in arrISP do 
		local s,e,a1,a2,a3,a4,b1,b2,b3,b4 = string.find(range, "(%d+)%.(%d+)%.(%d+)%.(%d+)-(%d+)%.(%d+)%.(%d+)%.(%d+)") 
		local aIP = Addzero(a1)..Addzero(a2)..Addzero(a3)..Addzero(a4) aIP = tonumber(aIP) 
		local bIP = Addzero(b1)..Addzero(b2)..Addzero(b3)..Addzero(b4) bIP = tonumber(bIP) 
		if (userIP >= aIP and userIP <= bIP) then return country end 
	end 
end 

Addzero = function(number) 
	local iAux = tonumber(number) 
	if (iAux < 10) then number = "00"..number elseif (iAux < 100) then number = "0"..number else number = number end 
	return number 
end

