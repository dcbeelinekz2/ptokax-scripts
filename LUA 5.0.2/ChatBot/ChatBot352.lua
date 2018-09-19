----------------------------------------------------- 
-- Chat Bot v3.5 Coded by [aXs] Wellx 01/09-03 
-- Converted to Lua 5 by jiten, Dessamator and plop
-- Formerly known as the Developer-Chat for TIC50 
-- Based on the idea VIPChat from Piglja 
-- Thx goes to Piglja & aMutex for Ideas and Help 
----------------------------------------------------- 

ChatBot = "•PublicChat•" -- Chat Bot Name 
CanUseCommands = { -1 , 0 , 1 , 2 , 3 ,4, 5 } -- Can Use Chat Bot Commands Lvl ( 0 = Master ~~ 1 = Operators ~~ 2 = VIPs ~~ 3 = Reg ~~ etc.) 

ChatArray={} 
ChatFile = "Chatters.tbl" 

function Main() 
	frmHub:RegBot(ChatBot) 
	LoadFromFile(ChatFile)
end 


--======================================================== Arrivals: =========================================================-- 

function ChatArrival(user, data) 
	data=string.sub(data,1,string.len(data)-1) 
	_,_,cmd=string.find(data, "%b<>%s+(%S+)") 
	local Commands = (DeveloperCommands(user, data, cmd)) 
	return Commands 
end

function ToArrival(user, data) 
	local s, e, to = string.find(data, "$To: (%S+)") 
	if to ~= ChatBot then 
		return 0 
	else 
		if to == ChatBot then 
			local data=string.sub(data,1,string.len(data)-1) 
			local s,e,from,msg = string.find(data,"From:%s+(%S+)%s+$%b<>%s+(.+)") 
			if ChatArray[user.sName] == nil then 
				user:SendPM(ChatBot,"You do not have permission to write inhere (Join or Talk to a Operator if you need permission)") 
				return 0
			else
				ChatArray[user.sName] = nil 
				for i,v in ChatArray do 
					Developer=GetItemByName(i) 
					if (Developer~=nil) then
						Developer:SendData("$To: "..i.." From: "..ChatBot.." $<"..user.sName.."> "..msg.."|") 
					end 
				end 
				ChatArray[user.sName] = user.sName 
			end 
			local _,_,cmd = string.find(data,"$%b<>%s+(%S+)") 
			local Commands = (DeveloperCommands(user, data, cmd)) 
		end 
	end 
end 

--===================================================== Chat Commands: ======================================================-- 

function DeveloperCommands(user, data, cmd) 
	if tfind(CanUseCommands, user.iProfile) then 
		if (cmd == "+chathelp") then 
			DevHelp(user) 
			return 1 
		elseif (cmd == "+chat") then 
			local s,e,cmd,ChatName = string.find( data, "%b<>%s+(%S+)%s+(.*)" ) 
			if (ChatName == nil) then 
				ChatName = user.sName 
			end 
			if ChatArray[ChatName] == nil then 
				table.insert(ChatArray, ChatName)
--				ChatArray[ChatName] = 1
				for index, value in ChatArray do 
					SendPmToNick(value, ChatBot, " "..ChatName.." Has joined the "..ChatBot) 
				end 
			else 
				for index, value in ChatArray do 
					SendPmToNick(index, ChatBot, " "..ChatName.." Has left the "..ChatBot) 
				end 
				ChatArray[ChatName] = nil 
			end 
			SaveToFile(ChatFile,ChatArray,"ChatArray") 
			return 1 
		elseif (cmd == "+showchatters") then 
			function DevList() 
			local DevList = "" 
			for index, value in ChatArray do 
				if GetItemByName(index) then 
					if (string.len(index) <= 10) then 
						DevList = DevList.." • "..index.."\t\t\t~ On-line ~\r\n" 
					else 
						DevList = DevList.." • "..index.."\t\t~ On-line ~\r\n" 
					end 
				else 
					if (string.len(index) <= 10) then 
						DevList = DevList.." • "..index.."\t\t\t• Off-Line •\r\n" 
					else 
						DevList = DevList.." • "..index.."\t\t• Off-Line •\r\n" 
					end 
				end 
			end 
			return DevList 
		end 
		user:SendPM(ChatBot, "\r\n\r\n(¯ ·.¸¸.-> "..ChatBot.." Chatters <-.¸¸.·´¯) \r\n\r\n"..DevList()) 
		return 1 
	end 
	else user:SendData("You don't have permission to use the commands to the "..ChatBot.." ask a Operator for permission !!") return 0 end 
end 

function DevHelp (user) 
	local disp = "\r\n\r\n" 
	disp = disp.."~~ Scripted DeveloperChat Commands: ~~\r\n\r\n" 
	disp = disp.." +chat <nick> - Add or part a user to the list of people that can chat in the "..ChatBot.."\r\n" 
	disp = disp.." +showchatters - See witch users that can chat in the "..ChatBot.."\r\n" 
	disp = disp.."\r\n" 
	user:SendPM(ChatBot, disp) 
end 

--======================================================== Functions: ===========================================================-- 



function tfind(table, key) 
	for id,tmp in ipairs(table) do
		if (tmp == key) and id then
			return id
		end
	end
end 

function Verify(filename)
	local f = io.open(filename, "r")
	if f then
		f:close()
		return true
	end
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