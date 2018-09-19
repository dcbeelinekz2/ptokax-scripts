--[[ 

	Client-side version by jiten (2/22/2006)

	Owner-Messenger-Bot made by Toobster®™ 04/01/06
	Filters mainchat for users calling your Nick
	Then PM's the user from your Nick asking them to leave you a Message
	Once they reply you get their pm
	Also Bot PM's you telling you they called your nick in Mainchat
	Like my script ? Then Plz help support my hub @ geordieland.no-ip.info

]]--

sBot = "Owner-Messenger"		-- name of bot that will message you

-- Insert your trigger nicks below
tNicks = { "toobster®™", "toob",  "toobster",  "tooby", "hubowner?", }

dcpp:setListener( "chat", "ownermessenger",
	function( hub, user, msg )
		if hub:getOwnNick() ~= user:getNick() then
			local msg = string.lower(msg)
			for i,v in pairs(tNicks) do
				if string.find(msg,string.lower(v),1,1) then
					hub:sendPrivMsgTo(user:getNick(),"<"..hub:getOwnNick()..
					"> THIS IS AN AUTO RESPONSE MESSAGE \r\n\r\n I have been informed you are calling "..
					"for me in mainchat, please leave a message for me here in pm and I will reply A.S.A.P.\r\n"..
					"\r\n Your mainchat message was: " ..msg,0)
					hub:injectChat("<"..sBot.."> "..user:getNick().." is calling for you in mainchat : "..msg)
				end
			end
		end
	end
)

DC():PrintDebug( "*** Loaded OwnerMessenger.lua ***" )