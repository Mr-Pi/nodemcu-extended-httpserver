-- vim: ts=4 sw=4
--
-- console

console={}

local consoleCfg={
	level=5,
	default=5
}

function console.log(message)
	print("*** "..tostring(message))
	message=nil
	collectgarbage()
end

function console.debug(message,level)
	if (level and consoleCfg.level>=level) or (not level and consoleCfg.level>=consoleCfg.default) then
		print("DEBUG: "..tostring(message).." heap("..tostring(node.heap())..")")
	end
	message=nil level=nil
	collectgarbage()
end

function console.moduleLoaded(module)
	print("*** module loaded: "..tostring(module))
end

function console.setDebugLevel(level)
	consoleCfg.level=tonumber(level)
	level=nil
	collectgarbage()
end


return console.moduleLoaded(...)
