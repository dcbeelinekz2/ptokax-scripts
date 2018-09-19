---------------------------------------------------------------
-- Heavily optimized by jiten (LUA 5)

--> Made by plop
--> Functions by nErBoS
--> Functions by [BR]Carlos
--> Convertion LUA 5 by Jelf
---------------------------------------------------------------
Bot = frmHub:GetHubBotName()
ALLUSERS={}
LEVELS = {["0"]=0, ["1"]=0, ["2"]=0, ["3"]=0, ["-1"]=0, ["4"]=0, ["5"]=0}
Stat = {
	uptime = 0,
	share = 0,
	users = 0,
}
sec = 1000 
min = 60*sec
os.execute("mkdir ".."\""..string.gsub("Data", "/", "\\").."\"")

function ChatArrival(user, data)
	if ALLUSERS[user.sName]==nil then ALLUSERS[user.sName]=1 LEVELS[tostring(user.iProfile)]=LEVELS[tostring(user.iProfile)]+1 end
	s,e,cmd= string.find(data, "%b<>%s+(%S+)")
	local commands = {
		["!addreguser"]=1,
		["!delreguser"]=1
	}
	if cmd ~= nil and commands[cmd] then SetTimer(5*1000) StartTimer() end
end

function NewUserConnected(user)
	local usrshare = user.iShareSize
	if loadfile("Data/CLP.Stat.dat") then
		dofile("Data/CLP.Stat.dat")
		local uptime,share,users = Stat["uptime"],Stat["share"],Stat["users"]
		if (users < frmHub:GetUsersCount()) then Stat.users = frmHub:GetUsersCount() else Stat.users = users end
		if share < frmHub:GetCurrentShareAmount() then Stat.share = frmHub:GetCurrentShareAmount() else Stat.share = share end
		if uptime < frmHub:GetUpTime() then Stat.uptime = frmHub:GetUpTime() else Stat.uptime = uptime end
		SaveToFile("Data/CLP.Stat.dat" , Stat , "Stat")
	else
		if (Stat.users < frmHub:GetUsersCount()) then Stat.users = frmHub:GetUsersCount() end
		if Stat.share < frmHub:GetCurrentShareAmount() then Stat.share = frmHub:GetCurrentShareAmount() end
		Stat.uptime = frmHub:GetUpTime()
		SaveToFile("Data/CLP.Stat.dat" , Stat , "Stat")
	end
	if ALLUSERS[user.sName]==nil then ALLUSERS[user.sName]=1 LEVELS[tostring(user.iProfile)]=LEVELS[tostring(user.iProfile)]+1 end
	Message(user)
end

OpConnected = NewUserConnected

function UserDisconnected(user)
	if ALLUSERS[user.sName] then 
		ALLUSERS[user.sName]=nil
		if LEVELS[tostring(user.iProfile)] > 0 then
			LEVELS[tostring(user.iProfile)]=LEVELS[tostring(user.iProfile)]-1
		end
	end
end

OpDisconnected = UserDisconnected

function Message(user)
	local tmp,share,SC,hubshare,ttshare = "",user.iShareSize,os.clock(),frmHub:GetCurrentShareAmount(),tonumber(Stat.share)
	local days,hours,minutes = math.floor(Stat.uptime/43200, 30), math.floor(math.mod(Stat.uptime/1440, 24)), math.floor(math.mod(Stat.uptime/60, 60))
	if share == nil then share = 0 end
	if user.sMode == "A" then tmp = "Activo" else tmp = "Passivo" end
	user:SendData(":.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.: "..user.sName.."")
	user:SendData("     -×--- Compartilhamento: "..rightSize( tonumber(share) ).." - Status: "..(GetProfileName(user.iProfile) or "Não Registrado").." - Senha: "..(frmHub:GetUserPassword(user.sName) or "(×××)").." ---×-") 
	user:SendData("     -×--- Conectado: "..(user.iHubs or "0").." Hub's - Com registro: "..(user.iRegHubs or "0").." - Como Operador: "..(user.iOpHubs or "0").." ---×-") 
	user:SendData("     -×--- Cliente: "..(user.sClient or "Desconhecido").." - Versão: "..(user.sClientVersion or "Indisponível").." - Modo: "..tmp.." - Slot's: "..(user.iSlots or "0").." ---×-") 
	user:SendData("     -×--- Endereço IP: "..user.sIP.." - Conexão: "..(user.sConnection or "Indisponível").." ---×-")
	user:SendData(":.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.: "..frmHub:GetHubName().."")
	user:SendData("     -×--- Comunidade de Lingua Portuguesa --×-- Compartilhamento: "..rightSize( tonumber(hubshare) ) .." ---×-")
	user:SendData("     -×--- Usuários Online : "..table.getn(frmHub:GetOnlineUsers(-1)).." - REG Online : "..getOn(3).." - OP's: "..getOn(1).." - ViP's: "..getOn(2).." - NetOP's: "..getOn(0).."  - Máximo: "..frmHub:GetMaxUsers().." ---×-") 
	user:SendData("     -×--- Usuários Registrados: "..getAll(3).." - OP's: "..getAll(0) + getAll(1).." - ViP's: "..getAll(2).." - NetOP's: "..getAll(0).." - Total: "..table.getn(frmHub:GetRegisteredUsers()).." ---×-")
	user:SendData("     -×--- Uptime: " ..math.floor(SC/86400).." dias "..math.floor(math.mod(SC/3600,24)).." horas e "..math.floor(math.mod(SC/60,60)).." minutos --×-- "..os.date().." ---×-")
	user:SendData("     -×--- Peak --×-- Uptime: "..days.." dias, "..hours.." horas e "..minutes.." minutos - Compartilhamento: "..rightSize( tonumber(ttshare) ).." - Usuários: "..Stat.users.." ---×-") 
	user:SendData("     -×--- Lista de Comandos - Regras - Ajuda - Informação: !ajuda - !help ---×-") 
	user:SendData(":.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:")
	user:SendData("     -×--- Tópico: "..(frmHub:GetHubTopic() or "Desconhecido").." ---×-")
	user:SendData(":.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:")
	user:SendData("	")
end

function getOn(p)
	local r,t = frmHub:GetOnlineRegUsers(),0
	for i,nick in r do
		if nick.iProfile == p then
			t = t + 1
		end
	end
	return t
end

function getAll(p)
	local r = table.getn(GetUsersByProfile(GetProfileName(p)))
	return r
end

function rightSize(intSize)				--- Thanks to kepp and NotRambitWombat 
	if intSize ~= 0 then 
		local tUnits = { "Bytes", "KB", "MB", "GB", "TB" } 
		intSize = tonumber(intSize); 
		local sUnits; 
		for index = 1, table.getn(tUnits) do 
			if(intSize < 1024) then 
				sUnits = tUnits[index]; 
				break; 
			else  
				intSize = intSize / 1024; 
			end 
		end 
		return string.format("%0.1f %s",intSize, sUnits); 
	else 
		return "nothing" 
	end 
end 

function Serialize(tTable, sTableName, sTab)
	assert(tTable, "tTable equals nil");
	assert(sTableName, "sTableName equals nil");
	assert(type(tTable) == "table", "tTable must be a table!");
	assert(type(sTableName) == "string", "sTableName must be a string!");
	sTab = sTab or "";
	sTmp = ""
	sTmp = sTmp..sTab..sTableName.." = {\n"
	for key, value in tTable do
                local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
                if(type(value) == "table") then
			sTmp = sTmp..Serialize(value, sKey, sTab.."\t");
                else
			local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
			sTmp = sTmp..sTab.."\t"..sKey.." = "..sValue
		end
		sTmp = sTmp..",\n"
	end
	sTmp = sTmp..sTab.."}"
	return sTmp
end

function SaveToFile(file , table , tablename)
	local handle = io.open(file,"w+")
	handle:write(Serialize(table, tablename))
	handle:flush()
	handle:close()
end