-- converted to Lua 5 by jiten (-)
-- Biorythm calculation bot
-- core written by RabidWombat
-- ported to PtokaX by bastya_elvtars
-- use !biorythm YYYY-MM-DD
-- where you enter your bithday

Bot="-Sybilla-"

-------------====================------------------

iPhysicalCycle = 23;
iEmotionalCycle = 28;
iIntellectualCycle = 33;
fRadian = 2.0 * math.pi;


-- GetBioRhythm
-- Desc: Gets the "BioRhythm" based on birthday
-- Input: Birthday Day (number), Birthday Month (number), Birthday Year (number)
-- Return: PhysicalIndex (number), IntellectualIndex (number), EmotionalIndex (number)
function GetBioRhythm( Day, Month, Year )
	local iCurDay, iCurMonth, iCurYear = tonumber(os.date("%m")), tonumber(os.date("%d")), tonumber(os.date("%Y"));


	local iDaysBetween = GetDaysBetween( Day, Month, Year, iCurDay, iCurMonth, iCurYear );


	local iPhysicalIndex = math.sin(iDaysBetween * fRadian / iPhysicalCycle)
	local iIntellectualIndex = math.sin(iDaysBetween * fRadian / iIntellectualCycle)
	local iEmotionalIndex = math.sin(iDaysBetween * fRadian / iEmotionalCycle)


	return iPhysicalIndex, iIntellectualIndex, iEmotionalIndex;
end


function GetDaysBetween( StartDay, StartMonth, StartYear, EndDay, EndMonth, EndYear )
	return JulianDate( EndDay, EndMonth, EndYear, 0, 0, 0 ) - JulianDate( StartDay, StartMonth, StartYear, 0, 0, 0 );
end


-- Convert Gregorian Date to Julian Date
function JulianDate(DAY, MONTH, YEAR, HOUR, MINUTE, SECOND) -- HOUR is 24hr format
	local jy, ja, jm;


	assert(YEAR ~= 0);
	assert(YEAR ~= 1582 or MONTH ~= 10 or DAY < 4 or DAY > 15);
	--The dates 5 through 14 October, 1582, do not exist in the Gregorian system!");


	if(YEAR < 0 ) then
		YEAR = YEAR + 1;
	end


	if( MONTH > 2) then 
		jy = YEAR;
		jm = MONTH + 1;
	else
		jy = YEAR - 1;
		jm = MONTH + 13;
	end


	local intgr = math.floor( math.floor(365.25*jy) + math.floor(30.6001*jm) + DAY + 1720995 );


	--check for switch to Gregorian calendar
	local gregcal = 15 + 31*( 10 + 12*1582 );
	if(DAY + 31*(MONTH + 12*YEAR) >= gregcal ) then
		ja = math.floor(0.01*jy);
		intgr = intgr + 2 - ja + math.floor(0.25*ja);
	end


	--correct for half-day offset


	local dayfrac = HOUR / 24 - 0.5;
	if( dayfrac < 0.0 ) then
		dayfrac = dayfrac + 1.0;
		intgr = intgr - 1;
	end


	--now set the fraction of a day
	local frac = dayfrac + (MINUTE + SECOND/60.0)/60.0/24.0;


	--round to nearest second
	local jd0 = (intgr + frac)*100000;
	local  jd  = math.floor(jd0);
	if( jd0 - jd > 0.5 ) then jd = jd + 1 end
	return jd/100000;
end

function ChatArrival(user,data)
	local msg
	local _,_,command,args=string.find(data,"%b<>%s+(%S+)%s+(.+)")
	if command=="!biorythm" then
		if args then
			local _,_,Y,M,D=string.find(args,"(%d%d%d%d)%D(%d%d)%D(%d%d)")
			if Y and M and D then
				user:SendData(D.."-"..M.."-"..Y)
				msg="\r\nBiorythm calculation started. Hold on! :)\r\n==================================\r\n"
				local Day,Month,Year=tonumber(D),tonumber(M),tonumber(Y)
				local Phys,Intell,Emot=GetBioRhythm( Day, Month, Year ) -- not Intel but Intell! :P (AMD)
				msg=msg.."\r\nPhysical index: "..Phys.."\r\nIntellectual index: "..Intell.."\r\nEmotional index: "..Emot.."\r\n\r\n=================================="
			else
				msg="Correct usage: !biorythm YYYY-MM-DD"
			end
		else
			msg="Correct usage: !biorythm YYYY-MM-DD"
		end
		user:SendData(Bot,msg)
		return 1
	end
end