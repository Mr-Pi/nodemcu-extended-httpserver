-- vim: sw=4 ts=4
--
-- module builder

require "console"

local exclude={}
exclude["init.lua"] = true
exclude["httpserver/compile.lua"] = true

for name, size in pairs(file.list()) do
	if name:find("\.lua$") and not exclude[name] then
		console.log("compile: "..name)
		node.compile(name)
		file.remove(name)
	end
end
name=nil size=nil exclude=nil

collectgarbage()

return nil
