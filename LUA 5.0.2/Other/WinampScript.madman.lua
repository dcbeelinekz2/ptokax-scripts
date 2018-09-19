-- Winamp script
-- Made by Madman
-- Based on Shoutcast interface through PtokaX script
-- Stuff you need:
-- Winamp 2.xx, if you dont got it -> http://www.download.com/Winamp-Full/3000-2139_4-10199518.html?tag=lst-0-2
-- Clever Download -> http://www.jukkis.net/clever/clever_2_98.zip
-- Script, Ptokax, Winamp and Clever nees to run on same pc
-- Important! Run clever.exe before useing this script! You need to config it first
-- Also if installing Clever in other then C:\Clever, you need to create that folder by your self and then runt clever.exe
-- Usage !w.<cmd> <option> (if there is one on it)
-- OBS! Full playlist cant be extracted by !w.playlist untill winamp has putted time on each song!
-- Nothing I can do about... Limit's in clever =(

Setup = {
	["Clever"] = "D:\\Program\\clever\\", -- Where did you install Clever
	["Music"] = "D:\\ServerMusic\\", -- And where do you have you Mp3 files?
	["Name"] = "WinampScript", --The bots name
	-- Outcome of standard <Bot> Playing ][ title ][ 
	["BeforeTitle"] = "Playing ][",
	["AfterTitle"] = "][",
	["Menu"] = "WinampScript"
}

WinampProfile = {
[0] = 1,	-- Masters
[1] = 0,	-- Operators
[2] = 0,	-- Vips
[3] = 0,	-- Regs
[-1] = 0,	-- Users(unregged)
}

function NewUserConnected(curUser)
	if curUser.bUserCommand then
	--curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Command$<%[mynick]> !cmd&#124;")
		curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Status on winamp$<%[mynick]> !w.status&#124;")
		curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Show current playing song$<%[mynick]> !w.song&#124;")
		curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Show pretty info about song$<%[mynick]> !w.pretty&#124;")
		curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Get track nr$<%[mynick]> !w.tracknr&#124;")
		if WinampProfile[curUser.iProfile] == 1 then
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Play (track)$<%[mynick]> !w.play %[line: Tracknr (Optional)]&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Pause song$<%[mynick]> !w.pause&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Stops song$<%[mynick]> !w.stop&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Previous song$<%[mynick]> !w.prev&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Next song$<%[mynick]> !w.next&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Set vol$<%[mynick]> !w.vol %[line: number 0-255]&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Get playlist$<%[mynick]> !w.playlist&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Clear the playlist$<%[mynick]> !w.clear&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Make the playlist$<%[mynick]> !w.makepl&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Reload playlist$<%[mynick]> !w.reload&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Toggle shuffle$<%[mynick]> !w.shuffle&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Toggle Repeat$<%[mynick]> !w.repeat&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Check shuffle mode$<%[mynick]> !w.getshuffle&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Check repeat mode$<%[mynick]> !w.getrepeat&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Start winamp$<%[mynick]> !w.start&#124;")
			curUser:SendData("$UserCommand 1 3 " ..Setup.Menu.. "\\Close winamp$<%[mynick]> !w.close&#124;")
		end
	end
end

OpConnected = NewUserConnected

function Main()
	frmHub:RegBot(Setup.Name)
end

function OnError(ErrorMsg)
	SendToOps(Setup.Name, ErrorMsg)
end

function ChatArrival(curUser, data)
	local data = string.sub(data, 1, -2)
	local s,e,cmd = string.find(data, "%b<>%s+[%!%+%?%#][w][%.](%S+)")
	if cmd then
		local tCmds = {
		["help"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
			curUser:SendData(Setup.Name, "\r\n\t--==Winamp script help==--\r\n"..
			-- Puted it like this so the menu is easy to read in here.. ;)
				"!w.status\t\t-\tCheck in what mode winamp is in. (Play, Pause, Stop)\r\n"..
				"!w.song\t\t-\tShow what track is beeing played now\r\n"..
				"!w.pretty\t\t-\tShow some nice info about the file being played\r\n"..
				"!w.tracknr\t\t-\tGet current track nr\r\n"..
				"!w.play <tacknr>\t-\tPlay song, <track> is optional\r\n"..
				"!w.pause\t\t-\tPause the song\r\n"..
				"!w.stop\t\t-\tStop playing song\r\n"..
				"!w.prev\t\t-\tBack to previous songr\n"..
				"!w.next\t\t-\tJump to next song\r\n"..
				"!w.vol <nr>\t-\tSet the volume 0-255\r\n"..
				"!w.playlist\t\t-\tGet current playlist\r\n"..
				"!w.clear\t\t-\tClear current playlist\r\n"..
				"!w.makepl\t-\tMake a playlist of the files in " ..Setup.Music.. " folder \r\n"..
				"!w.reload\t\t-\tReload the playlist\r\n"..
				"!w.shuffle\t\t-\tToggle shuffle\r\n"..
				"!w.repeat\t\t-\tToggle repeat\r\n"..
				"!w.getshuffle\t-\tCheck if shuffle is on/off\r\n"..
				"!w.getrepeat\t-\tCheck if repeat is on/off\r\n"..
				"!w.start\t\t-\tStart winamp\r\n"..
				"!w.close\t\t-\tClose winamp\r\n")
			else
				curUser:SendData(Setup.Name, "\r\n\t--==Winamp script help==--\r\n"..
				"!w.status\t\t-\tCheck in what mode winamp is in. (Play, Pause, Stop)\r\n"..
				"!w.song\t\t-\tShow what track is beeing played now\r\n"..
				"!w.pretty\t\t-\tShow some nice info about the file being played\r\n"..
				"!w.tracknr\t\t-\tGet current track nr\r\n")
			end
			return 1
		end,
		["start"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever..  "clever.exe new")
				curUser:SendData(Setup.Name, "Winamp started") return 1
			end
		end,
		["close"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe win close")
				curUser:SendData(Setup.Name, "Winamp has been closed")
			end
		end,
		["shuffle"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe swshuffle > winamp.tmp")
				local file = io.open("winamp.tmp")
				local shuf = file:read("*all") file:close() os.remove("winamp.tmp")
				curUser:SendData(Setup.Name, "Shuffle is now set to: "..shuf) return 1
			end
		end,
		["repeat"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe swrepeat > winamp.tmp")
				local file = io.open("winamp.tmp")
				local repe = file:read("*all") file:close() os.remove("winamp.tmp")
				curUser:SendData(Setup.Name, "Repeat is now set to: " ..repe) return 1
			end
		end,
		["getshuffle"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe getshuffle > winamp.tmp")
				local file = io.open("winamp.tmp")
				local gshuf = file:read("*all") file:close() os.remove("winamp.tmp")
				curUser:SendData(Setup.Name, "Shuffle is " ..gshuf) return 1
			end
		end,
		["getrepeat"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe getrepeat > winamp.tmp")
				local file = io.open("winamp.tmp")
				local grepe = file:read("*all") file:close() os.remove("winamp.tmp")
				curUser:SendData(Setup.Name, "Repeat is " ..grepe) return 1
			end
		end,
		["play"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				local s,e,nr = string.find(data, "%b<>%s+%S+%s+(%d+)") -- Get a number
				if not nr then -- No nr
					os.execute(Setup.Clever.. "clever.exe play") -- Play track
					curUser:SendData(Setup.Name, "Playing...") return 1
				end
				nr = tonumber(nr)
				os.execute(Setup.Clever.. "clever.exe play " ..nr) -- Got nr, play that track
				curUser:SendData(Setup.Name, "Playing... track nr: " ..nr) return 1
			end
		end,
		["pause"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe pause")
				curUser:SendData(Setup.Name, "Winamp has been paused") return 1
			end
		end,
		["stop"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe stop")
				curUser:SendData(Setup.Name, "Winamp has been stoped. Oh the silence") return 1
			end
		end,
		["next"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe next")
				curUser:SendData(Setup.Name, "Switched to next track") return 1
			end
		end,
		["prev"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe prev")
				curUser:SendData(Setup.Name, "Switched back to previous track") return 1
			end
		end,
		["status"] = function(curUser, data)
			os.execute(Setup.Clever.. "clever.exe status > winamp.tmp")
			local file = io.open("winamp.tmp")
			local status = file:read("*all") file:close() os.remove("winamp.tmp")
			curUser:SendData(Setup.Name, "Winamp is in: " ..status.. " mode") return 1
		end,
		["song"] = function(curUser, data)
			os.execute(Setup.Clever.. "clever.exe status > winamp.tmp")
			local file = io.open("winamp.tmp")
			local status = file:read("*all") file:close() os.remove("winamp.tmp")
			if status == "Pause" or status == "Stop" then
				curUser:SendData(Setup.Name, "Winamp is " ..status.. "ed") return 1
			else
				os.execute(Setup.Clever.. "clever.exe songtitle > songtitle.tmp")
				os.execute(Setup.Clever.. "clever.exe position > position.tmp")
				os.execute(Setup.Clever.. "clever.exe songlength > songlength.tmp")
				local fileA = io.open("songtitle.tmp")
				local fileB = io.open("position.tmp")
				local fileC = io.open("songlength.tmp")
				local songtitle = string.gsub(fileA:read("*all"),"\n", "") fileA:close() os.remove("songtitle.tmp")
				local timeelapsed = fileB:read("*all") fileB:close() os.remove("position.tmp")
				local songlength = fileC:read("*all") fileC:close() os.remove("songlength.tmp")
				SendToAll(Setup.Name, Setup.BeforeTitle.. " " ..songtitle.. " " ..Setup.AfterTitle.. " Played in " ..timeelapsed.. " of " ..songlength) return 1
			end
		end,
		["pretty"] = function(curUser, data)
			os.execute(Setup.Clever.. "clever.exe prettyinfo > winamp.tmp")
			local file = io.open("winamp.tmp")
			local info = file:read("*all") file:close() os.remove("winamp.tmp")
			SendToAll(Setup.Name, "\r\n" ..info) return 1
		end,
		["tracknr"] = function(curUser, data)
			os.execute(Setup.Clever.. "clever.exe getplpos > winamp.tmp")
			local file = io.open("winamp.tmp")
			local track = file:read("*all") file:close() os.remove("winamp.tmp")
			curUser:SendData(Setup.Name, "Current tracknumber is: " ..track) return 1
		end,
		["vol"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				local s,e,nr = string.find(data, "%b<>%s+%S+%s+(%d+)")
				if not nr then
					curUser:SendData(Setup.Name, "Please... We need a number to set the volume") return 1
				end
				nr = tonumber(nr)
				if nr > 255 then
					curUser:SendData(Setup.Name, "Number is to high to set, please write a numver between 0-255") return 1
				end
				os.execute(Setup.Clever.. "clever.exe volume " ..nr)
				curUser:SendData(Setup.Name, "Volume is now: " ..nr) return 1
			end
		end,
		--== Commands for the playlist ==--
		["playlist"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe playlist > winamp.tmp")
				local file = io.open("winamp.tmp")
				local list = file:read("*all") file:close() os.remove("winamp.tmp")
				curUser:SendPM(Setup.Name, "\r\n--==Current Playlist==--\r\n" ..list) return 1
			end
		end,
		["clear"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				os.execute(Setup.Clever.. "clever.exe clear") -- Clear the playlist
				curUser:SendData(Setup.Name, "Playlist was cleared! Who's next to erase?") return 1
			end
		end,
		["reload"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				local file = io.open(Setup.Music.. "playlist.pls")
				if file then
					os.execute(Setup.Clever.. "clever.exe clear") -- Make sure we have an empty playlist
					os.execute(Setup.Clever.. "clever.exe load " ..Setup.Music.. "playlist.pls") -- Load the playlist
					os.execute(Setup.Clever.. "clever.exe play") -- Start playing song
					curUser:SendData(Setup.Name, "Playlist has been reloaded") return 1
				else
					curUser:SendData(Setup.Name, "Error! " ..Setup.Music.. "playlist.pls was not found, use !w.makepl to create it") return 1
				end
			end
		end,
		["makepl"] = function(curUser, data)
			if WinampProfile[curUser.iProfile] == 1 then
				local file = io.open(Setup.Music.. "playlist.pls", "w+") -- Opens/Writes the file
					file:write("[playlist]\n") -- Delete everything in it and write this
					file:close() -- Close it
				local file = io.open(Setup.Music.. "Playlist.pls", "a+") -- Open file in Append mode
					os.execute("dir " ..Setup.Music.. "*.mp3 /b > " ..Setup.Music.. "TMPplaylist.pls") -- Make a playlist with only filenames
				local fTemp = io.open(Setup.Music.. "TMPplaylist.pls") -- Open the temp playlist
				if fTemp then -- If we found the tmplaylist
					count = 0 -- Count is 0
					for line in io.lines(Setup.Music.. "TMPplaylist.pls") do -- Read it and see lines
						count = count + 1 -- For each line we find count is +1
						file:write("File" ..count.. "=" ..Setup.Music..line.. "\n")
					end
					file:write("NumberOfEntries=" ..count.. "\nVersion=2") -- Add this to file as well
					fTemp:close() -- Close temp lisr
					os.remove(Setup.Music.. "TMPplaylist.pls") -- Remove it
					file:close() -- Close playlist
						curUser:SendData(Setup.Name, "Weee! We have now made a playlist of all Mp3 files in " ..Setup.Music)
					return 1
				else -- If we didn't found a file
					curUser:SendData(Setup.Name, "Crap! Sorry... Couldn't make playlist") return 1 -- Tell us that
				end
				return 1
			end
		end,
		}
		if tCmds[cmd] then
			return tCmds[cmd](curUser, data)
		end
	end
end