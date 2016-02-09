-- vim: ts=4 sw=4
require "misclib"
require "handler"
require "config"

local cb={}
local server


console.log("starting httpserver")
server=net.createServer(net.TCP, 30)
server:listen(config.getPort(), function(socket)
	local handler=Handler(socket)
end)


console.moduleLoaded("server")
return cb
