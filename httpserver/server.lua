-- vim: ts=4 sw=4
--
-- httpserver main module

require "console"
require "config"
Handler=require "httpserver/handler"

local cb={}
local server

function cb.start()
	console.log("starting httpserver")
	server=net.createServer(net.TCP, 30)
	server:listen(config.get("http.port"), function(socket)
		local handler=Handler(socket)
	end)
end

function cb.stop()
	server:close()
end


local function loaded(args)
	console.moduleLoaded(args)
	return cb
end
return loaded(...)
