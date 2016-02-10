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
	local ipap = tostring( wifi.ap.getip() or "")
	local ipsta= tostring(wifi.sta.getip() or "")
	console.log("httpserver is listing at: "..
	ipap..(ipap~="" and ipsta~="" and " and " or "")..ipsta)
	ipap=nil ipsta=nil
	collectgarbage()
end

function cb.stop()
	console.log("stopping httpserver")
	server:close()
	server=nil
	collectgarbage()
end


local function loaded(args)
	console.moduleLoaded(args)
	return cb
end
return loaded(...)
