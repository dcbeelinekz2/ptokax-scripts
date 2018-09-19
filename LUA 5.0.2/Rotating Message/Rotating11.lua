-- Rotating Message 1.1 by jiten - for PtokaX 0.3.3.0 build 16.09 or Higher
-- based on Rotating Message 1.0 by Mutor The Ugly
-- Rotates n text files posted to main chat at interval
-- Added: Rotates every .txt file stored in sFolder (by kepp)
-- Added: Text file sending by own trigger (Prefix - Filename)

mSet = {
	sBot = frmHub:GetHubBotName(),	-- Bot Name
	RunStatus = 0,			-- Auto Start -> 1=ON 0=OFF
	iDelay = 30,			-- Delay between each text file in minutes
	sFolder = "txt",		-- Folder where all the .txt files are stored
	-- Don't change this
	iCnt = 1,
}

sFile = {}

Main = function()
	ReloadText()
	SetTimer(mSet.iDelay*60*1000) 
	if (mSet.RunStatus == 1) then
		StartTimer()
	end
end 


ChatArrival = function(sUser, sData)
	sData=string.sub(sData,1,-2)
	local s,e,cmd = string.find(sData, "%b<>%s+[%!%?%+%#](%S+)" )
	if sUser.bOperator then
		local tCmds = {
		["adon"] =	function(user,data)
					mSet.RunStatus = 1
					user:SendData(mSet.sBot,"Messages started...")
					StartTimer()
				end,
		["adoff"] =	function(user,data)
					mSet.RunStatus = 0
					user:SendData(mSet.sBot,"Messages stopped...")
					StopTimer()
				end,
		["reload"] =	function(user,data)
					ReloadText()
					user:SendData(mSet.sBot,"Textfiles loaded...")
				end,
		}
		if tCmds[cmd] then
			return tCmds[cmd](sUser,sData),1
		else
			local sContent = FileExists(mSet.sFolder.."/"..cmd..".txt")
			if (sContent) then
				return sUser:SendData(mSet.sBot,"\r\n"..sContent),1 
			end
		end
	end
end

OnTimer = function()
	local TableSize = table.getn(sFile)
	for i=1,TableSize do
		if (i == mSet.iCnt) then
			local sContent = FileExists(mSet.sFolder.."/"..sFile[i])
			if (sContent) then
				SendToAll(mSet.sBot,"\r\n"..sContent)
			end
			if (TableSize == i) then mSet.iCnt = 1 else mSet.iCnt = mSet.iCnt + 1 end
			break
		end
	end
end

function FileExists(sFile)
	local oFile = io.open(sFile,"r");
	if (oFile) then
		local line = oFile:read("*all");
		oFile:close();
		return string.gsub(line,"\r","\r\n");
	else
		return nil;
	end
end

function ReloadText()
	sFile = nil;
	sFile = {};
	collectgarbage();

	--// Load up files to table from folder \\--
	os.execute("dir /b "..mSet.sFolder.."\\*.txt > files.txt");
	local hFile = io.open("files.txt","r");
	local line = hFile:read();
	while line do
		table.insert(sFile,1,line)
		line = hFile:read();
	end
	hFile:close();
	os.remove("files.txt");
end