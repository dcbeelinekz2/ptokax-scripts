MyINFOArrival = function(curUser, sData)
	if string.find(curUser.sEmail, "myemail@host.com") or string.find(curUser.sName, "mynick") and string.find(curUser.sDescription, "none") then
		curUser:Redirect(frmHub:GetRedirectAddress(),"Your DC++ system is infected by a virus. Please clean it!")
	end
end

-- mail = given statement 
-- mail and (not or) desc = given statements 
-- mail and nick = given statements 
-- nick and desc = given statements