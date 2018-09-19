--[[ 
	Rotating Message 1.1 by jiten - for PtokaX 0.3.3.0 build 16.09 or Higher
	based on Rotating Message 1.0 by Mutor The Ugly
	Rotates n text files posted to main chat at interval
	Added: Rotates every .txt file stored in sFolder (by kepp) 
]] --

mSet = {
	sBot = "<Rotator> ",		-- Bot Name
	RunStatus = 1,			-- Auto Start -> 1=ON 0=OFF
	iDelay = 30,			-- Delay between each text file in minutes
	sFolder = "txt",		-- Folder where all the .txt files are stored (default one is in /scripts/)
	-- Don't change this
	tLoop = 1,
}

tRotate = {}

Hub = {
	-- Only send to these hubs 0=disable / 1=enable
	["127.0.0.1"] = 1,
}

Main = function()
	ReloadText()
end 

tCmds = {
	["adon"] =	
	function(hub)
		mSet.RunStatus = 1 hub:injectChat("Messages started...")
	end,
	["adoff"] =	
	function(hub)
		mSet.RunStatus = 0 hub:injectChat("Messages stopped...")
	end,
	["reload"] =
	function(hub)
		ReloadText() hub:injectChat("Textfiles loaded...")
	end,
}

dcpp:setListener("ownChatOut","commands",function(hub,message)
	local s,e,cmd = string.find(message, "^%/(%S+)" )
	if tCmds[cmd] then return 1,tCmds[cmd](hub) end
end)

dcpp:setListener("timer","rotator",function()
	if not v then v = 0 Main() end
	if mSet.RunStatus == 1 then
		v = v + 1
		DC():PrintDebug(v)
		if v == 3 then --mSet.iDelay*60 then
			for _,hub in dcpp:getHubs() do
				if Hub[hub:getAddress()] and Hub[hub:getAddress()] == 1 then
					for i in ipairs(tRotate) do
						if (i == mSet.tLoop) then
							local sContent = FileExists("scripts/"..mSet.sFolder.."/"..tRotate[i])
							if (sContent) then hub:sendChat("\r\n"..sContent) end
							if table.getn(tRotate) == i then mSet.tLoop = 1 else mSet.tLoop = mSet.tLoop + 1 end
							break
						end
					end
				end
			end
			v = 0
		end
	end
end)

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
	tRotate = nil;
	tRotate = {};
	collectgarbage();

	--// Load up files to table from folder \\--
	os.execute("dir /b scripts\\"..mSet.sFolder.."\\*.txt > scripts\\"..mSet.sFolder.."\\files.txt");
	local hFile = io.open("files.txt","r");
	local line = hFile:read();
	while line do
		table.insert(tRotate,1,line)
		line = hFile:read();
	end
	hFile:close();
	os.remove("scripts\\"..mSet.sFolder.."\\files.txt");
end

DC():PrintDebug( "*** Loaded Rotating Messager.lua ***" )