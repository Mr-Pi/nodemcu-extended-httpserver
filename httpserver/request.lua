-- vim: ts=4 sw=4
--
--

require "console"


if not httpreq then httpreq={} end


function httpreq.updateResponders()
	dofile("httpserver/updateResponders.lc")
end

function httpreq.assembleBasicHeader(code, codeMsg, contentType, length, additionalHeaders)
	return dofile("httpserver/assembleHeader.lc")(code, codeMsg, contentType, length, additionalHeaders)
end

function httpreq.assembleSimplePackage(code, codeMsg, contentType, body, additionalHeaders)
	local package=httpreq.assembleBasicHeader(code, codeMsg, contentType, #tostring(body), additionalHeaders)
	package=package.."\r\n"..tostring(body)
	collectgarbage()
	return package
end

function httpreq.parseHeader(payload)
	return dofile("httpserver/parseHeader.lc")(payload)
end

function httpreq.errorResponder(code, codeMsg, socketAdditionalHeaders, additionalHeaders)
	return dofile("httpserver/errorResponders.lc")(code, codeMsg, socketAdditionalHeaders, additionalHeaders)
end

function httpreq.sendFinal(socket, data)
	socket:send(data)
	socket:on("sent", function(socket) socket:close() socket=nil end)
end

return console.moduleLoaded(...)
