-- vim: ts=4 sw=4
--
--

require "console"

local methodHandler = {}

methodHandler["HEAD"] = function(socket, header, payload, handler)
	local fslist = file.list()
	handler.bytesToSent = fslist["config.json"] or 2
	fslist = nil
	collectgarbage()
	socket:send(httpreq.assembleBasicHeader(200, "OK", "application/json", handler.bytesToSent).."\r\n")
	if header.method=="HEAD" then
		socket:close()
	end
end

methodHandler["GET"] = function(socket, header, payload, handler)
	console.debug("sending out configuration")
	socket:on("sent", function(socket)
		if not handler.bytesSent then handler.bytesSent=0 end
		local data = "failed to open configuration file"
		local okay = file.open("config.json")
		if okay then
			okay, data = pcall(file.seek, "set", handler.bytesSent)
		end
		if okay then
			okay, data = pcall(file.read, 512)
			handler.bytesSent = file.seek()
		else
			data = "{}"
			okay = true
		end
		file.close()
		collectgarbage()
		print("methodHandler GET", okay, data, handler.bytesSent, handler.bytesToSent)
		if okay and data then
			socket:send(data)
			console.debug("sending data: "..data,8)
		elseif okay or handler.bytesSent>=handler.bytesToSent then
			console.log("served served configuration as json file")
			socket:close()
		else
			console.log("Internal Server Error - "..tostring(data))
			httpreq.errorResponder(500, "Internal Server Error", socket)
		end
		data=nil okay=nil
		collectgarbage()
	end)
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
