--[[

	OnJoin 1.01 - LUA 5.1 by jiten (11/10/2006)
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	Based on: 
	
	- OnJoin by plop
	  Functions by nErBoS, [BR]Carlos
	  Convertion Lua5 by Jelf and heavily optimized by jiten

]]--


tSettings = {
	-- Bot Name
	sBot = frmHub:GetHubBotName(),

	-- Database
	fStats = "tStats.tbl",
}

tStats = {}

Main = function()
	if loadfile(tSettings.fStats) then dofile(tSettings.fStats) end
end

NewUserConnected = function(user)
	local tModes, sOnline, sRegistered = { ["A"] = "Active", ["P"] = "Passive", ["5"] = "Socks" }, "   • ", "   • "
	-- Count online users per profile
	for i, v in ipairs(GetProfiles()) do sOnline = sOnline..v..": "..(#frmHub:GetOnlineUsers(i-1))..", " end
	-- Count users per profile
	for i, v in ipairs(GetProfiles()) do sRegistered = sRegistered..v..": "..#GetUsersByProfile(v)..", " end
	-- Check uptime and share
	tStats.iUptime, tStats.iTotalShare = (tStats.iUptime or 0), (tStats.iTotalShare or 0)
	if frmHub:GetUpTime() > tStats.iUptime then tStats.iUptime = frmHub:GetUpTime() end
	if frmHub:GetCurrentShareAmount() > tStats.iTotalShare then tStats.iTotalShare = frmHub:GetCurrentShareAmount() end
	-- Build message
	local sMessage = "\r\n\r\n\t"..string.rep("_", 30).."\r\n\t\tUser Information\r\n\t"..string.rep("¯", 30).."\r\n\t"..
	"× Nick: "..(user.sName or "n/a").."\r\n\t"..
	"× Password: "..(frmHub:GetUserPassword(user.sName) or "n/a").."\r\n\t"..
	"× Share: "..DoUnits(user.iShareSize).."\r\n\t"..
	"× Profile: "..(GetProfileName(user.iProfile) or "Unregistered User").."\r\n\t"..
	"× IP: "..(user.sIP or "n/a").."\r\n\t"..
	"× Client: "..(user.sClient or "n/a").."\r\n\t"..
	"× Client Version: "..(user.sClientVersion or "n/a").."\r\n\t"..
	"× Mode: "..(tModes[user.sMode] or "n/a").."\r\n\t"..
	"× Slots: "..(user.iSlots or "n/a").."\r\n\t"..
	"× Connection: "..(user.sConnection or "n/a").."\r\n\t"..
	"× Total Hubs: "..(user.iHubs or "n/a").."\r\n\t"..
	"× Registered Hubs: "..(user.iRegHubs or "n/a").."\r\n\t"..
	"× Operator Hubs: "..(user.iOpHubs or "n/a").."\r\n\r\n\t"..
	string.rep("_", 30).."\r\n\t\tHub Information\r\n\t"..string.rep("¯", 30).."\r\n\t"..
	"× Hub Name: "..(frmHub:GetHubName() or "n/a").."\r\n\t"..
	"× Hub Current Share Amount: "..DoUnits(frmHub:GetCurrentShareAmount()).."\r\n\t"..
	"× Current Uptime: "..SecondsToTime(frmHub:GetUpTime()).."\r\n\t"..
	"× Current Topic: "..(frmHub:GetHubTopic() or "n/a").."\r\n\t"..
	"× Online Users per Profile:\r\n\t"..sOnline.."\r\n\t"..
	"× Registered Users per Profile:\r\n\t"..sRegistered.."\r\n\t"..
	"× Uptime Peak: "..SecondsToTime(tStats.iUptime).."\r\n\t"..
	"× Share Peak: "..DoUnits(tStats.iTotalShare).."\r\n\t"..
	"× Users Peak: "..(frmHub:GetMaxUsersPeak() or 0)
	-- Send
	user:SendData(tSettings.sBot, sMessage)
end

OpConnected = NewUserConnected

OnExit = function()
	-- Save
	local hFile = io.open(tSettings.fStats, "w+") Serialize(tStats, "tStats", hFile); hFile:close()
end

SecondsToTime = function(iSeconds)
	-- Build table with time fields
	local T = os.date("!*t", tonumber(iSeconds)); 
	-- Format to string
	local sTime = string.format("%i month(s), %i day(s), %i hour(s), %i minute(s)", T.month-1, T.day-1, T.hour, T.min)
	-- For each digit
	for i in string.gmatch(sTime, "%d+") do
		-- Reduce if is preceeded by 0
		if tonumber(i) == 0 then sTime = string.gsub(sTime, "^"..i.."%s(%S+),%s", "") end
	end
	-- Return
	return sTime
end

-- By kepp and NotRambitWombat
DoUnits = function(iValue)
	if iValue and iValue ~= 0 then 
		local tUnits, iValue, sUnits = { "Bytes", "KB", "MB", "GB", "TB" }, tonumber(iValue)
		for i in ipairs(tUnits) do 
			if (iValue < 1024) then sUnits = tUnits[i]; break else iValue = iValue/1024 end
		end 
		return string.format("%0.2f %s", iValue, sUnits);
	end
	return 0
end

Serialize = function(tTable, sTableName, hFile, sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key, value in pairs(tTable) do
		if (type(value) ~= "function") then
			local sKey = (type(key) == "string") and string.format("[%q]", key) or string.format("[%d]", key);
			if(type(value) == "table") then
				Serialize(value, sKey, hFile, sTab.."\t");
			else
				local sValue = (type(value) == "string") and string.format("%q", value) or tostring(value);
				hFile:write(sTab.."\t"..sKey.." = "..sValue);
			end
			hFile:write(",\n");
		end
	end
	hFile:write(sTab.."}");
end