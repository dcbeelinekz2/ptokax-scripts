sBot = "Mass-Message";
sPrefix = "!";

CmdOpt = {
	["massmaster"] = {
		[0] = 1,
		[1] = 1,
		[2] = 0,
		[3] = 0,
		[-1] = 0,
	},
	["massop"] = {
		[0] = 1,
		[1] = 1,
		[2] = 0,
		[3] = 0,
		[-1] = 0,
	},
	["massvip"] = {
		[0] = 1,
		[1] = 1,
		[2] = 1,
		[3] = 0,
		[-1] = 0,
	},
	["massreg"] = {
		[0] = 1,
		[1] = 1,
		[2] = 1,
		[3] = 0,
		[-1] = 0,
	}, 
	["massall"] = {
		[0] = 1,
		[1] = 1,
		[2] = 0,
		[3] = 0,
		[-1] = 0,
	}
};

function Main()
	frmHub:RegBot(sBot);
end

function ChatArrival(user,data)
	data=string.sub(data,1,-2);
	local s,e,cmd = string.find(data,"^%b<>%s+(%S+)");
	local Prefix = string.sub(cmd,1,1);
	if (Prefix == sPrefix) then
		cmd = string.lower(string.sub(cmd,2,string.len(cmd)));
		if (Commands[cmd]) then
			return (Commands[cmd](user,data))
		end
	end
end

Commands = {
	["massmaster"] = 
	function(user,data)
		if (Denial("massmaster",user) == 1) then return 1 end
		local s,e,Msg = string.find(data,"^%b<>%s+%S+%s+(.*)");
		return MassMessage(1,Msg,nil,user);
	end,

	["massop"] = 
	function(user,data)
		if (Denial("massop",user) == 1) then return 1 end
		local s,e,Msg = string.find(data,"^%b<>%s+%S+%s+(.*)");
		return MassMessage(1,Msg,nil,user);
	end,

	["massvip"] = 
	function(user,data)
		if (Denial("massvip",user) == 1) then return 1 end
		local s,e,Msg = string.find(data,"^%b<>%s+%S+%s+(.*)");
		return MassMessage(2,Msg,nil,user);
	end,

	["massreg"] = 
	function(user,data)
		if (Denial("massreg",user) == 1) then return 1 end
		local s,e,Msg = string.find(data,"^%b<>%s+%S+%s+(.*)");
		return MassMessage(3,Msg,nil,user);
	end,

	["massall"] = 
	function(user,data)
		if (Denial("massall",user) == 1) then return 1 end
		local s,e,Msg = string.find(data,"^%b<>%s+%S+%s+(.*)");
		return MassMessage(-1,Msg,1,user);
	end
};

function MassMessage(ProfileIdx, Msg, bToAll, user)
	local MassSend = function(user,Msg,Profile)
		local msg = "\r\n\r\n\t"..string.rep("-",100).."\r\n"
		msg = msg.."\t-- Sender: "..user.sName.."\r\n\r\n"
		msg = msg.."\t-- To: "..Profile.."\r\n"
		msg = msg.."\t-- Message: "..Msg.."\r\n"
		msg = msg.."\t"..string.rep("-",100)
		return msg
	end
	if (bToAll) then
		SendPmToAll(sBot,MassSend(user,Msg,"All"));
		user:SendData(sBot,"Your message has been sent!");
		return 1;
	end
	for i,v in frmHub:GetOnlineUsers() do
		if (v.iProfile == ProfileIdx) then
			v:SendPM(sBot,MassSend(user,Msg,GetProfileName(ProfileIdx)));
			SendPmToOps(sBot,"Report of Mass Message:"..MassSend(user,Msg,GetProfileName(ProfileIdx)))
		end
	end
	user:SendData(sBot,"Your message has been sent!");
	return 1;
end

function Denial(Table, user)
	if (CmdOpt[Table][user.iProfile] ~= 1) then
		user:SendData(sBot,"You are not allowed to use this command!");
		return 1;
	end
end
