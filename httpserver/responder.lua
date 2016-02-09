-- vim: ts=4 sw=4
--
--

require "console"


if not httpreq then httpreq={} end
if not httpreq.responder then httpreq.responder={} end


require "httpserver/static"


return console.moduleLoaded(...)
