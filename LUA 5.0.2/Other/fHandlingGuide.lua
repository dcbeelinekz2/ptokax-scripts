-- mine:
MOTD = "MOTD.txt" -- textfile

function TextFile(file)
	local f = io.open(file,"r")
	if f then
		local message = ""
		while 1 do
			local line = f:read("*l")
			if line == nil then
				break
			else
				message = message..line.."\n"
			end
		end
		f:close()
		return message
	end
end

-- plop's
function TextFile(file)
	local fFile = io.open(file)
	if fFile then
		local message = ""
		for line in io.lines(file)
			message = message..line.."\n"
		end
		fFile:close()
		return message
	else
		return file.." not found!"
	end
end

-- herodes
function TextFile( file )
	local f = io.open( file )
	if f then
		local content = f:read("*all");
		f:close()
		return string.gsub( content, "\n", "\r\n" )
	end
	return file.." not found!"
end
