--------------------------------------------------------------------------------------------------------------------- 
-- Mute script
-- changed a bit by jiten
--------------------------------------------------------------------------------------------------------------------- 

sBot = "-MUTE-" 

tMute = {} 

AllowedProfiles = {
--	[Gagger Profile Number] = {
--		[Gagged Profile Number] = 0 --> can't gag victim; 1 --> can gag victim
--	},

	[1] = { [1] = 1, [2] = 1, [3] = 1, [4] = 0, [5] = 0, [0] = 0, [-1] = 1, },
	[2] = { [1] = 0, [2] = 1, [3] = 1, [4] = 0, [5] = 0, [0] = 0, [-1] = 1, },
	[4] = { [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 0, [0] = 0, [-1] = 1, },
	[5] = { [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [0] = 1, [-1] = 1, },
	[0] = { [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 0, [0] = 1, [-1] = 1, },
}

function ChatArrival(user, data) 
	local data=string.sub(data,1,-2) 
	local s,e,cmd = string.find(data,"%b<>%s+(%S+)") 
	if AllowedProfiles[user.iProfile] or user.bOperator then
		if ((cmd=="+gag")) then 
			DoMute(user, data) return 1 
		elseif cmd == "+showgag" then 
			local disp = "" 
			for index, value in tMute do 
				local line = index 
				disp = disp.."\t • "..line.."\r\n" 
			end 
			user:SendPM(sBot,"\r\n\r\n\t\t\t\t\t(¯ ·.¸¸.-> These are the muted <-.¸¸.·´¯)\r\n\r\n"..disp.."|") 
			return 1 
		elseif ((cmd=="+ungag")) then 
			DoUnMute(user, data) return 1 
		end 
	end
	if tMute[user.sName] == 1 then return 1 end 
end 

function DoMute(user, data) 
	local s,e,cmd,vic = string.find(data,"%b<>%s+(%S+)%s+(%S+)") 
	local victim = GetItemByName(vic) 
	if victim == nil then 
		user:SendData(sBot,"User is not in the hub...") 
	else 
		if AllowedProfiles[user.iProfile][victim.iProfile] == 1 then
			if tMute[victim.sName] == nil then 
				tMute[victim.sName] = 1 
				SendToAll(sBot,"He, he "..victim.sName..", you txt not speak ;)") 
			end
		else
			if not victim.bRegistered then
				user:SendData(sBot,"*** Error: You can't gag Users!")
			else
				user:SendData(sBot,"*** Error: You can't gag "..GetProfileName(victim.iProfile).."s!")				
			end
		end 
	end 
end 

function DoUnMute(user, data) 
	local s,e,cmd,vic = string.find(data,"%b<>%s+(%S+)%s+(%S+)") 
	local victim = GetItemByName(vic) 
	if victim == nil then 
		user:SendData(sBot,"User is not in the hub...") 
	else 
		if tMute[victim.sName] == 1 then 
			tMute[victim.sName] = nil; 
			SendToAll(sBot, victim.sName.." you txt allow speak ;) ") 
		end 
	end 
end
