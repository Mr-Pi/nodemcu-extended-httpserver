-- vim: sw=4 ts=4
--
-- module builder

require "console"

if file.open("http-init/fwupdate.fw", "r") then
	console.log("applying firmware update")
	local line = file.readline()
	local filename = nil
	local decoder = dofile("base64.lc").decode
	while line~=nil do
		local offset = file.seek()
		file.close()
		if line:match("^filename=") then
			filename = line:match("^filename=([^\n\r]+)")
			file.remove(filename)
			console.log("updating: "..tostring(filename))
		elseif line:match("^[%w=+/]+") and filename then
			line = line:match("^[%w=+/]+")
			file.open(filename, "a+")
			file.write(decoder(line))
			file.close()
		end
		file.open("http-init/fwupdate.fw", "r")
		file.seek("set", offset)
		line = file.readline()
	end
	dofile("httpserver/compile.lua")
	file.remove("http-init/fwupdate.fw")
	console.log("firmware updated")
	line=nil filename=nil decoder=nil
	collectgarbage()
end

return nil
