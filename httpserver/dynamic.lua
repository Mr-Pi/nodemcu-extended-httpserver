-- vim: ts=4 sw=4
--
--

require "console"


if not httpreq then httpreq={} end
if not httpreq.responder then httpreq.responder={} end


local dynamicResponder={}

function dynamicResponder.respond(header, socket, handler)
	console.log("dynamicResponder executed")
	local fslist = file.list()
	if not fslist[header.filename] or (header.ext~="lua" and header.ext~="lc") then
		fslist=nil
		collectgarbage()
		return false
	end
	local okay
	okay, handler.dynamicResponder = pcall(require, header.filename:match("(.*)[\.][^\.\/]+$"))
	if not okay then
		console.log("failed to load dynamicResponder: "..header.filename)
		httpreq.errorResponder(500, "Internal Server Error", socket)
		collectgarbage()
		return true
	end
	fslist=nil
	collectgarbage()
	return false
end


table.insert(httpreq.responder, dynamicResponder)


return console.moduleLoaded(...)
