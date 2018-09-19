-------/-------------------------------------------------------------------------------------------------------------------------
-- Release or Request bot v.1.3 by jiten (5/21/2005)
-- For PtokaX 0.3.3.0 build 17.02 or Higher
-- Thanks to Star for the ideas and bug discovery gift

--/ Some Features:

-- Ability to switch from Release to Request mode (vice-versa)
-- Releases/Requests older than x Days are automatically deleted (optional)
-- Two separate databases: one for the Requests and the other for the Releases
-- Includes a RighClick
-------/-------------------------------------------------------------------------------------------------------------------------
Settings = {
	sBot = frmHub:GetHubBotName(),			-- Default Bot Name or -- sBot = "custombot"
	iVer = "1.3",				-- Script Version
	sFolder = "Releases",				-- Folder where the Release database is stored
	rFolder = "Requests",				-- Folder where the Request database is stored
	regBot = 1,				-- 1 = Register Bot Name automatically, 0 = erm...
	iClean = 7,				-- Maximum time for releases to be stored (in days)
	iMax = 30,					-- Maximum releases/requests to be shown
	fRequest = "Request.tbl",			-- File where the Requests are stored
	fRelease = "Release.tbl",			-- File where the Releases are stored
	fConfig = "config.tbl",				-- File where the Settings are stored
	RelSize = 50,				-- Release's size
	TypeSize = 20,				-- Type's size
	pCleaner = 1,				-- 1 = Sends cleaner actions to all; 0 = doesn't
	SendRC = 1,				-- 1 = Send RighClick; 0 = Don't
	SendTo = {				-- Send RightClick to Profile [x] = (1 = on, 0 = off)
			[0] = 1,			-- Master
			[1] = 1,			-- Operator
			[2] = 1,			-- VIP
			[3] = 1,			-- REG
			[4] = 0,			-- Custom Profile
			[5] = 0,			-- Custom Profile
			[-1] = 0,			-- Unreg
		},
	-- Commands -----------------------------------------------------------------------------
	addCmd = "add", delCmd = "del", showCmd = "show", findCmd = "find", delAllCmd = "delall", 
	helpCmd = "relhelp", rDoneCmd = "reqdone", Mode = "setup",
	-----------------------------------------------------------------------------------------
	sChar = { "-", " ", "i", "l", "r", "t", "I", "y", "o", }, -- Don't change this
	tPrefixes = {},
}
Releases = {} Config = {}
-------/-------------------------------------------------------------------------------------------------------------------------
Main = function()
	if Settings.regBot == 1 then frmHub:RegBot(Settings.sBot) end
	if not loadfile(Settings.sFolder.."/"..Settings.fRelease) then os.execute("mkdir "..Settings.sFolder) io.output(Settings.sFolder.."/"..Settings.fRelease) end
	if not loadfile(Settings.rFolder.."/"..Settings.fRequest) then os.execute("mkdir "..Settings.rFolder) io.output(Settings.rFolder.."/"..Settings.fRequest) end
	if Config.Mode == nil then Config.Mode = "on" end
	if Config.Cleaner == nil then Config.Cleaner = "on" end
	if Config.Link == nil then Config.Link = "off" end
	if loadfile(Settings.fConfig) then dofile(Settings.fConfig) end
	if loadfile(Settings.rFolder.."/"..Settings.fRequest) then dofile(Settings.rFolder.."/"..Settings.fRequest) end
	if loadfile(Settings.sFolder.."/"..Settings.fRelease) then dofile(Settings.sFolder.."/"..Settings.fRelease) end
	for a,b in pairs(frmHub:GetPrefixes()) do Settings.tPrefixes[b] = 1 end
	SetTimer(1000*60*60*12) StartTimer()
end

ChatArrival = function(sUser,sData) 
	local sData = string.sub(sData,1,-2) 
	local s,e,sPrefix,cmd = string.find(sData,"%b<>%s*(%S)(%S+)")
	if sPrefix and Settings.tPrefixes[sPrefix] then
		if Config.Mode == "on" then Mode = "Release" Table = Releases elseif Config.Mode == "off" then Mode = "Request" Table = Requests end
		local tmp = "\r\n\t"..string.rep("-", 220)
		local sOpHelpOutput = tmp.."\r\n\tOperator Commands:".."\r\n\r\n"
		local sHelpOutput = tmp.."\r\n\t[Mode / Cleaner / Link]: ["..Config.Mode.." / "..Config.Cleaner.." / "..Config.Link.."]\t\t\tRelease/Request v."..Settings.iVer.." by jiten\t\t\t["..Mode.." Mode]\r\n\t"..string.rep("-",220).."\r\n\tNormal Commands:".."\r\n\r\n"
		local tCmds = {
		[Settings.addCmd] = {	function(user,data)
				local s,e,desc,rel = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)") 
				if Config.Link == "on" then s,e,link = string.find(data,"%b<>%s+%S+%s+%S+%s+%S+%s+(%S+)") end
				if (rel == nil or desc == nil) then
					user:SendData(Settings.sBot,"*** Error: Type "..sPrefix..Settings.addCmd.." <Type> <"..Mode.."> <link> (Link can be required or not)")
				else
					if (string.len(rel) > Settings.RelSize) then
						user:SendData(Settings.sBot,"*** Error: The "..Mode.." Name can't have more than "..Settings.RelSize.." characters.")
					elseif (string.len(desc) > Settings.TypeSize) then
						user:SendData(Settings.sBot,"*** Error: The Type can't have more than "..Settings.TypeSize.." characters.")
					else
						if ShowReleases(1,table.getn(Table),1,6,rel,"") ~= nil then
							if link == nil then link = "" end
							table.insert( Table, { user.sName, rel, desc, os.date(), link, } ) sCheck()
							SendToAll(Settings.sBot, user.sName.." added a new "..Mode..": "..rel..". For more details type: "..sPrefix..Settings.showCmd)
						else
							user:SendData(Settings.sBot,"*** Error: There's already a "..Mode.." named "..rel..".")
						end
					end
				end
			end, 1, "\tAdds a "..Mode, "\t\t\t"..sPrefix..Settings.addCmd.." Movie Blade3 http://www.blade.com (link is optional)", },
		[Settings.delCmd] = {	function(user,data)
				local s,e,i = string.find(data,"%b<>%s+%S+%s+(%S+)")
				if i then
					if ShowReleases(1,table.getn(Table),1,4,i,"") == nil then
						ShowReleases(1,table.getn(Table),1,4,i,"") sCheck()
						user:SendData(Settings.sBot,Mode.." "..i.." was deleted succesfully!")
					else
						user:SendData(Settings.sBot,"*** Error: There is no "..Mode.." "..i..".")
					end
				else
					user:SendData(Settings.sBot,"*** Error: Type "..sPrefix..Settings.delCmd.." <"..Mode.." number>")
				end
			end, 0, "\tDeletes single "..Mode.."s", "\t\t"..sPrefix..Settings.delCmd.." <"..Mode..">", },
		[Settings.showCmd] = { function(user,data)
				local s,e,value = string.find(data,"%b<>%s+%S+%s+(%S+)")
				if value == "all" then
					msg = ShowReleases(1, table.getn(Table), 1, 1, false, "\t\t\t\t\t\t\t\t\tShowing all "..Mode.."s ["..table.getn(Table).."]\t\t\t\t\t\t["..os.date().."]\r\n")
					user:SendPM(Settings.sBot,msg)
				else
					msg = ShowReleases(table.getn(Table) - Settings.iMax + 1, table.getn(Table), 1, 1, false, "\t\t\t\t\t\t\t\t\tLast "..Settings.iMax.." "..Mode.."s\t\t\t\t\t\t\t["..os.date().."]\r\n")
					user:SendPM(Settings.sBot,msg)
				end
			end, 1, "\tShows last "..Settings.iMax.." or all "..Mode.."s", "\t\t"..sPrefix..Settings.showCmd.."; "..sPrefix..Settings.showCmd.." all", },
		[Settings.findCmd] = { function(user,data)
				local s,e,str = string.find(data,"%b<>%s+%S+%s+(%S+)")
				if str then
					user:SendPM(Settings.sBot,ShowReleases(1, table.getn(Table), 1, 2, string.lower(str), "\t\t\t\t\t\t\t\t\tSearch Results of: "..str.."\t\t\t\t\t\t["..os.date().."]\r\n"))
				else
					user:SendData(Settings.sBot,"*** Error: Type "..sPrefix..Settings.findCmd.." <string>")
				end
			end, 1, "\tFind a "..Mode.." by any string.", "\t\t"..sPrefix..Settings.findCmd.." jiten", }, 
		[Settings.delAllCmd] = { function(user,data)
				Table = nil Table = {} sCheck()
				user:SendData(Settings.sBot,"All "..Mode.."s have been deleted successfully")
			end, 0, "\tDeletes all "..Mode.."s", "\t\t"..sPrefix..Settings.delAllCmd, },
		[Settings.helpCmd] = { function(user)
				if user.bOperator then
					user:SendData(Settings.sBot, sHelpOutput..sOpHelpOutput.."\t"..string.rep("-",220));
				else
					user:SendData(Settings.sBot, sHelpOutput.."\t"..string.rep("-",220));
				end
			end, 1, "\tDisplays this help message.", "\t\t"..sPrefix..Settings.helpCmd, },
		[Settings.rDoneCmd] = { function(user,data)
				local s,e,i = string.find(data,"%b<>%s+%S+%s+(%S+)")
				if Mode == "Request" then
					if i then
						if ShowReleases(1,table.getn(Table),1,5,i,"") == nil then
							ShowReleases(1,table.getn(Table),1,5,i,"") sCheck()
							SendToAll(Settings.sBot,user.sName.." filled up "..Mode.." "..i.."!")
						else
							user:SendData(Settings.sBot,"*** Error: There is no "..Mode.." "..i..".")
						end
					else
						user:SendData(Settings.sBot,"*** Error: Type "..sPrefix..Settings.delCmd.." <"..Mode.."> <description>")
					end
				else
					user:SendData(Settings.sBot,"*** Error: This command is only available in Request Mode.")
				end
			end, 1, "\tFills up a Request (Request Mode only)", "\t"..sPrefix..Settings.rDoneCmd.." <"..Mode..">", },
		[Settings.Mode] = { function(user,data)
				local s,e,set,value = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)")
				if not (set == nil or value == nil) then
					if set == "cleaner" then
						if value == "on" then
							Config.Cleaner = "on" SaveToFile(Settings.fConfig,Config,"Config") StartTimer() 
							user:SendData(Settings.sBot,"The Automatic "..Mode.." cleaner has been enabled.")
						elseif value == "off" then
							Config.Cleaner = "off" SaveToFile(Settings.fConfig,Config,"Config") StopTimer()
							user:SendData(Settings.sBot,"The automatic "..Mode.." cleaner has been disabled.")
						end
					elseif set == "release" then
						if value == "on" then
							Config.Mode = "on" SaveToFile(Settings.fConfig,Config,"Config")
							user:SendData(Settings.sBot,"Release Mode has been enabled.")
						elseif value == "off" then
							Config.Mode = "off" SaveToFile(Settings.fConfig,Config,"Config")
							user:SendData(Settings.sBot,"Request Mode has been enabled.")
						end
					elseif set == "link" then
						if value == "on" then
							Config.Link = "on" SaveToFile(Settings.fConfig,Config,"Config")
							user:SendData(Settings.sBot,"The Link has been set to not optional.")
						elseif value == "off" then
							Config.Mode = "off" SaveToFile(Settings.fConfig,Config,"Config")
							user:SendData(Settings.sBot,"The Link has been set to optional.")
						end
					end
				else
					user:SendData(Settings.sBot,"*** Error: Type "..sPrefix..Settings.Mode.." <release/link/cleaner> <on/off>")
				end
			end, 0, "\tConfigure this bot.", "\t\t\t"..sPrefix..Settings.Mode.." <release/link/cleaner> <on/off>", },
		}
		for sCmd, tCmd in tCmds do
			if(tCmd[2] == 1) then sHelpOutput   = sHelpOutput.."\t"..sPrefix..sCmd.."\t "..tCmd[3].."\t "..tCmd[4].."\r\n";
			else sOpHelpOutput = sOpHelpOutput.."\t"..sPrefix..sCmd.."\t "..tCmd[3].."\t "..tCmd[4].."\r\n"; end
		end
		if tCmds[cmd] then
			if tCmds[cmd][2] == 1 or sUser.bOperator then return tCmds[cmd][1](sUser,sData), 1
			else return sUser:SendData(Settings.sBot,"*** Error: You are not authorized to use this command."), 1 end
		end
	end
end

ToArrival = ChatArrival

OnTimer = function()
	if (Config.Cleaner == 1) then -- RegCleaner based
		local juliannow = jdate(tonumber(os.date("%d")), tonumber(os.date("%m")), tonumber(os.date("%Y"))) 
		local oldest, chkd, clnd, x = Settings.iClean, 0, 0, os.clock()
		for i = 1, table.getn(Table) do
			chkd = chkd + 1 local s, e, month, day, year = string.find(Table[i][4], "(%d+)%/(%d+)%/(%d+)"); 
			local julian = jdate( tonumber(day), tonumber(month), tonumber("20"..year) )
			if ((juliannow - julian) > oldest) then clnd = clnd + 1 Table[i] = nil sCheck() end; 
		end
		if clnd ~= 0 and Settings.pCleaner == 1 then SendToAll(Settings.sBot,chkd.." "..Mode.."s were processed. "..clnd.." "..Mode.."s were deleted as they were more than "..Settings.iClean.." days old. ( "..string.format("%0.2f",((clnd*100)/chkd)).."% ) in: "..string.format("%0.4f", os.clock()-x ).." seconds.") end
	end
end

NewUserConnected = function(sUser)
	if Settings.SendTo[sUser.iProfile] == 1 and Settings.SendRC == 1 then
		if sUser.bUserCommand then
			if sUser.bOperator then
				sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Delete all$<%[mynick]> !delall&#124;|")
				sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Delete single$<%[mynick]> !del %[line:Release Name]&#124;|")
				sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Setup\\Cleaner$<%[mynick]> !setup cleaner %[line:on/off]&#124;|")
				sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Setup\\Link$<%[mynick]> !setup link %[line:on/off]&#124;|")
				sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Setup\\Release$<%[mynick]> !setup release %[line:on/off]&#124;|")
			end
			sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Show last "..Settings.iMax.."$<%[mynick]> !show&#124;|")
			sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Show all<%[mynick]> !show all&#124;|")
			sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Fill up request$<%[mynick]> !reqdone %[line:Request Name]&#124;|")
			sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Help$<%[mynick]> !relhelp&#124;|")
			sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Find$<%[mynick]> !find %[line:String]&#124;|")
			sUser:SendData("$UserCommand 1 3 Release/Request Bot\\Add$<%[mynick]> !add %[line:Type] %[line:Release] %[line:Link]&#124;|")
		end
	end
end

OpConnected = NewUserConnected

sCheck = function()
	if Config.Mode == "on" then SaveToFile(Settings.sFolder.."/"..Settings.fRelease,Releases,"Releases") 
	elseif Config.Mode == "off" then SaveToFile(Settings.rFolder.."/"..Settings.fRequest,Requests,"Requests") end
end

ShowReleases = function(a,z,x,mode,str,eMsg)
	local msg, border = "\r\n",string.rep("-", 300)
	msg = msg.."\t"..border.."\r\n"..eMsg.."\t"..string.rep("-- --",60).."\r\n\t mm/dd/yy - hh:mm:ss\tPoster\t\tType\t\t\t"..Mode.."\t\t\t\t\t\tInformation Link\r\n"
	msg = msg.."\t"..string.rep("-- --",60).."\r\n"
	for i = a, z, x do
		if Table[i] then
			if mode == 1 then
				msg = msg.."\t   "..Table[i][4].."\t"..Table[i][1]..DoTabs(1,10)..Table[i][2]..DoTabs(1,CheckSize(Table[i][2]))..Table[i][3]..DoTabs(2,55)..Table[i][5].."\r\n"
			elseif mode == 2 then
				where = string.lower(Table[i][1]..Table[i][2]..Table[i][3]..Table[i][4]..Table[i][5])
				if string.find(where,str) then
					msg = msg.."\t   "..Table[i][4].."\t"..Table[i][1]..DoTabs(1,10)..Table[i][2]..DoTabs(1,CheckSize(Table[i][2]))..Table[i][3]..DoTabs(2,55)..Table[i][5].."\r\n"
				end
			elseif mode == 3 then
				if Table[a] and Table[z] then Table[i] = nil return nil end
			elseif mode == 4 then
				if Table[i][2] == str then table.remove(Table,i) return nil end
			elseif mode == 5 then
				if Table[i][2] == str then table.remove(Table,i) return nil end
			elseif mode == 6 then
				if Table[i][2] == str then return nil end
			end
		end
	end
	msg = msg.."\t"..border.."\r\n" return msg
end

jdate = function(d, m, y)
	local a, b, c = 0, 0, 0 if m <= 2 then y = y - 1; m = m + 12; end 
	if (y*10000 + m*100 + d) >= 15821015 then a = math.floor(y/100); b = 2 - a + math.floor(a/4) end
	if y <= 0 then c = 0.75 end return math.floor(365.25*y - c) + math.floor(30.6001*(m+1) + d + 1720994 + b)
end

DoTabs = function(Type, size) -- nErBoS Release bot based
	local sTmp = "" 
	if (Type == 1) then
		if (size < 8) then sTmp = "\t\t\t" elseif (size < 16) then sTmp = "\t\t" else sTmp = "\t" end return sTmp
	elseif (Type == 2) then
		if (size < 8) then sTmp = string.rep("\t",12) elseif (size < 16) then sTmp = string.rep("\t",11)  elseif (size < 24) then sTmp = string.rep("\t",10) 
		elseif (size < 32) then sTmp = string.rep("\t",9) elseif (size < 40) then sTmp = string.rep("\t",8) elseif (size < 48) then sTmp = string.rep("\t",7)
		elseif (size < 56) then sTmp = string.rep("\t",6) elseif (size < 64) then sTmp = string.rep("\t",5) elseif (size < 72) then sTmp = "\t\t\t\t"
		elseif (size < 80) then sTmp = "\t\t\t" elseif (size < 88) then sTmp = "\t\t" else sTmp = "\t" end return sTmp
	end
end

CheckSize = function(String) -- nErBoS Release bot based
	local realSize,aux,remove = string.len(String),1,0
	while aux < realSize + 1 do
		for i=1, table.getn(Settings.sChar) do if (string.sub(String,aux,aux) == Settings.sChar[i]) then remove = remove + 0.5 end end
		aux = aux + 1
	end return realSize - remove
end

Serialize = function(tTable,sTableName,hFile,sTab)
	sTab = sTab or "";
	hFile:write(sTab..sTableName.." = {\n");
	for key,value in tTable do
		if (type(value) ~= "function") then
			local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
			if(type(value) == "table") then
				Serialize(value,sKey,hFile,sTab.."\t");
			else
				local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
				hFile:write(sTab.."\t"..sKey.." = "..sValue);
			end
			hFile:write(",\n");
		end
	end
	hFile:write(sTab.."}");
end

SaveToFile = function(file,table,tablename)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end
---------------------------------------------------------------------------------------------------------------------------------