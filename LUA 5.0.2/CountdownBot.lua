------------------------------------------------------------------------------
-------                  Lua 5 version by jiten                        -------
-------                  countdown bot by plop                         -------
-------             original julian day made by tezlo                  -------
-------      modifyd by chilla 2 also handle hours, mins, seconds      -------
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-------           THE TEXT FILE LOADS ON BOT START                     -------
------------------------------------------------------------------------------
------- this may sound weird but this 2 make sure it shows on time,    -------
-------      as i allready seen some big ascii's come by               -------
------------------------------------------------------------------------------


------------------------------------------------------------------------------
Bot = "newyear"

--This the date the timer has 2 stop @ midnight
-- year (2 numbers), month, day
SylYear,SylMonth,SylDay = 05,12,31
-- this is the file 2 be shown 
file = "happynewyear.txt"
------------------------------------------------------------------------------
------------------------------------------------------------------------------
function OnTimer()
	if last == 0 then
		SendToAll(Bot, TimeLeft())
		Sync()
	elseif last == 1 then
		SendAscii() -- send the msg
		StopTimer() -- kill the timer
	end
end
------------------------------------------------------------------------------
function jdatehms(d, m, y,ho,mi,se)
	local a, b, c = 0, 0, 0
	if m <= 2 then y = y - 1 m = m + 12 end
	if (y*10000 + m*100 + d) >= 15821015 then a = math.floor(y/100) b = 2 - a + math.floor(a/4) end
	if y <= 0 then c = 0.75 end
	return math.floor(365.25*y - c) + math.floor(30.6001*(m+1) + d + 1720994 + b),ho*3600+mi*60+se
end
------------------------------------------------------------------------------
function TimeLeft()
	local curday,cursec = jdatehms(tonumber(os.date("%d")),tonumber(os.date("%m")),tonumber(os.date("%y")),tonumber(os.date("%H")),tonumber(os.date("%M")),tonumber(os.date("%S")))
	local sylday,sylsec = jdatehms(SylDay,SylMonth,SylYear,24,0,0)
	local tmp = sylsec-cursec
	local hours, minutes,seconds = math.floor(math.mod(tmp/3600, 60)), math.floor(math.mod(tmp/60, 60)), math.floor(math.mod(tmp/1, 60))
	local day = sylday-curday
	if day >= 0 then
		line = "Time left till new year:"
		if day ~= 0 then line = line.." "..day.." Day's" end
		if hours ~= 0 then line = line.." "..hours.." Hours" end
		if minutes ~= 0 then line = line.." "..minutes.." Minutes" end
		if seconds ~= 0 then line = line.." "..seconds.." Seconds" end
		return line
	end
end
------------------------------------------------------------------------------
function ShowAscii()
	local f = io.open(file)
	if f then 
		text = f:read("*all")
		f:close()
		return string.gsub( text, "\n", "\r\n" )
	end 
end
------------------------------------------------------------------------------
function SendAscii()
	SendToAll(Bot, text.." |")
	SendToAll(Bot, "happy new year 2 everybody from all the guy's/girls/bot's from the lua forum|")
end
------------------------------------------------------------------------------
function ChatArrival(user, data) 
	data=string.sub(data,1,-2) 
	s,e,cmd = string.find(data,"%b<>%s+(%S+)") 
	if cmd == "!daysleft" then
		local tmp = TimeLeft()
		if tonumber(tmp) == nil then user:SendData(Bot, tmp.."|") end
		return 1
	end
end
------------------------------------------------------------------------------
function NewUserConnected(user)
	local tmp = TimeLeft()
	if tonumber(tmp) == nil then user:SendData(Bot, tmp.."|") end
end
------------------------------------------------------------------------------
OpConnected = NewUserConnected
------------------------------------------------------------------------------
function Main()
	SetTimer(100 * 1000) 
	StartTimer()
	local tmp = TimeLeft()
	if tonumber(tmp) == nil then SendToAll(Bot, tmp.."|") end
	Sync() ShowAscii() last = 0
end
------------------------------------------------------------------------------
function Sync()
	local curday,cursec = jdatehms(tonumber(os.date("%d")),tonumber(os.date("%m")),tonumber(os.date("%y")),tonumber(os.date("%H")),tonumber(os.date("%M")),tonumber(os.date("%S")))
	local sylday,sylsec = jdatehms(SylDay,SylMonth,SylYear,24,0,0)
	local tmp = sylsec-cursec
	local hours, minutes,seconds = math.floor(math.mod(tmp/3600, 60)), math.floor(math.mod(tmp/60, 60)), math.floor(math.mod(tmp/1, 60))
	local day = sylday-curday
	if day ~= 0 then
		adjust = (math.floor(math.mod(minutes, 60))*60)+seconds
		if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(3600 * 1000) end
	else
		if tmp > 3600 then  --- every hours a msg
			adjust = (math.floor(math.mod(minutes, 60))*60)+seconds
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(3600 * 1000) end
		elseif tmp > 900 then  -- every 15 mins a msg
			adjust = (math.floor(math.mod(minutes, 15))*60)+seconds
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(900 * 1000) end
		elseif tmp > 300 then  -- every 5 mins a msg
			adjust = (math.floor(math.mod(minutes, 5))*60)+seconds
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(300 * 1000) end
		elseif tmp > 60 then  -- every min a msg
			adjust = (math.floor(math.mod(minutes, 1))*60)+seconds
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(60 * 1000) end
		elseif tmp > 15 then  -- every 15 secs a msg
			adjust = math.floor(math.mod(seconds, 15))
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(15 * 1000) end
		elseif tmp > 10 then  -- every 10 secs a msg
			adjust = math.floor(math.mod(seconds, 10))
			if adjust ~= 0 then SetTimer(adjust * 1000) else SetTimer(5 * 1000) end
		elseif tmp > 1 then
			SetTimer(1 * 1000) 
		else
			last = 1
			SetTimer(1 * 1000)
		end
	end
end
------------------------------------------------------------------------------
