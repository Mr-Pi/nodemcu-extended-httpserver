-- vim: ts=4 sw=4
--
--

require "console"


if not httpreq then httpreq={} end
if not httpreq.responder then httpreq.responder={} end


local staticResponder={}
local serveredExts={html="text/html",css="text/css",js="text/javascript",txt="text/plain"}
local function getMimeType(ext)
	return serveredExts[ext] or "application/octet-stream"
end

function staticResponder.respond(header, socket, handler)
	console.log("staticResponder executed")
	local fslist = file.list()
	if not fslist[header.filename] then
		fslist=nil
		collectgarbage()
		return false
	end
	if header.method~="GET" and header.method~="HEAD" then
		console.log("method not allowed for static file: "..header.filename)
		httpreq.errorResponder(405, "Method Not Allowed", socket, "Allow: GET, HEAD\r\n")
		collectgarbage()
		return true
	elseif header.method=="GET" and (not file.open(header.filename)) then
		console.log("can't open static file: "..header.filename)
		httpreq.errorResponder(500, "Internal Server Error", socket)
		collectgarbage()
		return true
	elseif header.method=="GET" then
		console.debug("serving file static: "..header.filename)
		file.close()
		socket:on("sent", function(socket)
			if not handler.bytesSent then handler.bytesSent=0 end
			local data = "failed to open file '"..header.filename.."' while serving"
			local okay = file.open(header.filename)
			if okay then
				okay, data = pcall(file.seek, "set", handler.bytesSent)
			end
			if okay then
				okay, data = pcall(file.read, 512)
				handler.bytesSent = file.seek()
			end
			if okay and data then
				socket:send(data)
				console.debug("sending data: "..data,8)
			elseif okay or handler.bytesSent>=handler.bytesToSent then
				console.log("served served static file: "..tostring(header.filename))
				file.close()
				socket:close()
			else
				console.log("Internal Server Error - "..tostring(data))
				httpreq.errorResponder(500, "Internal Server Error", socket)
				file.close()
				collectgarbage()
			end
			data=nil okay=nil
			collectgarbage()
		end)
	end
	handler.bytesToSent = fslist[header.filename]
	socket:send(httpreq.assembleBasicHeader(200, "OK", getMimeType(header.ext), handler.bytesToSent).."\r\n")
	if header.method=="HEAD" then
		socket:close()
	end

	fslist=nil
	collectgarbage()
	return true
end


table.insert(httpreq.responder,staticResponder)


return console.moduleLoaded(...)
