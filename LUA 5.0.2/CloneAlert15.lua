-- Clone Alert 1.5
-- 1.0b by Mutor The Ugly
-- PM Clone login to Opchat
-- Applied to latest PtokaX by bastya_elvtars
-- Also added share checking, if different, only notifies ops.
--thx NightLitch
-- Added: Clone check immunity (add, remove and list immune users) by jiten
--- -- touched by Herodes
-- heavily optimised
-- moved to 1.5

OpChatName = "OpChat"  -- Rename to opchatbot
Bot = "•bot•" -- Rename to you main Px bot
PmOps = true -- true:enables / false:disables , operator notifincation (STRONGLY recommended to leave enabled!)

function Main()
	tImmune = {}
	if loadfile("logs/cloneimmune.txt") then dofile("logs/cloneimmune.txt"); end
end

function OnExit()
	collectgarbage()
	local f = io.open("logs/cloneimmune.txt", "w+")
	local m = "tImmune = { "
	for nick , _ in tImmune do m = m..string.format("%q, ", string.gsub( nick, "\"", "\"" )); end
	m = m.." }"
	f:write( m ); f:close();
end

function OnExit()
	collectgarbage()
	local f = io.open("logs/cloneimmune.txt", "w+")
	local m = "tImmune = { "
	for nick , _ in tImmune do m = m..string.format("%q, ", string.gsub( nick, "\"", "\"" )); end
	m = m.." }"
	f:write( m ); f:close();
end


function NewUserConnected( user, data )
	for _, nick in frmHub:GetOnlineUsers() do
		if not ( user.bOperator or nick.bOperator ) then
			if not ( tImmune[user.sName] or tImmune[nick.sName] ) then
				if (user.sIP == nick.sIP) then
					user:SendPM( Bot, "Double Login is not allowed. You are already connected to this hub with this nick: "..nick.sName )
					nick:SendPM( Bot, "Double Login is not allowed. You are already connected to this hub with this nick: "..user.sName )
					user:SendPM( Bot, "You're being timebanned. Your IP: "..user.sIP )
					user:TimeBan( 5 )
					if ( PmOps ) then
						SendPmToOps(OpChatName, "*** Cloned user <"..user.sName.."> ("..user.sIP..") logged in and timebanned for 5 minutes. User is a clone of <"..nick.sName..">")
					elseif (user.iShareSize == nick.iShareSize) then
						SendPmToOps(OpChatName, "*** User "..user.sName.." logged in, with same IP as "..nick.sName.." but with different share, please check.")
					end
				end
			end
		end
	end
end

function ChatArrival (user,data)
	if (user.bOperator) then
		local data = string.sub( data, 1, -2 )
		local s,e,cmd = string.find( data, "%b<>%s+([%-%+%?]%S+)" )
		if cmd then
			return Parse( user, cmd, data, false )
		end
	end
end

function ToArrival ( user, data )
	if ( user.bOperator ) then
		local data = string.sub( data , 1, -2 )
		local s,e, cmd = string.find( data , "%$%b<>%s+([%-%+%?]%S+)" )
		if cmd then
			return Parse ( user, cmd , data , true )
		end
	end
end

function Parse( user, cmd, data, how )

	local function SendBack( user, msg , from, how )
		if how then user:SendPM( from or Bot , msg );return 1; end;
		user:SendData( from or Bot, msg );
	end

	local t = {
	--- Add to cloneList
	["+clone"] = function ( user , data , how )
		local s,e, name = string.find( data, "%b<>%s+%S+%s+(%S+)" )

		if not name then user:SendData(Bot, "*** Error: Type !addclone nick") end
		if tImmune[name] then user:SendData("nope") end

		local nick = GetItemByName(name)
		if not nick then user:SendData(Bot, "*** Error: User is not online.") end

		tImmune[name] = 1
		OnExit()
		user:SendData(Bot, nick.sName.." is now immune to clone checks!")
		return 1
	end ,
	--- Remove from cloneList
	["-clone"] = function ( user , data , how )
		local s,e, name = string.find(data, "%b<>%s+%S+%s+(%S+)")
		if not name then user:SendData(Bot, "*** Error: Type !delclone nick") end
		if not tImmune[name] then user:SendData(Bot,"The user "..GetItemByName(name).sName.." is not immune!")  end

		local nick = GetItemByName( name )
		if not nick then user:SendData(Bot, "*** Error: That user is not online.") end

		tImmune[name] = nil
		OnExit()
		user:SendData(Bot,"Now "..nick.sName.." is not no longer immune to clone checks!")
		return 1
	end,
	--- Show cloneList
	["?clone"] = function ( user , data, how )
		local m = ""
		collectgarbage()
		for nick, _ in tImmune do
			local s = "  • (Offline)  "
			if GetItemByName(nick) then s = "  • (Online)  "; end
			m = m.."\r\n\t"..s..nick
		end
		if m == "" then return SendBack( user, "There are no users that can have a clone", Bot, how ) end
		m = "\r\nThe following users can have clones in this hub:"..m
		return SendBack( user, m , Bot, how )
	end,
	--- Show cloneBot help
	["?clonehelp"] = function ( user, data , how )
		local m = "\r\n\r\nHere are the commands for the CloneBot:"
		m = m.."\r\n\t+clone <nick> \t allows <nick> to have a clone"
		m = m.."\r\n\t-clone <nick> \t removes <nick> from the clone list"
		m = m.."\r\n\t?clone\t\t shows the users allowed to have a clone"
		m = m.."\r\n\t?clonehelp \t allows <nick> to have a clone"
		return SendBack( user, m, Bot, how )
	end, }

	if t[cmd] then return t[cmd]( user, data, how ) end
end