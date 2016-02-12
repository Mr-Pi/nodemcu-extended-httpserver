-- vim: ts=4 sw=4
--
--

require "console"


if not httpreq then httpreq={} end
if not httpreq.responder then httpreq.responder={} end


local dynamicResponder={}
local serveredExts={html="text/html",css="text/css",js="text/javascript",txt="text/plain"}
local function getMimeType(ext)
	return serveredExts[ext] or "application/octet-stream"
end

function dynamicResponder.respond(header, socket, handler)
	console.log("dynamicResponder executed")
	local fslist = file.list()
	if not fslist[header.filename] or (header.ext~="lua" and header.ext~="lc") then
		fslist=nil
		collectgarbage()
		return false
	end
	handler.dynamicResponder = require header.filename:match("(.*)[\.]+[^\.\/]+$")
	fslist=nil
	collectgarbage()
	return false
end


table.insert(httpreq.responder,dynamicResponder)


return console.moduleLoaded(...)
