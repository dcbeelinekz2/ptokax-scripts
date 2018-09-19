-- watch script by jiten

BotName = "•bot•"
watch = {}

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
end 

function ChatArrival (user,data) 
	data=string.sub(data,1,string.len(data)-1) 
	local s,e,cmd,Name = string.find( data, "%b<>%s+(%S+)%s+(%S+)" ) 
	local victim = GetItemByName(Name) 
	if AllowedProfiles[user.iProfile] == 1 then
		if cmd == "!watch" then
			if watch[user.sName] == nil then 
				watch[user.sName] = {}
				watch[user.sName]["victim"] = victim.sName
				user:SendData(BotName,"Watch-Mode is now set to: "..victim.sName)
			else 
				user:SendData(BotName,victim.sName.." is already being watched.") 
			end 
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
			return 1 
		end
	end
end 

function ToArrival(user, data)
	local _, _, to, from, msg = string.find(data, "^%$To:%s+(%S+)%s+From:%s+(%S+)%s-%$%b<>%s+(.*)|")
	local i,v
	for i,v in watch do
		local victim,fromtxt,towatch,totxt = GetItemByName(v.victim),GetItemByName(from),GetItemByName(i),GetItemByName(to)
		if watch[i]["victim"] == victim.sName then
			if fromtxt.sName == watch[i]["victim"] then
				towatch:SendPM(BotName,fromtxt.sName.." ::: message to: "..totxt.sName..": "..msg)				
			end
		end
	end
end

function UserDisconnected(user)
	local i,v
	for i,v in watch do
		local towatch = GetItemByName(i)
		if watch[i]["victim"] == user.sName then
			if not user.bRegistered then
				towatch:SendPM(BotName,"*** User "..user.sName.." went offline!")
				watch[towatch.sName] = nil
			else
				towatch:SendPM(BotName,"*** "..GetProfileName(user.iProfile).." "..user.sName.." went offline!")				
				watch[towatch.sName] = nil
			end
		end
	end
end

OpConnected = UserDisconnected

function ViewWatchers(user) 
	if isEmpty(watch) then
		user:SendData(BotName,"*** Error: There aren't currently watchers.")
	else
		temp="\r\n\r\n".."\t»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«".."\r\n" 
		temp=temp.."\t\tWatcher:\t\tSuspect:".."\r\n" 
		temp=temp.."\t»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«".."\r\n" 
		local i,v
		for i, v in watch do 
			temp =temp.."\t\t"..GetItemByName(i).sName.."\t\t"..GetItemByName(v.victim).sName.."	\r\n" 
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