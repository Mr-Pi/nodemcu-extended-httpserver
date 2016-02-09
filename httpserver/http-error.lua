-- vim: ts=4 sw=4
require "misclib"


if not httpreq then httpreq={} end
if not httpreq.responder then httpreq.responder={} end


local errorResponder={}

function httpreq.errorResponder(code, codeMsg)
	local errorMsg="<html><head>"
	errorMsg=errorMsg.."<title>"..tostring(code).." - "..tostring(codeMsg).."</title>"
	errorMsg=errorMsg.."</head><body>"
	errorMsg=errorMsg.."<h1>"..tostring(code).." - "..tostring(codeMsg).."</h1>"
	errorMsg=errorMsg.."</body></html>"
	console.debug("errorResponder error package assembled: "..tostring(code).." - "..tostring(codeMsg))
	return httpreq.assembleSimplePackage(code, codeMsg, "text/html; charset=UTF-8", errorMsg)
end

function errorResponder.respond(header, socket, handler)
	console.log("errorResponder executed")
	socket:send(httpreq.errorResponder(404,"Not Found"))
	socket:close()
	return true
end


table.insert(httpreq.responder,errorResponder)


console.moduleLoaded("http-error")
