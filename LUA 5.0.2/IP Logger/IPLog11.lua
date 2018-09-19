-- Heavily optimized by jiten (6/4/2005)
-- Added: Nick/IP Search
-- Removed: Logout logging

-- Connection Log 1.0 LUA 5 by Mutor The Ugly
--
-- Log connections to hub in an external file
-- Hublist pingers are excluded by nick, add IP's if needed

--User Settings------------------------------------------------
LogFile = "Log.tbl"		-- Log file
LogCmd = "+log"			-- View log Command
Maxlog = 200			-- Number of entries to cache
MaxShow = 30			-- Number of entries to show
sBot = frmHub:GetHubBotName()	-- Bot name pulled from hub
--End User Settings--------------------------------------------

Main = function()
	if loadfile(LogFile) then dofile(LogFile) else Log = {} OnExit() end
end

OnExit = function()
	local f,e = io.open( LogFile, "w+" )
	if f then
		f:write("Log = {\n") 
		for i = 1, table.getn(Log) do f:write( "  "..string.format("%q", Log[i])..",\n" )  end
		f:write("}") f:close()
	end
end

ChatArrival = function(user, data)
	local data = string.sub(data,1,-2)
	local s,e,cmd = string.find(data, "^%b<>%s+(%S+)")
	if cmd and string.lower(cmd) == LogCmd then
		local s,e,IP = string.find(data,"%b<>%s+%S+%s+(%S+)")
		if IP then
			local _,_,a,b,c,d = string.find(IP,"(%d*).(%d*).(%d*).(%d*)")
			local Message = function(user,data)
				local msg, Exists = "", nil
				for i, value in Log do if string.find(value,IP) then msg = msg..value.."\r\n" Exists = 1 end end
				if Exists == 1 then
					local Structure = "\r\n<"..string.rep("-",45).."-[ Search Results of: ( "..IP.." ) ] ----------->\r\n\r\n"
					Structure = Structure..msg
					Structure = Structure.."\r\n<"..string.rep("-",60).."-[ End of Connection Log ]--------------->"
					user:SendPM(sBot,Structure)
				else
					user:SendData(sBot,"*** Error: There's no User/IP: "..IP.." in the Connection Logs.")
				end
			end
			if not (a == "" or b == "" or c == "" or d == "") or not tonumber(a) and b == "" and c == "" and d == "" then
				Message(user,data)
			else
				user:SendData(sBot, "*** Syntax Error: Type "..LogCmd.." <User/IP>")
			end
		else
			local Structure = "\r\n<"..string.rep("-",45).."-[ Last ( "..table.getn(Log).." ) Connection Log Entries ] ----------->\r\n\r\n"
			for i = 1, table.getn(Log) do Structure = Structure..Log[i].."\r\n" end
			Structure = Structure.."\r\n<"..string.rep("-",60).."-[ End of Connection Log ]--------------->"
			user:SendPM(sBot,Structure)
		end
		return 1
	end
end

NewUserConnected = function(user,data)
	local GetMode = function(mode) if mode == "A" then mode = "Active" elseif mode == "P" then mode = "Passive" else mode = Socks5 end return mode end
	if string.find(string.lower(user.sName), "ping") then return end
	local userinfo = "- Log In > "..user.sName..", Profile: "..(GetProfileName(user.iProfile) or "Not Registered")..", IP: "..user.sIP..
	", Client/Version: "..user.sClient.."/"..user.sClientVersion..", Mode: "..GetMode(user.sMode).." , Share: "..string.format("%.2f GB.",user.iShareSize/(1024 * 1024 * 1024))..
	", Slots: "..user.iSlots..", User: "..(user.iNormalHubs or 0)..", Registered: "..(user.iRegHubs or 0)..
	", Operator: "..(user.iOpHubs or 0)..", Total Hubs: "..(user.iHubs or 0)
	table.insert(Log, os.date("[ %B %d %X ] ")..userinfo)
	if table.getn(Log) > Maxlog then table.remove(Log, 1) end OnExit()
end

OpConnected = NewUserConnected