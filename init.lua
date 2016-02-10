require "console"

console.log("nodemcu heap: "..tostring(node.heap()))
tmr.register(0, 1000, tmr.ALARM_SINGLE, function()
	console.log("initial start")
	server=require "httpserver/server"
end)
tmr.start(0)
