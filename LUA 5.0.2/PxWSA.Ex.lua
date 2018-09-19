--[[

	PxWSA lib's example script by jiten (3/10/2006)

	You should use the latest PxWSA lib available here: http://www.thewildplace.dk/#pxwsa

	ATTENTION: It must be in your scripts' folder

]]--

Settings = {
	sBot = frmHub:GetHubBotName(),				-- Default Bot Name or -- sBot = "custombot"
	sProt = 0,						-- 0 for TCP, 1 for UDP (mostly it's TCP)
	sPort = 80,						-- WSA lib default port
	sHost = "www.jonsthoughtsoneverything.com",		-- Host
	sFile = "/feeds/newzbin/newzbin-apps.xml",		-- File
}

fData = ""

-- Init WSA lib
libinit = loadlib("pxwsa.dll", "_libinit")
libinit()

-- Init sockets
WSA.Init()

Main = function()
	SetTimer(1000)
end

ChatArrival = function(user,data)
	local s,e,cmd = string.find(data, "^%b<>%s+%p(%S+).*|$")
	if cmd and string.lower(cmd) == "pxwsa" then
		ConnectToHost(); StartTimer()
		return 1
	end
end

OnExit = function()
	WSA.Dispose()
end

ConnectToHost = function()
	-- If not connected to any socket
	if not bConnected then
		-- Create a socket according to what we have above
		s,e,sock = WSA.NewSocket(Settings.sProt)
		-- Try connection to host
		local errorCode, errorStr = WSA.Connect(sock,Settings.sHost,Settings.sPort)
		-- Connection failed
		if errorCode then
			-- Connection Report
			SendToAll(Settings.sBot,"*** Error: Connection to "..Settings.sHost.." failed!")
			-- Mark as not connected
			bConnected = false
		else
			SendToAll(Settings.sBot,"*** Connected")
			-- Mark as connected
			bConnected = true
			-- Mark non-blocking socket
			local sError, Str = WSA.MarkNonBlocking(sock)
			-- Error
			if sError then
				-- Socket Error Marking Report
				SendToAll(Settings.sBot,"*** Error: Could not mark non-blocking socket.")
			else
				SendToAll(Settings.sBot,"*** Socket Marked")
				-- Send Request
				local wCmd = "GET "..Settings.sFile.." HTTP/1.1\r\nHost: "..Settings.sHost.."\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)\r\n"..string.char(13,10)
				-- Send the request
				local _ErrorCode, _ErrorStr, bytesSent = WSA.Send(sock,wCmd)
				-- Connection failed
				if _ErrorCode then
					-- Mark as not connected
					bConnected = false
					-- Report Error
					SendToAll(Settings.sBot,"*** Error: Connection Failed - ".._ErrorStr)
					-- Close existing socket
					WSA.Close(sock)
				else
					-- Connection Report
					SendToAll(Settings.sBot,"*** Request to "..Settings.sHost.." sent!")
				end
			end
		end
	end
end

-- PX WSA lib functions

-- Receive request
OnTimer = function()
	if bConnected then
		-- Wait for the request response
		local errorCode, errorStr, sData, bytesRead = WSA.Receive(sock)
		if errorCode then
			-- Connection gracefully closed
			if errorCode == 0 then
				-- Close existing socket
				WSA.Close(sock)
				-- Mark as connected
				bConnected = false
				-- Send received buffer
				SendToAll(fData)
				-- Empty receive buffer
				fData = ""
			-- Non-critical error
			elseif (errorCode == 10035) then
			-- Receive failed
			else
				-- Close existing socket
				WSA.Close(sock)
				-- Mark as not connected
				bConnected = false
				-- Empty receive buffer
				fData = ""
			end
		else
			-- Merge to receive buffer
			fData = fData..sData
		end
	end
end