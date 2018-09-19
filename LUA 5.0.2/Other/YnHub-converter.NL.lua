--//----------------------------------------------------------------------------------------------->>
--//-- Convert YnHub Register to PtokaX
--//-- Created by NightLitch 2005-04-23
--//-- To start the convert use specified command bellow in mainchat
--//-- Usage: #convert
--//----------------------------------------------------------------------------------------------->>

--//-- Specify the YnHub Profiles to work with your PtokaX Profiles
--//-- YnHub Profiles   =   PtokaX Profiles
ProfileRegistry = {
	 ["Owner"] = "Master",
	 ["OP"] = "Operator",
	 ["VIP"] = "VIP",
	 ["Registered"] = "Reg",
}

--//-- Specify the Path to YnHubs Register File
FileName = "filename_here.xml"

--//----------------------------------------------------------------------------------------------->>
--//-- Don't Edit
--//----------------------------------------------------------------------------------------------->>
function ConvertYnHubRegisterFile(filename)
    local curTable = {}
    local curNick = ""
    local Count = 0
    local file = io.open(filename, "r")
    for line in file:lines() do
        local s,e,col,value = string.find(line, "<(%S+)>(%S+)<")
        if col and value then
            if col == "Nick" and Count == 0 then
                curNick = value
                curTable[value] = {["Pass"] = "", ["Profile"] = ""}
                Count = Count + 1
            elseif col == "Pass" and Count == 1 then
                curTable[curNick].Pass = value
                Count = Count + 1
            elseif col == "Profile" and Count == 2 then
                curTable[curNick].Profile = value
                Count = 0
            end
        end
    end
    file:close()
    return curTable
end

function ChatArrival(sUser,sData)
	local _,_,Cmd = string.find(sData, "%b<>%s*(%S+)%|")
	if Cmd == "#convert" then
		sUser:SendData("Converter","Start Converting YnHub register into PtokaX register")
		local T = ConvertYnHubRegisterFile(FileName)
		local t,g,b = 0,0,0
		for nick,_ in T do
			t = t + 1
			if ProfileRegistry[T[nick].Profile] and GetProfileIdx(ProfileRegistry[T[nick].Profile]) ~= -1 then
				g = g + 1
				AddRegUser(nick,T[nick].Pass, GetProfileIdx(ProfileRegistry[T[nick].Profile]))
			else
				b = b +1
			end
		end
		sUser:SendData("Converter", "*** Total ( "..t.." ) registered user(s) is found in YnHub")
		sUser:SendData("Converter","*** Total ( "..g.." ) user(s) are registered to PtokaX registry")
		sUser:SendData("Converter","*** Total ( "..b.." ) user(s) is not registered because profiles doesn't exist in PtokaX")
		return 1
	end
end
--// NightLitch