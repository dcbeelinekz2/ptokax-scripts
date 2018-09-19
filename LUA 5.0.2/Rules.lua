-- rules by jiten

sConf = {
	sBot = frmHub:GetHubBotName(),
	sFile1 = "file1.txt",
}

function Main()
	frmHub:RegBot(sConf.sBot)
end

function ChatArrival(user,data)
	local data = string.sub(data,1,-2)
	local s,e,cmd = string.find (data, "%b<>%s+[%!%?%+%#](%S+)" )
	if cmd then
		local tCmds = 	{
			["rules"] = 	function(user,data)
						user:SendPM(sConf.sBot,ReadFile(sConf.sFile1))
					end,
		}
		if tCmds[cmd] then 
			return tCmds[cmd](user,data), 1
		end
	end
end

function ReadFile(file)
	local fFile = io.open(file)
	if fFile then
		local message = ""
		for line in io.lines(file) do
			message = message..line.."\n"
		end
		fFile:close()
		return message
	else
		return file.." not found!"
	end
end