-- Lua 5 version by jiten (completely rewritten)
-- Removed: Unnecessary code;
-- Added: Profile x can (not) download from profile y table
-- Changed: Commands' structure to tables
-- Added: Immune users that can download from blocked nicks (requested by felix444) (1/1/2006)
-- Fixed: tImmune if
-- Changed: tIdxBlocked to allow connections between every profile by default (1/2/2006)

-- 100% Blocker by chill
-- Table Load and Save (added by nErBoS)

sBot = "LeechBot"

tBlocked = {}

-- File where the blocked nicks are stored
fBlock = "tBlock.tbl"

tImmune = {
--	[Blocked Uploader's Nick] = {
--		[Nick allowed to download from him]
--	},
	["uploader"] = {
		["downloader1"] = 1,
		["downloader2"] = 1,
	},
}

tIdxBlocked = {
--	[Downloader Profile Number] = {
--		[Uploader Profile Number] = 1 - Connection Blocked; 0 - Unblocked Connection
--	},

	[0] = { [-1] = 0, [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, },
	[1] = { [-1] = 0, [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, },
	[2] = { [-1] = 0, [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, },
	[3] = { [-1] = 0, [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, },
	[4] = { [-1] = 0, [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, },
	[5] = { [-1] = 0, [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, },
	[-1] = { [-1] = 0, [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, },
}

Main = function()
	if loadfile(fBlock) then dofile(fBlock) end
end

ChatArrival = function(user,data)
	local data = string.sub(data,1,-2) 
	if user.bOperator then
		local s,e,cmd = string.find (data,"^%b<>%s+(%!%S+)")
		if cmd and tCmds[cmd] then return tCmds[cmd](user,data),1 end
	end
end

CTMArrival = function(user,data)
	local sFind
	if string.sub(data,1,4) == "$Rev" then sFind = "(%S+)|$" elseif string.sub(data,1,4) == "$Con" then sFind = "%S+%s+(%S+)" end
	local s,e,nick = string.find(data,sFind)
	-- (user is blocked and can't download? OR user's profile can download from nick's? OR nick is blocked and can't upload?) AND (can immune user download from blocked nick?)
	if (tBlocked[string.lower(user.sName)] or tIdxBlocked[user.iProfile][GetItemByName(nick).iProfile] == 1 or tBlocked[string.lower(nick)]) then
		if not (tImmune[string.lower(GetItemByName(nick).sName)] and tImmune[string.lower(GetItemByName(nick).sName)][string.lower(user.sName)]) then
			user:SendData(sBot,"*** Error: You are not authorized to download from "..nick..".")
			return 1
		end
	end
end

ConnectToMeArrival = CTMArrival
RevConnectToMeArrival = CTMArrival

tCmds = {
	["!block"] = 
	function(user,data)
		local s,e,nick = string.find(data,"%b<>%s+%S+%s+(%S+)")
		if nick then
			if tBlocked[string.lower(nick)] == 1 then
				user:SendData(sBot,"*** Error: "..nick.." is already blocked.")
			else
				tBlocked[string.lower(nick)] = string.lower(user.sName) SaveToFile(fBlock,tBlocked,"tBlocked")
				user:SendData(sBot,"*** "..nick.." is now blocked.") 
			end
		else
			user:SendData(sBot,"*** Syntax Error: Type !block <nick>")
		end
	end,
	["!unblock"] = 
	function(user,data)
		local s,e,nick = string.find(data,"%b<>%s+%S+%s+(%S+)")
		if nick then
			if tBlocked[string.lower(nick)] then
				tBlocked[string.lower(nick)] = nil SaveToFile(fBlock,tBlocked,"tBlocked")
				user:SendData(sBot,"*** "..nick.." is now unblocked.")
			else
				user:SendData(sBot,"*** Error: "..nick.." isn't blocked.")
			end
		else
			user:SendData(sBot,"*** Syntax Error: Type !unblock <nick>")
		end
	end,
	["!showblock"] =
	function(user)
		local msg = "\r\n\r\n".."\t"..string.rep("- -",20).."\r\n" 
		msg = msg.."\t\tCurrent Blocked Users:\r\n" 
		msg = msg.."\t"..string.rep("- -",20).."\r\n"
		for v, i in tBlocked do msg = msg.."\t • "..v.."\t blocked by "..i.."\r\n" end
		user:SendData(sBot,msg)
	end,
}

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