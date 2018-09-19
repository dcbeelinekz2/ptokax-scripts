-- vim:ts=4:sw=4:noet
-- FileChecker.lua, rewrite of a 'SearchKick' bot for PtokaX by ptaczek and
-- Leon (called The Illegalist)
-- version 1.0 for DCH++
-- by Sedulus 20030910, requested by BSOD2600
-- 20030919: 1.0
--
-- Translated back to PtokaX (OpiumVolage 9 Sept. 2003)
-- Added timer for automating search
--
-- (using more mem (3 tables, instead of one) but less cpu)
--
-- searches for all terms in the SearchFor table,
-- sends a message to the user that he/she shares the file, with the response
-- message.
-- set disconnectUser to 1 if you want the user disconnected as well (not
-- recommended, as bots always seem to find a way to misinterpret data  )
--
-- spaces in the SearchFor table will be converted to dollar's, but they will
-- (purposely) only match if there's a space in the result later.
-- so "a b" won't match "b a" or "aXXXb"

--// useful stuff
botName = "LAV-FileChecker™"
disconnectUser = nil -- disconnect the user, nil = don't
-- opchatName = "-TropiCo-" -- set opchat nick here if you want messages to opchat instead of mainchat, else nil
opchatName = botName -- set opchat nick here if you want messages to opchat instead of mainchat, else nil
mb = 1024 * 1024
gb = 1024 * mb
-- Timer value, will send search for 1 of the file on all users at each timer
timerValue = 10*1000 -- Every 10 seconds (higher value will reduce load)
useTimer = 1 -- set to 1 to enable timer functions
counter = 1
--// do not modify this table, lookup the meanings in the $Search section in the protocol documentation
SearchTypes = {
	ANY = 1,
	AUDIO = 2,
	COMPRESSED = 3,
	DOCUMENT = 4,
	EXECUTABLE = 5,
	IMAGE = 6,
	VIDEO = 7,
	FOLDER = 8, -- do not use FOLDER's! the $SR's are formatted differently
}

st = SearchTypes
--// MODIFY THIS TABLE <-------
--      { searchType, words[, minimumSize[, regexMatch]] }
SearchFor = {
	["Não tenhas no share porno destes tipos (pre)teen/incest/sick! Lê as regras em http://www.lav-sounds.pt.vu ou Info: http://www.ownage.site.vu"] = {
		{ st.IMAGE, "preteen" },
		{ st.VIDEO, "preteen" },
		{ st.IMAGE, "incest" },
		{ st.VIDEO, "incest" },
		{ st.IMAGE, "underage" },
		{ st.VIDEO, "underage" },
		{ st.IMAGE, "teenage sex" },
		{ st.VIDEO, "teenage sex" },
	},
	["Não tenhas no share aplicações instaladas e\ou aplicações descomprimidas! Lê as regras em http://www.lav-sounds.pt.vu ou Info: http://www.ownage.site.vu"] = {
		{ st.ANY, "explorer.scf" },
		{ st.ANY, "explore.ex_" },
		{ st.ANY, "cd_clint.dll" },
		{ st.EXECUTABLE, "express msimn.exe", 0, "express\\msimn%.exe$" },
		{ st.EXECUTABLE, "IEXPLORE.EXE" },
		{ st.ANY, "bfdist.vlu" },
		{ st.ANY, "War3Inst.log" },
		{ st.ANY, "ut2003.log" },
		{ st.EXECUTABLE, "NFSHP2.exe" },
		{ st.ANY, "avp2.rez" },
		{ st.ANY, "ntuser.dat" },
		{ st.EXECUTABLE, "winword.exe" },
		{ st.ANY, "sav", 0, "%.sav$" },
		{ st.ANY, "dll", 0, "%.dll$" },
		{ st.ANY, "ex_", 0, "%.ex_$" },
		{ st.EXECUTABLE, "setup.exe", 0, "\\setup%.exe$" },
	},
	["Não tenhas downloads incompletos no share! Lê as regras em http://www.lav-sounds.pt.vu Info: http://www.ownage.site.vu"] = {
		{ st.ANY, "antifrag", 0, "antifrag$" },
		{ st.ANY, "download dat", 0, "download[0-9]+%.dat$" },
		{ st.ANY, "INCOMPLETE~" },
		{ st.ANY, "__INCOMPLETE___" },
		{ st.ANY, ".part.met"},
		{ st.ANY, ".mp3.temp"},
		{ st.ANY, " .torrent"},
	},
	["Não é premitido ter DVD's descomprimidos aqui! Remove todos os ficheiros VOB!  Lê as regras em http://www.lav-sounds.pt.vu ou Info: http://www.ownage.site.vu"] = {
		{ st.ANY, "VTS_01_0.VOB" },
	},
	["Não tenhas no share ficheiros WAV! Obrigada pela atenção, lê as regras em http://www.lav-sounds.pt.vu ou Info: http://www.ownage.site.vu"] = {
		{ st.AUDIO, ".wav", 5*mb, "wav$" },
	},
	["Se tens no teu share copias de ficheiros só para aumentar o share, estamos de olho em ti... lê as regras em http://www.lav-sounds.pt.vu ou Info: http://www.ownage.site.vu"] = {
		{ st.ANY, "copy of", 300*mb, "\\Copy of" },
		{ st.ANY, "kopie van", 300*mb, "\\Kopie van" },
	},
--	["Please do not share unzipped DVD's and/or other large files. Use rar-sets."] = {
--		{ st.ANY, ".", 1*gb },
--	},
}

--// convert the tables
SearchTable = {}
ResultTable = {}

function Main()
	--frmHub:EnableSearchData(1)
	frmHub:RegBot(botName)
	botLen = string.len( botName )
	local i = 0 -- add the serial botnames in here as well.. so the user doesn't think he is flooded by one person
	for k,v in SearchFor do
		for _,search in v do
			-- add $Search
			local s = "$Search Hub:"..botName..i.." "
			if search[3] then
				s = s.."T?F?"..search[3]
			else
				s = s.."F?F?0"
			end
			s = s.."?"..search[1].."?"..string.gsub( search[2], " ", "$" ).."|"
			table.insert( SearchTable, s )
			-- add $SR match
			local idx = string.lower( search[2] )
			ResultTable[idx] = { msg = k }
			if search[4] then ResultTable[idx].regex = string.lower( search[4] ) end
			-- next..
			i = i + 1
		end
	end
	st, SearchTypes, SearchFor = nil, nil, nil

	-- set options
	if opchatName then
		messageFunc = SendPmToOps
	else
		messageFunc = SendPmToOps
		opchatName = botName
	end
	if useTimer then SetTimer(timerValue) StartTimer() end
end

-- on new user
function NewUserConnected( client )
	table.foreachi(SearchTable, function(_, v) client:SendData( v ) end)
end

-- on $SR
function SRArrival( client, line )
	local match = nil
	-- test if it was a result to us only
	local ret,c,to = string.find( line, "\005([^\005|]*)|$" )
	if ret and string.sub( to, 1, botLen ) == botName then
		local ret,c,file,size = string.find( line, "^%$SR [^ ]+ ([^\005]*)\005([0-9]+) " )
		if ret then
			file = string.lower( file )
			for k,v in ResultTable do
				if ( v.regex and string.find( file, v.regex ) ) or ( not v.regex and string.find( file, k, 1, 1 ) ) then
					match = 1
					warn( client, file.." ("..dchpp.formatBytes( size ).." ("..size..")", v.msg )
					warn( client, file.." ("..size.."", v.msg )
				end
			end
		end
	end
	-- disconnect user
	if match and disconnectUser and not client.bOperator then
		client:SendData( "<"..botName.."> Estás a ser Kikado!" )
		clientisconnect()
		return 1
	end
end

function warn( client, file, response )
	-- send message to user
	client:SendData( "<"..botName.."> Tens no share o seguinte Ficheiro: "..file..": "..response )
	if client.bOperator then return end
	message = client.sName.." tem no share: "..file
	-- send message to all Operators
	messageFunc( opchatName, message )
end

function OnTimer()
	if table.getn(SearchTable) < 1 then return end
	SendToAll(SearchTable[counter])
	counter = counter + 1
	if counter > table.getn(SearchTable) then counter =1 end
end
