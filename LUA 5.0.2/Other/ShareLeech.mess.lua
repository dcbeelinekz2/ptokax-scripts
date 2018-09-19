-- share checker by jiten
-- ideas from:
--- ShaveShare v4.8 request by judas ( 10/08 - 2004 )
--- by Herodes ( 11/08 - 2004 )
--- 100% Blocker by chill and modded by nErBoS

Bot = "Share"

secs=1000 
minutes = 60 
hours = 60 ^2

tUsers = {} 
wtime = 30*minutes		---this is the time in seconds. .. Feel free to use the #*hours to say in # hours ... and  #*minutes to say in # minutes .. :) 

sharertxt = "shares.tbl"	--Will be created in the script folder
sh = {}

-- do not edit this
frequency = 10
-- 

function Main()
	frmHub:RegBot(Bot)
	SetTimer(1000)
	StartTimer()
	bal = math.floor(wtime/frequency)
end

function NewUserConnected(user, data)
	local share = user.iShareSize
	local i = string.format("%0.2f", tonumber(share)/(1024*1024*1024))
	CheckShare(user, i)
	if user.sMyInfoString then 
		local ishere = 0 
		if tUsers[user.sName] == nil and ishere ~= 1 then 
			tUsers[user.sName] = {}  
			tUsers[user.sName][1] = 0 
			tUsers[user.sName][2] = 1 
		end 
	end 
end 

OpConnected = NewUserConnected

function ChatArrival(user, data)
	data=string.sub(data,1,string.len(data)-1) 
	s,e,cmd = string.find(data,"%b<>%s+(%S+)") 
	if (cmd=="!sgrw") then
		if (user.bOperator) then
			local s,e,who = string.find(data,"%b<>%s+%S+%s+(%S+)")
			if (who == nil or who == "") then
				user:SendPM(Bot, "Syntax Error, !sgrw <who>, you must write a name.")
			else
				user:SendPM(Bot, CheckUser(who))
			end
		else
			user:SendPM(Bot, "You don´t have permission to use this command.")
		end
		return 1
	end
end

ToArrival = ChatArrival

function CheckUser(user)
	local tmp = ""
	if (Verify(sharertxt) == nil) then
		tmp = tmp.."the file hasn't been created yet."
	else
		local e = io.open(sharertxt,"r")
		while 1 do
			local line = e:read("*l")
			if (line == nil) then
				tmp = tmp.."The user "..user.." wasn't found in the list, have you write the right name ?"
				break
			else
				local s,e,who,lshare, fshare = string.find(line, "(%S+)%s+%&%s+(%S+)%s+&%s+(%S+)")
				if (who ~= nil and string.lower(who) == string.lower(user) ) then
					if (GetItemByName(user) ~= nil) then
						tmp = tmp.."The user "..user.." is sharing "..lshare.." GB his last share was "..fshare.." GB."
					else 
						tmp = tmp.."The user "..user.." has shared "..lshare.." GB."
					end
					break
				end
			end
		end
		e:read()
		e:close()
	end
	return tmp
end

function CheckShare(user, share)
	local tmp = ""
	local time = 0
	if (Verify(sharertxt) == nil) then
		local f = io.open(sharertxt,"w+")
		f:write(user.sName.." & "..share.." & 0\r\n")
		f:close()
	else
		local g = io.open(sharertxt,"r")
		while 1 do
			local line = g:read("*l")
			if (line == nil) then
				if (time == 0) then
					tmp = tmp..user.sName.." & "..share.." & 0\r\n"
				end
				break
			else
				local s,e,who,nshare = string.find(line, "(%S+)%s+%&%s+(%S+)%s+&%s+%S+")
				if (who ~= nil and string.lower(who) == string.lower(user.sName)) then
					if (tonumber(nshare) > tonumber(share)) then
						SendPmToOps(Bot, "The user "..user.sName.." has least share then his last loggin.")
						SendPmToOps(Bot, "He had "..nshare.." GB and now he has "..share.." GB.")
						tmp = tmp..user.sName.." & "..share.." & "..nshare.."\r\n"
						sh[user.sName] = share
						time = 1
					elseif (tonumber(nshare) < tonumber(share)) then
						SendPmToOps(Bot, "The user "..user.sName.." has more share then his last loggin.")
						SendPmToOps(Bot, "He had "..nshare.." GB and now he has "..share.." GB.")
						tmp = tmp..user.sName.." & "..share.." & "..nshare.."\r\n"
						sh[user.sName] = share
						time = 1
					elseif (tonumber(nshare) == tonumber(share)) then
						tmp = tmp..user.sName.." & "..share.." & "..nshare.."\r\n"
						sh[user.sName] = share
						time = 1
					end
				else
					tmp = tmp..line.."\r\n"
				end
			end
		end
		g:read()
		g:close()
		local h = io.open(sharertxt,"w+")
		h:write(tmp)
		h:close()
	end
end

function Verify(filename)
	local f = io.open(filename, "r")
	if f then
		f:close()
		return true
	end
end

function DoTimeUnits(time) 
	local tTimes = {} 
	local time = time * 1000 
	if ( time >= 86400000 ) then 
	repeat  
		if tTimes[4] then 
			tTimes[4] = tTimes[4] + 1 
		else tTimes[4] = 1 
		end 
		time = time - 86400000  
	until time < 86400000 
	end 
 
	if ( time >= 3600000 ) then 
	repeat  
		if tTimes[3] then 
			tTimes[3] = tTimes[3] + 1 
		else tTimes[3] = 1 
		end 
		time = time - 3600000  
	until time < 3600000 
	end 
 
	if ( time >= 60000 ) then 
	repeat 
		if tTimes[2] then 
			tTimes[2] = tTimes[2] + 1 
		else tTimes[2] = 1 
		end 
		time = time - 60000 
	until time < 60000 
	end 
	 
	if ( time >= 1000 ) then 
	repeat  
		if tTimes[1] then 
			tTimes[1] = tTimes[1] + 1 
		else tTimes[1] = 1 
		end 
		time = time - 1000 
	until time < 1000 
	end 
	local msg = "" 
	local tTimeUns = { "seconds", "minutes", "hours", "days"} 
	for i,v in tTimes do  
		msg = v.." "..tTimeUns[i].." "..msg 
	end 
	return msg 
end 

--- // --- Transforming bytes Into KB, MB, GB, TB, PT and Returning the ideal (highest possible) Unit --- // --- 
function DoShareUnits(intSize)				--- Thanks to kepp and NotRambitWombat 
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

function TakeCare(table, timeallowed, balance, freq) 
	for user, time in table do 
		local usr = GetItemByName(user) 
		table[user][1] = table[user][1] + 1 
		if usr and usr.sMyInfoString then 
			_,_,share = string.find(usr.sMyInfoString, "%$(%d+)%$") 
			if ( table[user][1] >= timeallowed ) then 
				if (Verify(sharertxt) ~= nil) then
					local e = io.open(sharertxt,"r")
					while 1 do
						local line = e:read("*l")
						if (line ~= nil) then
							local s,e,who,lshare, fshare = string.find(line, "(%S+)%s+%&%s+(%S+)%s+&%s+(%S+)")
							if (who ~= nil and string.lower(who) == string.lower(user) ) then
								if lshare <= fshare then
									usr:SendPM(Bot, "You didn't fill up your share. You are being banned.") 
									usr:TimeBan(60) -- Action for users that don't change/add share
									table[usr.sName] = nil
								else
									table[usr.sName] = nil
								end
								break
							end
						end
					end
					e:read()
					e:close()
				end
			elseif ( table[user][1] == balance * table[user][2] ) then 
				table[user][2] = table[user][2] + 1 
			end 
		end 
	end 
end 

function OnTimer()
	TakeCare(tUsers, wtime, bal, frequency)
	collectgarbage()
	io.flush()
end