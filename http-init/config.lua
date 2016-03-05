-- vim: ts=4 sw=4
--
--

require "console"

local methodHandler = {}

methodHandler["HEAD"] = function(socket, header, payload, handler)
	local fslist = file.list()
	header.ext = "json"
	header.filename = "config.json"
	if not fslist["config.json"] then
		header.filename = "config.default.json"
	end
	fslist = nil
	collectgarbage()
	dofile("httpresponder/11_static.lc")(header, socket, handler)
end

methodHandler["GET"] = function(socket, header, payload, handler)
	console.debug("sending out configuration")
	methodHandler["HEAD"](socket, header, payload, handler)
end

methodHandler["POST"] = function(socket, header, payload, handler)
	console.log("writing configuration, package: "..tostring(handler.package))
	local openmode = "a+"
	if handler.package==1 then openmode = "w+" end
	if not pcall(file.open, "config.json", openmode) then
		console.log("Internal Server Error - failed to open config file for writing")
		httpreq.errorResponder(500, "Internal Server Error", socket)
	end
	if not pcall(file.write, payload) then
		console.log("Internal Server Error - failed to write configuration file")
		httpreq.errorResponder(500, "Internal Server Error", socket)
	end
	file.close()
	openmode=nil collectgarbage()
	if handler.bytesReceived>=header.contentLength then
		local data = httpreq.assembleSimplePackage(200, "OK", "application/json; charset=UTF-8","{\"config\":\"updated\"}","")
		httpreq.sendFinal(socket, data)
		data = nil
		collectgarbage()
		console.log("configuration written "..tostring(node.heap()))
	end
end

return function(payload, header, handler, socket)
	tmr.stop(0) tmr.unregister(0) collectgarbage()
	if methodHandler[header.method] then
		methodHandler[header.method](socket, header, payload, handler)
	else
		httpreq.errorResponder(405, "Method Not Allowed", socket, "Allow: GET, HEAD, POST\r\n")
	end
	payload=nil methodHandler=nil
	collectgarbage()
	return true
end
