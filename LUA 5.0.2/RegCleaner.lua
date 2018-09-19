-- auto/manual registered user cleaner if user hasn't been in the hub for x weeks
-- made by plop
-- julian day function made by the guru tezlo
-- code stripped from artificial insanety bot
-- updated to LUA 5 by Pothead
-- updated to PtokaX 16.09 by [_XStaTiC_]  Removed the seen part sorry :) i don't use it :)
--- touched by Herodes (optimisation tsunami, and added !seen again)
--- thx to god for giving TimeTraveler the ability to discover those bugs.. notice the plural? :)
--- should be working flawlessly now. 15:18 - 31/3/2005
--- ( before you doubt the above line be sure that you have a 'logs' folder in 'scripts' folder)
--- modded by jiten to list deleted users in main
--- added: (iMax/cleaned users) ratio
--- added: option to send to users/main/opchat
--- Max users shown on main by Dessamator

-- !noclean <user_name> add/remove  - adds/removes users from/to the list which aren't cleaned
-- !showusers - shows all registered users
-- !seen <user_name> - shows the last time the user left the hub
-- !shownoclean - shows all names wich are on the noclean list
-- !cleanusers - manualy start the usercleaner

cl = {}
cl.sets = {}
--------------------------------------------------------------------- config
cl.sets.weeks = 1 -- every1 older then x weeks is deleted
cl.sets.bot = "Helvetia" -- the bot Name...
cl.sets.opchat = frmHub:GetOpChatName() -- OpChat bot
cl.sets.auto = 1 -- 0:disables / 1:enables , automatic mode ( if disabled use !cleanusers to clean )
cl.sets.send = 2 -- 0:Main / 1:OpChat / 2:Users in cl.send (send deleted users to)
cl.levels = { [3]=1, [2]=1} -- levels it needs 2 clean 3=reg 2=vip
cl.files = { no = "logs/NoClean.lst", user = "logs/CleanUser.lst" } -- these are the files..
--------------------------------------------------------------------- the needed tables // pls dont edit anything here..
cl.user = {}
cl.no = {}
cl.funcs = {}
cl.iMax = 3 -- Max deleted users to show in Main
cl.send = { "scorpio", "user2", "user3", } -- users to send the deleted user list
--------------------------------------------------------------------- julian day function 2 calcute the time users spend in the hub
function cl.funcs.jdate(d, m, y)
	local a, b, c = 0, 0, 0
	if m <= 2 then y = y - 1; m = m + 12; end
	if (y*10000 + m*100 + d) >= 15821015 then
		a = math.floor(y/100); b = 2 - a + math.floor(a/4)
	end
	if y <= 0 then c = 0.75 end
	return math.floor(365.25*y - c) + math.floor(30.6001*(m+1) + d + 1720994 + b)
end

--------------------------------------------------------------------- Load a file
function cl.funcs.load(file, tbl)
	local f = io.open(file, "r")
	if f then
		for line in f:lines() do
			local s,e,name,date = string.find(line, "(.+)$(.+)")
			if name then tbl[name] = date; end
		end; f:close();
	end
end

--------------------------------------------------------------------- Save to file
function cl.funcs.save(file, tbl)
	local f = io.open(file, "w+")
	for a,b in tbl do f:write(a.."$"..b.."\n"); end; f:close()
end

--------------------------------------------------------------------- call the garbage man
function cl.funcs.cls()
	collectgarbage();io.flush();
end

--------------------------------------------------------------------- Display some table
function cl.funcs.showusers( user, data )
	local tbl, txt, sep = {}, "users who aren't cleaned", string.rep("=", 40);
	if (type(data) == "string") then
		local s,e,Profile = string.find(data, "%b<>%s+%S+%s+(%S+)")
		if not Profile then user:SendData(cl.sets.bot , "Syntax Error, Verwende: !showusers <profile_name>"); return 1; end
		tbl = GetUsersByProfile(Profile); txt = "registrierte user mit Profile ("..Profile..")";
	else
		local c=1; for i,v in data do tbl[c] = i; c=c+1;end;
	end
	local c = table.getn(tbl);
	if (c > 0) then
		local info = "\r\n Dies sind die "..txt.."\r\n "..sep.."\r\n"
		for i=1,c do info = info.."   ¬ "..tbl[i].."\r\n "; end
		user:SendData( "$To: "..user.sName.." From: "..user.sName.." $<"..cl.sets.bot.."> "..info..sep.."\r\n");
		cl.funcs.cls();return 1;
	end
	user:SendData( cl.sets.bot, "Es gibt keine "..txt);cl.funcs.cls();return 1;
end


--------------------------------------------------------------------- cleanup old users
function cl.funcs.clean() 
	local delnicks = "\r\n"
	SendToAll(cl.sets.bot , "The Cleaner has been called. Every registered user who hasn't been in the hub for "..cl.sets.weeks.." weeks will be deleted. ") 
	SendToAll(cl.sets.bot , "(contact an Operator if you are going to be away for a longer period than that)") 
	local juliannow = cl.funcs.jdate(tonumber(os.date("%d")), tonumber(os.date("%m")), tonumber(os.date("%Y"))) 
	local oldest, chkd, clnd,x = (cl.sets.weeks*7),0,0,os.clock() 
	local i,delnick = 0,""
	for prof, v in cl.levels do 
		for a, b in GetUsersByProfile(GetProfileName(prof)) do 
			chkd = chkd + 1 
			if cl.user[b] then 
				if not cl.no[b] then 
					local s, e, month, day, year = string.find(cl.user[b], "(%d+)%/(%d+)%/(%d+)"); 
					local julian = cl.funcs.jdate( tonumber(day), tonumber(month), tonumber("20"..year) )
					if ((juliannow - julian) > oldest) then 
						if i < cl.iMax then
							i = i + 1
							delnick=delnick..b.."\r\n"
						end
						--cl.user[b] = nil;
						--DelRegUser(b);
						clnd = clnd + 1;
					end; 
				end 
			else
				--cl.user[b] = os.date("%x"); 
			end 
		end 
	end 
	cl.funcs.save(cl.files.user, cl.user); 
	if (chkd > 0) then
		sSend = function(m,iBot)
			m(iBot , chkd.." users were processed, "..clnd.." were deleted ( "..string.format("%0.2f",((clnd*100)/chkd)).."% ) in: "..string.format("%0.4f", os.clock()-x ).." seconds.");
			if clnd ~= 0 then
				m(iBot,"These are the deleted users (showing "..cl.iMax.."/"..clnd..") - ( "..string.format("%0.2f",((cl.iMax*100)/clnd)).."% ):")
				m(iBot,"\r\n"..delnick)
			end
			return 1
		end
		if cl.sets.send == 0 then
			sSend(SendToAll,cl.sets.bot)
		elseif cl.sets.send == 1 then
			sSend(SendPmToOps,cl.sets.opchat)
		else
			for i, nick in cl.send do
				if (GetItemByName(nick) ~= nil) then
					GetItemByName(nick):SendPM(cl.sets.bot , chkd.." users were processed, "..clnd.." were deleted ( "..string.format("%0.2f",((clnd*100)/chkd)).."% ) in: "..string.format("%0.4f", os.clock()-x ).." seconds.");
					if clnd ~= 0 then
						GetItemByName(nick):SendPM(cl.sets.bot,"These are the deleted users (showing "..cl.iMax.."/"..clnd..") - ( "..string.format("%0.2f",((cl.iMax*100)/clnd)).."% ):")
						GetItemByName(nick):SendPM(cl.sets.bot,"\r\n"..delnick)
					end
					return 1;
				end
			end
		end
	end;
	SendToAll(cl.sets.bot ,"Nobody to clean :(");
	return 1;
end

--------------------------------------------------------------------- don't clean this users adding/removing
function cl.funcs.addnocl( user, data )
	local s,e,who, addrem = string.find(data, "%b<>%s+%S+%s+(%S+)%s+(%S+)%s*")
	if who and addrem then
		if frmHub:isNickRegged(who) then
			if (addrem == "add") then
				if cl.no[who] then user:SendData(cl.sets.bot , who.." ist bereits auf der Immunliste.");return 1; end;
				cl.no[who] = 1; cl.funcs.save(cl.files.no, cl.no);
				user:SendData(cl.sets.bot , who.." wurde der Immunliste hinzugefügt und wird nicht gelöscht.");return 1;
			elseif addrem == "remove" then
				if not cl.no[who] then user:SendData(cl.sets.bot , who.." war nicht in der Immunlist.");return 1; end
				cl.no[who] = nil; cl.funcs.save(cl.files.no, cl.no);
				user:SendData(cl.sets.bot , who.." wurde von der Immunlist gelöscht.");return 1;
			end; user:SendData(cl.sets.bot , "Syntax Error, Verwende: !noclean <nick> <add oder remove>");return 1;
		end; user:SendData(cl.sets.bot , who.." ist kein registrierter User.");return 1;
	end; user:SendData(cl.sets.bot , "Syntax Error, Verwende: !noclean <nick> <add oder remove>");return 1;
end
--------------------------------------------------------------------- Respond to a !seen
function cl.funcs.seen( user, data )
	local s,e,who = string.find( data, "%b<>%s+%S+%s+(%S+)" )
	if who then
		if (who ~= user.sName) then
			if not GetItemByName(who) then
				if cl.user[who] then user:SendData( cl.sets.bot, who.." war zuletzt hier am "..cl.user[who]);return 1; end
				user:SendData( cl.sets.bot, "Woher soll ich wissen wann "..who.." zuletzt hier war ?");return 1;
			end; user:SendData( cl.sets.bot, who.." ist Online... öffne deine Augen..");return 1;
		end; user:SendData( cl.sets.bot, "bist nicht DU dieser User?");return 1;
	end; user:SendData( cl.sets.bot, "Syntax Error, Verwende: !seen <nick>");return 1;
end
--------------------------------------------------------------------- do i need 2 explain this ?????
function ChatArrival(user, data)
	if ( (cl.sets.auto == 1) and (cl.day ~= os.date("%x")) ) then -- user cleaning trigger, works as a timer without a timer
		cl.day = os.date("%x"); cl.funcs.clean();
	end
	if (user.bOperator) then
		data = string.sub(data,1,-2)
		local s,e,cmd = string.find(data,"%b<>%s+(%S+)")
		if cmd then
			if (cmd == "!noclean") then return cl.funcs.addnocl(user, data);
			elseif (cmd == "!seen") then return cl.funcs.seen(user, data);
			elseif (cmd == "!showusers") then return cl.funcs.showusers( user, data );
			elseif (cmd == "!shownoclean") then return cl.funcs.showusers( user, cl.no );
			elseif (cmd =="!cleanusers") then return cl.funcs.clean();
			end
		end
	end
end

--------------------------------------------------------------------- stuff done when a user/vip leaves or come
function NewUserConnected(user)
	if cl.user[user.sName] then
		cl.user[user.sName] = nil; cl.funcs.save(cl.files.user, cl.user);
	end
end
OpConnected = NewUserConnected

function UserDisconnected(user)
	if (cl.levels[user.iProfile] == 1) then
		cl.user[user.sName] = os.date("%x"); cl.funcs.save(cl.files.user, cl.user);
	end
end
OpDisconnected = UserDisconnected

--------------------------------------------------------------------- stuff done on bot startup
function Main()
	cl.funcs.load(cl.files.no, cl.no);
	cl.funcs.load(cl.files.user, cl.user);
	cl.day = os.date("%x")
end