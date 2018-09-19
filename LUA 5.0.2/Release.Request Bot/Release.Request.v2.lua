-------/-------------------------------------------------------------------------------------------------------------------------
-- Release or Request bot v.2 by jiten (12/14/2005)
-- For PtokaX 0.3.3.0 build 17.02 or Higher

-- Thanks to Star for the ideas and bug discovery gift

--/ Some Features:
-- Ability to switch from Release to Request mode (vice-versa)
-- Releases/Requests older than x Days are automatically deleted (optional)
-- Two separate databases: one for the Requests and the other for the Releases
-- Includes a RighClick

-- NOTE: For those who want to run a Release and Request bot at the same time, start the first script and set it to Release Mode.
-- Then, open the other one and set it to Request Mode. And voila...
-- Remember to verify if the commands are different from each other. 
-------/-------------------------------------------------------------------------------------------------------------------------
Settings = {
	sBot = frmHub:GetHubBotName(),		-- Default Bot Name or -- sBot = "custombot"
	iVer = "2",				-- Script Version
	sFolder = "Releases",			-- Folder where the Release database is stored
	rFolder = "Requests",			-- Folder where the Request database is stored
	Mode = "Request",			-- Release = Act as Release bot; Request = Act as Request Bot
	sTimer = 1,				-- 1 = Start Timer automatically; 0 = don't
	regBot = 0,				-- 1 = Register Bot Name automatically, 0 = erm...
	iClean = 7,				-- Maximum time for releases to be stored (in days)
	iMax = 30,				-- Maximum releases/requests to be shown
	rMax = 30,				-- Maximum Filled Requests to be shown
	fRequest = "Request.tbl",		-- File where the Requests are stored
	fRelease = "Release.tbl",		-- File where the Releases are stored
	fReqDone = "ReqDone.tbl",		-- File where the Requests done are stored
	fConfig = "config.tbl",			-- File where the Settings are stored
	RelSize = 90,				-- Release's size
	TypeSize = 20,				-- Type's size
	cDelay = 12,				-- Cleaner Checking Delay (in hours)
	pCleaner = 1,				-- 1 = Sends cleaner actions to all; 0 = doesn't
	Sensitive = 0,				-- 1: Searches case-sensitive; 0: not case-sensitive
	SendRC = 1,				-- 1 = Send RighClick; 0 = Don't
	SendTo = {				-- Send RightClick to Profile [x] = (1 = on, 0 = off)
			[0] = 1,			-- Master
			[1] = 1,			-- Operator
			[2] = 1,			-- VIP
			[3] = 1,			-- REG
			[4] = 0,			-- Custom Profile
			[5] = 1,			-- Custom Profile
			[-1] = 0,			-- Unreg
		},
	-- Commands -------------------------------------------------------------------------------------------------------------
	doPrefix = 0,				-- 1: Normal commands; 0: Commands with Prefix (Default)
	RelPrefix = "rel",			-- Release Commands Prefix
	ReqPrefix = "req",			-- Request Commands Prefix
	addCmd = "add", delCmd = "del", showCmd = "show", findCmd = "find", delAllCmd = "delall",
	helpCmd = "help", rDoneCmd = "done", SetupCmd = "setup",
	--------------------------------------------------------------------------------------------------------------------------
	sChar = { "-", " ", "i", "l", "r", "t", "I", "y", "o", }, -- Don't change this
	tPrefixes = {},
}
Release = {} Config = {} Request = {} ReqDone = {}
-- If you're using PtokaX's default profiles it should be like this:

-- Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [0] = 5 }
-- If you're using Robocop profiles don't change this.
Levels = { [-1] = 1, [3] = 2, [2] = 3, [1] = 4, [4] = 5, [0] = 6, [5] = 7, }
-------/-------------------------------------------------------------------------------------------------------------------------

Main = function()
	-- Register sBot
	if Settings.regBot == 1 then frmHub:RegBot(Settings.sBot) end
	-- Create Folder and Files if they don't exist
	if not loadfile(Settings.sFolder.."/"..Settings.fRelease) then os.execute("mkdir "..Settings.sFolder) io.output(Settings.sFolder.."/"..Settings.fRelease) end
	if not loadfile(Settings.rFolder.."/"..Settings.fRequest) then os.execute("mkdir "..Settings.rFolder) io.output(Settings.rFolder.."/"..Settings.fRequest) end
	-- Add PtokaX's default prefixes to custom table
	for a,b in pairs(frmHub:GetPrefixes()) do Settings.tPrefixes[b] = 1 end sCheck(1)
	-- Auto-deleting timer setup
	SetTimer(Settings.cDelay*60*60*1000) if Settings.sTimer == 1 then StartTimer() end
end

ChatArrival = function(sUser,sData) 
	local sData = string.sub(sData,1,-2) 
	local s,e,sPrefix,cmd = string.find(sData,"%b<>%s*(%S)(%S+)")
	-- Commands sent to Main or to sBot
	if (string.sub(sData,1,1) == "<") or (string.sub(sData,1,5+string.len(Settings.sBot)) == "$To: "..Settings.sBot) then
		-- If used prefix and cmd exists in custom table
		if sPrefix and Settings.tPrefixes[sPrefix] and tCmds[cmd] then
			-- Table setup according to selected mode
			if Settings.Mode == "Release" then Value = "on" Table = Release elseif Settings.Mode == "Request" then Value = "off" Table = Request end
			-- If specific command profile permission is lower than user's profile
			if tCmds[cmd][2] <= Levels[sUser.iProfile] then
				return tCmds[cmd][1](sUser,sData), 1
			else
				return sUser:SendData(Settings.sBot,"*** Error: You are not authorized to use this command."), 1
			end
		end
	end
end

ToArrival = ChatArrival

-- Prefix setup according to selected mode and custom changes
if Settings.Mode == "Release" then
	if Settings.doPrefix ~= 1 then mPrefix = Settings.RelPrefix else mPrefix = "" end 
elseif Settings.Mode == "Request" then
	if Settings.doPrefix ~= 1 then mPrefix = Settings.ReqPrefix else mPrefix = "" end
end

tOptional = function()
	Config.Cleaner = Config.Cleaner or "on" Config.Link = Config.Link or "off"
	-- Table content loading according to the selected mode
	if Settings.Mode == "Request" then
		if loadfile(Settings.rFolder.."/"..Settings.fConfig) then dofile(Settings.rFolder.."/"..Settings.fConfig) end
		if loadfile(Settings.rFolder.."/"..Settings.fRequest) then dofile(Settings.rFolder.."/"..Settings.fRequest) end
		if loadfile(Settings.rFolder.."/"..Settings.fReqDone) then dofile(Settings.rFolder.."/"..Settings.fReqDone) end
	elseif Settings.Mode == "Release" then
		if loadfile(Settings.sFolder.."/"..Settings.fConfig) then dofile(Settings.sFolder.."/"..Settings.fConfig) end
		if loadfile(Settings.sFolder.."/"..Settings.fRelease) then dofile(Settings.sFolder.."/"..Settings.fRelease) end
	end
	-- Link Status
	if Config.Link == "on" then return "not " elseif Config.Link == "off" then return "" end
end

sCheck = function(Mode)
	-- Releases/Request saving
	if Mode == nil then
		if Settings.Mode == "Release" then SaveToFile(Settings.sFolder.."/"..Settings.fRelease,Release,"Release") elseif Settings.Mode == "Request" then SaveToFile(Settings.rFolder.."/"..Settings.fRequest,Request,"Request") SaveToFile(Settings.rFolder.."/"..Settings.fReqDone,ReqDone,"ReqDone") end
	elseif Mode == 1 then
		if Settings.Mode == "Release" then SaveToFile(Settings.sFolder.."/"..Settings.fConfig,Config,"Config") elseif Settings.Mode == "Request" then SaveToFile(Settings.rFolder.."/"..Settings.fConfig,Config,"Config") end
	end
end

tCmds = {
	[mPrefix..Settings.addCmd] = {	
		function(user,data)
			local s,e,cat,rel = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)") 
			local s,e,link = string.find(data,"%b<>%s+%S+%s+%S+%s+%S+%s+(%S+)") 
			local linkCheck = function()
				-- rel size checkpoint
				if (string.len(rel) > Settings.RelSize) then
					user:SendData(Settings.sBot,"*** Error: The "..Settings.Mode.." Name can't have more than "..Settings.RelSize.." characters.")
				-- cat size checkpoint
				elseif (string.len(cat) > Settings.TypeSize) then
					user:SendData(Settings.sBot,"*** Error: The Type can't have more than "..Settings.TypeSize.." characters.")
				else
					-- If rel doesn't exist in database
					if ShowReleases(1,table.getn(Table),1,4,rel,"",Table) ~= nil then
						-- Release/Request Added
						if link == nil then link = "" end table.insert( Table, { user.sName, rel, cat, os.date(), link, } ) sCheck() link = nil
						SendToAll(Settings.sBot, user.sName.." added a new "..Settings.Mode..": "..rel..". For more details type: !"..mPrefix..Settings.showCmd)
					else
						user:SendData(Settings.sBot,"*** Error: There's already a "..Settings.Mode.." named "..rel..".")
					end
				end
			end
			-- Data sent according to Link status
			if Config.Link == "on" then 
				if (link == nil) then user:SendData(Settings.sBot,"*** Error: Type !"..mPrefix..Settings.addCmd.." <Type> <"..Settings.Mode.."> <link> (Link is required)") else linkCheck() end
			else
				if (rel == nil or cat == nil) then user:SendData(Settings.sBot,"*** Error: Type !"..mPrefix..Settings.addCmd.." <Type> <"..Settings.Mode.."> <link> (Link is optional)") else linkCheck() end
			end
		end, 3, "Adds a "..Settings.Mode, "!"..mPrefix..Settings.addCmd.." Movie Blade3 http://www.blade.com (link is "..tOptional().."optional)",
		"$UserCommand 1 3 "..Settings.Mode.." Bot\\Add$<%[mynick]> !"..mPrefix..Settings.addCmd.." %[line:Type] %[line:Release] %[line:Link]" },
	[mPrefix..Settings.delCmd] = {	
		function(user,data)
			local s,e,i = string.find(data,"%b<>%s+%S+%s+(%S+)")
			if i then
				-- If specified ID exists
				if ShowReleases(1,table.getn(Table),1,3,i,"",Table) == nil then
					ShowReleases(1,table.getn(Table),1,3,i,"",Table) sCheck()
					user:SendData(Settings.sBot,Settings.Mode.." "..i.." was deleted succesfully!")
				else
					user:SendData(Settings.sBot,"*** Error: There is no "..Settings.Mode.." "..i..".")
				end
			else
				user:SendData(Settings.sBot,"*** Error: Type !"..mPrefix..Settings.delCmd.." <"..Settings.Mode..">")
			end
		end, 4, "Deletes single "..Settings.Mode.."s", "!"..mPrefix..Settings.delCmd.." <"..Settings.Mode..">",
		"$UserCommand 1 3 "..Settings.Mode.." Bot\\Delete single$<%[mynick]> !"..mPrefix..Settings.delCmd.." %[line:Release Name]" },
	[mPrefix..Settings.showCmd] = { 
		function(user,data)
			local s,e,value = string.find(data,"%b<>%s+%S+%s+(%S+)")
			-- Shows all
			if value == "all" then
				-- Data sent according to Selected mode and if ReqDone isn't empty
				if Settings.Mode == "Request" and next(ReqDone) then
					user:SendPM(Settings.sBot,ShowReleases(1, table.getn(Table), 1, 1, false, string.rep("\t",9).."Showing all "..Settings.Mode.."s ["..table.getn(Table).."]"..string.rep("\t",7).."["..os.date().."]\r\n",Table)..(ShowReleases(1, table.getn(ReqDone), 1, 1, false, string.rep("\t",9).."Showing all Filled Requests ["..table.getn(ReqDone).."]"..string.rep("\t",6).."["..os.date().."]\r\n",ReqDone)))
				else
					user:SendPM(Settings.sBot,ShowReleases(1, table.getn(Table), 1, 1, false, string.rep("\t",9).."Showing all "..Settings.Mode.."s ["..table.getn(Table).."]"..string.rep("\t",7).."["..os.date().."]\r\n",Table))
				end
			else
				-- Data sent according to Selected mode and if ReqDone isn't empty
				if Settings.Mode == "Request" and next(ReqDone) then
					user:SendPM(Settings.sBot,ShowReleases(table.getn(Table) - Settings.iMax + 1, table.getn(Table), 1, 1, false, string.rep("\t",9).."Last "..Settings.iMax.." "..Settings.Mode.."s"..string.rep("\t",8).."["..os.date().."]\r\n",Table)..ShowReleases(table.getn(ReqDone) - Settings.rMax + 1, table.getn(ReqDone), 1, 1, false, string.rep("\t",9).."Last "..Settings.rMax.." Filled Requests"..string.rep("\t",7).."["..os.date().."]\r\n",ReqDone))
				else
					user:SendPM(Settings.sBot,ShowReleases(table.getn(Table) - Settings.iMax + 1, table.getn(Table), 1, 1, false, string.rep("\t",9).."Last "..Settings.iMax.." "..Settings.Mode.."s"..string.rep("\t",8).."["..os.date().."]\r\n",Table))
				end
			end
		end, 1, "Shows last "..Settings.iMax.." or all "..Settings.Mode.."s", "!"..mPrefix..Settings.showCmd.."; !"..mPrefix..Settings.showCmd.." all",
		"$UserCommand 1 3 "..Settings.Mode.." Bot\\Show last "..Settings.iMax.."/All$<%[mynick]> !"..mPrefix..Settings.showCmd.." %[line:Empty/All]" },
	[mPrefix..Settings.findCmd] = { 
		function(user,data)
			local s,e,str = string.find(data,"%b<>%s+%S+%s+(%S+)")
			if str then
				-- Find
				user:SendPM(Settings.sBot,ShowReleases(1, table.getn(Table), 1, 2, str, string.rep("\t",9).."Search Results of: "..str..string.rep("\t",7).."["..os.date().."]\r\n",Table))
			else
				user:SendData(Settings.sBot,"*** Error: Type !"..mPrefix..Settings.findCmd.." <string>")
			end
		end, 1, "Find a "..Settings.Mode.." by any string.", "!"..mPrefix..Settings.findCmd.." jiten",
		"$UserCommand 1 3 "..Settings.Mode.." Bot\\Find$<%[mynick]> !"..mPrefix..Settings.findCmd.." %[line:String]" }, 
	[mPrefix..Settings.delAllCmd] = { 
		function(user,data)
			-- Delete all table contents
			ShowReleases(1,table.getn(Table),1,5,false,"",Table) sCheck()
			user:SendData(Settings.sBot,"All "..Settings.Mode.."s have been deleted successfully!")
		end, 6, "Deletes all "..Settings.Mode.."s", "!"..mPrefix..Settings.delAllCmd,
		"$UserCommand 1 3 "..Settings.Mode.." Bot\\Delete all$<%[mynick]> !"..mPrefix..Settings.delAllCmd, },
	[mPrefix..Settings.helpCmd] = { 
		function(user)
			local sHelpOutput = "\r\n\t"..string.rep("-", 220).."\r\n\t[Mode / Cleaner / Link]: ["..Value.." / "..Config.Cleaner.." / "..Config.Link.." : "..Settings.iClean.." days]\t\tRelease/Request v."..Settings.iVer.." by jiten\t\t\t["..Settings.Mode.." Mode]\r\n\t"..string.rep("-",220).."\r\n\tCommands:\t\tDescription:\t\tExample:".."\r\n\r\n"
			-- For each entry in tCmds table
			for sCmd, tCmd in tCmds do
				-- If specific command profile permission is lower than user's profile according to the Levels' table
				if(tCmd[2] <= Levels[user.iProfile]) then
					if Settings.Mode == "Release" then
						-- If command isn't reqDone
						if sCmd ~= mPrefix..Settings.rDoneCmd then sHelpOutput = sHelpOutput.."\t!"..sCmd..DoTabs(1,CheckSize(sCmd))..tCmd[3]..DoTabs(1,CheckSize(tCmd[3]))..tCmd[4].."\r\n" end
					else
						sHelpOutput = sHelpOutput.."\t!"..sCmd..DoTabs(1,CheckSize(sCmd))..tCmd[3]..DoTabs(1,CheckSize(tCmd[3]))..tCmd[4].."\r\n"
					end
				end
			end
			user:SendData(Settings.sBot, sHelpOutput.."\t"..string.rep("-",220));
		end, 1, "Displays this help message.", "!"..mPrefix..Settings.helpCmd,
		"$UserCommand 1 3 "..Settings.Mode.." Bot\\Help$<%[mynick]> !"..mPrefix..Settings.helpCmd, },
	[mPrefix..Settings.rDoneCmd] = { 
		function(user,data)
			local s,e,i = string.find(data,"%b<>%s+%S+%s+(%S+)")
			if Settings.Mode == "Request" then
				if i then
					-- If specified ID exists
					if ShowReleases(1,table.getn(Table),1,3,i,"",Table,user.sName) == nil then
						ShowReleases(1,table.getn(Table),1,3,i,"",Table,user.sName) sCheck()
						SendToAll(Settings.sBot,user.sName.." filled up "..Settings.Mode.." "..i.."!")
					else
						user:SendData(Settings.sBot,"*** Error: There is no "..Settings.Mode.." "..i..".")
					end
				else
					user:SendData(Settings.sBot,"*** Error: Type !"..Settings.rDoneCmd.." <Request>")
				end
			else
				user:SendData(Settings.sBot,"*** Error: This command is only available in Request Mode.")
			end
		end, 1, "Fills up a Request", "!"..mPrefix..Settings.rDoneCmd.." <Request>",
		"$UserCommand 1 3 "..Settings.Mode.." Bot\\Fill up request$<%[mynick]> !"..mPrefix..Settings.rDoneCmd.." %[line:Request Name]" },
	[mPrefix..Settings.SetupCmd] = { 
		function(user,data)
			local s,e,set,value = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)")
			if not (set == nil or value == nil) then
				if set == "cleaner" then
					if value == "on" then
						Config.Cleaner = "on" sCheck(1) StartTimer() 
						user:SendData(Settings.sBot,"The Automatic "..Settings.Mode.." cleaner has been enabled.")
					elseif value == "off" then
						Config.Cleaner = "off" sCheck(1) StopTimer()
						user:SendData(Settings.sBot,"The automatic "..Settings.Mode.." cleaner has been disabled.")
					end
				elseif set == "link" then
					if value == "on" then
						Config.Link = "on" sCheck(1)
						user:SendData(Settings.sBot,"The Link has been set to not optional.")
					elseif value == "off" then
						Config.Link = "off" sCheck(1)
						user:SendData(Settings.sBot,"The Link has been set to optional.")
					end
				end
			else
				user:SendData(Settings.sBot,"*** Error: Type !"..mPrefix..Settings.SetupCmd.." <link/cleaner> <on/off>")
			end
		end, 6, "Configure this bot.", "!"..mPrefix..Settings.SetupCmd.." <link/cleaner> <on/off>",
		"$UserCommand 1 3 "..Settings.Mode.." Bot\\Setup\\Cleaner/Link$<%[mynick]> !"..mPrefix..Settings.SetupCmd.." %[line:cleaner/link] %[line:on/off]", },
}

OnTimer = function()
	-- Release/Request auto-deleting and table setup accoring to selected mode
	if Settings.Mode == "Release" then Table = Release elseif Settings.Mode == "Request" then Table = Request end
	if (Config.Cleaner == "on") then -- RegCleaner based
		local juliannow = jdate(tonumber(os.date("%d")), tonumber(os.date("%m")), tonumber(os.date("%Y"))) 
		local oldest, chkd, clnd, x = Settings.iClean, 0, 0, os.clock()
		-- For each addition in specified table
		for i = table.getn(Table), 1, -1 do
			chkd = chkd + 1; local _,_,month, day, year = string.find(Table[i][4], "(%d+)%/(%d+)%/(%d+)"); 
			local julian = jdate( tonumber(day), tonumber(month), tonumber("20"..year) )
			if ((juliannow - julian) > tonumber(oldest)) then
				-- Delete
				clnd = clnd + 1 table.remove(Table,i) sCheck()
			end; 
		end
		-- Sending Stats
		if clnd ~= 0 and Settings.pCleaner == 1 then SendToAll(Settings.sBot,chkd.." "..Settings.Mode.."s were processed. "..clnd.." "..Settings.Mode.."s were deleted as they were more than "..Settings.iClean.." days old. ( "..string.format("%0.2f",((clnd*100)/chkd)).."% ) in: "..string.format("%0.4f", os.clock()-x ).." seconds.") end
	end
end

NewUserConnected = function(sUser)
	-- Sending RightClick
	if Settings.SendTo[sUser.iProfile] == 1 and Settings.SendRC == 1 and sUser.bUserCommand then
		for i,v in tCmds do
			-- If specific command profile permission is lower than user's profile according to the Levels' table
			if(v[2] <= Levels[sUser.iProfile]) then
				if Settings.Mode == "Release" then 
					-- If command isn't reqDone
					if i ~= mPrefix..Settings.rDoneCmd then sUser:SendData(v[5].."&#124;") end
				else
					sUser:SendData(v[5].."&#124;")
				end
			end
		end
	end
end

OpConnected = NewUserConnected

ShowReleases = function(a,z,x,mode,str,eMsg,tbl,user)
	-- Borders
	local msg, border = "\r\n",string.rep("-", 325)
	msg = msg.."     "..border.."\r\n"..eMsg.."     "..string.rep("-- --",65).."\r\n     Date - Time\t\tPoster\t\t\tType\t\t\t"..Settings.Mode.." / Information Link\r\n"
	msg = msg.."     "..string.rep("-- --",65).."\r\n"
	for i = a, z, x do
		if tbl[i] then
			-- Add Link to each line shown if it isn't ""
			sLink = function () if tbl[i][5] ~= "" then tmp = "\r\n"..string.rep("\t",9).."-> "..tbl[i][5] else tmp = tbl[i][5] end return tmp end
			-- Tabbed Table Content
			if mode == 1 then
				msg = msg.."     "..tbl[i][4].."\t"..tbl[i][1]..DoTabs(1,CheckSize(tbl[i][1]))..tbl[i][3]..DoTabs(1,CheckSize(tbl[i][3]))..tbl[i][2]..sLink().."\r\n"
			-- Find mode
			elseif mode == 2 then
				-- If sensitive-search then
				if Settings.Sensitive == 1 then
					where = tbl[i][1]..tbl[i][2]..tbl[i][3]..tbl[i][4]..tbl[i][5]
				else
					where = string.lower(tbl[i][1]..tbl[i][2]..tbl[i][3]..tbl[i][4]..tbl[i][5]) str = string.lower(str)
				end
				-- If found then send results
				if string.find(where,str) then
					msg = msg.."     "..tbl[i][4].."\t"..tbl[i][1]..DoTabs(1,CheckSize(tbl[i][1]))..tbl[i][3]..DoTabs(1,CheckSize(tbl[i][3]))..tbl[i][2]..sLink().."\r\n"
				end
			-- Content deleting/request filling
			elseif mode == 3 then
				if tbl[i][2] == str then 
					if user then table.insert( ReqDone, { user, tbl[i][2], tbl[i][3], os.date(), tbl[i][5], } ) end table.remove(tbl,i) return nil
				end
			-- If str exists in the table returns nil
			elseif mode == 4 then
				if tbl[i][2] == str then return nil end
			-- Table content deleting
			elseif mode == 5 then
				if Settings.Mode == "Release" then Release = nil Release = {} elseif Settings.Mode == "Request" then Request = nil Request = {} ReqDone = nil ReqDone = {} end
			end
		end
	end
	-- Return msg
	msg = msg.."     "..border.."\r\n" return msg
end

-- Julian data function
jdate = function(d, m, y)
	local a, b, c = 0, 0, 0 if m <= 2 then y = y - 1; m = m + 12; end 
	if (y*10000 + m*100 + d) >= 15821015 then a = math.floor(y/100); b = 2 - a + math.floor(a/4) end
	if y <= 0 then c = 0.75 end return math.floor(365.25*y - c) + math.floor(30.6001*(m+1) + d + 1720994 + b)
end

-- nErBoS Release bot based
DoTabs = function(Type, size)
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


-- nErBoS Release bot based
CheckSize = function(String)
	local realSize,aux,remove = string.len(String),1,0
	while aux < realSize + 1 do
		for i=1, table.getn(Settings.sChar) do if (string.sub(String,aux,aux) == Settings.sChar[i]) then remove = remove + 0.5 end end
		aux = aux + 1
	end return realSize - remove
end

-- File handling functions
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