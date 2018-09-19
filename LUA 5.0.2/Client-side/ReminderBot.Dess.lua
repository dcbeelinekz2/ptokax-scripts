-- By Dessamator
-- Ideas from Post Bot by Nerbos(and some functions aswell), 
-- (Mutor, Plop thx for the hints/help, jiten(thnx for the debugging/help))
--## Most recent changes & fixes on : 14/01/2006

fAlarm = "fAlarm.dat"			
Listeners={["ownChat"]=1,["ownChatOut"]=1,["chat"]=1,["pm"]=1,} -- Listeners
Alarm = 
{ 	["Reminders"]={}, 
  	["Cfg"]=
	{		      -- Cfg Table
		["interval"]=0,       -- Dont Touch this.
			--## Configuration ##--                  
  		["ServerOn"] = 1,      	    -- Reminder Server on=1 ,off=0
		["iCleanUp"] = 1 ,  -- Time To wait before Cleaning up the reminders(in days).
	},
}
			    --## END ##--

if loadfile(fAlarm) then dofile(fAlarm) end 	--Load File -- 

tCmds = {
	["alarm"]  = {function(sUser,hub,time,Reminder)
		if not Alarm["Cfg"]["hub"] then Alarm["Cfg"]["hub"]=hub:getHubName() end
		local function Checkpost(sReminder) 
			if next(Alarm) and Alarm["Reminders"][sUser] then
				for i=1,table.getn(Alarm["Reminders"][sUser]) do
					if Alarm["Reminders"][sUser][i] then
						if (Alarm["Reminders"][sUser][i]["Reminder"] == sReminder) then
							SendPM(hub,sUser,"The Reminder already exists")
							return 1
						end
					end
				end
			end 
		end
		if not(Alarm["Reminders"][sUser]) then Alarm["Reminders"][sUser] = {} end
		if Checkpost(Reminder) then return 1 
		elseif time~="" and Reminder~="" and string.find(time,"%d+%d+:%d+%d+") then 
			if (time<=os.date("%X")) then SendPM(hub,sUser,"Incorrect Time. Try Again!") return 1 end
			local tStore ={
					["Reminder"] = Reminder,
					["ctime"]= os.date("%X"),
					["atime"] = time..":00"	,
					["date"] = os.date("%d/%m/%Y"),
					["alerts"] = 0
					}
			table.insert(Alarm["Reminders"][sUser], tStore)
			SendPM(hub,sUser,"Your Reminder has been set.")
			
		else	
			SendPM(hub,sUser,"Syntax Error, /Alarm <time: ex.: 19:19> <reminder>, you must write a reminder.")
		end    
		SaveToFile(fAlarm , Alarm , "Alarm")
	end,"$UserCommand 1 3 Reminder\\Set Reminder$<%[mynick]> /alarm %[line:time ex.:20:20] %[line:Reminder]&amp;#124;",},
	["aread"] ={ function(sUser,hub)
		if not(ReadPost(sUser,hub,1)) then
			SendPM(hub,sUser,"No Scheduled apointments", hideFromSelf )		
		end
	end,"$UserCommand 1 3 Reminder\\View Reminder$<%[mynick]> /aread&amp;#124;"},
	["delalarm"] = {function (sUser,hub,id)
		if id == nil or tonumber(id)==nil then
			 SendPM(hub,sUser,"Syntax Error, !delalarm <id> , the id must be specified!")
		elseif (Alarm["Reminders"][sUser][tonumber(id)] == nil) then
			 SendPM(hub,sUser,"That post doesnt exist!")
		elseif  Alarm["Reminders"][sUser][tonumber(id)] then
			 table.remove(Alarm["Reminders"][sUser],tonumber(id))
			 SendPM(hub,sUser,"The post has been deleted!", hideFromSelf )
		         SaveToFile(fAlarm , Alarm , "Alarm")
		else
			 SendPM(hub,sUser,"You are not authorized to delete the post !", hideFromSelf )
		end
	end,"$UserCommand 1 3 Reminder\\Remove Reminder$<%[mynick]> /delalarm %[line:Reminder <id> ex.: 1]&amp;#124;",},
}

dcpp:setListener("connected", "RC_Remind", function(hub)
	hub:injectChat("$UserCommand 0 3 |") 
	for i,v in tCmds do
		hub:injectChat(v[2])
	end
end)

for listener,i in Listeners do
	dcpp:setListener( listener, "Cmds",function( hub, data,PM )
		local nick,msg,prefix = hub:getOwnNick(),PM or data,"^%/"
		if type(data)=="table" then  nick=data:getNick()  end
		if Alarm.Cfg.ServerOn==1 then prefix="^[%/%!]" else SendPM(hub,sUser,"Reminder Server has been Deactived!") end
		local s,e,cmd,arg1,arg2 = string.find(string.lower(msg), prefix.."(%S*)%s*(%S*)%s*(.*)")
		if cmd then
			if tCmds[cmd] then
				return 1,tCmds[cmd][1](nick,hub,arg1,arg2)
			end
		end	
	end) 
end

dcpp:setListener( "timer", "reminder",function( )
	for sUser,id in Alarm["Reminders"] do
		if Alarm["Reminders"][sUser] and next(Alarm["Reminders"][sUser]) then
			 if (Alarm["Cfg"]["interval"]==60) then	
				Alarm["Cfg"]["interval"] =0				
				for _,hub in dcpp:getHubs() do
					if Alarm["Cfg"]["hub"]== hub:getHubName() then
						ReadPost(sUser,hub)				
					end
				end
				if not(i) then i=1 else i=i+1 end
			elseif 	i==360 then
				ReadPost(sUser,"clr")
				i=nil
			else
				Alarm["Cfg"]["interval"]=Alarm["Cfg"]["interval"] + 1
			end
		end
	end	
end)
		
tMonths={[1]=31,[2]=28,[3]=31,[4]=30,[5]=31,[6]=30,[7]=31,[8]=31,[9]=30,[10]=31,[11]=30,[12]=31,}
function ReadPost(sUser,hub,status)
	local sTmp,tRemind = "\r\n\Your reminder(s) :\r\n"
	local function WorkTime(string1, string2)
		local day1,month1,year1 = string.find(string1,"(%d%d)%/(%d%d)%/(%d%d%d%d)")
		local day2,month2,year2= string.find(string2,"(%d%d)%/(%d%d)%/(%d%d%d%d)")
		local dYear = 365
		if not(string.find((year1 /4),"%.")) or not(string.find((year2 /4),"%.")) then tMonths[2] =29 dYear=366 end
		local day,month,year = (tonumber(day2) - tonumber(day1)),(tMonths[tonumber(month2)]*tonumber(month2) -  tMonths[tonumber(month1)]*tonumber(month1)),(dYear*tonumber(year2) - dYear*tonumber(year1))
		local time = day + month + year
		return time
	end
	for i=1,table.getn(Alarm["Reminders"][sUser]) do	
		tRemind =Alarm["Reminders"][sUser][i]	
		if tRemind and ((os.date("%X")>= tRemind.atime) or status) then 
			sTmp = sTmp.."\t"..string.rep("_",20).."\r\n"
			.."ID: "..i.."\r\n"
			.."By: "..sUser.."\r\n"
			.."Creation Time: "..tRemind.ctime.."\r\n"
			.."Schedule Time: "..tRemind.atime.."\r\n"
			.."Reminder :"..tRemind["Reminder"].."\r\n"
			.."Date :"..tRemind["date"].."\r\n"
			.."\t"..string.rep("_",20).."\r\n"
			SendPM(hub,sUser,sTmp)
			if not(status) then table.remove(Alarm["Reminders"][sUser],i) status=2 end
		elseif hub=="clr" and (WorkTime(Alarm["Reminders"][sUser][i]["date"], os.date("%d/%m/%Y")) >= Alarm["Cfg"]["iCleanUp"])  then	
			table.remove(Alarm["Reminders"][sUser],i) 			
		end	
	end
	if status==2 then
		if table.getn(Alarm["Reminders"][sUser])==0 then Alarm["Reminders"][sUser] =nil	 end
		SaveToFile(fAlarm , Alarm , "Alarm")	
	end
	return 1
end
	
--SendPM
function SendPM(hub,sUser,msg)
	if msg then
		if sUser==hub:getOwnNick() then
			hub:injectPrivMsgFmt(sUser, 1,msg)
		else
			hub:sendPrivMsgTo(sUser, "<"..hub:getOwnNick().."> "..msg, 1 )
		end
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

DC():PrintDebug( "** Started Reminder.lua **" )