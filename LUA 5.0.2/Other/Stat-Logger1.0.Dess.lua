----> Stat-Logger v1.0 By Dessamator 
--  optimized the code  
-- removed redutant login info-->request by penguin 
----> Stat-Logger 0.4a By Dessamator 
-- Added Search Log(!searchlog) 
-- Added SendTo (request by Penguin ) 
----> Stat-logger 0.3b 
-- fixed error in saving logs(report by TTB) 
----> Stat-logger 0.3a  
-- Added !lastips(request by Penguin) 
-- Lua 5 by Dessamator 
----> Stat-logger 0.3 by Troubadour  
-- created a seperated config file + gui 
----> Stat-logger 0.2 by Troubadour  
-- to write all info to a file with the date of that day when users log in (name, e-mail, ip and share) 
-- command for viewing the files is !<date> 
-- for example !280704 is the command to view the file of 28 juli 2004 
----> Stat-logger 0.1 by Troubadour  
-- to write all info to a file when a user logs in (name, e-mail, ip and share) 
-- command to view the file is !statlog 
 
 
a={} 
LoginInfo ={} 
fLoginInfo = "logininfo.dat" 
-- 
MaxLogins = 15 
SendTo = 2 -- (1 =>MainChat 2=>PM, 3=>Main and pvt (request by Penguin) 
 
function Main()  
	if io.open("Stat-logger03.cfg","r") then   -- is used for the settings 
		dofile("Stat-logger03.cfg") 
	else 
		BOTName = "Stat-logger" 
		Version = "Stat-logger V.1" 
	end 
		frmHub:RegBot(BOTName) 
	SendToAll("( >>>>  "..Version.." Started"..os.date(" the %d/%m-%Y at %X ").."  <<<< )") 
	if io.open(fLoginInfo,"r") then 
		dofile(fLoginInfo) 
	end	 
end  
 
 
function OnExit() 
	SaveToFile(fLoginInfo,LoginInfo,"LoginInfo") 
end 
 
function ChatArrival(user,data)  
data=string.sub(data,1,-2)  
s,e,cmd = string.find(data,"%b<>%s+(%S+)")  
local n,temp,usrinfo=0,"The last "..MaxLogins.." logged users\r\n","This is the log you Requested:\r\n" 
 
local function loadinfo(cmd,insert) 
	if not cmd then  
		usrinfo="" 
		cmd=os.date("%d%m%y") 
	end 
	for i,v in LoginInfo[cmd] do 
		usrinfo= usrinfo.."On the "..LoginInfo[cmd][i].Date.." - "..i.. 
		" - made 1st login @ :"..LoginInfo[cmd][i].Time.. 
		" with e-mail :  "..LoginInfo[cmd][i]["email"].. 
		", Description : "..LoginInfo[cmd][i]["description"].. 
		", IP :"..LoginInfo[cmd][i]["IP"]..  
		", logged in "..LoginInfo[cmd][i]["Times"].." more times,".. 
		" and with share: "..LoginInfo[cmd][i]["share"].."Gb connected:\r\n" 
	end 
	if insert then 
		table.insert(a, usrinfo) 
	end 
	return usrinfo 
end 
 
	if cmd =="!lastips" then 
		loadinfo(blah,"insert") 
		for i=table.getn(a),1, -1 do 
			if n<MaxLogins then 
				temp=temp..a[i].."\r\n" 
				n=n+1 
			end 
		end 
		if		SendTo == 1 then user:SendData(BOTName,temp) 
			elseif	SendTo == 2 then user:SendPM(BOTName,temp) 
			elseif	SendTo == 3 then SendToAll(BOTName,temp) user:SendPM(BOTName,temp) 
		end 
		a=nil 
		return 1 
	elseif cmd=="!searchlog" then 
		s,e,date = string.find(data, "%b<>%s+%S+%s+%S+%s+(.+)") 
		s,e,ip = string.find(data,"%b<>%s+%S+%s+(%S+)")  
		findloggedip(user,ip, date) 
		return 1 
	end 
	cmd = string.sub(cmd, 2,string.len(cmd))  
	if LoginInfo[cmd] then  
		user:SendData(BOTName,loadinfo(cmd)) 
		return 1  
	end  
end 
 
function ToArrival(user,data) 
s,e,cmd = string.find(data,"$To:%s+%S+%s+From:%s+%S+%s+$%b<>%s+(%S+)")  
cmd = string.sub(cmd, 2,string.len(cmd))  
	if LoginInfo[cmd] then  
		showtext(user, cmd)  
		return 1  
	end  
	 
end  
 
function OpConnected(user) 
	local share = string.format("%0.2f",(user.iShareSize / (1024*1024*1024))) 
	if not LoginInfo[os.date("%d%m%y")] then 
		LoginInfo[os.date("%d%m%y")] = {} 
	end 
	if not LoginInfo[os.date("%d%m%y")][user.sName] then 
		LoginInfo[os.date("%d%m%y")][user.sName]= {} 
		LoginInfo[os.date("%d%m%y")][user.sName]["description"]=user.sDescription 
		LoginInfo[os.date("%d%m%y")][user.sName]["email"]=user.sEmail 
		LoginInfo[os.date("%d%m%y")][user.sName]["share"]=share 
		LoginInfo[os.date("%d%m%y")][user.sName]["Date"]=os.date("%x") 
		LoginInfo[os.date("%d%m%y")][user.sName]["Time"]=os.date("%X") 
		LoginInfo[os.date("%d%m%y")][user.sName]["IP"]=user.sIP 
		LoginInfo[os.date("%d%m%y")][user.sName]["Times"]=0 
	end 
	if LoginInfo[os.date("%d%m%y")][user.sName]["Times"] then 
		LoginInfo[os.date("%d%m%y")][user.sName]["Times"]=LoginInfo[os.date("%d%m%y")][user.sName]["Times"] + 1 
	end 
end 
 
NewUserConnected = OpConnected 
 
function findloggedip(user,ip,date) 
	local found ="\r\n\t\t".."The Results of your search:".."\r\n","" 
	date=date or os.date("%d%m%y") 
	found=found.."\t\t"..string.rep("»«",12).."\r\n" 
	if ip and LoginInfo[date] then 
		for i,v in LoginInfo[date] do 
			if LoginInfo[date][i]["IP"] == ip then 
				found= found.."On the "..LoginInfo[date][i].Date.." - "..i.." - made 1st login @ :"..LoginInfo[date][i].Time.. 
				" with e-mail :"..LoginInfo[date][i]["email"]..", IP :"..LoginInfo[date][i]["IP"]..  
				", logged in "..LoginInfo[date][i]["Times"].." more times,".. 
				" and with share: "..LoginInfo[date][i]["share"].."Gb connected:\r\n" 
			end 
		end 
	elseif not ip then 
		user:SendPM(BOTName,"Syntax Error. Correct Syntax is : !searchlog <ip> <date(DDMMDYY)> eg.: !searchlog 127.0.0.1 060505") 
	elseif not LoginInfo[date] then 
		user:SendPM(BOTName,"There is no log to search in !!!") 
	end 
	if found then 
		user:SendPM(BOTName,found) 
	else 
		user:SendPM(BOTName,"That ip or nick wasnt found in the logs!!") 
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