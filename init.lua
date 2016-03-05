require "console"

dofile("httpserver/compile.lua")

console.log("nodemcu heap: "..tostring(node.heap()))
tmr.register(0, 1000, tmr.ALARM_SINGLE, function() --timer is required to leave the nodemcu-firmare some time to free the ram
	console.log("initial start")
	server=require "httpserver/server"
end)
tmr.start(0)
