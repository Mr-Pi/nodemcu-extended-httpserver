-- vim: ts=4 sw=4
require "misclib"

config={}
local loadedCfg={
	http={port=80,prefix="http"}
}


function config.getPort()
	return loadedCfg.http.port
end

function config.getPrefix()
	return loadedCfg.http.prefix
end


console.moduleLoaded("config")
