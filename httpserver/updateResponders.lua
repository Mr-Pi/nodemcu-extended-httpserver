-- vim: ts=4 sw=4
--
-- collects all http responder and add them

require "console"


if not httpreq then httpreq={} end
if not httpreq.responder then
	httpreq.responder = {}
	local fslist = file.list()
	table.foreach(fslist, function(name, size)
		if name:match("^httpresponder/") then
			table.insert(httpreq.responder, name)
		end
	end)
	fslist = nil
	table.sort(httpreq.responder)
	collectgarbage()
end

return nil
