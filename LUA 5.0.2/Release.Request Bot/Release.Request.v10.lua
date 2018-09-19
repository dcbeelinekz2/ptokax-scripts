-------/-------------------------------------------------------------------------------------------------------------------------
-- Release or Request bot v1.0 by jiten (5/19/2005)
-- For PtokaX 0.3.3.0 build 17.02 or Higher
-------/-------------------------------------------------------------------------------------------------------------------------
Settings = {
	sBot = frmHub:GetHubBotName(),			-- Default Bot Name or -- sBot = "custombot"
	sFolder = "Releases",				-- Folder where the Release/Request database is stored
	regBot = 1,				-- 1 = Register Bot Name automatically, 0 = erm...
	Release = 1,				-- 1 = Act as Release Bot, 0 = Act as Request Bot
	autoClean = 1,				-- 1 = Auto clean Releases/Requests older than iClean, 0 = not
	iClean = 1,				-- Maximum time for releases to be stored (in days)
	iMax = 30,					-- Maximum releases/requests to be shown
	fRelease = "Release.tbl",			-- File where the Releases are stored
	AllowedProfile = { [2] = 0, [3] = 0, [-1] = 0, },	-- Other Profiles allowed to use bot commands (apart from OPs) -- 1 = yes; 0 = no
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
		local tCmds = {
		["add"] =	function(user,data)
				local s,e,rel,desc = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)")
				if rel == nil or desc == nil then
					user:SendData(Settings.sBot,"*** Error: Type !add <"..Mode.."> <description>")
				elseif (string.len(rel) > 26) then
					user:SendData(Settings.sBot,"*** Error: The "..Mode.." Name can't have more than 100 characters.")
				elseif (string.len(desc) > 41) then
					user:SendData(Settings.sBot,"*** Error: The Description can't have more than 20 characters.")
				else
					table.insert( Releases, { user.sName, rel, desc, os.date(),} )
					SaveToFile(Settings.sFolder.."/"..Settings.fRelease,Releases,"Releases")
					SendToAll(Settings.sBot, user.sName.." added a new "..Mode..": "..rel..". For more details type: !show")
				end
			end,
		["del"] =	function(user,data)
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
					user:SendData(Settings.sBot,"*** Error: Type !add <"..Mode.."> <description>")
				end
			end,
		["show"] =	function(user,data)
				local s,e,begin,stop = string.find(data,"%b<>%s+%S+%s+(.+)%-(.*)")
				if begin == nil or stop == nil then
					msg = ShowReleases(table.getn(Releases), table.getn(Releases) - Settings.iMax + 1, -1, 1, false, false,"\t\t\t\t\t\t\t\tLast "..Settings.iMax.." "..Mode.."s\r\n")
					user:SendPM(Settings.sBot,msg)
				else
					msg = ShowReleases(begin, stop, 1, 1, false, false, "\t\t\t\t\t\t\tShowing "..begin.."-"..stop.." of "..table.getn(Releases).." "..Mode.."s\r\n")
					user:SendPM(Settings.sBot,msg)
				end
			end,
		["find"] =	function(user,data)
				local s,e,cat,str = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)")
				if cat and str then
					user:SendPM(Settings.sBot,ShowReleases(1, table.getn(Releases), 1, 2, cat, str, "\t\t\t\t\t\t\tSearch Results of: "..cat.." "..str.."\r\n"))
				else
					user:SendData(Settings.sBot,"*** Error: Type !find <category> <string>\r\n\t\t        Category can be: date, poster, release or description")
				end
			end,
		["clear"] = function(user,data)
				Releases = nil Releases = {} SaveToFile(Settings.sFolder.."/"..Settings.fRelease,Releases,"Releases")
				user:SendData(Settings.sBot,"All "..Mode.."s have been deleted successfully")
			end,
		}
		if tCmds[cmd] then
			if Settings.AllowedProfile[sUser.iProfile] == 1 or sUser.bOperator then
				return tCmds[cmd](sUser,sData), 1
			else
				return sUser:SendData(Settings.sBot,"*** Error: You are not authorized to use this command."), 1
			end
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
		if clnd ~= 0 then SendToAll(Settings.sBot,chkd.." "..Mode.."s were processed; "..clnd.." were deleted ( "..string.format("%0.2f",((clnd*100)/chkd)).."% ) in: "..string.format("%0.4f", os.clock()-x ).." seconds.") end
	end
end

ShowReleases = function(a,z,x,mode,sCat,str,eMsg)
	local msg, border = "\r\n",string.rep("-", 250)
	msg = msg.."\t"..border.."\r\n"..eMsg.."\t"..string.rep("-- --",50).."\r\n\t\tNr.\tDate - Time\t\tPoster\t\t\t"..Mode.." - Description\r\n"
	msg = msg.."\t"..string.rep("-- --",50).."\r\n"
	for i = a, z, x do
		if Releases[i] then
			if tonumber(string.len(Releases[i][1])) < 8 then sTmp = "\t\t\t" elseif tonumber(string.len(Releases[i][1])) < 16 then sTmp = "\t\t" else sTmp = "\t" end
			if mode == 1 then
				msg = msg.."\t\t"..i..".\t"..Releases[i][4].."\t\t"..Releases[i][1]..sTmp..Releases[i][2].." - "..Releases[i][3].."\r\n"
			else
				if sCat == string.lower("poster") then where = Releases[i][1] elseif sCat == string.lower("release") or string.lower("request") then where = Releases[i][2] 
				elseif sCat == string.lower("description") then where = Releases[i][3] elseif sCat == string.lower("date") then where = Releases[i][4] end
				if string.find(where,str) then
					msg = msg.."\t\t"..i..".\t"..Releases[i][4].."\t\t"..Releases[i][1]..sTmp..Releases[i][2].." - "..Releases[i][3].."\r\n"
				end
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