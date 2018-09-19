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
	table.insert( tDelay, { msg, Bot, delay or 1 } )
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