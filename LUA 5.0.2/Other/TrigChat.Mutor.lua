--modded a bit by jiten
--TrigChat 1.0
--by Mutor
--Add / Remove triggers as you wish.
-- little customizing & conv. to lua5 by UwW (nothing much)
--
---Editable Section---------------------
botname = "-=Holly-Helps=-"	-- Change this to your main bot
 
tTrigs = {
        shit = "Hey [User]! Watch the language. Dont use words like that in here please.",
        fuck = "Hey [User]! Watch the language. Dont use words like that in here please.",
        goodnight = "Goodnight, [User]. Sleep well.",
        Goodnight = "Goodnight, [User]. Sleep well.",
        ["anyone have"] = "[User], please use the search tool, instead of making requests in main chat.",
        ["anyone got"] = "[User], please use the search tool, instead of making requests in main chat.",
        ["anyone get"] = "[User], please use the search tool, instead of making requests in main chat.",
        ["got to go"] = "Alright, later, [User]",
        ["XP Fire"] = "\r\n\r\nTo disable the XP firewall, follow these steps \r\n*****************************************************\r\n- Double click 'My Network Places'\r\n- Click 'View Network Connections'\r\n- Right click on 'Local Area Connection and Select 'Properties'\r\n- Click the 'Advanced' tab\r\n- Make sure to uncheck the box under 'Internet Connection Firewall'\r\n",
        ["hidden tag"] = "\r\n\r\n    Hiding client tags:\r\n******************************\r\nA tag is the DC++ tag, i.e. <++ V:0.305,M:A,H:0/1/0,S:2\r\n\r\nA faker can simply be defined as, having a false misleading or fraudulent appearance. That being\r\nsaid,a tag faker is someone who either hides or fraudulently modifies their DC++ tag. OPs typically\r\ndisallow hidden tag clients from entering a hub or will simply permanently ban on sightany user\r\nwho is found doing this.\r\n", 
        ["setup active"] = "\r\n\r\n\t**Active mode requires both TCP and UDP access on the same port for DC++ to work properly\r\n\r\n * First you need to set up the router to forward the connections to the computer with DC++. This could\r\n   be called Port mapping, port redirecting, port forwarding or something like that. Find out how to do\r\n   this with your router/NAT in the user manual.\r\n\r\n * You need to forward one port (select a number between 150 - 65535, they should mostly all be free.\r\n   The default port is 411, but it is wise to select a unique one) and make sure both UDP and TCP is\r\n    forwarded to your client.\r\n\r\n * The IP that you are forwarding to should be the internal IP address of your DC++ computer. It usually\r\n   begins with '192.168', '172.16.' or '10.x.'. Go to the command prompt and type: ipconfig.\r\n\r\n * When you have mapped a port, you need to open up DC++ and go to the settings. Where you select\r\n   active mode, in the port field, enter the port number that you are forwarding on the router.\r\n\r\n * In the IP field, you need to enter the external IP address of your router. This can can normally be found\r\n   on the router/firewall 'Status' page.\r\n\r\n * It should now be working. If it is working for a while, but the next time you use DC++, you only get\r\n   'Connection Timeout’s or no results when searching, your IP (either external or internal) is likely to have\r\n    changed. If you find the external IP is constantly changing, you can set yourself up with a dynamic name.\r\n   Such as Dynip or DynDns and put that name into the IP field. Make sure to use a program that\r\n   updates the dynamic name service with your latest IP.\r\n",
        ["forward a port"] = "\r\n\r\n\t**Active mode requires both TCP and UDP access on the same port for DC++ to work properly\r\n\r\n * First you need to set up the router to forward the connections to the computer with DC++. This could\r\n   be called Port mapping, port redirecting, port forwarding or something like that. Find out how to do\r\n   this with your router/NAT in the user manual.\r\n\r\n * You need to forward one port (select a number between 150 - 65535, they should mostly all be free.\r\n   The default port is 411, but it is wise to select a unique one) and make sure both UDP and TCP is\r\n    forwarded to your client.\r\n\r\n * The IP that you are forwarding to should be the internal IP address of your DC++ computer. It usually\r\n   begins with '192.168', '172.16.' or '10.x.'. Go to the command prompt and type: ipconfig.\r\n\r\n * When you have mapped a port, you need to open up DC++ and go to the settings. Where you select\r\n   active mode, in the port field, enter the port number that you are forwarding on the router.\r\n\r\n * In the IP field, you need to enter the external IP address of your router. This can can normally be found\r\n   on the router/firewall 'Status' page.\r\n\r\n * It should now be working. If it is working for a while, but the next time you use DC++, you only get\r\n   'Connection Timeout’s or no results when searching, your IP (either external or internal) is likely to have\r\n    changed. If you find the external IP is constantly changing, you can set yourself up with a dynamic name.\r\n   Such as Dynip or DynDns and put that name into the IP field. Make sure to use a program that\r\n   updates the dynamic name service with your latest IP.\r\n",
        ["port map"] = "\r\n\r\n\t**Active mode requires both TCP and UDP access on the same port for DC++ to work properly\r\n\r\n * First you need to set up the router to forward the connections to the computer with DC++. This could\r\n   be called Port mapping, port redirecting, port forwarding or something like that. Find out how to do\r\n   this with your router/NAT in the user manual.\r\n\r\n * You need to forward one port (select a number between 150 - 65535, they should mostly all be free.\r\n   The default port is 411, but it is wise to select a unique one) and make sure both UDP and TCP is\r\n    forwarded to your client.\r\n\r\n * The IP that you are forwarding to should be the internal IP address of your DC++ computer. It usually\r\n   begins with '192.168', '172.16.' or '10.x.'. Go to the command prompt and type: ipconfig.\r\n\r\n * When you have mapped a port, you need to open up DC++ and go to the settings. Where you select\r\n   active mode, in the port field, enter the port number that you are forwarding on the router.\r\n\r\n * In the IP field, you need to enter the external IP address of your router. This can can normally be found\r\n   on the router/firewall 'Status' page.\r\n\r\n * It should now be working. If it is working for a while, but the next time you use DC++, you only get\r\n   'Connection Timeout’s or no results when searching, your IP (either external or internal) is likely to have\r\n    changed. If you find the external IP is constantly changing, you can set yourself up with a dynamic name.\r\n   Such as Dynip or DynDns and put that name into the IP field. Make sure to use a program that\r\n   updates the dynamic name service with your latest IP.\r\n",
        trigs = "\r\n---<>----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<>---\r\n\ AVAILABLE TRIGS -> brb , bbiab , bbiaw , kk , wb , Hi , Hi , hey , Hey , hello , Hi , Hello , goodnight , Goodnight , Goodnight, g'ni , \r\n Nite , nite , bye , cya , gtg , g2g , whats up , any slot , no slot , peace , lol , lmao , rofl , haha , hehe , lag , a drink , see ya , \r\n good bye , anyone have , anyone got ,anyone get , got to go , got to go , later , c ya , needs sleep , need sleep , zz , Zz ,\r\n damn , regist , Yo , my list , my file list , search my file , active mode , passive mode ,peer , xp fire , XP Fire , XP fire , the icons ,\r\n user icons , commands , tags , extra slot , slot lock , slotlock , share fak , sharefak , hidden tag , setup active , forward a port , \r\n port map ,  port , hashing , file hashing , trigs \r\n---<>----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<>---\r\n",
        }
---End Editable scetion--------------
---Dont edit below unless you know what your doing 8-)

function Main() 
        --frmHub:RegBot(botname) 
end 

--// function ChatArrival(user, data) 
function ChatArrival(user, data) 
	local data = string.sub(data,1,-2) 
	local s,e,msg = string.find(data,"%s+(%S+)")
	-- check for trigs in table
	if not iscommand(msg) then
		for key, value in tTrigs do
			if( string.find( data, key) ) then
				answer, x = string.gsub(value,"%b[]", user.sName)
				SendToAll(user.sName,msg)
				user:SendData( botname, answer ) -- message sent to user only
				--SendToAll(botname, answer) -- message sent to everyone 
				return 1
			end 
		end 
	end
end

function iscommand(str)  
	return string.sub(str, 1, 1) == "!" or string.sub(str, 1, 1) == "+" or string.sub(str, 1, 1) == "/" or string.sub(str, 1, 1) == "?" or string.sub(str, 1, 1) == "3õ"  
end