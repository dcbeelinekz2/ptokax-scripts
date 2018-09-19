--[[

	WebBot 1.0 LUA 5.1
	
	By Mutor        04/08/06
	
	Quick sample script for 'single' file
	download using bluebears httpget-beta1
	extension lib for PtokaX. See hdload.lua
	that ships with the lib for multiple file
	example.
	
	Get the pre-released beta here:
	http://www.thewildplace.dk/downloads/betas/httpget-beta1.zip
	

]]--

GetCfg = {
Interval = 500,
Bot = "[WebBot]",
Path = "http://www.domain.com",
File = "filename.ext",
Done = 0,
Count = 0,
Time = os.time(),
}


function Main()
	libinit = package.loadlib("luahttpget.dll", "_libinit")
	libinit()
	AddDL(GetCfg.Path..GetCfg.File,GetCfg.File)
	SetTimer(GetCfg.Interval)
	StartTimer()
end

GetStats = function(uri)
	local Tab = {
	[0] = "Pending",
	[1] = "Downloading",
	[2] = "Download Complete",
        [3] = "Download Failed",
        }
	if uri then
		local r,s = HttpDlStats(uri)," = "..uri
		r = tonumber(r)
		if Tab[r] then
			s = Tab[r]..s
		else
  			s = s.." is not in list!"
		end
		return s,r
	end
end

OnTimer = function()
        if GetCfg.Path ~= "" and GetCfg.File ~= "" then
		local status,code = GetStats(GetCfg.Path..GetCfg.File)
		local file = GetCfg.File
		if code < 2 then
			if GetCfg.Count == 0 then
				SendToAll(GetCfg.Bot, status)
				GetCfg.Count = 1
			end
		end
		if code >= 2 then
			StopTimer()
			if code == 2 then
			        local hub,ver = getHubVersion()
			        local size,kb = Checkfile(file)
			        kb = string.format ("%-5.2f Kb/s", kb / (os.time() - GetCfg.Time))
			        local stat = "\r\n\r\n\t"..status.."\r\n"..
				"\tDownload Size:\t"..size..
				"\r\n\tDownload Time:\t"..
				(os.time() - GetCfg.Time).." seconds\r\n"..
				"\tTransfer Speed:\t"..kb.." \r\n"..
				"\tPtokaX Version:\t"..hub.." "..ver.."\r\n"..
				"\tPXLua Version:\t".._VERSION.."\r\n\r\n"
				SendToAll(GetCfg.Bot,stat)
			end
			if GetCfg.Done == 0 then
				GetCfg.Done = 1
			elseif GetCfg.Done == 1 then
				GetCfg.Done = 0
		                GetCfg.Path,GetCfg.File = "",""
			end
		end
	end
end

Checkfile = function(file)
	local f,e = io.open(file,"r")
	if f then
		local current = f:seek()
		local size = f:seek("end")
		local kb = string.format ("%-5.2f", size / 1024)
		kb = tonumber(kb)
		f:seek("set", current)
		f:close()
		if size > 1048576 then
			size = string.format ("%-5.2fMb", size / 1048576)
		elseif size > 1024  and size < 1048576 then
			size = string.format ("%-5.2f Kb", size / 1024)
		else
			size = string.format ("%-4d Bytes", size)
		end
		return size,kb
	else
	        return nil
	end
end

AddDL = function(url,target)
	if url and target then
        	local res = HttpDlAdd(url, target)
  		if res then
			SendToAll(GetCfg.Bot, " Not added")
  		else
			SendToAll(GetCfg.Bot, url..", Has Been added to download list!")
			GetCfg.Time = os.time()
			GetCfg.Count = 0
  		end
		SendToAll(GetCfg.Bot, GetStats(GetCfg.Path..GetCfg.File))
	end
end
