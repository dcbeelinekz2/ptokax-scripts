----------------------------------------------------------
-- Tiny Release v2.02					--
-- changed a bit the file handling by jiten		--
-- Made by Optimus 01/17/05				--
--							--
-- Add/Del releases					--
-- Top 10 new releases on connect			--
----------------------------------------------------------

sBot = "-=Releases=-"

Release = {}
sCommands = {}

ReleaseFile = "releases.tbl"
TopRelease = 10
MaxReleases = 500			-- Don't set it to high it will give problems
EnableTopRelease = 1 			-- 1=on / 0=off
TopReleaseConnect = "main"		-- Set to main/pm
ShowRelease = "main"			-- Set to main/pm
ShowVote = "main"			-- Set to main/pm
TopVote = 25

Allowed = {
[0] = 1,	-- Master
[1] = 1,	-- Operator
[2] = 1,	-- VIPs
[3] = 1,	-- Regs
[4] = 1,	-- Moderator
[5] = 1,	-- Netfounder
}

CmdPrefix = {
["!"]=1,
["?"]=1,
["+"]=1,
}

Main = function()
	frmHub:RegBot(sBot)
	if loadfile(ReleaseFile) then dofile(ReleaseFile) end
	NewReleases = GetReleases(table.getn(Release), table.getn(Release)-TopRelease)
end

NewUserConnected = function(user)
	if EnableTopRelease == 1 and Allowed[user.iProfile] == 1 then
		local disp = "\r\n\t\t\t- ---- Top "..TopRelease.." Releases ---- -\r\n\r\n"..NewReleases
		disp = disp.."\r\n\t\t\t- ---- Top "..TopRelease.." Releases ---- -"
		ShowWhere(user, TopReleaseConnect, disp)
	end
end

OpConnected = NewUserConnected

sCommands["addrel"] = function(user, data)
	if Allowed[user.iProfile] == 1 then
		local s,e,item,descr = string.find(data, "%b<>%s+%S+%s+(.+)%-(.*)")
		if s then
			if table.getn(Release) < MaxReleases then
				table.insert(Release,{user.sName,item,descr,os.date("%c"),0})
				saveTableToFile(ReleaseFile, Release, "Release")
				NewReleases = GetReleases(table.getn(Release), table.getn(Release)-TopRelease)
				SendToAll(sBot, user.sName.." added a new Release, Check It Out ** "..table.getn(Release)..". "..item.." - "..descr.." **")
			else
				user:SendData(sBot, "*** Database is full, maxium number of releases are: "..MaxReleases)
			end
		else
			user:SendMessage(sBot, "*** Usage: !addrel item-descr")
		end
	end return 1
end

sCommands["delrel"] = function(user, data)
	if user.bOperator then
		local s,e,nr = string.find(data, "%b<>%s+%S+%s+(%d+)")
		if s then
			if Release[tonumber(nr)] then
				table.remove(Release,nr)
				saveTableToFile(ReleaseFile, Release, "Release")
				NewReleases = GetReleases(table.getn(Release), table.getn(Release)-TopRelease)
				user:SendMessage(sBot, "Release nr."..nr.." is deleted from database!")
			else
				user:SendMessage(sBot, "*** Release nr."..nr.." is not in database!")
			end
		else
			user:SendMessage(sBot, "*** Usage: !delrel nr")
		end
	end return 1
end

sCommands["showrel"] = function(user, data)
	if Allowed[user.iProfile] == 1 then
		local disp = "\r\n\t\t\t- ---- Top "..table.getn(Release).." Releases ---- -\r\n\r\n"
		disp = disp..GetReleases(table.getn(Release), 1)
		ShowWhere(user, ShowRelease, disp.."\r\n\t\t\t- ---- Top "..table.getn(Release).." Releases ---- -")
	end return 1
end

sCommands["cleanup"] = function(user, data)
	if user.bOperator then
		local howmuch = table.getn(Release)
		if howmuch >= MaxReleases then
			for i = 1,howmuch/2 do table.remove(Release,i) end 
			saveTableToFile(ReleaseFile, Release, "Release")
			user:SendMessage(sBot, "The database is cleaned!")
		else
			user:SendMessage(sBot, "The database doesn't need tobe cleaned!")
		end
	end return 1
end

sCommands["voterel"] = function(user, data)
	if Allowed[user.iProfile] == 1 then
		local s,e,nr = string.find(data, "%b<>%s+%S+%s+(%d+)")
		if s then
			if Release[tonumber(nr)] then
				Release[tonumber(nr)][5] = Release[tonumber(nr)][5] + 1
   				saveTableToFile(ReleaseFile, Release, "Release")
	   			SendToAll(sBot, user.sName.." has voted on Release: ["..nr.."]. "..Release[tonumber(nr)][2].." - "..Release[tonumber(nr)][3])
			else
				user:SendMessage(sBot, "*** Release nr."..nr.." is not in database!")
			end
		end
	end return 1
end

sCommands["topvotes"] = function(user, data)
	if Allowed[user.iProfile] == 1 then
		Votes = {}
		for i = 1,TopVote do
			if Release[i] then
				if Release[i][5] > 0 then
					table.  insert(Votes,{Release[i][1],Release[i][2],Release[i][3],Release[i][4],Release[i][5],i})
				end
			end
		end table.sort(Votes,function(a,b) return (a[5] > b[5]) end)
		local disp = "\r\n\t\t\t- ---- Top "..TopVote.." Votes ---- -\r\n\r\n"
		for t = 1,TopVote do
			if Votes[t] then
				disp = disp.."\t "..Votes[t][6]..". "..Votes[t][2].." - "..Votes[t][3].." # Votes: "..Votes[t][5].." # Added: "..Votes[t][1].." # "..Votes[t][4].."\r\n"
			end
		end
		ShowWhere(user, ShowVote, disp.."\r\n\t\t\t- ---- Top "..TopVote.." Votes ---- -")
		Votes = {}
	end return 1
end

sCommands["clearvotes"] = function(user, data)
	if user.bOperator then
		for i = 1,table.getn(Release) do
			if Release[i] then Release[i][5] = 0 end
		end saveTableToFile(ReleaseFile, Release, "Release")
		user:SendMessage(sBot, "Votes are now cleared and saved to database!")
	end return 1
end

GetReleases = function(startpos, endpos)
	local text = ""
	for i = startpos, endpos, -1 do
		if Release[i] then
			text = text.."\t "..i..". "..Release[i][2].." - "..Release[i][3].." # Votes: "..Release[i][5].." # Added: "..Release[i][1].." # "..Release[i][4].."\r\n"
		end
	end return text
end

ChatArrival = function(user, data)
	user.SendMessage = user.SendData return GetCommands(user, data)
end

ToArrival = function(user, data)
	user.SendMessage = user.SendPM return GetCommands(user, data)
end

GetCommands = function(user, data)
	data=string.sub(data,1,-2)
	local s,e,prefix,cmd=string.find(data, "%b<>%s*(%S)(%S+)")
	if prefix and CmdPrefix[prefix] then
		if sCommands[cmd] then
			return sCommands[cmd](user, data)
		end
	end
end

ShowWhere = function(user, where, msg)
	if where == "main" then user:SendData(sBot, msg) elseif where == "pm" then user:SendPM(sBot, msg) end
end

sCommands["test"] = function(user, data)
	ReleaseCleaner() return 1
end

----------------------------------------------
-- save Tables
----------------------------------------------
Serialize = function(tTable, sTableName, sTab)
	assert(tTable, "tTable equals nil");
	assert(sTableName, "sTableName equals nil");
	assert(type(tTable) == "table", "tTable must be a table!");
	assert(type(sTableName) == "string", "sTableName must be a string!");
	sTab = sTab or "";
	sTmp = ""
	sTmp = sTmp..sTab..sTableName.." = {\n"
	for key, value in tTable do
                local sKey = (type(key) == "string") and string.format("[%q]",key) or string.format("[%d]",key);
                if(type(value) == "table") then
			sTmp = sTmp..Serialize(value, sKey, sTab.."\t");
                else
			local sValue = (type(value) == "string") and string.format("%q",value) or tostring(value);
			sTmp = sTmp..sTab.."\t"..sKey.." = "..sValue
		end
		sTmp = sTmp..",\n"
	end
	sTmp = sTmp..sTab.."}"
	return sTmp
end
-----------------------------------------------------------
saveTableToFile = function(file , table , tablename)
	local handle = io.open(file,"w+")
	handle:write(Serialize(table, tablename))
	handle:flush()
	handle:close()
end
-----------------------------------------------------------