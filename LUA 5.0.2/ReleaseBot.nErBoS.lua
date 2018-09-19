--/--------------------------------------------------------------------------------------------------
--## Lua 5 version by jiten
--## Added: Command to delete all releases
--## Added: Folder to store the files
--/--------------------------------------------------------------------------------------------------
--## Release Bot Re-Written
--## Made by nErBoS
--## Commands:
--##	+add <release_name> <style>	- Will add a Release to the list
--##	+del <release_name>		- Will deleted a Relese from the list
--##	+rlsall				- Will Show all the Releases
--##	+rls				- Will Show the Lastest Releases
--##	+rlsfind <search_for>		- Will make a search for a Release	

sBot = "Release-Bot"

arrRelease = {}
arrSmallChar = { "-", " ", "i", "l", "r", "t", "I", "y", "o", }
sFolder = "_Release" -- folder where the release files are stored
fDataRelease = sFolder.."/release.dat"
fRelease = sFolder.."/release.work"

--## Configuration ##--

iLastRelease = 30 	-- Choose how many new release you want to show in +rls

--## END ##--

function Main()
	frmHub:RegBot(sBot)
	if not loadfile(fDataRelease) then os.execute("mkdir "..sFolder) end dofile(fDataRelease) 
end

function OnExit()
	local f = io.open(fDataRelease ,"w+") 
	f:write(Serialize(arrRelease, "arrRelease")) 
	f:flush() 
	f:close() 
end

function ChatArrival(user, data)
	if (string.sub(data,1,1) == "<" or string.sub(data,1,5+string.len(sBot)) == "$To: "..sBot) then
		data = string.sub(data,1,-2)
		s,e,cmd = string.find(data, "%b<>%s+(%S+)")
		if (cmd == "+add") then
			AddRelease(user, data) OnExit() return 1
		elseif (cmd == "+rlsall") then
			ShowAllRelease(user) return 1
		elseif (cmd == "+rls") then
			ShowLastestReleases(user) return 1
		elseif (cmd == "+del" and user.bOperator) then
			DeleteRelease(user, data) OnExit() return 1
		elseif (cmd == "+rlsfind") then
			FindRelease(user, data) return 1
		elseif (cmd == "+rlsdelall") then
			user:SendData(sBot, "All releases have been deleted.")
			arrRelease = nil arrRelease = {} OnExit() io.output(fRelease) return 1
		end
	end
end

ToArrival = ChatArrival

function AddRelease(user, data)
	local s,e,rel,style = string.find(data, "%b<>%s+%S+%s+(%S+)%s+(%S+)")
	local d,mm,y = os.date("%d"),os.date("%m"),os.date("%y") 
	local Date = d.."/"..mm.."/"..y 
	if (rel == nil or style == nil) then
		user:SendData(sBot, "Syntax Error, +add <release_name> <style>, you must write a release name and a style.")
	elseif (string.len(rel) > 101) then
		user:SendData(sBot, "The Release Name can't have more then 100 characters.")
	elseif (string.len(style) > 21) then
		user:SendData(sBot, "The Style can't have more then 20 characters.")
	elseif (arrRelease[string.lower(rel)] ~= nil) then
		user:SendData(sBot, "That Release already exists.")
	else
		arrRelease[string.lower(rel)] = 1 AddToFile(Date, style, rel, user.sName)
		SendToAll(sBot, "A New Release has been added by "..user.sName..". Type +rls to see all releases.")
	end
end

function AddToFile(date, sytle, release, submiter)
	local sWrite = date.."##"..sytle.."##"..release.."##"..submiter
	local f = io.open(fRelease)
	if f then 
		local g = io.open(fRelease,"a+") g:write("\r\n"..sWrite) g:close()
		f:close()
	else
		local f = io.open(fRelease,"w+") f:write(sWrite) f:close()
	end
end

function ShowAllRelease(user)
	local sTmp = "All Releases of The HUB:\r\n\r\n"
	sTmp = sTmp.."\tDate\t\tStyle"..DoColuns(1,5).."Release Name"..DoColuns(2,11).."Submiter\r\n\r\n"   
	local f = io.open(fRelease)
	if f then
		for sLine in io.lines(fRelease) do
			local s,e,date,sytle,release,submiter = string.find(sLine, "(.+)##(.+)##(.+)##(.+)")
			if (release ~= nil and sytle ~= nil) then
				sTmp = sTmp.."\t"..date.."\t\t"..sytle..DoColuns(1,CheckSize(sytle))..release..DoColuns(2,CheckSize(release))..submiter.."\r\n"
			end
		end
		f:close()
	end
	user:SendPM(sBot, sTmp)
end

function ShowLastestReleases(user)
	local sTmp,count,line = "The Last "..iLastRelease.." Releases of The HUB:\r\n\r\n",1,CountLines(fRelease)-iLastRelease
	sTmp = sTmp.."\tDate\t\tStyle"..DoColuns(1,5).."Release Name"..DoColuns(2,11).."Submiter\r\n\r\n"   
	local f = io.open(fRelease)
	if f then
		for sLine in io.lines(fRelease) do
			if (count > line) then
				local s,e,date,sytle,release,submiter = string.find(sLine, "(.+)##(.+)##(.+)##(.+)")
				if (release ~= nil and sytle ~= nil) then
					sTmp = sTmp.."\t"..date.."\t\t"..sytle..DoColuns(1,CheckSize(sytle))..release..DoColuns(2,CheckSize(release))..submiter.."\r\n"
				end
			end
			count = count + 1
		end
		f:close()
	end
	user:SendPM(sBot, sTmp)
end

function DeleteRelease(user, data)
	local s,e,rel = string.find(data, "%b<>%s+%S+%s+(%S+)")
	if (rel == nil) then
		user:SendData(sBot, "Syntax Error, +del <release_name>, you must write a release name.")
	elseif (string.len(rel) > 101) then
		user:SendData(sBot, "The Release Name can't have more then 100 characters.")
	elseif (arrRelease[string.lower(rel)] == nil) then
		user:SendData(sBot, "That Release doesn't exists.")
	else
		arrRelease[string.lower(rel)] = nil RemoveFromFile(rel) user:SendPM(sBot, "The Release was been removed.")
	end
end

function RemoveFromFile(release) 
	local f = io.open(fRelease)
	if f then
		local sTmp = "" 
		for sLine in io.lines(fRelease) do
			local s,e,rel = string.find(sLine, ".+##.+##(.+)##.+") 
			if (rel ~= nil and string.lower(rel) ~= string.lower(release)) then 
				sTmp = sTmp..sLine.."\r\n" 
			end 
		end 
		f:close()
		local g = io.open(fRelease,"w+") g:write(sTmp) g:close()
	end 
end 

function FindRelease(user, data)
	local s,e,rel = string.find(data, "%b<>%s+%S+%s+(.+)")
	if (rel == nil) then
		user:SendData(sBot, "Syntax Error, +rlsfind <search_for>, you must write a word for search.")
	else
		rel = string.lower(rel)
		local sTmp = "The Last "..iLastRelease.." Releases of The HUB:\r\n\r\n"
		sTmp = sTmp.."\tDate\t\tStyle"..DoColuns(1,5).."Release Name"..DoColuns(2,11).."Submiter\r\n\r\n"
		local f = io.open(fRelease)
		if f then
			for sLine in io.lines(fRelease) do
				if (Compare(rel,string.lower(sLine)) == 1) then
					local s,e,date,sytle,release,submiter = string.find(sLine, "(.+)##(.+)##(.+)##(.+)")
					sTmp = sTmp.."\t"..date.."\t\t"..sytle..DoColuns(1,CheckSize(sytle))..release..DoColuns(2,CheckSize(release))..submiter.."\r\n"
				end
			end
			f:close()
		end
		user:SendPM(sBot, sTmp)
	end
end

function Compare(search, In)
	local aux = 0
	while aux + string.len(search) < string.len(In)+1 do
		if (string.sub(In,aux+1,string.len(search)+aux) == search) then
			return 1
		end
		aux = aux + 1
	end
	return 0
end

function Serialize(tTable, sTableName, sTab)
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

function CheckSize(String)
	local realSize,aux,remove = string.len(String),1,0
	while aux < realSize + 1 do
		for i=1, table.getn(arrSmallChar) do
			if (string.sub(String,aux,aux) == arrSmallChar[i]) then
				remove = remove + 0.5
			end
		end
		aux = aux + 1
	end
	return realSize - remove
end

function CountLines(file) 
	local f = io.open(file,"r")
	if f then
		local count = 0 
		for sLine in io.lines(file) do
			count = count + 1 
		end 
		f:close()
		return count 
	end 
end 

function DoColuns(Type, size)
	local sTmp = ""
	if (Type == 1) then
		if (size < 8) then sTmp = "\t\t\t" elseif (size < 16) then sTmp = "\t\t" else sTmp = "\t" end 	return sTmp
	elseif (Type == 2) then
		if (size < 8) then sTmp = string.rep("\t",12)
		elseif (size < 16) then sTmp = string.rep("\t",11)
		elseif (size < 24) then sTmp = string.rep("\t",10)
		elseif (size < 32) then sTmp = string.rep("\t",9)
		elseif (size < 40) then sTmp = string.rep("\t",8)
		elseif (size < 48) then sTmp = string.rep("\t",7)
		elseif (size < 56) then sTmp = string.rep("\t",6)
		elseif (size < 64) then sTmp = string.rep("\t",5)
		elseif (size < 72) then sTmp = "\t\t\t\t"
		elseif (size < 80) then sTmp = "\t\t\t"
		elseif (size < 88) then sTmp = "\t\t" else sTmp = "\t" end return sTmp
	end
end

function OnTimer()
	if (os.date("%H") == "00") and next(arrRelease) then 
		arrRelease = nil 
		arrRelease = {} 
		SendPmToOps(sBot,"All releases have been cleaned!") 
		OnExit()
	end
end
--/--------------------------------------------------------------------------------------------------