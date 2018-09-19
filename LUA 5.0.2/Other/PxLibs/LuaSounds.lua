--[[

	LuaSounds 1.0 LUA 5.1
	
	By Mutor	04/08/06
	
	Quick sample script for luasndplay-0.0.1-Beta
	extension lib for PtokaX. This lib can play sounds
	through script calls on your windows system.
	The following script uses default sounds from XP,
	and will play sounds on script start, exit, user/op
	connect and disconnect and OnError. Also will play on
	pm to hub bot and/or pm's from specified users to specified nick.


	Get the pre-released beta here:
	http://www.thewildplace.dk/downloads/luasndplay-0.0.1-Beta.zip


]]


SndCfg = {
--Listen for pm to this nick
OpNick = "Mutor",
--Listen for pm's from these nicks
Nicks = {
	["Rizzo"] = 1,
	["Mutor"] = 1,
	["[Admin]Mutor"] = 1,
	},
}

function Main()
	if _VERSION == "Lua 5.1" then
		libinit = package.loadlib("luasndplay.dll", "_libinit")
	else
		libinit = loadlib("luasndplay.dll", "_libinit")
	end
	libinit()
	SndPlay("WI7723~1.WAV", 0, 0)
	SendToOps(frmHub:GetHubBotName(),SndVer().." started.")
end

NewUserConnected = function(user, data)
	SndPlay("WI8A6F~1.WAV", 0, 0)
end
OpConnected = NewUserConnected

UserDisconnected = function(user, data)
	SndPlay("WI6030~1.WAV", 0, 0)
end
OpDisconnected = UserDisconnected

ChatArrival = function(user, data)
	local s,e,to = string.find(data,"^$To:%s(%S+)%s+From:")
	if to and to == frmHub:GetHubBotName() then
		SndPlay("WI6855~1.WAV", 0, 0)
	elseif to == SndCfg.OpNick and SndCfg.Nicks[user.sName] then
		SndPlay("WI95E5~1.WAV", 0, 0)
	end
end
ToArrival = ChatArrival

KickArrival = function(user, data)
	SndPlay("WI9470~1.WAV", 0, 0)
end

OnError = function(ErrorMsg)
	SndPlay("WINDOW~4.WAV", 0, 0)
end

function OnExit()
	SndPlay("WI443C~1.WAV", 1, 0)
	SndPlay("", 0, 0)
end

--[[
	Default Sounds Installed with Windows XP
	8.3 filenames shown where needed
	-----------------------------------------
	chimes.wav
	chord.wav
	ding.wav
	notify.wav
	recycle.wav
	ringin.wav
	ringout.wav
	start.wav
	tada.wav
	WINDOW~1.WAV - Windows XP Balloon.wav
	WINDOW~2.WAV - Windows XP Battery Critical.wav
	WINDOW~3.WAV - Windows XP Battery Low.wav
	WINDOW~4.WAV - Windows XP Critical Stop.wav
	WI91B0~1.WAV - Windows XP Default.wav
	WI632E~1.WAV - Windows XP Ding.wav
	WI86C1~1.WAV - Windows XP Error.wav
	WI6627~1.WAV - Windows XP Exclamation.wav
	WI3201~1.WAV - Windows XP Hardware Fail.wav
	WI7723~1.WAV - Windows XP Hardware Insert.wav
	WI443C~1.WAV - Windows XP Hardware Remove.wav
	WIC409~1.WAV - windows xp information bar.wav
	WI6030~1.WAV - Windows XP Logoff Sound.wav
	WI8A6F~1.WAV - Windows XP Logon Sound.wav
	WI412B~1.WAV - Windows XP Menu Command.wav
	WI0707~1.WAV - Windows XP Minimize.wav
	WI6E87~1.WAV - Windows XP Notify.wav
	WI2DAD~1.WAV - windows xp pop-up blocked.wav
	WI9470~1.WAV - Windows XP Print complete.wav
	WI31E4~1.WAV - Windows XP Recycle.wav
	WI6FEC~1.WAV - Windows XP Restore.wav
	WI6855~1.WAV - Windows XP Ringin.wav
	WI95E5~1.WAV - Windows XP Ringout.wav
	WI814D~1.WAV - Windows XP Shutdown.wav
	WI76D5~1.WAV - Windows XP Start.wav
	WI8680~1.WAV - Windows XP Startup.wav
]]