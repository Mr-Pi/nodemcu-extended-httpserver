-- vim: ts=4 sw=4
--
-- http error responder

require "console"

return function(header, socket, handler)
	console.log("errorResponder 404 for: "..header.uri)
	httpreq.errorResponder(404," Not Found", socket)
	return true
end
