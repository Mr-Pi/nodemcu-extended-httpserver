-- vim: sw=4 ts=4
--
-- http module builder

require "console"


function compileAll()
	for name, size in pairs(file.list()) do
		if name:find("\.lua$") and not name:find("^init.lua$") then
			console.log("compile: "..name)
			node.compile(name)
			file.remove(name)
		end
	end
	name=nil size=nil
	collectgarbage()
end
compileAll()


return console.moduleLoaded(...)
