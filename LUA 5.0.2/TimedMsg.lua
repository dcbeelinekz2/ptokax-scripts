-- timed message by jiten

sConf = {
	sBot = frmHub:GetHubBotName(),
	sFile = "file.txt", -- the txt file
}

function Main()
	SetTimer(30*60*1000) -- timed message in 30 minutes
	StartTimer()
end

function OnTimer()
	local H = os.date("%H")  
	if (H == "16") then 
		SendToAll(sConf.sBot,ReadFile(sConf.sFile1)) -- Send sFile1
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
	end
end