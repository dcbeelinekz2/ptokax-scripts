 --On Connect Cmds  By Dessamator
tCfg={	
["iInterval"]=2, -- how many seconds to wait before sending cmds to hub.P.S. must be more than 1
["tHubs"]={["127.0.0.1"]=0,["127.0.0.2"]=0} ,
["tCmds"] ={["help"]=1,["myip"]=1}, -- Cmds !
["sPrefix"]="!",
}

dcpp:setListener( "connected","OnConCmds",function(hub)
	if tCfg["tHubs"][hub:getAddress()] and tCfg["tHubs"][hub:getAddress()]~=2 then
		tCfg["tHubs"][hub:getAddress()]=1
	end
end)

dcpp:setListener( "timer", "OnConCmds",function( )
	for _,hub in dcpp:getHubs() do
		if tCfg["tHubs"][hub:getAddress()]==1  then
			if not(i) then i=1 else i=i+1 end
			if i==tCfg["iInterval"] then		
				for i,v in tCfg["tCmds"] do
					hub:sendChat(tCfg["sPrefix"]..i)
				end
				tCfg["tHubs"][hub:getAddress()]=2
				i=nil
				break
			end
		end
	end
end)

dcpp:setListener("ownChatOut","OnConCmds",function(hub,message) 
	local s,e,cmd = string.find(message, "^%/(%S+)" ) 
	if cmd=="uconcmds" then
		DC():PrintDebug("*** OnConCmds.lua Stopped!")
		for i,v in dcpp._listeners do 
			for listener,_ in v do 
				if listener=="OnConCmds" then
					dcpp._listeners[i][listener]=nil
				end
			end
		end
		i=nil tCfg=nil
		return 1
	end
end)

DC():PrintDebug( "*** Loaded OnConCmds.lua ***" ) 