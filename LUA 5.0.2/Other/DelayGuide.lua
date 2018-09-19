--// mine
-- script modded from "welcomemesses script by AmsterdamBulldogs" and Dessamator's Delaying script by jiten
-- removed unnecessary code and added table clearing
login = {
	["BotName"] = "CarinaLUA5",
}

local kb = "1024"
local mb = kb*kb
local gb = mb*kb
local tb = gb*kb

tDelay={}

function Main()
	frmHub:RegBot(login.BotName)
	SetTimer(1000)
	StartTimer()
end

--// Profile Counter
function ProfileCounter(profile)
	local table, count = GetUsersByProfile(profile), 0
	for i, User in table do 
		if GetItemByName(User) then
			count = count + 1
		end
	end
	return count
end

function NewUserConnected(user)
	tDelay[user.sName] = {}
	tDelay[user.sName]["time"] = "1"
end

function OnTimer()
	for i,v in tDelay do
		tDelay[i]["time"] = tDelay[i]["time"] - 1
		if tDelay[i]["time"] == 0 then
			local disp = ""
			doGetProfile =  GetProfileName(GetItemByName(i).iProfile) or "Not registered"
			local _,_,share = string.find(GetItemByName(i).sMyInfoString, "^%$MyINFO %$ALL [^ ]+ [^$]*%$ $[^$]+[^$]%$[^$]*%$%s*(%d+)%$" )
			if share then
				minshare = string.format("%0.3f", tonumber(share)/gb).." GB"
			else
				minshare = "Corrupt"
			end
			border1 = "  <========================= A Tua Info ================================>"
			disp = "\r\n\r\n"..border1.."\r\n"
			disp = disp.."	• Nick:				"..GetItemByName(i).sName.."\r\n"
			disp = disp.."	• IP:				"..GetItemByName(i).sIP.."\r\n"
			disp = disp.."	• Status:				"..doGetProfile.."\r\n"
			disp = disp.."	• Estás a partilhar:			"..minshare.."\r\n"
			GetItemByName(i):SendData(disp)
			tDelay[user.sName] = nil
		end
	end
end

OpConnected = NewUserConnected

-- tezlo

delayed = {}

function Main()
	SetTimer(1000)
	StartTimer()
end

function OnTimer()
	for nick, msg in delayed do
		SendToNick(nick, msg)
		delayed[nick] = nil
	end
end

function NewUserConnected(user)
	delayed[user.sName] = string.format("Your info..\n\tnick:\t%s\n\tip:\t%s\n\tprofile:\t%s\n\tshare:\t%0.2fGB",
		user.sName, user.sIP, GetProfileName(user) or "Unregistered", user.iShareSize/1024^3)
end

-- herodes

--- touched by Herodes
-- to provide an example of delayed messages..

Bot = "-=Brainu=-"
tDelay = {}

function Main()
	SetTimer(1000)
	StartTimer()
end

function OnTimer()
	for i,v in tDelay do
		v[3] = v[3] - 1
		if v[3] == 0 then
			SendToAll( v[2], v[1] )
		end
		tDelay[i] = nil
	end
end

function AddDelayedMessage( msg, delay )
	table.insert( tDelays, { msg, Bot, delay or 1 } )
end

function NewUserConnected(user) 
	local tProfiles = {
		[0] = "O Admin -= "..user.sName.." =- entrou no Hub",
		[1] = "O Operador -= "..user.sName.." =- entrou no Hub",
		[2] = "O ViP -= "..user.sName.." =- entrou no Hub",
		[4] = "O Networker -= "..user.sName.." =- entrou no Hub",
		[5] = "O Master -= "..user.sName.." =- entrou no Hub",
	}
	if tProfiles[user.iProfile] then
		AddDelayedMessage( tProfiles[user.iProfile] )
	elseif (user.sName == "{HubListPinger}") then
		AddDelayedMessage( "O Bot {HubListPinger} entrou no Hub." )
		AddDelayedMessage( "A Lista de Users em www.lusoleader.co.nr foi Actualizada" )
	end
end

function UserDisconnected(user)
	local tProfiles = {
		[0] = "O Admin -= "..user.sName.." =- saiu do Hub",
		[1] = "O Operador -= "..user.sName.." =- saiu do Hub",
		[2] = "O ViP -= "..user.sName.." =- saiu do Hub",
		[4] = "O Networker-= "..user.sName.." =- saiu do Hub",
		[5] = "O Master -= "..user.sName.." =- saiu do Hub",
	}
	if tProfiles[user.iProfile] then
		AddDelayedMessage( tProfiles[user.iProfile] )
	elseif (user.sName == "{HubListPinger}") then
		AddDelayedMessage( "O Bot {HubListPinger} saiu do Hub." )
	end
end

OpConnected=NewUserConnected
OpDisconnected=UserDisconnected