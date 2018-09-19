--/-------------------------------------------------------------------
-- Heavily touched by jiten (6/21/2005)
--
-- Kick-Counter By VidFamne, with lot of help by tezlo's code 
--/-------------------------------------------------------------------
Settings = {
	sBot = frmHub:GetHubBotName(),		-- Bot Name
	iMax = 10,				-- Number of Toppers to show
	iLimit = 8,				-- Limitter for Time-counter (in minutes) to filter "short-time" visitors
	sFolder = "Topper",			-- Folder where the .tbl files are stored
	oFile = "Onliners.tbl",			-- Online related file
	tFile = "Toppers.tbl",			-- Toppers file
}

tPrefixes = {}
tOnline = { ["Onliners"] = { ["login"] = {}, ["Time"] = {} } } 
tTopper = { ["Kickers"] = {}, ["Chatters"] = {}, ["Banners"] = {}, ["Reggers"] = {}, } 

Main = function() 
	if loadfile(Settings.sFolder.."/"..Settings.oFile) then dofile(Settings.sFolder.."/"..Settings.oFile) else os.execute("mkdir "..Settings.sFolder) end
	if loadfile(Settings.sFolder.."/"..Settings.tFile) then dofile(Settings.sFolder.."/"..Settings.tFile) end
	for a,b in pairs(frmHub:GetPrefixes()) do tPrefixes[b] = 1 end
end

ChatArrival = function(curUser, sData)
	local sData=string.sub(sData,1,-2) 
	local s,e,sPrefix,cmd = string.find(sData,"%b<>%s*(%S)(%S+)")
	if sPrefix and tPrefixes[sPrefix] then
		local s,e,arg = string.find(sData, "%b<>%s+%S+%s*(%S*)")
		local tCmds = {
		["topregger"] = 
			function(curUser) Messager(curUser,"Current Top Reggers","Registered",tTopper.Reggers,false) end, 
		["topkicker"] =
			function(curUser) Messager(curUser,"Current Top Kickers","Kicks",tTopper.Kickers,false) end,
		["topchatter"] =
			function(curUser) Messager(curUser,"Current Top Chatters","Posts",tTopper.Chatters,false) end,
		["topbanner"] = 
			function(curUser) Messager(curUser,"Current Top Banners","Bans",tTopper.Banners,false) end,
		["toponliner"] =
			function(curUser)
				local indeX = {} 
				table.foreach(tOnline.Onliners.login, function(key,value) 
					for key, value in tOnline.Onliners.login do 
						for key2, value2 in tOnline.Onliners.Time do 
							if (key == key2) then 
								local minute = Jmn() 
								local diff = tonumber(value2) + minute - tonumber(value) 
								rawset(indeX, key, diff)
							end 
						end 
					end 
				end)
				Messager(curUser,"Current Top Onliner","Uptime",indeX,true)
			end,
		["mytime"] =
			function(curUser)
				local minute = Jmn() 
				local onTime = ""
				for key, value in tOnline.Onliners.login do 
					for key2, value2 in  tOnline.Onliners.Time do 
						if key == curUser.sName and key2 == curUser.sName then 
							onTime = tonumber(value2) + minute - tonumber(value) 
						end 
					end 
				end
				local days, hrs, min = Timemess(onTime) 
				curUser:SendData(Settings.sBot,"You have been "..days.." days, "..hrs.." hours and "..min.." minutes in this hub.")
			end,
		["nicktime"] =
			function(curUser,arg)
				local s,e,nick = string.find(sData, "%b<>%s+%S+%s+(%S+)")
				local minute = Jmn() local onTime ="" 
				for k, v in tOnline.Onliners.login do 
					for k2, v2 in tOnline.Onliners.Time do
						if k==nick and k2==nick then
							onTime = tonumber(v2) + minute - tonumber(v)
						elseif (tOnline.Onliners.login[nick] == nil) then
							onTime = tonumber(tOnline.Onliners.Time[nick])
						end
					end
				end 
				if onTime == nil then curUser:SendData(Settings.sBot,"*** Error: "..nick.." isn't in our records.") return 1 end 
				local days, hrs, min = Timemess(onTime)
				curUser:SendData(Settings.sBot,""..nick.." has been "..days.." days, "..hrs.." hours and "..min.." minutes in this hub." ) 
			end,
		}
		if tCmds[string.lower(cmd)] then return tCmds[string.lower(cmd)](curUser,sData),1 end
		if cmd and arg and curUser.bOperator then
			if cmd == "nickban" or cmd == "ban" then
				tTopper.Banners[curUser.sName] = tTopper.Banners[curUser.sName] or 0
				tTopper.Banners[curUser.sName] = tTopper.Banners[curUser.sName] + 1
			elseif cmd == "regreg" or cmd == "regvip" then
				tTopper.Reggers[curUser.sName] = tTopper.Reggers[curUser.sName] or 0
				tTopper.Reggers[curUser.sName] = tTopper.Reggers[curUser.sName] + 1
			end
		end
	end
	tTopper.Chatters[curUser.sName] = tTopper.Chatters[curUser.sName] or 0
	tTopper.Chatters[curUser.sName] = tTopper.Chatters[curUser.sName] + 1
end

KickArrival = function(curUser)
	tTopper.Kickers[curUser.sName] = tTopper.Kickers[curUser.sName] or 0
	tTopper.Kickers[curUser.sName] = tTopper.Kickers[curUser.sName] + 1
end

NewUserConnected = function(curUser) 
	local minute = Jmn(a) 
	tOnline.Onliners.login[curUser.sName] = tOnline.Onliners.login[curUser.sName] or 0 tOnline.Onliners.login[curUser.sName] = tonumber(minute) 
	tOnline.Onliners.Time[curUser.sName] = tOnline.Onliners.Time[curUser.sName] or 0 
	tOnline.Onliners.Time[curUser.sName] = tOnline.Onliners.Time[curUser.sName] + tonumber(minute) - tonumber(tOnline.Onliners.login[curUser.sName])  
end

OpConnected = NewUserConnected

UserDisconnected = function(curUser) 
	local minute = Jmn(a)
	if tOnline.Onliners.login[curUser.sName] == nil then 
		tOnline.Onliners.Time[curUser.sName] = nil 
	else 
		tOnline.Onliners.Time[curUser.sName] = tOnline.Onliners.Time[curUser.sName] or 0 
		tOnline.Onliners.Time[curUser.sName] = tOnline.Onliners.Time[curUser.sName] + tonumber(minute) - tonumber(tOnline.Onliners.login[curUser.sName]) 
		if tOnline.Onliners.Time[curUser.sName] <= Settings.iLimit then 
			tOnline.Onliners.Time[curUser.sName] = nil tOnline.Onliners.login[curUser.sName] = nil 
		else 
			tOnline.Onliners.login[curUser.sName] = nil  
		end 
	end 
end

OpDisconnected = UserDisconnected

OnExit = function()
	if next(tTopper) then saveTableToFile(Settings.sFolder.."/"..Settings.tFile,tTopper,"tTopper") end
	if next(tOnline) then saveTableToFile(Settings.sFolder.."/"..Settings.oFile,tOnline,"tOnline") end
end

Messager = function(curUser,Msg,Type,Table,Value)
	local Message,Index = "",{n=0} 
	Message = Message.."\r\n\r\n\t"..Msg.."\t\t\t["..os.date("%X").."]\r\n\t"..string.rep("--",55).."\r\n"
	Message = Message.."\t Nr.\t Nick:\t\t "..Type..":\r\n\t"..string.rep("--",55).."\r\n"
	table.foreach(Table, function(key, value) table.insert(Index, key) end)
	local Sort = function(a, b) return Table[a] > Table[b] end table.sort(Index, Sort)
	for i = 1, table.getn(Index) do 
		local key = Index[i]
		local days, hrs, min = Timemess(Table[key]) 
		if Value then
			Message = Message.."\t "..i..".\t "..key.."\t\t "..days.." days, "..hrs.." hours and "..min.." minutes\r\n"
		else
			Message = Message.."\t "..i..".\t "..key.."\t\t "..Table[key].."\r\n"
		end
		if i>=Settings.iMax then break end
	end
	Message = Message.."\t"..string.rep("--",55) curUser:SendData(Settings.sBot,Message)
end

Jmn = function() --(Modified Julian "minute" number. This restricts the algorithm to 1900 Mar 01 until 2100 Feb 28) 
	D = tonumber(os.date("%d")) H = tonumber(os.date("%H")) minutE = tonumber(os.date("%M"))
	Y = tonumber(os.date("%Y")) M = tonumber(os.date("%m"))
	if M <= 2 then M = M + 12 Y=Y-1 end
        mn = 1440*(math.floor(Y*365,25) + math.floor((M+1)*30,6) + D -428) + H*60 + minutE return mn
end

Timemess = function(T) 
	local min = tonumber(T) local days = math.floor(min/1440) local hrs = math.floor((min-(days*1440))/60) 
	min = math.floor(min-(days*1440)-(hrs*60)) return days, hrs, min 
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

saveTableToFile = function(file,table,tablename)
	local hFile = io.open(file,"w+") Serialize(table,tablename,hFile); hFile:close() 
end