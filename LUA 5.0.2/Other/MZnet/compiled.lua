-- K-VIP by Seiya (Version 1.6);
-- N-VIP by jiten and dessamator;
-- RightClicker for RoboCopv10.01d;
-- Kenny / Mute by Hawk
-- IP Finder by Dessamator
-- SaveShare 5 by Herodes
-- ChatStats by Optimus, madman, Herodes and jiten
-- Chatrooms by tezlo
-- Clone Alert 1.6 (Mutor The Ugly, bastya, Dessa and jiten)
-- Lucifer 6.6.6

sBot = frmHub:GetHubBotName() 

kVip = {} kFile = "logs/kVip.tbl"
vLog = {} vFile = "logs/kVipLog.tbl"
nVip = {} nFile = "logs/nVip.tbl"
sLog = {} sFile = "logs/ShareLog.tbl" 
cLog = {} cFile = "logs/CloneLog.tbl" 
tUsers = {} tUsersFile = "logs/tUsers.tbl"
tMoreUsers = {} tMoreUsersFile = "logs/tMoreUsers.tbl"
CloneImmune = {} CloneImmuneFile = "logs/CloneImmune.tbl"
ShareImmune = {} ShareImmuneFile = "logs/ShareImmune.tbl"
Chatstats = {} ChatStatsFile = "logs/chatstats.tbl"
cRoomFile = "logs/ChatRooms.tbl"

-- Start: MultiTimer
tabTimers = {n=0}
TmrFreq = 1000
-- End: MultiTimer

-- Start:Lucifer Settings
tabAdvert = {}
advtrigs = {
	"serveftp","dns2go","no-ip.com","no-ip.org","no-ip.biz","hubmoz","mozradiaction","afrobeat",
	"paismz","n0-ip","mozcorporation","mozbeat","latinosspot","mozkiss","mozserver",
	"mismz","mozcorp","no-ip.info","no-ip","put0","mozville","hgmz","zuluhub","noipcom",
	"xidzakuas","c0m","0rg","mzzone","mzsons","mzusers","noiporg",
	"mozentertainment","beatzone","redirectme","myftpsite","dyndns","bounceme","m0z","z0n","noipinfo",
	"mzvisao","realcity","dreamhub","mzbebados","mzfederados","vitomoz","mozbebados","noipbiz","katdream",
	"serveftp","dns2go","no-ip","ÒRG","ip.org","ip.biz","mozcorporation","mdreamer.tk","gold-hub",
	"ip.info","ip.com","BÏZ","BÎZ","ÔRG","BÌZ","ÕRG","redirectme.net",
	"ÖRG","bîz","cóm","côm","cõm","òrg","õrg","örg","ôrg","bíz","bïz",
	"bìz","n0-ip","z0n","m0z","put0","utilities.com","m-vito","netcabo.co.mz","sytes.net","zapto.org",
}

Adver = { "Ø", "•", "Ö", }

controltrigs={["entra"]=1,["entre"]=2,["venham"]=3,["h%s+u%s+b"]=4,["join"]=5,["netrabo"]=6,["aparece"]=7,["hub"]=8,["maputo"]=9}

validtrigs = {"none"}
-- End: Lucifer Settings

-- Start: ChatStats Settings
Sortstats = 2	-- 1=words / 2=posts
ChatStatsTo = "user" -- Send TopChatters to? user or all
EnableChatStats = { [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [-1] = 1, }
AllowedProfiles = { [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [-1] = 1, }
-- End: ChatStats Settings

-- Start:SaveShare Settings
tAgain = {} 
kb = 1024  mb = 1024 ^ 2 gb = 1024 ^ 3 
secs=1000 minutes = 60 hours = 60 ^2  

wtime = 3 * hours 		--- this is the time in seconds. .. Feel free to use the #*hours to say in # hours ... and  #*minutes to say in # minutes .. :) 
frequency = 180 		--- this is the number of warnings the user is going to receive within the predifined time limit 
w2time = 10 * minutes		--- this is the time that a user entering with below share limit for the second time while have to fill up the requirement 
secfrequency = 10		--- this is how many times a user entering with below share limit for the second time is going to be warned in the time set by ' w2time ' variable. 
limitshare = 300 * mb 		--- this sets the share limit that needs to be reached by the user so that he doesnt get the action .. :) keep format ex: 5 *gb is 5GB ... and so on 
--- for the two variables below ( TheAction & The2Action ) use these ¦ 1 = disconnect , 2 = redirect , 3 = kick , 4 = tempban , 5 = ban, 6 = nickban, 7 = timeban, 8 = flood&disconnect ¦ 
TheAction = 7 			--- this sets the action to take against these ppl 
The2Action = 7 			--- this sets the action to take against the ppl that come back after they were given a first chance 
bantime = 30 			--- the time for the Time Ban action in minutes 
floodTimes = 1			--- how many times the user may be flooded 
floodMsg = "You should have done something about your share." 		--- the message the user will be flooded with 
-- End: SaveShare Settings

Kennylizednicks = {} Mutes = {} Clicker = {}

SendTo = { [0] = 1, [1] = 1, [2] = 1, [3] = 1, [4] = 1, [5] = 1, [-1] = 0, } --> 1=on/0=off -- Send RightClick To

intros = { -- N-VIP Intros
	"[USERNAME] Crawls In On Their Hands And Knees.", 
	"In A Fiery Explosion [USERNAME] Appears.", 
	"With A Crazed Look In Their Eyes [USERNAME] Arrives.", 
	"Sir [USERNAME] Of The East Lunatic Fringe Has Arrived.", 
	"[USERNAME] Arrives Yelling And Screaming Like A Maniac.", 
	"[USERNAME] Arrives Ranting And Raving About Aliens Or Some Such Rot.", 
	"The Demented [USERNAME] Has Arrived.", 
	"[USERNAME] Appears Out Of Nowhere And Begins Speaking In Tongues.", 
	"[USERNAME] Arrives And Immediately Heads For The Light Like A Moth.", 
	"[USERNAME] Climbs In Through The Window With A Big Joint.", 
	"[USERNAME] Falls From The Skylight And Lands On A Mushroom.", 
	"[USERNAME] Enters the Room With A Bottle Of L.S.D On His Hands.", 
	"After Alot Of Loud Groaning [USERNAME] Comes Waltzing Out Of Janines Room...", 
	"Hair In Everywhich Direction [USERNAME] Arrives On The Scene Looking More Crazed Than Usual.", 
	"Brandishing What Looks Like A Hairbrush [USERNAME] Arrives.", 
	"[USERNAME] Arrives An ElfGirl Under Each Arm", 
	"[USERNAME] Appears Out Of Thin Air Scaring The Hell Out Of Janine.", 
	"[USERNAME] Parachutes In From An Airplane.", 
	"[USERNAME] Runs In, Stubs Their Toe On A Couch And Falls Over A Table Landing On Janine.", 
	"[USERNAME] Crashes Through The East Wall Arriving In The Hub.", 
	"[USERNAME] is here, How about a round of elfgirls for everyone?", 
} 

kennytext = { -- Kenny Text
	"*umfl* *uuffum*",
	"*lluu* *mlmlff* *umfl* *lfumfl* *umfl*",
	"*lmmf* *uullu* *mmmm*",
	"*ommlu* *uullu* *lmmf* *ommlu* *mflf*",
	"*olomum* *lmmf* *mhhhmmlm*",
	"*Mhhl* *mujm* *umfl*",
} 
-- End Editable Settings --

Main = function() 
	local CreateFile = function(file,table)
		local f = io.open(file, "w+")
		f:write(table.." = {\n"); f:write("}"); f:close()
	end
	-- Start: RightClick/K-VIP/N-VIP/VIP/SaveShare Files Handling
	if loadfile("tbl/scriptlevel.tbl") then dofile("tbl/scriptlevel.tbl") end
	if loadfile("tbl/inbuildlevel.tbl") then dofile("tbl/inbuildlevel.tbl") end
	if loadfile("logs/Clicker.tbl") then dofile("logs/Clicker.tbl") else CreateFile("logs/Clicker.tbl","Clicker") end
	if loadfile(kFile) then dofile(kFile) else CreateFile(kFile,"kVip") end
	if loadfile(vFile) then dofile(vFile) else CreateFile(vFile,"vLog") end
	if loadfile(nFile) then dofile(nFile) else CreateFile(nFile,"nVip") end
	if loadfile(ShareImmuneFile) then dofile(ShareImmuneFile) else CreateFile(ShareImmuneFile,"ShareImmune") end
	if loadfile(sFile) then dofile(sFile) else CreateFile(sFile,"sLog") end
	if loadfile(ChatStatsFile) then dofile(ChatStatsFile) else CreateFile(ChatStatsFile,"ChatStats")  end
	if loadfile(CloneImmuneFile) then dofile(CloneImmuneFile) else CreateFile(CloneImmuneFile,"CloneImmune") end
	if loadfile(tUsersFile) then dofile(tUsersFile) else CreateFile(tUsersFile,"tUsers") end
	if loadfile(tMoreUsersFile) then dofile(tMoreUsersFile) else CreateFile(tMoreUsersFile,"tMoreUsers") end
	if loadfile(cFile) then dofile(cFile) else CreateFile(cFile,"cLog") end
	-- End: RightClick/K-VIP/N-VIP/VIP/ShaveShare Files Handling
	RegTimer(SecondTimer,1000) RegTimer(MinuteTimer,60*1000) 
	RegTimer(GarbageTimer,5*60*1000) RegTimer(HourTimer,60*60*1000) SetTimer(TmrFreq) StartTimer()
	-- Start: SaveShare variables
	bal = math.floor(wtime/frequency) bal2 = math.floor(w2time/secfrequency) 
	-- End: SaveShare variables
	-- Load Chatrooms
	chatrooms:load()
end 

ChatArrival = function(user,data) 
	if AllowedProfiles[user.iProfile] == 1 then
		local data=string.sub(data,1,-2) 
		local s,e,cmd = string.find( data, "%b<>%s+([%-%+%?%!]%S+)")
		if cmd then
			local tCmds = {

			-- Start: K-VIP Commands
			["!addvkick"] = 
			function(user,data)
				if user.iProfile == 0 or user.iProfile == 5 then 
					local s,e,victim = string.find(data, "%b<>%s+%S+%s+(%S+)")
					if victim then
						if kVip[victim] == nil then 
							kVip[victim] = 1 
							SaveToFile(kFile,kVip,"kVip")
							SendPmToOps(sBot,"The Operator "..user.sName.." gave the K-VIP status to "..victim..".") 
						else 
							user:SendData(sBot,"*** Error: "..victim.." is already a K-VIP.")
						end 
					else
						user:SendData(sBot,"*** Syntax Error: Type !addvkick <nick>")
					end
				end
			end,
			["!delvkick"] =
			function(user,data)
				if user.iProfile == 0 or user.iProfile == 5 then
					local s,e,victim = string.find(data, "%b<>%s+%S+%s+(%S+)")
					if victim then
						if kVip[victim] ~= 0 then 
							kVip[victim] = nil 
							SaveToFile(kFile,kVip,"kVip") 
							SendPmToOps(sBot,"The Operator "..user.sName.." has just revoked the K-VIP status from "..victim..".") 
						else 
							user:SendData(sBot,"The user "..victim.." isn't a K-VIP.") 
						end
					else
						user:SendData(sBot,"*** Syntax Error: Type !delvkick <nick>")
					end
				end
			end,
			["!vinfo"] =
			function(user,data)
				if user.iProfile == 2 and kVip[user.sName] == 1 then 
					local s,e,cmd,who = string.find(data, "%b<>%s+(%S+)%s+(%S+)%s*")  
					local usr = GetItemByName(who)  
					if usr == nil then user:SendData(sBot,"Error: User is not online.") return 1 end  
					local tmp = "" if user.sMode == "A" then tmp = "Active" else tmp = "Passive" end
					local temp="\r\n\r\n\t• Name: "..usr.sName.." \r\n"  
					temp=temp.."\t• Profile: "..(GetProfileName(usr.iProfile) or "Not Registered").." \r\n"  
					temp=temp.."\t• IP: "..(usr.sIP or "n/a").." \r\n"  
					temp=temp.."\t• Client: "..(usr.sClient or "n/a").." "..(usr.sClientVersion or "n/a").."\r\n" 
					temp=temp.."\t• Mode: "..tmp.." \r\n" 
					temp=temp.."\t• "..(usr.iSlots or "n/a").." - Slot(s) \r\n"  
					temp=temp.."\t• "..(usr.iHubs or "n/a").." - Hub(s) \r\n"  
					temp=temp.."\t• "..(usr.iNormalHubs or "n/a").." - Hub(s) as User \r\n"  
					temp=temp.."\t• "..(usr.iRegHubs or "n/a").." - Hub(s) as VIP \r\n"  
					temp=temp.."\t• "..(usr.iOpHubs or "n/a").." - Hub(s) as OP"
					user:SendPM(sBot, temp) 
				end
			end,
			["!vkick"] =
			function(user,data)
				if (kVip[user.sName] == 1) and (user.iProfile == 2) then
					local s,e,victim,reason = string.find( data, "%b<>%s+%S+%s+(%S+)%s*(.*)" ) 
					local victim = GetItemByName(victim)
					if victim then
						if victim.iProfile == -1 or victim.iProfile == 3 then 
							SendToAll(sBot,"The K-VIP "..user.sName.." is kicking "..victim.sName.." because: "..reason) 
							SendPmToOps (sBot,""..os.date().." - K-VIP Report: "..user.sName.." kicked "..victim.sName.." <"..victim.sIP.."> because: "..reason)
							victim:SendPM(sBot,"You are being kicked because : "..reason) 
							if (vLog[victim.sName] == nil) then
								vLog[victim.sName] = {}
								vLog[victim.sName]["KICK"] = ""..os.date().." - User "..victim.sName.." ("..victim.sIP..") kicked by K-VIP "..user.sName.." - Reason : "..reason
							else
								vLog[victim.sName]["KICK"] = ""..os.date().." - User "..victim.sName.." ("..victim.sIP..") kicked by K-VIP "..user.sName.." - Reason : "..reason
							end
							victim:TempBan() victim:Disconnect()
							SaveToFile(vFile , vLog , "vLog")
						else
							user:SendData(sBot,"*** Error: You can't kick an OP or VIP.")
						end
					else
						user:SendData(sBot,"*** Error: User is not online.")
					end
				end
			end,
			["!vkicklog"] = 
			function(user,data)
				if user.bOperator then
					local sTmp,victim,table = "*** These are the logged K-VIP kicks:\r\n\r\n"
					for victim, table in vLog do
						sTmp = sTmp.."\t"..table["KICK"].." - Kicked: "..table["TIMES"].." time(s)\r\n"
					end
					user:SendPM(sBot, sTmp)
				end
			end,
			["!showkvip"] = 
			function(user,data)
				if ((user.iProfile == 2) and (kVip[user.sName] == 1)) or user.bOperator then
					if next(kVip) then
						local temp="\r\n\r\n".."\t»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«".."\r\n" 
						temp=temp.."\t          ¤ Current Regged K-VIP's ¤".."\r\n" 
						temp=temp.."\t»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«".."\r\n" 
						local usr,aux 
						for usr, aux in kVip do 
							if GetItemByName(usr) then 
							temp =temp.."\t • [online]   "..usr.."\r\n" 
							else 
							temp =temp.."\t • [offline]   "..usr.."\r\n" 
							end 
						end 
						user:SendData(sBot,temp) 
					else
						user:SendData(sBot,"*** Error: There aren't registered K-VIPs.")
					end
				end
			end,
			-- End: K-VIP Commands

			-- Start: N-VIP Commands
			["!addnvip"] =
			function(user,data)
				if user.iProfile == 0 or user.iProfile == 5 then 
					local s,e,victim = string.find(data, "%b<>%s+%S+%s+(%S+)")
					if victim then
						if nVip[victim] == nil then 
							nVip[victim] = 1 	SaveToFile(nFile,nVip,"nVip")
							SendPmToOps(sBot,"The Operator "..user.sName.." gave the N-VIP status to "..victim..".") 
						else 
							user:SendData(sBot,"*** Error: "..victim.." is already a N-VIP.")
						end 
					else
						user:SendData(sBot,"*** Syntax Error: Type !addnvip <nick>")
					end
				end
			end,
			["!delnvip"] = 
			function(user,data)
				if user.iProfile == 0 or user.iProfile == 5 then 
					local s,e,victim = string.find(data, "%b<>%s+%S+%s+(%S+)")
					if victim then
						if nVip[victim] ~= 0 then 
							nVip[victim] = nil SaveToFile(nFile,nVip,"nVip")
							SendPmToOps(sBot,"The Operator "..user.sName.." has just revoked the N-VIP status from "..victim..".") 
						else 
							user:SendData(sBot,"The user "..victim.." isn't a N-VIP.") 
						end
					else
						user:SendData(sBot,"*** Syntax Error: Type !delnvip <nick>")
					end
				end
			end,
			["!nbanner"] =
			function(user,data)
				if user.iProfile == 3 and nVip[user.sName] == 1 then
					local s,e,input = string.find(data, "%b<>%s+%S+%s+(.+)")
					if input then
						local temp="\r\n\r\n".."By NVip: "..user.sName.."\r\n"
						temp=temp.."------------------".."\r\n"
						temp=temp..input.."\r\n"
						temp=temp.."------------------".."\r\n"
						SendToAll(temp)
					else
						SendPmToNick(user.sName,sBot,"*** Syntax error: Type !nbanner message ")
					end
				else
					user:SendData(sBot,"You're not allowed to use this command.") 
				end
			end,
			["!shownvip"] =
			function(user,data)
				if (user.iProfile == 3 and nVip[user.sName] == 1) or user.bOperator then
					if next(nVip) then
						local temp="\r\n\r\n".."\t»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«".."\r\n" 
						temp=temp.."\t          ¤ Current Regged N-VIP's ¤".."\r\n" 
						temp=temp.."\t»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«»«".."\r\n" 
						local usr,aux 
						for usr, aux in nVip do 
							if GetItemByName(usr) then 
							temp =temp.."\t • [online]   "..usr.."\r\n" 
							else 
							temp =temp.."\t • [offline]   "..usr.."\r\n" 
							end 
						end 
						user:SendData(sBot,temp) 
					else
						user:SendData(sBot,"*** Error: There aren't registered N-VIPs.")
					end
				end
			end,
			-- End: N-VIP Commands

			-- Start: IP Finder Commands
			["!findip"] = 
			function(user,data)
				if user.bOperator then
					local s,e,ip = string.find(data, "%b<>%s+%S+%s+(.+)")
					findip(user,ip,1)
				end
			end,
			["!getserver"] = 
			function(user,data)
				if user.bOperator then
					local s,e,ip = string.find(data, "%b<>%s+%S+%s+(.+)")
					findip(user,"127.0.0.1",0)
				end
			end,
			["!findserver"] = 
			function(user,data)
				if user.bOperator then
					local s,e,ip = string.find(data, "%b<>%s+%S+%s+(.+)")
					findip(user,findlocalip(),0)
				end
			end,
			["!searchlog"] =
			function(user,data)
				if user.bOperator then
					local s,e,ip = string.find(data, "%b<>%s+%S+%s+(.+)")
					findloggedip(user,ip)
				end
			end,
			-- End: IP Finder Commands

			-- Start: Kenny/Mute Commands
			["!kenny"] = 
			function(user,data)
				if user.bOperator then kenylize(user, data) end
			end,
			["!unkenny"] = 
			function(user,data)
				if user.bOperator then Unkenylize(user, data) end
			end,
			["!showkenny"] = 
			function(user,data)
				if user.bOperator then ShowKennys(user) end
			end,
			["!unkennyall"] = 
			function(user,data)
				if user.bOperator then Kennylizednicks = {} SendToAll(sBot, "All Kennys have gone ! ! !") end
			end,
			["+mute"] = 
			function(user,data)
				if user.bOperator then DoMutes(user, data) end
			end,
			["+unmute"] = 
			function(user,data)
				if user.bOperator then UnDoMutes(user, data) end
			end,
			["+showmutes"] = 
			function(user,data)
				if user.bOperator then ShowMutes(user) end
			end,
			["+clearmutes"] = 
			function(user,data)
				if user.bOperator then Mutes = {} SendToAll(sBot, "All muted users can now speak ! ! !") end
			end,
			-- End: Kenny/Mute Commands

			-- Start: RightClick Commands
			["!clicker"] =	
			function(user,data)
				if user.bRegistered then
					local s,e,arg = string.find(data,"%b<>%s+%S+%s+(%S+)")
					if arg then
						if string.lower(arg) == "on" then
							if Clicker[user.sName] then
								user:SendData(sBot,"*** Error: You have already enabled your personal RightClick.")
							else
								Clicker[user.sName] = 1 SaveToFile("logs/Clicker.tbl",Clicker,"Clicker")
								-- RightClick Sending
								if (SendTo[user.iProfile] == 1) and Clicker[user.sName] then
									if user.bUserCommand or (user.sClient =="iDC" or "LDC")then
										user:SendData("$UserCommand 255 7 ")
										user:SendData("$UserCommand 0 3 ")
										user:SendData("$UserCommand 1 3 ¨˜”°º• MZ Network •º°”˜¨$;")
										user:SendData("$UserCommand 0 3 ")
										if user.bOperator then OpCmds(user) end
										UserCmds(user)
										GetRightClick(user, ScriptLevel, ScriptCmds)
										GetRightClick(user, InbuildLevel, InbuildCmds)
									end
								end
								user:SendData(sBot,"Your personal Righclick has been enabled.")
							end
						elseif string.lower(arg) == "off" then
							if Clicker[user.sName] then
								Clicker[user.sName] = nil SaveToFile("logs/Clicker.tbl",Clicker,"Clicker")
								user:SendData("$UserCommand 255 3") 
								user:SendData(sBot,"Your personal Rightclick has been disabled.")
							else
								user:SendData(sBot,"*** Error: You haven't enabled your personal RightClick.")
							end
						end
					else
						user:SendData(sBot,"*** Syntax Error: Type !clicker <on/off>")
					end
				else
					user:SendData(sBot,"*** Error: Register yourself to enable your RightClick.")
				end
			end,
			["!viewclicker"] =	
			function(user,data)
				local temp= "\r\n\r\n\t       RightClick Enabled Users:\r\n\t"..string.rep("-", 60).."\r\n" 
				if user.bOperator then
					for i,v in Clicker do 
						temp = temp.."\t\t\•  "..i.."\r\n" 
					end 
					user:SendData(sBot,temp)
				end
			end,
			-- End: RightClick Commands

			-- Start: SaveShare Commands
			["!sharelog"] =	
			function(user,data)
				if user.bOperator then
					tLogs={}
					local sTmp,victim= "*** These are the logged •bot• kicks:\r\n\r\n" 
					for victim, tab in sLog do 
						table.insert( tLogs, {sLog[victim]["date"],sLog[victim]["log"]} )
					end 
					table.sort(tLogs,function(a,b) return (a[1] > b[1]) end)
					for i,v in tLogs do
						sTmp = sTmp.."\t"..tLogs[i][2].."\r\n"
					end
					tLogs={}
					user:SendPM(sBot, sTmp) 
				end
			end,
			["!noshare"] =	
			function(user,data)
				if user.bOperator then
					local msg = "\r\n\t\t\t\t - ---==Users that are under the limit==--- -\r\n" 
					msg = msg..string.rep(" -", 110).."\r\n" 
					msg = msg.."\t The following users are going to be "..DoStringActions(TheAction).." after their period of grace is over ( initialy set to "..DoTimeUnits(wtime).." )\r\n" 
					msg = msg..string.rep(" -", 110).."\r\n"..DoList(tUsers, wtime, frequency) 
					msg = msg..string.rep(" -", 110).."\r\n\r\n" 
					msg = msg..string.rep(" -", 110).."\r\n" 
					msg = msg.."\t The following users are going to be "..DoStringActions(The2Action).." after their period of grace is over ( initialy set to "..DoTimeUnits(w2time).." )\r\n" 
					msg = msg..string.rep(" -", 110).."\r\n"..DoList(tMoreUsers, w2time, secfrequency) 
					msg = msg..string.rep(" -", 110).."\r\n\r\n" 
					SendPmToNick(user.sName, sBot, msg) 
				end
			end,
			["!disnoshare"] = 
			function(user,data)
				if user.bOperator then
					if next(tUsers or tMoreUsers) then
						TableClear(tUsers) SaveToFile(tUsersFile,tUsers,"tUsers") -- tUsers saving
						TableClear(tMoreUsers) SaveToFile(tMoreUsersFile,tMoreUsers,"tMoreUsers") -- tMoreUsers saving
						user:SendData(sBot, "*** Info: All low-sharing users will be disconnected.") 
					else
						user:SendData(sBot,"*** Error: There aren't low-sharing users.")
					end
				end
			end,
			["+share"] =	
			function(user,data)
				if user.iProfile == 5 or user.sName == "Killer" then
					local s,e,Name = string.find( data, "%b<>%s+%S+%s+(%S+)" ) 
					if Name == nil then
						user:SendData(sBot, "*** Error: Type !imune nick")
					else
						if ShareImmune[string.lower(Name)] == nil then
							ShareImmune[string.lower(Name)] = 1
							SaveToFile(ShareImmuneFile, ShareImmune, "ShareImmune")
							user:SendData(sBot, Name.." is now immune to share checks!")
						else
							user:SendData(sBot,"The user "..Name.." is already immune!") 
						end
					end
				end
			end,
			["-share"] =	
			function(user,data)
				if user.iProfile == 5 or user.sName == "Killer" then
					local s,e,Name = string.find(data, "%b<>%s+%S+%s+(.+)")
					if Name == nil then
						user:SendData(sBot, "*** Error: Type -share nick")
					else
						if ShareImmune[string.lower(Name)] == 1 then
							ShareImmune[string.lower(Name)] = nil
							SaveToFile(ShareImmuneFile, ShareImmune, "ShareImmune")
							user:SendData(sBot,"Now "..Name.." is not no longer immune to share checks!")
						else
							user:SendData(sBot,"The user "..Name.." is not immune!") 
						end
					end
				end
			end,
			["?share"] =	
			function(user,data)
				if user.bOperator then
					if next(ShareImmune) then
						local Tmp,usr,table1 = "\r\n\t\ • These are the Immuned User(s):\r\n\r\n"  
						for usr, table1 in ShareImmune do 
							if GetItemByName(usr) then
								Tmp = Tmp.."\t".."  • (Online)   "..usr.." \r\n" 
							else
								Tmp = Tmp.."\t".."  • (Offline)  "..usr.." \r\n" 
							end 
						end	 			
						user:SendData(sBot,Tmp)
					else
						user:SendData(sBot,"There aren't any immuned users.")
					end
				end
			end,
			-- End: SaveShare Commands

			-- Start: ChatStats Commands
			["!mychatstat"] = 
			function (user, data)
				if Chatstats[user.sName] then
					user:SendData(sBot, StatsToString( Chatstats[user.sName], user.sName ))
				else
					user:SendData(sBot, "*** No chat statistics found!")
				end
			end,

			["!topchatters"] = 
			function ( user, data )
				tCopy={}
				if Chatstats then
					for i,v in Chatstats do
						table.insert( tCopy, { i, v.post, v.chars, v.words, v.smileys} )
					end
					table.sort( tCopy, function(a, b) return (a[Sortstats] > b[Sortstats]) end)
					local chat = "Current Top Chatters:\r\n\r\n"
					chat = chat.."\t ------------------------------------------------------------------------------------------------------------\r\n"
					chat = chat.."\t Nr.\tPosts:\tChars:\tWords:\tHappy:\tSad:\tName:\r\n"
					chat = chat.."\t ------------------------------------------------------------------------------------------------------------\r\n"
					for i = 1,25 do
						if tCopy[i] then
		--										Nr:			Posts:				Chars:				Words:				Name:
							chat = chat.."\t "..i..".\t "..tCopy[i][2].."\t "..tCopy[i][3].."\t "..tCopy[i][4].."\t "..tCopy[i][5].happy.."\t "..tCopy[i][5].sad.."\t"..tCopy[i][1].."\r\n"
						end
					end
					if ChatStatsTo == "user" then
						user:SendData(sBot, chat)
					elseif ChatStatsTo == "all" then
						SendToAll(sBot, chat)
					end
					tCopy=nil
				end
			end,

			["!delchatter"] = 
			function (user, data)
				if AllowedProfiles[user.iProfile] == 1 and user.bOperator then
					local s,e,cmd,name = string.find( data, "%b<>%s+(%S+)%s+(%S+)" )
					if name then
						if Chatstats[name] then
							Chatstats[name] = nil
							user:SendData(sBot, "Chatstats from user "..name.." are now removed!")
							SaveToFile(ChatStatsFile, Chatstats, "Chatstats")
						else
							user:SendData(sBot, "*** Chatstats from user "..name.." not found!")
						end
					else
						user:SendData(sBot, "*** Usage: !delchatter <name>")
					end
				end
			end,

			["!clearchatstats"] =
			function (user, data)
				if AllowedProfiles[user.iProfile] == 1 and user.bOperator then
					Chatstats = {}
					SaveToFile(ChatStatsFile, {}, "Chatstats")
					user:SendData(sBot, "Chatstats are cleared by "..user.sName)
				end
			end,
			-- End: ChatStats Commands

			-- Start: Chatrooms Commands
			["!mkchat"] =
			function(user,data)
				if user.bOperator then
					local s,e,args = string.find(data,"%b<>%s+%S+%s+(%S+)")
					local s,e,name,profiles = string.find(args,"(%S+)%s*(.*)")
					if not s then
						user:SendData(">> Syntax: !mkchat <name> [groups]")
					elseif chatrooms.items[name] then	
						user:SendData(">> "..name.." is already a Chatroom.")
					elseif GetItemByName(name) then
						user:SendData(">> There is a user with that name")
					else
						frmHub:RegBot(name)
						local tmp = chatrooms:new(name, user.sName)
						string.gsub(profiles, "(%S+)", function(profile)
							profile = tonumber(profile) or GetProfileIdx(profile)
							if GetProfileName(profile) then tmp.groups[profile] = 1 end
						end); tmp:chat("Hello", name)
						chatrooms:save()
						return 1
					end
				end
			end,
			-- End: Chatrooms Commands

			-- Start: Clone Alert commands
			["+clone"] =
			function(user,data)
				if user.bOperator then
					local s,e, name = string.find( data, "%b<>%s+%S+%s+(%S+)" )
					if not name then
						user:SendData(sBot, "*** Error: Type +clone nick")
					else
						if CloneImmune[string.lower(name)] then 
							user:SendData(sBot,"*** Error: "..name.." is already immune.")
						else
							CloneImmune[string.lower(name)] = 1
							SaveToFile(CloneImmuneFile, CloneImmune, "CloneImmune")
							user:SendData(sBot, name.." is now immune to clone checks!")
						end
					end
				end
			end ,
			["-clone"] =
			function(user,data)
				if user.bOperator then
					local s,e, name = string.find(data, "%b<>%s+%S+%s+(%S+)")
					if not name then
						user:SendData(sBot, "*** Error: Type -clone nick")
					else
						if not CloneImmune[string.lower(name)] then
							user:SendData(sBot,"The user "..name.." is not immune!")
						else
							CloneImmune[string.lower(name)] = nil
							SaveToFile(CloneImmuneFile, CloneImmune, "CloneImmune")
							user:SendData(sBot,"Now "..name.." is not no longer immune to clone checks!")
						end
					end
				end
			end,
			["?clone"] =
			function(user,data)
				if user.bOperator then
					local m = ""
					collectgarbage()
					for nick, _ in CloneImmune do
						local s = "Offline"
						if GetItemByName(nick) then
							s = "Online"
						end
						m = m.."\r\n\t • ("..s..")  "..nick
					end
					if m == "" then
						user:SendData(sBot, "*** Error: There aren't any immuned users") return 1
					end
					m = "\r\nThe following users can have clones in this hub:"..m
					user:SendData(sBot, m)
				end
			end,
			["!clonehelp"] =
			function(user,data)
				if user.bOperator then
					local m = "\r\n\r\nHere are the commands for the CloneBot:"
					m = m.."\r\n\t+clone <nick> \t allows <nick> to have a clone"
					m = m.."\r\n\t-clone <nick> \t removes <nick> from the clone list"
					m = m.."\r\n\t?clone\t\t shows the users allowed to have a clone"
					m = m.."\r\n\t?clonehelp \t allows <nick> to have a clone"
					user:SendData(sBot, m)
				end
			end,
			["!clonelog"] =
			function(user,data)
				if user.bOperator then
					tLogs={}
					local sTmp,victim= "*** These are the logged •bot• kicks:\r\n\r\n" 
					for victim, tab in cLog do 
						table.insert( tLogs, {cLog[victim]["date"],cLog[victim]["log"]} )
					end 
					table.sort(tLogs,function(a,b) return (a[1] > b[1]) end)
					for i,v in tLogs do
						sTmp = sTmp.."\t"..tLogs[i][2].." \r\n"
					end
					tLogs={}
					user:SendData(sBot, sTmp)
				end
			end,
			-- Start: Clone Alert commands
			}
			if tCmds[cmd] then return tCmds[cmd](user,data),1 end
		end
	end
	-- Filter Kennylized Main Chat Messages
	if (string.sub(data,1,1) == "<") then
		if Kennylizednicks[user.sName] == 1 then
			local text = kennytext[math.random(1, table.getn(kennytext))]
			SendToAll(user.sName, text)
			return 1
		elseif Mutes[user.sName] == 1 then
			user:SendData(sBot,"You are muted. Your message has been blocked ! ! !")
			return 1
		end
		-- ChatStats Saving
		if EnableChatStats[user.iProfile] == 1 then
			local s,e,str = string.find(data, "^%b<> (.*)%|$")
			updStats(user.sName, str)
		end
		-- Anti Advertiser
		if not user.bOperator then
			local _, _, msg = string.find(data, "^%b<>%s+(.*)")
			for key, value in Adver do
				if (string.find(msg, string.lower(value), 1, 1)) then
					SendPmToOps(sBot,"Symbol Shield: <"..user.sName.."> ("..user.sIP..") used forbidden symbols in Main-Chat: <"..user.sName.."> "..msg)
					return 1
				end
			end
			if Verify(user.sName, user.sName..msg) then 
				local Lines = Verify(user.sName, msg)
				tabAdvert = nil
				tabAdvert = {}
				SendPmToOps (sBot,"Report: <"..user.sName.."> ("..user.sIP..") is advertising in main: "..msg)
				SendToVips("Report: <"..user.sName.."> ("..user.sIP..") is advertising in main: "..msg) 
				user:SendData(user.sName,""..msg.."") 
				return 1
			end
			for key, value in controltrigs do
				if( string.find( string.lower(data), key) ) then
					temp = msg
				end	
			end
			if temp ~= nil then -- check if theres a trig
				SendPmToOps (sBot, "Control: <"..user.sName.."> ("..user.sIP..") told in main: "..temp.."")
				SendToVips("Control: <"..user.sName.."> ("..user.sIP..") told in main: "..temp) 
				temp = nil    -- reset temp
			end	
			local spam=0
			if( string.find( string.lower(data), "no",1,1) ) and ( string.find( string.lower(data), "ip.",1,1) ) then
				if ( string.find( string.lower(data), "com",1,1) ) or ( string.find( string.lower(data), "org",1,1) ) or ( string.find( string.lower(data), "info",1,1) ) then
					spam=spam+1;
				end;
			end;
			if( string.find( string.lower(data), "dns",1,1) ) and ( string.find( string.lower(data), "2",1,1) ) and ( string.find( string.lower(data), "go",1,1) ) then
				spam=spam+1;
			end
			if( string.find( string.lower(data), "dy",1,1) ) and ( string.find( string.lower(data), "nu",1,1) ) then
				if( string.find( string.lower(data), ".net",1,1) ) or ( string.find( string.lower(data), ".com",1,1) ) then
					spam=spam+1;
				end;
			end
			if( string.find( string.lower(data), "d n s a",1,1) ) or ( string.find( string.lower(data), "d n s .",1,1) ) or ( string.find( string.lower(data), "d n s 2",1,1) ) or ( string.find( string.lower(data), "o d s .",1,1) ) or ( string.find( string.lower(data), "d y n",1,1) ) then
				spam=spam+1;
			end
		end
	end
end

ToArrival = function(user,data)
	if (string.sub(data,1,5+string.len(sBot)) == "$To: "..sBot) then  ChatArrival(user,data) end
	-- Filter Kennylized PM Messsages
	if Kennylizednicks[user.sName] == 1 then
		local s,e,g,h,j = string.find(data,"$To:%s+(%S+)%s+From:%s+(%S+)%s+$%b<>%s+(.*)")
		local j = kennytext[math.random(1, table.getn(kennytext))]
		SendPmToNick(g,h,j)			
		user:SendPM(sBot," You have been kenylized this was sent instead. ' "..j.." '")
		return 1
	elseif Mutes[user.sName] == 1 then
		user:SendPM(sBot,"You are muted. Your message has been blocked ! ! !")
		return 1
	end
	-- Chatroom's Messages
	local s,e,to,str = string.find(data,"^$To: (%S+) From: %S+ $%b<> (.*)")
	if chatrooms.items[to] then
		local tmp = chatrooms.items[to]
		if not tmp.members[user.sName] then
			if user.bOperator or tmp.groups[user.iProfile] == 1 then
				tmp.members[user.sName] = 1
				tmp:chat(user.sName.." joined", to)
				tmp:chat(str, user.sName)
				chatrooms:save()
			else
				user:SendPM(to, "You're not a member here.")
			end
		else
			local isowner = (tmp.owner == user.sName)
			local s, e, cmd, args = string.find(str, "^%!(%a+)%s*(.*)$")
			if not s then
				tmp.members[user.sName] = 1
				tmp:chat(str, user.sName)
			elseif cmd == "away" then
				tmp:chat(user.sName.." is away.. "..args, to)
				tmp.members[user.sName] = 0
			elseif cmd == "leave" then
				tmp:chat(user.sName.." left. "..args, to)
				tmp.members[user.sName] = nil
				chatrooms:save()
			elseif cmd == "members" then
				local n, na, msg = 0, 0
				for nick, stat in tmp.members do
					if not GetItemByName(nick) then msg = " (offline)"
					elseif stat == 0 then msg = " (away)"
					else msg, na = "", na+1
					end; n = n+1
					user:SendPM(to, "\t"..nick..msg)
				end; user:SendPM(to, na.."/"..n.." active members.")
			elseif cmd == "help" then
				user:SendPM(to,"Escreva !join para entrar na sala, !leave para sair e !members para ver quem está presente.")
			elseif cmd == "invite" then
				string.gsub(args, "(%S+)", function(nick)
					if not tmp.members[nick] then
						tmp.members[nick] = 1
						tmp:chat(nick.." has been invited to the room. ", to)
					end
				end); chatrooms:save()
			elseif cmd == "remove" and user.bOperator then
				string.gsub(args, "(%S+)", function(nick)
					if tmp.members[nick] and nick ~= tmp.owner then
						tmp:chat(nick.." has been removed from the room", to)
						tmp.members[nick] = nil
					end
				end); chatrooms:save()
			elseif cmd == "delchat" and isowner then
				tmp:chat("End of session.", to)
				chatrooms.items[to] = nil
				chatrooms:save()
				frmHub:UnregBot(to)
			else
				tmp:chat(str, user.sName)
			end
		end;
		return 1
	end
	-- Anti Advertiser for PMs
	if not user.bOperator then
		local _, _, to, from, msg = string.find(data, "^%$To:%s+(%S+)%s+From:%s+(%S+)%s-%$%b<>%s+(.*)")
		local nick = GetItemByName(to)
		for key, value in Adver do
			if (string.find(msg, string.lower(value), 1, 1)) and to ~= sBot then
				SendPmToOps(sBot,"Symbol Shield: <"..user.sName.."> ("..user.sIP..") used forbidden symbols in PM to <"..nick.sName..">, typing: <"..user.sName.."> "..msg)
				return 1
			end
		end
		local userdata = to.." "..from
		if Verify(userdata, msg) then 
			local Lines = Verify(userdata, msg)
			tabAdvert = nil
			tabAdvert = {}
			SendPmToOps (sBot,"Report: <"..user.sName.."> ("..user.sIP..") is advertising to <"..to.."> in PVT this: "..msg)
			SendToVips("Report: <"..user.sName.."> ("..user.sIP..") is advertising to <"..to.."> in PVT this: "..msg) 
			return 1
		end
		for key, value in controltrigs do
			if( string.find( string.lower(data), key) ) then
				temp2 = msg
			end
		end
		if temp2 ~= nil then -- check if theres a trig
			SendPmToOps (sBot, "Control: <"..user.sName.."> ("..user.sIP..") said to <"..to.."> in PVT this: "..temp2.."")
			SendToVips("Control: <"..user.sName.."> ("..user.sIP..") said to <"..to.."> in PVT this: "..temp2) 
			temp2 = nil    -- reset temp
		end
		local spam = 0
		if( string.find( string.lower(data), "no",1,1) ) and ( string.find( string.lower(data), "ip.",1,1) ) then
			if ( string.find( string.lower(data), "com",1,1) ) or ( string.find( string.lower(data), "org",1,1) ) or ( string.find( string.lower(data), "info",1,1) ) then
				spam=spam+1;
			end;
		end;
		if( string.find( string.lower(data), "dns",1,1) ) and ( string.find( string.lower(data), "2",1,1) ) and ( string.find( string.lower(data), "go",1,1) ) then
			spam=spam+1;
		end
		if( string.find( string.lower(data), "dy",1,1) ) and ( string.find( string.lower(data), "nu",1,1) ) then
			if( string.find( string.lower(data), ".net",1,1) ) or ( string.find( string.lower(data), ".com",1,1) ) then
				spam=spam+1;
			end;
		end
		if( string.find( string.lower(data), "d n s a",1,1) ) or ( string.find( string.lower(data), "d n s .",1,1) ) or ( string.find( string.lower(data), "d n s 2",1,1) ) or ( string.find( string.lower(data), "o d s .",1,1) ) or ( string.find( string.lower(data), "d y n",1,1) ) then
			spam=spam+1;
		end
	end
end

NewUserConnected = function(user,data) 
	-- RightClick Sending
	if (SendTo[user.iProfile] == 1) and Clicker[user.sName] then
		if user.bUserCommand or (user.sClient =="iDC" or "LDC")then
			user:SendData("$UserCommand 255 7 ")
			user:SendData("$UserCommand 0 3 ")
			user:SendData("$UserCommand 1 3 ¨˜”°º• MZ Network •º°”˜¨$;")
			user:SendData("$UserCommand 0 3 ")
			if user.bOperator then OpCmds(user) end
			UserCmds(user)
			GetRightClick(user, ScriptLevel, ScriptCmds)
			GetRightClick(user, InbuildLevel, InbuildCmds)
		end
	end
	-- SaveShare related
	if ShareImmune[string.lower(user.sName)] ~= 1 then -- if user isnt imune 
		if user.sMyInfoString then 
			if user.iShareSize < limitshare then
				local ishere,share = 0,user.iShareSize
				if tUsers[user.sName] ~= nil then 
					user:SendPM(sBot, "Please fill up your share to reach "..DoShareUnits(limitshare)..". Presently you are sharing "..DoShareUnits(tonumber(share))..". To do so, go to File - Settings - Sharing and then choose Add Folders.") 
					user:SendPM(sBot, " - You have another "..DoTimeUnits(wtime - tUsers[user.sName][1]).." left.") 
				elseif tMoreUsers[user.sName] ~= nil then 
					user:SendPM(sBot, "Fill up your share to reach "..DoShareUnits(limitshare)..". Presently you are sharing "..DoShareUnits(tonumber(share))..". To do so, go to File - Settings - Sharing and then choose Add Folders.") 
					user:SendPM(sBot, " - You have another "..DoTimeUnits(w2time - tMoreUsers[user.sName][1]).." left.") 
				end	 
				if tUsers[user.sName] == nil and ishere ~= 1 then 
					if tAgain[user.sName] == 1 then 
						tAgain[user.sName] = nil 
						tMoreUsers[user.sName] = {} 
						tMoreUsers[user.sName][1] = 0 
						tMoreUsers[user.sName][2] = 1 
						user:SendPM(sBot, "You come without having the required share of "..DoShareUnits(limitshare).." Again? Presently you are sharing "..DoShareUnits(tonumber(share))..". To do so, go to File - Settings - Sharing and then choose Add Folders.") 
						user:SendPM(sBot, "You now have just "..DoTimeUnits(w2time).." left to fill it up. If you don't you are getting "..DoStringActions(The2Action)..".") 
					else 
						tUsers[user.sName] = {}  
						tUsers[user.sName][1] = 0 
						tUsers[user.sName][2] = 1 
						user:SendPM(sBot, "Please fill up your share to reach "..DoShareUnits(limitshare)..". Presently you are sharing "..DoShareUnits(tonumber(share))..". To do so, go to File - Settings - Sharing and then choose Add Folders.") 
						user:SendPM(sBot, " - You have another "..DoTimeUnits(wtime).." left.") 
					end 
				end 
			end 
		end 
	end
	if not user.bOperator then
		-- N-VIP Intro Sending
		if nVip[user.sName] == 1 and user.iProfile == 3 then 
			local intro, x = string.gsub(intros[math.random(1,table.getn(intros))], "%b[]", "[MZNet Member]: "..user.sName) 
			SendToAll(sBot, intro) 
		end 
		-- Clone Checker
		for _,Nick in frmHub:GetOnlineNonOperators() do
			if user.sIP==Nick.sIP then
				if not(CloneImmune[string.lower(user.sName)] == 1 or CloneImmune[string.lower(Nick.sName)]== 1) then
					if user.iShareSize==Nick.iShareSize then
						user:SendPM(sBot,"Double Login is not allowed. You are already connected to this hub with this nick: "..Nick.sName)
						user:SendPM(sBot,"You're being timebanned. Your IP: "..user.sIP)
						user:SendPM(sBot,"Please contact the Operators in case you have a Home Network.")
						user:SendPM(sBot,"Contacte os Operadores do hub caso tenha uma rede de computadores em casa.")
						Nick:SendPM(sBot,"Double Login is not allowed. You tried to connect with this nick: "..user.sName)
						user:TimeBan(5)
						-- clone logging
						if (cLog[user.sName] == nil) then 
							cLog[user.sName] = {} 
							cLog[user.sName]["date"] = os.date()
							cLog[user.sName]["log"] = os.date().." - User "..user.sName.." ("..user.sIP..") kicked by •bot• - Reason: Clone of <"..Nick.sName..">"
						else 
							cLog[user.sName]["log"] = os.date().." - User "..user.sName.." ("..user.sIP..") kicked by •bot• - Reason: Clone of <"..Nick.sName..">"
						end 
						-- clone logging stop
					end
				end
			end
		end
		-- Collect garbage and flush
		collectgarbage(); io.flush();
	end
end

OpConnected = NewUserConnected

OnTimer = function()
	for i in ipairs(tabTimers) do
		tabTimers[i].count = tabTimers[i].count + 1
		if tabTimers[i].count > tabTimers[i].trig then
			tabTimers[i].count=1
			tabTimers[i]:func()
		end
	end
end

RegTimer = function(f, Interval)
	local tmpTrig = Interval / TmrFreq
	assert(Interval >= TmrFreq , "RegTimer(): Please Adjust TmrFreq")
	local Timer = {n=0}
	Timer.func=f
	Timer.trig=tmpTrig
	Timer.count=1
	table.insert(tabTimers, Timer)
end

OnExit = function()
	-- .tbl saving
	if next(Chatstats) then SaveToFile(ChatStatsFile, Chatstats, "Chatstats") end -- ChatStats saving
	if next(tUsers) then SaveToFile(tUsersFile,tUsers,"tUsers") end -- tUsers saving
	if next(tMoreUsers) then SaveToFile(tMoreUsersFile,tMoreUsers,"tMoreUsers") end -- tMoreUsers saving
	if next(cLog) then SaveToFile(cFile,cLog,"cLog") end -- log all bot kicks/bans 
	if next(sLog) then SaveToFile(sFile,sLog,"sLog") end -- log all bot kicks/bans 
	-- Save Chatrooms
	chatrooms:save()
end

OnError = function(ErrorMsg)
local s,e,nline =string.find(ErrorMsg,"%:(%S+)%:")
local i=0
	for line in io.lines("compiled.lua") do
		i=i + 1
		if tonumber(i)==tonumber(nline) then
			ErrorMsg = ErrorMsg.."\r\n\-->\t\t".." line "..i..": "..line
			SendPmToOps(frmHub:GetOpChatName(), ErrorMsg)
		end
	end
	io.close()
end

-- Start: IP Finder functions
findip = function(user,ip,i)
	local check,msg,border ="","\r\n",string.rep ("«»", 12)
	if i==1 and ip then 
		temp= msg.."\t"..border..""
		temp= temp.."\r\n".."\t".."IP: "..ip.." belongs to :".."\r\n"
	else
		temp= msg.."\t"..border..""
		temp= temp.."\r\n".."\t".."Current server is: ".."\r\n"
	end
	temp=temp.."\t"..border.."\r\n"
	for _,nick in frmHub:GetOnlineUsers() do
		if nick.sIP==ip and i==1 then
			temp=temp.."\t\t".."•"..nick.sName.."\r\n"
			check=check..nick.sIP
		elseif i==0 and nick.sIP==frmHub:GetHubIp() or nick.sIP==ip then 
			temp=temp.."\t\t".."•"..nick.sName.."\r\n"
			check=check..nick.sIP
		elseif i==0 and not(nick.sIP==ip )and check==nil then
			temp="*** Error: The person with the server isn't online."
		end
	end
	if check=="" then
		user:SendData(sBot,"*** Error: User with that IP isn't online.")
	elseif not(check=="") then 
		user:SendPM(sBot,temp)
	end
	temp=""
	check=""
end


-- ping localhost to find ip --
findlocalip = function()
	os.execute("ping -n 1 localhost >localip.txt")
	local stuff =""
	for line in io.lines("localip.txt") do
    		stuff = stuff..line.."\r\n"
	end
	s,l =string.find(stuff,"%[")
	e,f=string.find(stuff,"%]")
	local hubip=(string.sub(stuff,s+1,e-1))
	os.execute("del localip.txt")
	return hubip 
end

--search iplog(from robocop)
findloggedip = function(user,ip) 
	local check,todayslog,msg,border= "","logs/iplogs/"..os.date("%m-%d-%y").."_IP.log","\r\n",string.rep ("«»", 18)
	found= msg.."\t"..border..""
	found= found.."\r\n\t\t".."Results of your search:".."\r\n"
	found= found.."\t"..border.."\r\n"
	if ip and io.open(todayslog,"r") then
		for line in io.lines(todayslog) do
			s,e =string.find(line,ip)
			if not(e==nil) and not(s==nil) then 
				e=nil		--reset the searcher
				s=nil		-- ""		""
				found=found.."\t"..(string.sub(line,0,e)).."\r\n"
				check=check..string.sub(line,0,e)
			end
		end
	else 
		user:SendData(sBot,"*** Syntax Error: Type: !searchlog IP")
	end
	if not(check=="") then
		user:SendPM(sBot,found)
	else
		user:SendData(sBot,"*** Error: That IP wasn't found in the logs.")
	end
	check=nil
	found=nil
end
-- End: IP Finder functions

-- Start: Kenny and Mute functions

DoMutes = function(user, data)
	local s,e,cmd,usr = string.find(data,"%b<>%s+(%S+)%s+(%S+)")
	local Muted = GetItemByName(usr)
	if Muted == nil then
		user:SendData(sBot,"The User is not in the hub ! ! !")
	else
		if Mutes[Muted.sName] == nil then
			Mutes[Muted.sName] = 1
			SendToAll(sBot,Muted.sName.." Has been Muted ! ! !")
		end
	end
end

UnDoMutes = function(user, data)
	local s,e,cmd,usr = string.find(data,"%b<>%s+(%S+)%s+(%S+)")
	local Muted = GetItemByName(usr)
	if Muted == nil then
		user:SendData(sBot,"The User is not in the hub ! ! !")
	else
		if Mutes[Muted.sName] == 1 then
			Mutes[Muted.sName] = nil;
			SendToAll(sBot, Muted.sName.." Has Been Un-Muted ..")
		end
	end
end

ShowMutes = function(user)
	local names = ""
	for index, value in Mutes do
		local line = index
		names = names.." "..line.."\r\n"
	end
	user:SendData(sBot,"\r\n\r\nMuted users..\r\n\r\n"..names)
end

kenylize = function(user, data)
	local s,e,cmd,usr = string.find(data,"%b<>%s+(%S+)%s+(%S+)")
	local kennyd = GetItemByName(usr)
	if kennyd == nil then
		user:SendData(sBot,"The User is not in the hub ! ! !")
	else
		if Kennylizednicks[kennyd.sName] == nil then
			Kennylizednicks[kennyd.sName] = 1
			SendToAll(sBot,kennyd.sName.." Has been turned in to a Kenny Clone  ! ! !")
		end
	end
end

Unkenylize = function(user, data)
	local s,e,cmd,usr = string.find(data,"%b<>%s+(%S+)%s+(%S+)")
	local kennyd = GetItemByName(usr)
	if kennyd == nil then
		user:SendData(sBot,"The User is not in the hub ! ! !")
	else
		if Kennylizednicks[kennyd.sName] == 1 then
			Kennylizednicks[kennyd.sName] = nil;
			SendToAll(sBot, kennyd.sName.." Has Returned ..")
		end
	end
end

ShowKennys = function(user)
	local names = ""
	for index, value in Kennylizednicks do
		local line = index
		names = names.." "..line.."\r\n"
	end
	user:SendData(sBot,"\r\n\r\nKennylised users..\r\n\r\n"..names)
end
-- End: Kenny and Mute functions

-- Start: RightClick functions

GetRightClick = function(user, table1, table2)
	for cmd,_ in table1 do
		if table1[cmd][user.iProfile] == 1 then
			for value,command in table2 do
				if cmd == value then user:SendData(command) end 
			end 
		end
	end
end

ScriptCmds = {
	["dash"]="$UserCommand 0 3 ", 
	["regreg"]="$UserCommand 1 3 Comandos dos OPs\\Registo de Users\\!regreg - Reg User$<%[mynick]> !regreg %[nick] %[line:Password]&#124;",	-- regreg
	["regvip"]="$UserCommand 1 3 Comandos dos OPs\\Registo de Users\\!regvip - Reg Vip$<%[mynick]> !regvip %[nick] %[line:Password]&#124;",	-- regvip
	["regop"]="$UserCommand 1 3 Comandos dos OPs\\Registo de Users\\!regop - Reg Op$<%[mynick]> !regop %[nick] %[line:Password]&#124;",	-- regop
	["regmop"]="$UserCommand 1 3 Comandos dos OPs\\Registo de Users\\!regmod - Reg Moderator$<%[mynick]> !regmod %[nick] %[line:Password]&#124;",	-- regmop
	["regmaster"]="$UserCommand 1 3 Comandos dos OPs\\Registo de Users\\!regmaster - Reg Master$<%[mynick]> !regmaster %[nick] %[line:Password]&#124;",	-- regmaster
	["regfounder"]="$UserCommand 1 3 Comandos dos OPs\\Registo de Users\\!regfounder - Reg Founder$<%[mynick]> !regfounder %[nick] %[line:Password]&#124;",	-- regfounder
	["deluser"]="$UserCommand 1 3 Comandos dos OPs\\Registo de Users\\!deluser - Apagar User Registado$<%[mynick]> !deluser %[nick]&#124;",	-- deluser
	["upgrade"]="$UserCommand 1 3 Comandos dos OPs\\Registo de Users\\!upgrade - Upgrade User$<%[mynick]> !upgrade %[nick] %[line:reg/vip/op/mod/master/founder]&#124;",	-- upgrade
	["getpass"]="$UserCommand 1 3 Comandos dos OPs\\Registo de Users\\!getpass - Get Password do User$<%[mynick]> !getpass %[nick]&#124;",	-- getpass

	["faq"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!faq - Guia do DC++$<%[mynick]> !faq&#124;",	-- faq 
	["myip"]="$UserCommand 1 3 Comandos Básicos\\!myip - O seu actual IP$<%[mynick]> !myip&#124;",	-- myip 
	["rules"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!rules - Regras do Hub$<%[mynick]> !rules&#124;",	-- rules 
	["myInfo"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!myInfo - Toda a sua Informação disponível$<%[mynick]> !myInfo&#124;",	-- myInfo 
	["version"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!version - Versão do script$<%[mynick]> !version&#124;",	-- version 
	["getaways"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!getaways - Mostra todos os nicks ausentes$<%[mynick]> !getaways&#124;",	-- getaways 
	["myhubtime"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!myhubtime - Seu tempo online no Hub$<%[mynick]> !myhubtime&#124;",	-- myhubtime 
	["jump"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!jump - Mostra os endereços de redirect disponíveis$<%[mynick]> !jump&#124;",	-- jump 
	["help"]="$UserCommand 1 3 Comandos Básicos\\!help - Ajuda$<%[mynick]> !help&#124;",	-- help 
	["inbuild"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!inbuild - Mostra os comandos Inbuild$<%[mynick]> !inbuild %&#124;",	-- inbuild 
	["offline"]="$UserCommand 1 3 Comandos Básicos\\!offline - Offline Message$<%[mynick]> !offline %[line:Nick] %[line:Mensagem]&#124;",	-- offline 
	["regme"]="$UserCommand 1 3 Comandos Básicos\\!regme - Registe-se no Hub$<%[mynick]> !regme %[line:Password]&#124;",	-- regme 
	["repass"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!repass - Mude a sua password$<%[mynick]> !repass %[line:Nova Password]&#124;",	-- repass 
	["showreg"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!showreg - Users por Profile (reg/vip/op/mod/master/founder)$<%[mynick]> !showreg %[line:reg/vip/op/mod/master/founder]&#124;",	-- showreg 
	["report"]="$UserCommand 1 3 Comandos Básicos\\Geral\\!report - Avise aos OPs sobre um User$<%[mynick]> !report %[nick] %[line:Motivo]&#124;",	-- report 
	["away"]="$UserCommand 1 3 Comandos Básicos\\!away - Defina-se como ausente$<%[mynick]> !away %[line:Motivo]&#124;",	-- away 
	["back"]="$UserCommand 1 3 Comandos Básicos\\!back - Retorne após ausência$<%[mynick]> !back&#124;",	-- back 
	["noclean"]="$UserCommand 1 3 Comandos dos OPs\\User Cleaner\\!noclean - Add/Delete user from NoClean list $<%[mynick]> !noclean %[line:add/delete] %[line:nick]&#124;",
	["shownoclean"]="$UserCommand 1 3 Comandos dos OPs\\User Cleaner\\!shownoclean - Show users in NoClean list$<%[mynick]> !shownoclean&#124;",
}

InbuildCmds = {
	["op"]="$UserCommand 1 3 Comandos dos OPs\\Geral\\!op - Temp Op$<%[mynick]> !op %[nick]&#124;", 	-- op
	["banip"]="$UserCommand 1 3 Comandos dos OPs\\Temp/Perm Ban\\!banip - Banip user$<%[mynick]> !banip %[line:IP]&#124;",
	["getbanlist"]="$UserCommand 1 3 Comandos dos OPs\\Temp/Perm Ban\\!getbanlist - Getbanlist$<%[mynick]> !getbanlist&#124;",
	["clrpermban"]="$UserCommand 1 3 Comandos dos OPs\\Temp/Perm Ban\\!clrpermban - Clearpermban$<%[mynick]> !clrpermban&#124;",
	["clrtempban"]="$UserCommand 1 3 Comandos dos OPs\\Temp/Perm Ban\\!clrtempban - Cleartempban$<%[mynick]> !clrtempban&#124;",
	["gettempbanlist"]="$UserCommand 1 3 Comandos dos OPs\\Temp/Perm Ban\\!gettempbanlist - Gettempbanlist$<%[mynick]> !gettempbanlist&#124;",
	["tempunban"]="$UserCommand 1 3 Comandos dos OPs\\Temp/Perm Ban\\!tempunban - Unban tempbanned user$<%[mynick]> !tempunban %[line:Nick/IP]&#124;",
	["tempban"]="$UserCommand 1 3 Comandos dos OPs\\Temp/Perm Ban\\!tempban - Tempban user for x minutes$<%[mynick]> !tempban %[nick] %[line:Time (1h = 1 hour, 1m = 1 minute)] %[line:Reason]&#124;",
	["reloadtxt"]="$UserCommand 1 3 Comandos dos OPs\\Geral\\!reloadtxt - Reload txts$<%[mynick]> !reloadtxt&#124;",
}

UserCmds = function(user) 
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\a.join - Jogar$<%[mynick]> a.join&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\a.leave - Sair$<%[mynick]> a.leave&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\a.hint - Dica$<%[mynick]> a.hint&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\a.phrase - Frase Actual$<%[mynick]> a.phrase&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\a.help - Ajuda$<%[mynick]> a.help&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\a.scores - Pontuação do Hub$<%[mynick]> a.scores&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\TopChatter\\!topchatters - TopChatters$<%[mynick]> !topchatters&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\TopChatter\\!mychatstat - My Chat Stat$<%[mynick]> !mychatstat&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Help$<%[mynick]> +entryhelp&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Find$<%[mynick]> !find %[line:String]&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Geral\\!requisitos - Requisitos$<%[mynick]> !requisitos&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Network\\!mznet - MZ Network$<%[mynick]> !mznet&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Network\\!netrules - Regras da Rede$<%[mynick]> !netrules&#124;")
	user:SendData("$UserCommand 0 3 ") 
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Network\\!safenet - SAFENET$<%[mynick]> !safenet&#124;")

	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Show\\!show cinemas - Cinemas$<%[mynick]> !show cinemas&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Show\\!show eventos - Eventos$<%[mynick]> !show eventos&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Show\\!show destaques - Destaques$<%[mynick]> !show destaques&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Show\\!show publicidades - Publicidades$<%[mynick]> !show publicidades%[line:Category]&#124;")

	if user.iProfile == 3 then 
		if nVip[user.sName] == 1 then
			user:SendData("$UserCommand 1 3 Comandos dos N-VIP\\!nbanner - Mensagem no main$<%[mynick]> !nbanner %[line:Mensagem]&#124;") 
			user:SendData("$UserCommand 1 3 Comandos dos N-VIP\\!shownvip - Mostra os N-VIPs$<%[mynick]> !shownvip&#124;") 
		end 
	end 

	if user.iProfile == 2 then 
		if kVip[user.sName] == 1 then
			user:SendData("$UserCommand 1 3 Comandos dos K-VIP\\!vkick - Kick$<%[mynick]> !vkick %[nick] %[line:Kick Reason]&#124;") 
			user:SendData("$UserCommand 1 3 Comandos dos K-VIP\\!vinfo - Informação$<%[mynick]> !vinfo %[nick]&#124;") 
			user:SendData("$UserCommand 1 3 Comandos dos K-VIP\\!showkvip - Mostrar K-VIPs$<%[mynick]> !showkvip&#124;")
		else
			user:SendData("$UserCommand 0 3 ") 
			user:SendData("$UserCommand 1 3 Comandos dos VIP\\!warn - Warn User$<%[mynick]> !warn %[nick] %[line:Motivo]&#124;")	-- Example line
			user:SendData("$UserCommand 1 3 Comandos dos VIP\\!banner - Mensagem no Main$<%[mynick]> !banner %[line:Mensagem]&#124;")	-- Example line
			user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\Começar (VIP/OP)$<%[mynick]> a.start&#124;")
			user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\Parar (VIP/OP)$<%[mynick]> a.stop&#124;")
		end 
	end 
end 

OpCmds = function(user) 
	user:SendData("$UserCommand 1 3 !warn - Warn User$<%[mynick]> !warn %[nick] %[line:Motivo]&#124;")	-- Example line
	user:SendData("$UserCommand 1 3 !kick - Kick User$<%[mynick]> !kick %[nick] %[line:Motivo]&#124;")	-- Example line
	user:SendData("$UserCommand 1 3 !ban - Ban User$<%[mynick]> !ban %[nick] %[line:Motivo]&#124;")
	user:SendData("$UserCommand 1 3 !kill - Kill User <ip/nameban>$<%[mynick]> !kill %[nick] %[line:Motivo]&#124;")	-- Example line
	user:SendData("$UserCommand 1 3 !timeban - Timeban User$<%[mynick]> !timeban %[nick] %[line:hr:mn] %[line:Motivo]&#124;")	-- Example line
	user:SendData("$UserCommand 1 3 !nameban - Nameban User$<%[mynick]> !nameban %[nick] %[line:Motivo]&#124;")
	user:SendData("$UserCommand 1 3 !info - Info$<%[mynick]> !info %[nick]&#124;")	-- Example line
	user:SendData("$UserCommand 1 3 !drop - Drop User$<%[mynick]> !drop %[nick]&#124;")	-- Example line
	user:SendData("$UserCommand 1 3 !gag - Gag User$<%[mynick]> !gag %[nick]&#124;")	-- Example line
	user:SendData("$UserCommand 1 3 !watch - Watch User$<%[mynick]> !watch %[nick]&#124;")
	user:SendData("$UserCommand 1 3 !banner - Mensagem no Main$<%[mynick]> !banner %[line:Mensagem]&#124;")
	user:SendData("$UserCommand 0 3 ") 
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\a.private - Jumble Privado$<%[mynick]> a.private&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\a.public - Jumble Público$<%[mynick]> a.public&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\TopChatter\\!delchatter - Del Chatter$<%[mynick]> !delchatter %[line:Nick]&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\TopChatter\\!clearchatstats - Clear Chat Stats$<%[mynick]> !clearchatstats&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Share Control\\!sharelog - Share Kick List$<%[mynick]> !sharelog&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Share Control\\!noshare - Under Share Users$<%[mynick]> !noshare&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Share Control\\!disnoshare - Disconnect Under Share Users$<%[mynick]> !disnoshare&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Share Control\\+share - Share Immunity$<%[mynick]> +share %[nick]&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Share Control\\-share - Delete Share Immunity$<%[mynick]> -share %[line:Nick]&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Share Control\\?share - Show Share Immune Users$<%[mynick]> ?share&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Clone Control\\!clonelog - Kicked Clones List$<%[mynick]> !clonelog&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Clone control\\+clone - Make a User Immune$<%[mynick]> +clone %[nick]&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Clone control\\-clone - Remove immunity from Clone$<%[mynick]> -clone %[line:Nick]&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Clone control\\?clone - Show all immuned users$<%[mynick]> ?clone&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Kenny\\!kenny - Kenny$<%[mynick]> !kenny %[nick] &#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Kenny\\!unkenny - UnKenny$<%[mynick]> !unkenny %[nick] &#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Kenny\\!showkenny - Mostrar Kennys$<%[mynick]> !showkenny&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Kenny\\!unkennyall - Limpar Kennys$<%[mynick]> !unkennyall&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\IP Finder\\!findip - Find IP$<%[mynick]> !findip %[line:IP]&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\IP Finder\\!searchlog - Search in Logs$<%[mynick]> !searchlog %[line:IP]&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Mute\\+mute - Mute$<%[mynick]> +mute %[nick] &#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Mute\\+unmute - UnMute$<%[mynick]> +unmute %[nick] &#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Mute\\+showmutes - Mostrar Mutes$<%[mynick]> +showmutes&#124;")
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\Mute\\+clearmutes - Limpar Mutes$<%[mynick]> +clearmutes&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Salas de Chat\\!mkchat - Criar$<%[mynick]> !mkchat %[line:Nome da Sala] %[line:Profile mínimo exigido (reg/vip/op/mod/founder)]&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\RightClick\\!clicker off - Desligar RightClick$<%[mynick]> !clicker off&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\RightClick\\!viewclicker - Users Activos$<%[mynick]> !viewclicker&#124;")

	user:SendData("$UserCommand 1 3 Comandos dos OPs\\N-VIP\\!shownvip - Mostra os N-VIPs$<%[mynick]> !shownvip&#124;") 
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\K-VIP\\!vkicklog - V-Kick Log$<%[mynick]> !vkicklog %[nick]&#124;") 
	user:SendData("$UserCommand 1 3 Comandos dos OPs\\K-VIP\\!showkvip - Mostrar K-VIPs$<%[mynick]> !showkvip&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\Começar (VIP/OP)$<%[mynick]> a.start&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\Parar (VIP/OP)$<%[mynick]> a.stop&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Add\\Category$<%[mynick]> !addcat %[line:Category] %[line:Maximum LifeTime in days]&#124;") 
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Delete\\Category$<%[mynick]> !delcat %[line:Category]&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Delete\\Specific ID$<%[mynick]> !del %[line:ID]&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Delete\\Specific Entry$<%[mynick]> !del %[line:Entry Name]&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Delete\\Category Content$<%[mynick]> !del %[line:Category Name]&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Delete\\All Entries$<%[mynick]> !delall&#124;")
	user:SendData("$UserCommand 1 3 Comandos Básicos\\Entry Bot\\Setup\\Rotator Status$<%[mynick]> !rotator %[line:on/off]&#124;")

	if user.iProfile == 0 or (user.iProfile == 5) then 
		user:SendData("$UserCommand 1 2 Comandos dos OPs\\N-VIP\\!addnvip - Adicionar N-VIP$<%[mynick]> !addnvip %[nick]&#124;") 
		user:SendData("$UserCommand 1 2 Comandos dos OPs\\N-VIP\\!delnvip - Apagar N-VIP$<%[mynick]> !delnvip %[nick]&#124;") 
		user:SendData("$UserCommand 1 3 Comandos dos OPs\\K-VIP\\!addvkick - Adicionar K-VIP$<%[mynick]> !addvkick %[nick]&#124;") 
		user:SendData("$UserCommand 1 3 Comandos dos OPs\\K-VIP\\!delvkick - Apagar K-VIP$<%[mynick]> !delvkick %[nick]&#124;") 
		user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\Começar (VIP/OP)$<%[mynick]> a.start&#124;")
		user:SendData("$UserCommand 1 3 Comandos Básicos\\Jogos\\Jumble\\Parar (VIP/OP)$<%[mynick]> a.stop&#124;")
	end
end

-- End: RightClick functions

-- Start: SaveShare functions
TakeCare = function(table, timeallowed, balance, freq, doaction) 
	for user, time in table do 
		local usr = GetItemByName(user) 
		if not (usr == nil) then
			if not (ShareImmune[string.lower(usr.sName)] == 1) then -- if user is imune 
				if usr and usr.sMyInfoString then 
					table[user][1] = table[user][1] + 1 
					if usr.iShareSize < limitshare then 
						local share = usr.iShareSize
						if ( table[user][1] >= timeallowed ) then 
							usr:SendPM(sBot, "You didn't fill up your share to fulfill hub requirements. Go to File - Settings - Sharing and then Add Folders to your share.") 
							if (sLog[usr.sName] == nil) then 
								sLog[usr.sName] = {} 
								sLog[usr.sName]["date"] = os.date()
								sLog[usr.sName]["log"] = os.date().." - User "..usr.sName.." ("..usr.sIP..") kicked by •bot• - Reason: Low Share"
							else 
								sLog[usr.sName]["log"] = os.date().." - User "..usr.sName.." ("..usr.sIP..") kicked by •bot• - Reason: Low Share"
							end 
							return Act(usr, table, doaction) 
						elseif ( table[user][1] == balance * table[user][2] ) then 
							table[user][2] = table[user][2] + 1 
							usr:SendPM(sBot, "Please fill up your share ... "..(table[user][2]-1).."/ "..freq.." warnings ... on the last warning you will get "..DoStringActions(doaction)..". To do so, go to File - Settings - Sharing and then choose Add Folders.") 
							usr:SendPM(sBot, "- You have another "..DoTimeUnits(timeallowed - table[user][1]).." left.") 
						end 
					else 
						table[usr.sName] = nil 
					end 
				end 
			end 
		end
	end 
end 

DoStringActions = function(act) 
	local tActionStr = { 
			[1] = "Disconnected", 
			[2] = "Redirected", 
			[3] = "Kicked", 
			[4] = "Temporalily Banned", 
			[5] = "Banned", 
			[6] = "Banned", 
			[7] = "Time Banned", 
			[8] = "Flooded "..floodTimes.." times and then Disconnected",  
		}; 
	return tActionStr[act] 
end 

DoList = function(table, timeallowed, freq) 
	local msg = "" 
	local cnt = 0 
	for nick , time in table do 
		if GetItemByName(nick) then 
			status = "online" 
		else
			status = "offline" 
		end 
		cnt = cnt + 1 
		msg = msg..cnt..".\t - Nick : "..nick.."\t Time Left : "..DoTimeUnits(timeallowed - table[nick][1]).."\t Warnings : "..(table[nick][2]-1).."/ "..freq.."\t Status : "..status.."\r\n" 
	end 
	return msg 
end 
 
TableClear = function(table) 
	for nick, v in table do  
		local usr = GetItemByName(nick) 
		if not(usr==nil) then 
			usr:SendPM(sBot, "You have to leave because your share was not enough for this hub ...") 
			usr:Disconnect() 
		end 
	end 
	table = {} 
end

Act = function(user, table, var)  
	-- Performing action and also informing the user about it ... It is handled from the ' TheAction ' variable .... 
	local tActions = { 
		[1] = function(user) user:SendPM(sBot, "You will now be Disconnected") user:Disconnect() end, 
		[2] = function(user) user:SendPM(sBot, "You will now be Redirected to "..frmHub:GetRedirectAddress()) user:SendData("$OpForceMove "..frmHub:GetRedirectAddress()) end, 
		[3] = function(user) user:SendPM(sBot, "You will now be Kicked") user:Kick("You didn't meet the Hub's share requirements ...") user:Disconnect() end, 
		[4] = function(user) user:SendPM(sBot, "You are temporalily Banned") user:TempBan() end, 
		[5] = function(user) user:SendPM(sBot, "You are Banned") user:NickBan() end, 
		[6] = function(user) user:SendPM(sBot, "You are permenantly Banned") user:Ban() end, 
		[7] = function(user) user:SendPM(sBot, "You are Banned for "..bantime.." minutes.") user:TimeBan(bantime) end, 
		[8] = function(user)
				local cnt = 0 
				for i = 1, floodTimes do 
					cnt = cnt + 1 
					SendPmToNick(user.sName, sBot, floodMsg.." "..cnt.."/"..floodTimes) 
					if (cnt == floodTimes) then 
						user:Disconnect() 
					end 
				end 
			end, 
		}; 
	for i,v in tActions do 
		if i == var then 
			table[user.sName] = nil 
			if ( (i ~= 3) or (i ~= 4) or (i ~= 5) or (i ~= 6) ) then 
				tAgain[user.sName] = 1 
			end 
			return tActions[i](user) 
		end 
	end 
	tActions = nil 
end 

DoShareUnits = function(intSize)
	--- Transforming bytes Into KB, MB, GB, TB, PT and Returning the ideal (highest possible) Unit (thx to kepp and NotRambitWombat)
	if intSize ~= 0 then 
		local tUnits = { "Bytes", "KB", "MB", "GB", "TB" } 
		intSize = tonumber(intSize); 
		local sUnits; 
		for index = 1, table.getn(tUnits) do 
			if(intSize < 1024) then 
				sUnits = tUnits[index]; 
				break; 
			else  
				intSize = intSize / 1024; 
			end 
		end 
		return string.format("%0.1f %s",intSize, sUnits); 
	else 
		return "nothing" 
	end 
end 

DoTimeUnits = function(time)
	local time, msg = time*1000, ""
	local tO = { { 86400000, 0, "days"}, { 3600000, 0, "hours"}, { 60000, 0, "minutes"}, { 1000, 0, "seconds"}, };
	for i , v in (tO) do
		if time >= tO[i][1] then
			repeat 
				tO[i][2] = tO[i][2] + 1
				time = time - tO[i][1]
			until time < tO[i][1]
		end
	end
	for i,v in tO do 
		if tO[i][2] ~= 0 then
			msg = msg.." "..tO[i][2].." "..tO[i][3]
		end
	end
	return msg
end
-- End: SaveShare functions

-- Start: ChatStats functions
updStats = function(nick, str)
	local function cntargs(str, rule) local s,n = string.gsub(str, rule, "");return n;end;

	local t = Chatstats[nick] or {["post"]=0, ["chars"]=0, ["words"]=0, ["time"]=os.date("%x"), ["smileys"] = { ["happy"] = 0, ["sad"] = 0,}, }

	t.post = t.post + 1
	t.chars = t.chars + string.len(str)
	t.words = t.words + cntargs( str, "(%a+)")
	t.smileys.happy = t.smileys.happy + cntargs( str, "%s-(%:%-?%))")
	t.smileys.sad = t.smileys.sad + cntargs( str, "%s-(%:%-?%()")
	t.time = os.date("%x")

	Chatstats[nick] = t
end

StatsToString = function( tTable, nick )
	local function doRatio( val, max ) if (max==0) then max=1;end;return string.format("%0.3f",(val/max));end;
	local function doPerc ( val, max ) if (max==0) then max=1;end;return string.format("%0.2f",((val*100)/max));end;

	local sMsg = "\r\n\t\t\tHere are the stats for "..nick
	sMsg = sMsg.."\r\n\t--------------------------------------------------------------------------------------------------------------------------------------------------"
	sMsg = sMsg.."\r\n\tPosts in MainChat :\t\t "..tTable.post
	sMsg = sMsg.."\r\n\tWords in Posts :\t\t "..tTable.words.." [ "..doRatio( tTable.words, tTable.post ).." words per post ]"
	sMsg = sMsg.."\r\n\tCharacters in Posts :\t "..tTable.chars.." [ "..doRatio( tTable.chars, tTable.post ).." chars per post ]"
	sMsg = sMsg.."\r\n\t--------------------------------------------------------------------------------------------------------------------------------------------------"
	sMsg = sMsg.."\r\n\t\tYou were happy in "..doPerc(tTable.smileys.happy, tTable.post).."% of your posts, and sad in "..doPerc(tTable.smileys.sad, tTable.post).."% of them."
	return sMsg
end
-- End: ChatStats functions

-- Start: Timer functions
GarbageTimer = function()
--	.tbl saving
	OnExit()
end

HourTimer = function()
	-- K-VIP Kick Logs Cleaner (1 hour)
	if (os.date("%H") == "00") then 
		if next(vLog) then vLog = nil vLog = {} SaveToFile(vFile,vLog,"vLog") end
		if next(sLog) then sLog = nil sLog = {} SaveToFile(sFile,sLog,"sLog") end
		if next(cLog) then cLog = nil cLog = {} SaveToFile(cFile,cLog,"cLog") end
		if next(tUsers) then tUsers = nil tUsers = {} SaveToFile(tUsersFile,tUsers,"tUsers") end
		if next(tMoreUsers) then tMoreUsers = nil tMoreUsers = {} SaveToFile(tMoreUsersFile,tMoreUsers,"tMoreUsers") end
	end
end

MinuteTimer = function()
	-- Lucifer Function
	for key, value in tabAdvert do
		if (tabAdvert[key].iClock > os.clock()+60) then
			tabAdvert[key]=nil
		end
	end
end

SecondTimer = function()
	-- SaveShare Handling (1 second)
	TakeCare(tUsers, wtime, bal, frequency, TheAction) 
	TakeCare(tMoreUsers, w2time, bal2, secfrequency, The2Action) 
end
-- End: Timer functions

-- Start: Tezlo Chatrooms functions
botchat = function(self, msg, from)
	for nick, id in self.members do
		if nick ~= from and id == 1 then
			SendToNick(nick, "$To: "..nick.." From: "..self.name.." $<"..from.."> "..msg)
		end
	end
end

chatrooms = {
	new = function(self, name, owner)
		local tmp = {
			name = name,
			owner = owner,
			groups = {},
			members = { [owner] = 1 },
			chat = botchat
		}; self.items[name] = tmp
		return tmp
	end,

	load = function(self)
		self.items = dofile(cRoomFile) or {}
		for name, room in self.items do
			frmHub:RegBot(name)
			room.chat = botchat
		end
	end,

	save = function(self)
		if loadfile(cRoomFile) then 
			local f = io.open(cRoomFile, "w+")
			f:write("return {\n")
			for name, tmp in self.items do
				f:write(string.format("\t[%q] = {\n\t\tname = %q,\n\t\towner = %q,\n\t\tgroups = {\n", name, tmp.name, tmp.owner))
				for id, stat in tmp.groups do
					f:write(string.format("\t\t\t[%d] = %d,\n", id, stat))
				end; f:write("\t\t},\n\t\tmembers = {\n")
				for nick, stat in tmp.members do
					f:write(string.format("\t\t\t[%q] = %d,\n", nick, stat))
				end;
				f:write("\t\t}\n\t},\n")
			end;
			f:write("}") f:close()
		else
			local f = io.open(cRoomFile, "w+")
			f:write("return {\n"); f:write("}"); f:close()
		end
	end
}
-- End: Tezlo Chatrooms functions

-- Start: Anti Advertiser functions
Verify = function(userdata, msg)
	if not msg then return end
	tmp =""
	if (string.find(msg,"([.:%-])", 1, 1)) then
		string.gsub(string.lower(msg), "([a-z0-9])", function(x) tmp = tmp..x end)
	else
		string.gsub(string.lower(msg), "([a-z0-9.:%-])", function(x) tmp = tmp..x end)
	end
	if not tabAdvert[userdata] then
		tabAdvert[userdata] = { iClock = os.clock(), l1 = "", l2 = "", l3 = "", l4= "", l5= "",l6= "",l7= "",l8= "",l9 = tmp}
	else
		tabAdvert[userdata].iClock = os.clock()
		tabAdvert[userdata].l1 = tabAdvert[userdata].l2
		tabAdvert[userdata].l2 = tabAdvert[userdata].l3
		tabAdvert[userdata].l3 = tabAdvert[userdata].l4
		tabAdvert[userdata].l4 = tabAdvert[userdata].l5
		tabAdvert[userdata].l5 = tabAdvert[userdata].l6
		tabAdvert[userdata].l6 = tabAdvert[userdata].l7
		tabAdvert[userdata].l7 = tabAdvert[userdata].l8
		tabAdvert[userdata].l8 = tabAdvert[userdata].l9
		tabAdvert[userdata].l9 = tmp
	end
	local Lines = tabAdvert[userdata].l1..tabAdvert[userdata].l2..tabAdvert[userdata].l3..tabAdvert[userdata].l4..tabAdvert[userdata].l5..tabAdvert[userdata].l6..tabAdvert[userdata].l7..tabAdvert[userdata].l8..tabAdvert[userdata].l9
	for key, value in advtrigs do
		if (string.find(Lines, string.lower(value), 1, 1)) then
			for key2, value2 in validtrigs do
				if (string.find(Lines, string.lower(value2), 1, 1)) then
					return nil
				end
			end
			return 1
		end
	end
end

SendToVips = function(msg)
	local usr,aux
	for usr, aux in kVip do
		if (GetItemByName(usr) ~= nil) then
			GetItemByName(usr):SendPM(sBot, msg)
		end
	end
end
-- End: Anti Advertiser functions

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