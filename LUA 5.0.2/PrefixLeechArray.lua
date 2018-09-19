-- Prefix Leech Array
-- based on script by nErBoS
-- modded by jiten

sBot = "-=Brainu=-" 

sOpChatName = "-=OpChat=-"


--## Configuration ##-- 

-- Put in this table the Prefixes you want the users to have
 
sPrefix = { "[CV]" , "(CV)" ,}

-- Put in this table the IP-Range or IP you want to be checked for

arrIP = { 
   ["10.6.0.0"] = "10.6.0.30",
   ["84.90.0.0"] = "84.91.255.255",      --  Cabovisao,SA
   ["213.228.128.0"] = "213.228.191.255",   --  Cabovisao,SA
   ["217.129.0.0"] = "217.129.255.255",      --  Cabovisao,SA
}
--## END ##-- 

function Main()
	frmHub:RegBot(sBot) 
end 

function NewUserConnected(user) 
	if (CheckUserPrefix(user) == nil) and not (isGoodIP(user.sIP) == nil) then 
		user:SendPM(sBot, "Inclui o prefixo [CV] ou (CV) no teu nick, isto porque o Sapo Adsl conta como internacional o trafego de ti")
		user:SendPM(sBot, "Se precisares de ajuda, ou tiveres dúvidas contacta um Operador")
		SendPmToOps(sOpChatName, "O utilizador "..user.sName.." foi requisitado para usar o prefixo [CV]")
	end 
end 

OpConnected = NewUserConnected 

function ConnectToMeArrival(user,data)
	if (CheckUserPrefix(user) == nil) and not (isGoodIP(user.sIP) == nil) then 
		user:SendData(sBot, "Não podes fazer downloads/uploads até mudares o teu prefixo para [CV] ou (CV)")
		return 1
	end
end

RevConnectToMeArrival = ConnectToMeArrival

function CheckUserPrefix(user)
	for key,pre in sPrefix do 
		if string.find(string.lower(user.sName), string.lower(pre),1,1) then 
			return 1 
		end 
	end 
end

function isGoodIP(sIP) 
	sIP = ipToNumber(sIP) 
	local iFirst,iLast 
	for iFirst, iLast in arrIP do 
		if (sIP >= ipToNumber(iFirst) and sIP <= ipToNumber(iLast)) then 
			return 1 
		end 
	end 
	return nil 
end 

function ipToNumber(sIP) 
	iAux = "" 
	string.gsub(sIP,"(%d+)", function(w) 
		w = tonumber(w) 
		if (w < 10) then 
			iAux = iAux.."00"..w 
		elseif (w < 100) then 
			iAux = iAux.."0"..w 
		else 
			iAux = iAux..w 
		end 
	end) 
	return tonumber(iAux) 
end