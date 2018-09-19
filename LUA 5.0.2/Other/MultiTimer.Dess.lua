--lua5 version by Dessamator
-- MultiTimer by OpiumVolage (19/06/2003)
-- Ideas taken from tezlo's retrobot

tabTimers = {n=0}

-- Time Definition
Sec  = 1000
Min  = 60*Sec
Hour = 60*Min
Day  = 24*Hour

TmrFreq = 1*Sec
botname=  frmHub:GetHubBotName() -- bot name
------------------------------MAIN FUNCTION ------------------------ 
function Main()  
frmHub:RegBot(botname)


--timerS
	RegTimer(Trig1, 1*Min)
	RegTimer(Trig2, 2*Min)
	SetTimer(TmrFreq)
	StartTimer()
--
end  
----------------------------------------------------------------------
--Timer Functions--
function Trig1()
	SendToAll("txt")

end
function Trig2()
	SendToAll("txt2")
	
end

function OnTimer()
	for i in ipairs(tabTimers) do
		tabTimers[i].count = tabTimers[i].count + 1
		if tabTimers[i].count > tabTimers[i].trig then
			tabTimers[i].count=1
			tabTimers[i]:func()
		end
	end
end

function RegTimer(f, Interval)
	local tmpTrig = Interval / TmrFreq
	assert(Interval >= TmrFreq , "RegTimer(): Please Adjust TmrFreq")
	local Timer = {n=0}
	Timer.func=f
	Timer.trig=tmpTrig
	Timer.count=1
	table.insert(tabTimers, Timer)
end

-- Timer Functions--------
