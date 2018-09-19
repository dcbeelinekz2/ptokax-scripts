--- begin " RW¦One-ArmedBandit.lua "
-------------------------------------------------------------------------------
--- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
--- "The One Armed Bandit" 					   ---
--- Created by: FlipDeluXe 					   ---
--- Date: May 10 2003 						   ---
--- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
--- touched by Herodes' one arm :)			   ---
--- Date: July 27 2004						   ---
--- RW in the title of the script is for : ReWrite	   ---
--- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- ---
-------------------------------------------------------------------------------
--- there is !insert to start the game...   ( FlipDeluxe )
--- Pull the arm with !hit ...   ( FlipDeluxe )
--- At any point there is !oknow to take your bucks and go .. :) ( Herodes )
------------------------------------------------------------------ 18/4 - 2005
--- Lua 5 conversion ( Herodes )
--- some small optimisations ..  ( Herodes )
-------------------------------------------------------------------------------

----------------- edit this at will ...
Bot="Bandit"
SendComm = 1		-- Send user command [right click] "1"=yes "0"=no

SetTo = {
 [0] = 1,   -- Masters
 [1] = 1,   -- Operators
 [2] = 1,   -- Vips
 [3] = 1,   -- Regs
 [4] = 1,   -- Moderator
 [5] = 1,   -- NetFounder
 [-1] = 0,  -- Users
}
----------------- pls dont touch below here ..
----------------- or if you touch dont blame either of the authors .. :)

function NewUserConnected(user)
	if SendComm == 1 and SetTo[user.iProfile] == 1 then 
		if user.bUserCommand then -- Is new function to check if client has UserCommand support.
			user:SendData("$UserCommand 0 3")
			user:SendData("$UserCommand 1 3 -=( The One Armed Bandit )=-\\Insert Coin $<%[mynick]> !insert&#124;|")
			user:SendData("$UserCommand 1 3 -=( The One Armed Bandit )=-\\Hit Arm$<%[mynick]> !hit&#124;|")
			user:SendData("$UserCommand 1 3 -=( The One Armed Bandit )=-\\Take Money & Quite $<%[mynick]> !oknow&#124;|")
		end
	end
end

OpConnected = NewUserConnected

function Main()
	bSwitch, sPlayer, iTriesLeft = false, "", 5
end

function ChatArrival( user, data )
	local data=string.sub(data,1,-2)
	s,e,cmd = string.find( data, "%b<>%s+(%S+)" )
	if cmd then
		local t = {

		["!insert"] = function ( user, data )
			if not bSwitch then
				sStart, iCredit, bSwitch, iTriesLeft, sPlayer = os.date("%X"), 0, true, 5, user.sName
				SendToAll( Bot, "Alright!, "..sPlayer.." just threw in a buck! Let's see what he can do ..." )
				SendToAll( Bot, "Tries left : "..iTriesLeft )
				user:SendData( Bot, "started. Pull with !hit in Main Chat!" )
				return 1
			end
		end,

		["!hit"] = function ( user, data )
			if sPlayer ~= user.sName then SendToAll(Bot, "Sorry "..user.sName.." you must wait until "..sPlayer.." is done with his round."); return 1; end
			if ( (iTriesLeft == 0) or (not bSwitch) ) then bSwitch = false;SendToAll( Bot, "Better insert a coin if you wanna play with me ..." ); return 1; end
			-- checks done carry on playing
			local iFirst, iSecond, iThird = math.random( 1, 8 ), math.random( 1, 8 ), math.random( 1, 8 )
			-- one try less left
			iTriesLeft = iTriesLeft - 1
			local tFruits = { "@", "$", "#","&", "£","O","%","€" }
			sFirst, sSecond, sThird = tFruits[iFirst], tFruits[iSecond], tFruits[iThird]
			SendToAll("\t...----------------o-0-o----------------...")
			SendToAll("\t¦        One-Armed-Bandit        ¦")
			SendToAll("\t¦      >>>  "..sFirst.."  -  "..sSecond.."  -  "..sThird.."  <<<      ¦")
			--SendToAll("\t"..iFirst.." "..iSecond.." "..iThird)
			SendToAll("\t```----------------o-0-o----------------```" )

			local Reward = {
				{ "Cool " ..user.sName.. ", you just won 10 bucks!", 10 },
				{ "Great!! " ..user.sName.." 20 bucks for you!", 20},
				{ user.sName..", just won 30 bucks...", 30},
				{ "Wow! "..user.sName.." it must be your lucky day, 40 bucks!!", 40},
				{ "yeah!! " ..user.sName.." cha-ching 50 bucks!!!", 50},
				{ "Woohoo!! " ..user.sName.." You're on a winning spree!! 70 bucks!!!", 70},
				{ "Wow, you won 90 bucks " ..user.sName.."!!", 90},
				{ "Awesome!! " ..user.sName.." You just hit the jackpot! cha-ching 100 bucks!!!", 100},
				{ "Great!! " ..user.sName.." a buck for you!", 1},
			}

			for i, v in Reward do
				failed = nil
				if (iFirst == i) then
					if (iSecond == i) then
						if (iThird == i) then
							SendToAll( Bot, Reward[i][1] ) ; iTriesLeft = iTriesLeft + Reward[i][2] ; iCredit = iCredit + Reward[i][2]
							SendToAll("A : credit is "..iCredit.." because I added "..Reward[i][2])
							break
						else
							SendToAll( Bot, Reward[9][1] ) ; iTriesLeft = iTriesLeft + Reward[9][2] ; iCredit = iCredit + Reward[9][2]
							SendToAll("B : credit is "..iCredit.." because I added "..Reward[9][2])
							break
							
						end
					else
						if (iThird == i) then
							SendToAll( Bot, Reward[9][1] ) ; iTriesLeft = iTriesLeft + Reward[9][2] ; iCredit = iCredit + Reward[9][2]
							SendToAll("C : credit is "..iCredit.." because I added "..Reward[9][2])
							break
						else
							failed = true
						end
					end 
				else
					if ( iSecond == i ) then
						if ( iThird == i ) then
							SendToAll( Bot, Reward[9][1] ) ; iTriesLeft = iTriesLeft + Reward[9][2] ; iCredit = iCredit + Reward[9][2]
							SendToAll("D : credit is "..iCredit.." because I added "..Reward[9][2])
							break
						else
							failed = true
							
						end
					else
						failed = true
						
					end
				end
			end
			if failed then SendToAll(Bot, "Ahhh, too bad "..user.sName.." you won nothing..."); end
			SendToAll("Tries left : "..iTriesLeft)
			if ( iTriesLeft == 0) then
				bSwitch = false
				SendToAll( Bot, "Outta credits, insert coin.")
				
			end
			if (not bSwitch) then IQuit( user, sStart, iTriesLeft ) end
				return 1
		end,

		["!oknow"] = function ( user, data )
			if bSwitch then
				bSwitch = false
				if (iCredit > 0) then
					SendToAll(Bot , user.sName.." has taken the money... He dont wanna play with me ...")
				else
					SendToAll(Bot, user.sName.." is a quiter ...")
					return 1
				end
				IQuit( user, sStart, iTriesLeft, true )
				
			end
		end,
		}
		if t[cmd] then return t[cmd]( user, data ) end
	end
end

function IQuit( user, sStart, iTriesLeft, bQuit )
	if (iCredit > 0) then
		local f = io.open( "bandit_wins.txt", "a+" )
		local m = "\n - € -"..user.sName.." won "..iCredit.." bucks - started playing at "..sStart.." ended at "..os.date("%X ¦ on %d/%m-%Y")
		if bQuit then m = m.." ¦ * quiter *";end;
		f:write( m );f:close();iCredit = 0
	end
	local f = io.open( "bandit_plays.txt", "a+" )
	local m = "\n - € -"..sPlayer.." - started playing at "..sStart.." ended at "..os.date("%X ¦ on %d/%m-%Y")
	if bQuit then m = m.." ¦ * quiter *"; end;
	f:write( m ); f:close()
end
