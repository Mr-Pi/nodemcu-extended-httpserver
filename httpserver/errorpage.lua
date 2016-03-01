-- vim: ts=4 sw=4
--
-- http request handler (error responder)

require "console"


if not httpreq then httpreq={} end


function httpreq.errorResponder(code, codeMsg, socketAdditionalHeaders, additionalHeaders)
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
		socketAdditionalHeaders:send(errorMsg)
		socketAdditionalHeaders:close()
		errorMsg=nil
		collectgarbage()
		return true
	else
		return errorMsg
	end
end

function httpreq.error404(header, socket, handler)
	console.log("errorResponder 404 for: "..header.uri)
	httpreq.errorResponder(404," Not Found", socket)
	return true
end


return console.moduleLoaded(...)
