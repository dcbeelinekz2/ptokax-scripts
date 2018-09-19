-- Small Release Bot by jiten (6/7/2005)

sBot = frmHub:GetHubBotName()
fRelease = "logs/Releases.tbl"	-- File where the Address File is stored

Releases = {}

Main = function()
	if loadfile(fRelease) then dofile(fRelease) end
end

ChatArrival = function(user, data) 
	local data = string.sub(data, 1, -2) 
	local s,e,cmd = string.find(data,"%b<>%s+[%!%?%+%#](%S+)")
	if cmd then
		local tCmds = {
		["add"]	=	function(user,data)
					local s,e,rel,desc = string.find(data,"%b<>%s+%S+%s+(%S+)%s+(%S+)")
					if rel == nil or desc == nil then
						user:SendData(sBot,"*** Error: Type +add <name> <address>")
					else
						table.insert( Releases, { user.sName, rel, desc, os.date(), } )
						SaveToFile(fRelease,Releases,"Releases")
						SendToAll(sBot, user.sName.." added a new Address: "..rel..". For more details type: +read")
					end
				end,
		["read"] =	function(user,data)
					local msg, Exists = "", nil
					for i = 1, table.getn(Releases) do
						if Releases[i] then
							msg = msg.."\r\n\tNumber "..i..".\r\n\t["..Releases[i][2].."]\r\n\t["..Releases[i][3].."]\r\n\tPosted by: "..Releases[i][1].." on "..Releases[i][4].."\r\n" Exists = 1
						end
					end
					if Exists == nil then 
						user:SendData(sBot,"*** Error: The Address list is empty.")
					else
						user:SendPM(sBot,msg)
					end
				end,
		["del"]	=	function(user,data)
					if user.iProfile == 0 then
						local s,e,i = string.find(data,"%b<>%s+%S+%s+(%S+)")
						if i then
							if Releases[tonumber(i)] then
								table.remove(Releases,i)
								SaveToFile(fRelease,Releases,"Releases")
								user:SendData(sBot,"Address "..i..". was deleted succesfully!")
							else
								user:SendData(sBot,"*** Error: There is no Address "..i..".")
							end
						else
							user:SendData(sBot,"*** Error: Type +del <ID>")
						end
					else
						return user:SendData(sBot,"*** Error: You are not allowed to use this command."),1
					end
				end,
		}
		if tCmds[cmd] then return tCmds[cmd](user,data),1 end
	end
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