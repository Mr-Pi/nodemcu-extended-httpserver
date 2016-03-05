-- vim: ts=4 sw=4
--
-- httpserver main module

require "console"
require "config"
Handler = require "httpserver/handler"

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

function cb.startSafemode()
	console.log("switching to safemode")
	if not config.loaded then config.loaded={} end
	config.loaded.http = {port=80, prefix="http-init"}
	tmr.register(0, config.get("safemode.timeout"), tmr.ALARM_SINGLE, function()
		console.log("switching back to normal serve mode")
		config.load()
		if not config.get("http.enabled") then cb.stop() end
	end)
	tmr.start(0)
end

httpreq.updateResponders()
if config.get("safemode.enabled") or config.get("http.enabled") then
	cb.start()
end
if config.get("safemode.enabled") then
	cb.startSafemode()
end

local function loaded(args)
	console.moduleLoaded(args)
	return cb
end
return loaded(...)
