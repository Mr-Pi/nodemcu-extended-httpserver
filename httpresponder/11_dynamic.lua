-- vim: ts=4 sw=4
--
--

require "console"


local function serverError(message, socket)
	console.log(message)
	httpreq.errorResponder(500, "Internal Server Error", socket)
	collectgarbage()
	return true
end

local function dynamicResponder(header, socket, handler)
	console.log("dynamicResponder executed")
	local fslist = file.list()
	if not fslist[header.filename] or (header.ext~="lua" and header.ext~="lc") then
		fslist = nil
		collectgarbage()
		return false
	end
	fslist = nil

	if not pcall(function() dofile(header.filename)(handler.payload, header, handler, socket) end) then
		handler.payload=nil collectgarbage()
		return serverError("failed to proceed: "..header.filename, socket)
	end
	okay=nil methodAllowed=nil methodsAllowed=nil handler.payload=nil
	collectgarbage()
	return true
end


return dynamicResponder
