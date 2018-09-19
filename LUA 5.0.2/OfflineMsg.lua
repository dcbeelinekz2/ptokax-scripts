-- LUA 5 version - heavily modified by jiten

-- offlinemsg.lua, created by amutex 11.01.2003
-- thx to nathanos for the fine pm-parsing
-- bits and pieces added and deleted by bolamix over time, kudos to all scripters who helped!
-- attempted conversion to lua5 by bolamix Feb. 27 2005
-- successful conversion to lua5 by Jelf March 9 2005
-- usage: send a PM to the bot with <command> <username> <message>

sBot = frmHub:GetHubBotName()		-- sBot = "yourbotname"
Command = "mail"			-- Offline message command
Path = "messages"			-- Name of the folder where the message files will be stored
Ext = ".msg"				-- Extension for the message files

Main = function()
	if sBot ~= frmHub:GetHubBotName() then frmHub:RegBot(sBot) end
	os.execute("mkdir ".."\""..string.gsub(Path, "/", "\\").."\"")
end

ChatArrival = function(sUser,data)
	local data = string.sub(data, 1, -2)
	local s,e,cmd = string.find(data,"%b<>%s+[%!%?%+%#](%S+)")
	if (string.sub(data,1,1) == "<") or (string.sub(data,1,5+string.len(sBot)) == "$To: "..sBot) then
		if cmd then
			local tCmds = {
			[Command] =	function(user,data)
						local s,e,usr,msg = string.find(data, "%b<>%s+%S+%s+(%S+)%s+(.*)")
						if (usr == nil or msg == nil) then
							sUser:SendData(sBot, "*** Syntax Error: Type !"..Command.." <nick> <message>")
						else
							local f = io.open(Path.."/"..usr..Ext,"a+")
							if f then
								f:write(""..user.sName.." sent you this message on "..os.date("%d:%m:%y").." at "..os.date("%H:%M")..": "..msg)
								user:SendPM(sBot,"Message stored. It will be sent to "..usr.." next time he/she logs in.")
								f:close()
							end
						end
					end,
			}
			if tCmds[cmd] then return tCmds[cmd](sUser,data),1 end
		end
	end
end

ToArrival = ChatArrival

NewUserConnected = function(sUser)
	local f = io.open(Path.."/"..sUser.sName..Ext)
	if f then
		local line = f:read() f:close()
		sUser:SendPM(sBot,line) line = nil
	 	os.remove(Path.."/"..sUser.sName..Ext)
	end
end

OpConnected = NewUserConnected