-- vim: ts=4 sw=4
--
-- http request handler (error responder)

require "console"


if not httpreq then httpreq={} end
if not httpreq.responder then httpreq.responder={} end


local errorResponder={}

function httpreq.errorResponder(code, codeMsg, socket)
	local errorMsg="<html><head>"
	errorMsg=errorMsg.."<title>"..tostring(code).." - "..tostring(codeMsg).."</title>"
	errorMsg=errorMsg.."</head><body>"
	errorMsg=errorMsg.."<h1>"..tostring(code).." - "..tostring(codeMsg).."</h1>"
	errorMsg=errorMsg.."</body></html>"
	console.debug("errorResponder error package assembled: "..tostring(code).." - "..tostring(codeMsg))
	errorMsg = httpreq.assembleSimplePackage(code, codeMsg, "text/html; charset=UTF-8", errorMsg)
	if socket then
		socket:send(errorMsg)
		socket:close()
		errorMsg=nil
		collectgarbage()
		return true
	else
		return errorMsg
	end
end

function errorResponder.respond(header, socket, handler)
	console.log("errorResponder 404 for: "..header.uri)
	httpreq.errorResponder(404," Not Found", socket)
	return true
end


table.insert(httpreq.responder,errorResponder)


return console.moduleLoaded(...)
