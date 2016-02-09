-- vim: ts=4 sw=4
--
-- NodeMCU configuration

require "console"

config={}

local function loadCfg(filename)
	console.log("loading configuration "..filename)
	if not file.open(filename) then
		console.log("failed to open configuration "..filename)
		return nil
	end
	local cfg={}
	if not pcall(function() cfg=cjson.decode(file.read()) end) then
		console.log("failed to parse configuration "..filename)
		cfg=nil
		file.close()
		collectgarbage()
		return nil
	end
	file.close()
	collectgarbage()
	return cfg
end

config.default=loadCfg("config.default.json")
config.loaded=loadCfg("config.json")

function config.get(part)
	local result={}
	console.debug("loading configuration part: "..part, 6)
	if part then
		part="."..tostring(part)
	else
		part=""
	end
	if pcall(function() result=loadstring("return config.loaded"..part)() end) then
		part=nil
		collectgarbage()
		return result
	end
	if pcall(function() result=loadstring("return config.default"..part)() end) then
		part=nil
		collectgarbage()
		return result
	end
	part=nil result=nil
	collectgarbage()
	return result
end


return console.moduleLoaded(...)
