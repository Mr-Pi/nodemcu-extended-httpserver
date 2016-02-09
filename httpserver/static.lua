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
	if fslist[header.filename] then
		console.debug("serving file static: "..header.filename)
		if header.method~="GET" and header.method~="HEAD" then
			console.log("method not allowed for static file: "..header.filename)
			httpreq.errorResponder(405, "Method Not Allowed", socket)
			collectgarbage()
			return true
		elseif header.method=="GET" and (not file.open(header.filename)) then
			console.log("failed to serve static file: "..header.filename)
			httpreq.errorResponder(500, "Internal Server Error", socket)
			collectgarbage()
			return true
		elseif header.method=="GET" then
			socket:on("sent", function(socket)
				local _, data = pcall(file.read, 128)
				if data then
					socket:send(data)
					console.debug("sending data: "..data,8)
				else
					console.log("served served static file: "..tostring(header.filename))
					file.close()
					socket:close()
				end
				data=nil
				collectgarbage()
			end)
		end
		socket:send(httpreq.assembleBasicHeader(200, "OK", getMimeType(header.ext), fslist[header.filename]).."\r\n")
		if header.method=="HEAD" then
			socket:close()
		end

		collectgarbage()
		return true
	end
	return false
end


table.insert(httpreq.responder,staticResponder)


return console.moduleLoaded(...)
