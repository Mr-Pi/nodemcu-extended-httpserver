-- vim: ts=4 sw=4
--
-- firmware updater script

require "console"

return function(payload, header, handler, socket)
	if handler.package==1 then
		file.remove("http-init/fwupdate.fw.txt")
		console.debug("applying fwupdate")
	end
	file.open("http-init/fwupdate.fw.txt","a+")
	file.write(payload)
	file.close()
	payload=nil
	collectgarbage()
	if handler.bytesReceived>=header.contentLength then
		console.debug("last fw package received")
		local data = "{\"fwupdate\":\"failed\"}"
		file.remove("http-init/fwupdate.fw")
		if file.rename("http-init/fwupdate.fw.txt", "http-init/fwupdate.fw") then
			if pcall(function() dofile("httpserver/applyUpdate.lc") end) then
				data="{\"fwupdate\":\"success\"}"
			end
		end
		local data = httpreq.assembleSimplePackage(200, "OK", "application/json; charset=UTF-8", data)
		httpreq.sendFinal(socket, data)
		data=nil
		collectgarbage()
	end
	return true
end
