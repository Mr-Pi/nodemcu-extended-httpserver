-- vim: ts=4 sw=4
--
-- http error responder

require "console"

return function(code, codeMsg, socketAdditionalHeaders, additionalHeaders)
	local errorMsg="<html><head>"
	errorMsg=errorMsg.."<title>"..tostring(code).." - "..tostring(codeMsg).."</title>"
	errorMsg=errorMsg.."</head><body>"
	errorMsg=errorMsg.."<h1>"..tostring(code).." - "..tostring(codeMsg).."</h1>"
	errorMsg=errorMsg.."</body></html>"
	console.debug("errorResponder error package assembled: "..tostring(code).." - "..tostring(codeMsg))
	if not (additionalHeaders and type(additionalHeaders)=="string") and socketAdditionalHeaders and type(socketAdditionalHeaders)=="string" then
		additionalHeaders=socketAdditionalHeaders
	end
	errorMsg = httpreq.assembleSimplePackage(code, codeMsg, "text/html; charset=UTF-8", errorMsg, additionalHeaders)
	if socketAdditionalHeaders and type(socketAdditionalHeaders)=="userdata" then
		httpreq.sendFinal(socketAdditionalHeaders, errorMsg)
		errorMsg=nil
		collectgarbage()
		return true
	else
		return errorMsg
	end
end
