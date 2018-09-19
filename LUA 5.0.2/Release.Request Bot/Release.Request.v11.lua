-------/-------------------------------------------------------------------------------------------------------------------------
-- Release or Request bot v1.1 by jiten (5/20/2005)
-- For PtokaX 0.3.3.0 build 17.02 or Higher
-------/-------------------------------------------------------------------------------------------------------------------------
Settings = {
	sBot = frmHub:GetHubBotName(),			-- Default Bot Name or -- sBot = "custombot"
	iVer = "1.1",				-- Script Version
	sFolder = "Releases",				-- Folder where the Release/Request database is stored
	regBot = 1,				-- 1 = Register Bot Name automatically, 0 = erm...
	Release = 0,				-- 1 = Act as Release Bot, 0 = Act as Request Bot
	autoClean = 1,				-- 1 = Auto clean Releases/Requests older than iClean, 0 = not
	iClean = 7,				-- Maximum time for releases to be stored (in days)
	iMax = 30,					-- Maximum releases/requests to be shown
	fRelease = "Release.tbl",			-- File where the Releases are stored
	RelSize = 18,				-- Release's size
	DescSize = 20,				-- Description's size
	pCleaner = 1,				-- 1 = Sends cleaner actions to all; 0 = doesn't
	-- Commands -----------------------------------------------------------------------------
	addCmd = "add", delCmd = "del", showCmd = "show", findCmd = "find",
	delAllCmd = "delall", helpCmd = "relhelp", clnCmd = "cleaner", rDoneCmd = "reqdone",
	-----------------------------------------------------------------------------------------
	tPrefixes = {},
}
Releases = {}
-------/-------------------------------------------------------------------------------------------------------------------------
Main = function()
	if regBot == 1 then frmHub:RegBot(Settings.sBot) end
	if not loadfile(Settings.sFolder.."/"..Settings.fRelease) then os.execute("mkdir "..Settings.sFolder) end
	if loadfile(Settings.sFolder.."/"..Settings.fRelease) then dofile(Settings.sFolder.."/"..Settings.fRelease) end
	for a,b in pairs(frmHub:GetPrefixes()) do Settings.tPrefixes[b] = 1 end
	if Settings.Release == 1 then Mode = "Release" else Mode = "Request" end
	SetTimer(1000*60*60*12) StartTimer()
end

ChatArrival = function(sUser,sData) 
	local sData = string.sub(sData,1,-2) 
	local s,e,sPrefix,cmd = string.find(sData,"%b<>%s*(%S)(%S+)")
	if sPrefix and Settings.tPrefixes[sPrefix] then
		local tmp = "\r\n\t"..string.rep("-", 220)
		local sOpHelpOutput = tmp.."\r\n\t\t\t\t\t\tRelease/Request v."..Settings.iVer.." bot by jiten\t\t\t("..Mode.." Mode)\r\n\t"..string.rep("-",220).."\r\n\tOperator Commands:".."\r\n\r\n"
		local sHelpOutput = tmp.."\r\n\tNormal Commands:".."\r\n\r\n"
		local tCmds = {
		[Settings.addCmd] = {	function(user,data)
				local s,e,rel,desc = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)") local s,e,link = string.find(data,"%b<>%s+%S+%s+%S+%s+%S+%s+(%S+)")
				if (rel == nil or desc == nil) then
					user:SendData(Settings.sBot,"*** Error: Type "..sPrefix..Settings.addCmd.." <"..Mode.."> <description> <link> (link is optional)")
				else
					if (string.len(rel) > Settings.RelSize) then
						user:SendData(Settings.sBot,"*** Error: The "..Mode.." Name can't have more than "..Settings.RelSize.." characters.")
					elseif (string.len(desc) > Settings.DescSize) then
						user:SendData(Settings.sBot,"*** Error: The Description can't have more than "..Settings.DescSize.." characters.")
					else
						if link == nil then link = "(empty)" end
						table.insert( Releases, { user.sName, rel, desc, os.date(), link, } )
						SaveToFile(Settings.sFolder.."/"..Settings.fRelease,Releases,"Releases")
						SendToAll(Settings.sBot, user.sName.." added a new "..Mode..": "..rel..". For more details type: "..sPrefix..Settings.showCmd)
					end
				end
			end, 1, "\tAdds a "..Mode..". Example: "..sPrefix..Settings.addCmd.." Blade3 Movie http://www.blade.com (link is optional)", },
		[Settings.delCmd] = {	function(user,data)
				local s,e,begin,stop = string.find(data,"%b<>%s+%S+%s+(.+)%-(.*)")
				if not (begin == nil and stop == nil) then
					ShowReleases(begin, stop, 1, 3, false,"")
					SaveToFile(Settings.sFolder.."/"..Settings.fRelease,Releases,"Releases")
				else
					local s,e,i = string.find(data,"%b<>%s+%S+%s+(%S+)")
					if i then
						if Releases[tonumber(i)] then
							table.remove(Releases,i)
							SaveToFile(Settings.sFolder.."/"..Settings.fRelease,Releases,"Releases")
							user:SendData(Settings.sBot,Mode.." "..i..". was deleted succesfully!")
						else
							user:SendData(Settings.sBot,"*** Error: There is no "..Mode.." "..i..".")
						end
					else
						user:SendData(Settings.sBot,"*** Error: Type "..sPrefix..Settings.delCmd.." <"..Mode.." number>")
					end
				end
			end, 0, "\tDeletes single or multiple "..Mode.."s. Example: "..sPrefix..Settings.delCmd.." 15; "..sPrefix..Settings.delCmd.." 1-2", },
		[Settings.showCmd] = { function(user,data)
				local s,e,begin,stop = string.find(data,"%b<>%s+%S+%s+(.+)%-(.*)")
				if begin == nil or stop == nil then
					msg = ShowReleases(table.getn(Releases), table.getn(Releases) - Settings.iMax + 1, -1, 1, false, "\t\t\t\t\t\t\t\tLast "..Settings.iMax.." "..Mode.."s\r\n")
					user:SendPM(Settings.sBot,msg)
				else
					msg = ShowReleases(begin, stop, 1, 1, false, "\t\t\t\t\t\t\tShowing "..begin.."-"..stop.." of "..table.getn(Releases).." "..Mode.."s\r\n")
					user:SendPM(Settings.sBot,msg)
				end
			end, 1, "\tShows all/group of "..Mode.."s. Example: "..sPrefix..Settings.showCmd.."; "..sPrefix..Settings.showCmd.." 10-15" },
		[Settings.findCmd] = { function(user,data)
				local s,e,str = string.find(data,"%b<>%s+%S+%s+(%S+)")
				if str then
					user:SendPM(Settings.sBot,ShowReleases(1, table.getn(Releases), 1, 2, str, "\t\t\t\t\t\t\tSearch Results of: "..str.."\r\n"))
				else
					user:SendData(Settings.sBot,"*** Error: Type "..sPrefix..Settings.findCmd.." <category> <string>\r\n\t\t        Category can be: date, poster, release or description")
				end
			end, 1, "\tFind a "..Mode.." by any category (date, poster, release, description, link). Example: "..sPrefix..Settings.findCmd.." jiten", }, 
		[Settings.delAllCmd] = { function(user,data)
				Releases = nil Releases = {} SaveToFile(Settings.sFolder.."/"..Settings.fRelease,Releases,"Releases")
				user:SendData(Settings.sBot,"All "..Mode.."s have been deleted successfully")
			end, 0, "\tDeletes all "..Mode.."s", },
		[Settings.helpCmd] = { function(user)
				if user.bOperator then
					user:SendData(Settings.sBot, sOpHelpOutput..sHelpOutput.."\t"..string.rep("-",220));
				else
					user:SendData(Settings.sBot, sHelpOutput.."\t"..string.rep("-",220));
				end
			end, 1, "\tDisplays this help message.", },
		[Settings.clnCmd] = { function(user,data,mode)
				local s,e,stat = string.find(data,"%b<>%s+%S+%s+(%S+)")
				if stat == "on" then StartTimer() user:SendData(Settings.sBot,"The "..Mode.."s automatic cleaner has been enabled.")
				elseif stat == "off" then StopTimer() user:SendData(Settings.sBot,"The "..Mode.."s automatic cleaner has been disabled.")
				else user:SendData(Settings.sBot,"*** Error: Type "..sPrefix..Settings.clnCmd.." <on/off>") end
			end, 0, "\tSet "..Mode.."s automatic cleaner status. Example: "..sPrefix..Settings.clnCmd.." off; "..sPrefix..Settings.clnCmd.." on", },
		[Settings.rDoneCmd] = { function(user,data)
				local s,e,i = string.find(data,"%b<>%s+%S+%s+(%S+)")
				if Mode == "Request" then
					if i then
						if Releases[tonumber(i)] then
							if Releases[tonumber(i)][1] == user.sName then
								table.remove(Releases,i)
								SaveToFile(Settings.sFolder.."/"..Settings.fRelease,Releases,"Releases")
								SendToAll(Settings.sBot,user.sName.." got the "..Mode.." "..i.."!")
							else
								user:SendData(Settings.sBot,"*** Error: You can't complete "..Mode.." "..i..". as you aren't its poster.")
							end
						else
							user:SendData(Settings.sBot,"*** Error: There is no "..Mode.." "..i..".")
						end
					else
						user:SendData(Settings.sBot,"*** Error: Type "..sPrefix..Settings.delCmd.." <"..Mode.."> <description>")
					end
				else
					user:SendData(Settings.sBot,"*** Error: This command is only available in Request Mode.")
				end
			end, 1, "\tCompletes a previous Request (only available in Request Mode). Example: "..sPrefix..Settings.rDoneCmd.." 15", },
		}
		for sCmd, tCmd in tCmds do
			if(tCmd[2] == 1) then sHelpOutput   = sHelpOutput.."\t"..sPrefix..sCmd.."\t "..tCmd[3].."\r\n";
			else sOpHelpOutput = sOpHelpOutput.."\t"..sPrefix..sCmd.."\t "..tCmd[3].."\r\n"; end
		end
		if tCmds[cmd] then
			if tCmds[cmd][2] == 1 or sUser.bOperator then return tCmds[cmd][1](sUser,sData), 1
			else return sUser:SendData(Settings.sBot,"*** Error: You are not authorized to use this command."), 1 end
		end
	end
end

ToArrival = ChatArrival

OnTimer = function()
	if (Settings.autoClean == 1) then -- RegCleaner based
		local juliannow = jdate(tonumber(os.date("%d")), tonumber(os.date("%m")), tonumber(os.date("%Y"))) 
		local oldest, chkd, clnd, x = Settings.iClean, 0, 0, os.clock()
		for i = 1, table.getn(Releases) do
			chkd = chkd + 1 
			local s, e, month, day, year = string.find(Releases[i][4], "(%d+)%/(%d+)%/(%d+)"); 
			local julian = jdate( tonumber(day), tonumber(month), tonumber("20"..year) )
			if ((juliannow - julian) > oldest) then 
				clnd = clnd + 1
				Releases[i] = nil
				SaveToFile(Settings.sFolder.."/"..Settings.fRelease,Releases,"Releases")
			end; 
		end
		if clnd ~= 0 and Settings.pCleaner == 1 then SendToAll(Settings.sBot,chkd.." "..Mode.."s were processed. "..clnd.." "..Mode.."s were deleted as they were more than "..Settings.iClean.." days old. ( "..string.format("%0.2f",((clnd*100)/chkd)).."% ) in: "..string.format("%0.4f", os.clock()-x ).." seconds.") end
	end
end

ShowReleases = function(a,z,x,mode,str,eMsg)
	local msg, border = "\r\n",string.rep("-", 250)
	msg = msg.."\t"..border.."\r\n"..eMsg.."\t"..string.rep("-- --",50).."\r\n\t   Nr.\tDate - Time\t\tPoster\t\t"..Mode.."\t\tDescription\tLink\r\n"
	msg = msg.."\t"..string.rep("-- --",50).."\r\n"
	for i = a, z, x do
		if Releases[i] then
			DoTabs = function(cat) local sTmp = "" if tonumber(string.len(cat)) < 9 then sTmp = "\t\t" elseif tonumber(string.len(cat)) < 16 then sTmp = "\t" else sTmp = "\t" end return sTmp end
			if mode == 1 then
				msg = msg.."\t   "..i..".\t"..Releases[i][4].."\t\t"..Releases[i][1]..DoTabs(Releases[i][1])..Releases[i][2]..DoTabs(Releases[i][2])..Releases[i][3]..DoTabs(Releases[i][3])..Releases[i][5].."\r\n"
			elseif mode == 2 then
				where = Releases[i][1]..Releases[i][2]..Releases[i][3]..Releases[i][4]..Releases[i][5]
				if string.find(where,str) then
					msg = msg.."\t   "..i..".\t"..Releases[i][4].."\t\t"..Releases[i][1]..DoTabs(Releases[i][1])..Releases[i][2].."\t\t"..Releases[i][3]..DoTabs(Releases[i][3])..Releases[i][5].."\r\n"
				end
			elseif mode == 3 then
				Releases[i] = nil
			end
		end
	end
	msg = msg.."\t"..border.."\r\n" return msg
end

jdate = function(d, m, y)
	local a, b, c = 0, 0, 0
	if m <= 2 then y = y - 1; m = m + 12; end
	if (y*10000 + m*100 + d) >= 15821015 then a = math.floor(y/100); b = 2 - a + math.floor(a/4) end
	if y <= 0 then c = 0.75 end return math.floor(365.25*y - c) + math.floor(30.6001*(m+1) + d + 1720994 + b)
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