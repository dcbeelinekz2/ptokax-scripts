-- watch script by jiten

BotName = "�bot�"
watch = {}
WatchFile = "Watchers.tbl" 

AllowedProfiles = {
	[-1] = 0, -- unreg
	[0] = 0, -- master
	[1] = 0, -- operator
	[2] = 0, -- vip
	[3] = 0, -- reg
	[4] = 0, -- moderator
	[5] = 1, -- founder
}

function Main() 
	frmHub:RegBot(BotName)
	LoadFromFile(WatchFile)
end 

function ChatArrival (user,data) 
	data=string.sub(data,1,-2) 
	local s,e,cmd,Name = string.find( data, "%b<>%s+(%S+)%s+(%S+)" ) 
	local victim = GetItemByName(Name) 
	if AllowedProfiles[user.iProfile] == 1 then
		if cmd == "!watch" then
			if watch[user.sName] == nil then 
				watch[user.sName] = {}
--				watch[user.sName]["victim"] = victim.sName
				table.insert(watch[user.sName],victim.sName)
				user:SendData(BotName,"Watch-Mode is now set to: "..victim.sName)
			else 
				user:SendData(BotName,victim.sName.." is already being watched.") 
			end 
			SaveToFile(WatchFile,watch,"WatchArray") 
			return 1
		end
		local s,e,cmd = string.find(data, "%b<>%s+(%S+)")
		if cmd== "!getwatch" then
			ViewWatchers(user) 
			return 1 
		elseif cmd == "!watchoff" then 
			if isEmpty(watch) then
				user:SendData(BotName,"*** Error: There aren't watchers currently.")
			else
				watch[user.sName] = nil
				user:SendData(BotName,"Watch-Mode is now disabled!") 
			end
			SaveToFile(WatchFile,watch,"WatchArray") 
			return 1 
		end
	end
end 

function ToArrival(user, data)
	local _, _, to, from, msg = string.find(data, "^%$To:%s+(%S+)%s+From:%s+(%S+)%s-%$%b<>%s+(.*)|")
	local i,v
	for i,v in watch do
		local victim,fromtxt,towatch,totxt = GetItemByName(v[1]),GetItemByName(from),GetItemByName(i),GetItemByName(to)
		if v[1] == victim.sName then
			if fromtxt.sName == v[1] then
				towatch:SendPM(BotName,fromtxt.sName.." ::: message to: "..totxt.sName..": "..msg)				
			end
		end
	end
end

function UserDisconnected(user)
	local i,v
	for i,v in watch do
		local towatch = GetItemByName(i)
		if v[1] == user.sName then
			if not user.bRegistered then
				towatch:SendPM(BotName,"*** User "..user.sName.." went offline!")
				watch[towatch.sName] = nil
				SaveToFile(WatchFile,watch,"WatchArray") 
			else
				towatch:SendPM(BotName,"*** "..GetProfileName(user.iProfile).." "..user.sName.." went offline!")				
				watch[towatch.sName] = nil
				SaveToFile(WatchFile,watch,"WatchArray") 
			end
		end
	end
end

OpConnected = UserDisconnected

function ViewWatchers(user) 
	if isEmpty(watch) then
		user:SendData(BotName,"*** Error: There aren't currently watchers.")
	else
		temp="\r\n\r\n".."\t������������������������������������������".."\r\n" 
		temp=temp.."\t\tWatcher:\t\tSuspect:".."\r\n" 
		temp=temp.."\t������������������������������������������".."\r\n" 
		local i,v
		for i, v in watch do 
			temp =temp.."\t\t"..GetItemByName(i).sName.."\t\t"..GetItemByName(v[1]).sName.."	\r\n" 
		end 
		user:SendData(BotName,temp) 
	end
end 

function isEmpty(t)
	for i,v in t do
		return false;
	end
	return true;
end;

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

function SaveToFile(file , table , tablename)
	local handle = io.open(file,"w+")
	handle:write(Serialize(table, tablename))
	handle:flush()
	handle:close()
end

function LoadFromFile(file)
	local handle = io.open(file,"r")
        if (handle ~= nil) then
		dofile(file)
		handle:flush()
		handle:close()
	end
end