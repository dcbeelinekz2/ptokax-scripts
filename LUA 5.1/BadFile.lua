--[[

	---------------------------------------------------------------------------
	Advanced BadFile Active Search // Stripped from Thor 6

	By: NightLitch 2005-03-04

	Changelog:

	Changed: Quick update to LUA 5.1 by jiten (4/15/2006);
	Changed: Searches are case insensitive (4/18/2006).
	Changed: string.find to a plain search - bastya (4/19/2006)'
	Modified: UDPSRArrival's string.find (4/29/2006)
	---------------------------------------------------------------------------

]]--

tBadFiles = {
	{"faces of death" , "NO sharing of FACES OF DEATH material!"},
	{"child porn" , "NO sharing of CHILD PORN material!"},
	{"childporn" , "NO sharing of CHILDPORN material!"},
	{"preteen" , "NO sharing of PRETEEN material!"},
	{"pre-teen" , "NO sharing of PRE-TEEN material!"},
	{"kiddieporn" , "NO sharing of KIDDIEPORN material!"},
	{"kiddyporn" , "NO sharing of KIDDYPORN material!"},
	{"kiddie porn" , "NO sharing of KIDDIE PORN material!"},
	{"beastiality" , "NO sharing of BEASTIALITY material!"},
	{"underage" , "NO sharing of UNDERAGE material!"},
	{"r@ygold" , "NO sharing of R@YGOLD material!"},
}

---------------------------------------------------------------------------
--// Don't Edit below this point if you don't now what you are doing
---------------------------------------------------------------------------

tTimer = {}

Main = function()
	RegTimer(SearchForBadFiles, 20*1000, "ActiveBadFileSearch") -- Active Search Each 20 Sec
	SetTimer(1000); StartTimer()
end

OnTimer = function()
	for i in ipairs(tTimer) do
		tTimer[i][3] = tTimer[i][3] + 1
		if tTimer[i][3] > tTimer[i][2] then
			tTimer[i][3] = 1; tTimer[i][1]()
		end
	end
end

UDPSRArrival = function(sUser,sData)
	local _,_,From,Path,FileSize,FreeSlots,TotalSlots = string.find(sData, "^%$SR%s+(%S+)%s+(.*)(%d+)%s+(%d+)%/(%d+)")
	if tCall["BadFileSearch"] then pcall(tCall["BadFileSearch"],sUser,Path,FileSize) end
end

tCall = {
	BadFileSearch = function(sUser,Path,FileSize)
		if not sUser.bOperator then 
			local FileFound, FileReason = BadFiles(string.lower(Path))
			if FileFound then
				sUser:SendData(frmHub:GetHubBotName(), "*** You have been kicked for "..FileReason..". "..Path.." "..Units(FileSize))
				SendToOps(frmHub:GetHubBotName(), "*** User "..sUser.sName.." has been kicked for "..FileReason..". "..Path.." "..Units(FileSize))
				sUser:TempBan()
			end
		end
	end
}

RegTimer = function(Function,Interval,str)
	local tmpTrig = Interval / 1000
	table.insert(tTimer,{Function,tmpTrig,1,str})
end

Units = function(intSize)
	if tonumber(intSize) ~= 0 then
		local tUnits = { "Bytes", "KB", "MB", "GB", "TB" }
		intSize = tonumber(intSize); local sUnits;
		for i in ipairs(tUnits) do
			if(intSize < 1024) then sUnits = tUnits[i]; break; else intSize = intSize / 1024; end
		end
		return string.format("%0.1f %s",intSize, sUnits);
	else
		return "0 Bytes"
	end
end

BadFiles = function(PathStr)
	for i in ipairs(tBadFiles) do
		if string.find(PathStr, string.lower(tBadFiles[i][1]), 1, true) then
			return 1,tBadFiles[i][2]
		end
	end
	return nil, "Other Files"
end

SearchForBadFiles = function()
	if t == nil then
		t =1
		if tBadFiles[t] then
			SendToAll("$Search "..frmHub:GetHubIp()..":"..frmHub:GetHubUdpPort().." F?F?0?1?"..tBadFiles[t][1])
		end
	elseif t > table.getn(tBadFiles) then
		t = nil
	else
		t = t+1
		if tBadFiles[t] then
			SendToAll("$Search "..frmHub:GetHubIp()..":"..frmHub:GetHubUdpPort().." F?F?0?1?"..tBadFiles[t][1])
		else
			t = 0
		end
	end
end