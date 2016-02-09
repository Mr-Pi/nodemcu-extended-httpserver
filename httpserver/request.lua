-- vim: ts=4 sw=4
--
--

require "console"


if not httpreq then httpreq={} end


local function decodeURI(str)
	str=str:gsub('%+', " ")
	str=str:gsub('%%(%x%x)', function(hex) return string.char(tonumber(hex,16)) end)
	return str
end

function httpreq.assembleBasicHeader(code, codeMsg, contentType, length)
	local header="HTTP/1.1 "..tostring(code).." "..tostring(codeMsg).."\r\n"
	header=header.."Server: NodeMCU simple httpserver (v0.1.0)\r\n"
	header=header.."Content-Type: "..tostring(contentType).."\r\n"
	header=header.."Content-Length: "..tostring(length).."\r\n"
	header=header.."Cache-Control: no-cache\r\n"
	header=header.."Connection: close\r\n"
	return header
end

function httpreq.assembleSimplePackage(code, codeMsg, contentType, body)
	local package=httpreq.assembleBasicHeader(code, codeMsg, contentType, #tostring(body))
	package=package.."\r\n"..tostring(body)
	collectgarbage()
	return package
end

local defaultExt = {"html","txt","lua","lc"}
function httpreq.parseURI(uri)
	local args = {}
	local fslist = file.list()
	local filename = uri:gsub("^([^?$]+)[?]*(.*)$","%1")
	local argsStr = uri:gsub("^([^?$]+)[?]*(.*)$","%2")
	filename = config.get("http.prefix")..filename:gsub("/$","/index")
	local _, _, ext = filename:find("[\.]+([^\.\/]+)$")

	if not ext then
		for _, cExt in ipairs(defaultExt) do
			if fslist[filename.."."..cExt] then
				ext=cExt
				filename = filename.."."..cExt
				break
			end
		end
	end

	console.debug("http request filename: "..tostring(filename),6)
	console.debug("http request argument string: "..tostring(argsStr),7)

	for key,value in argsStr:gmatch("([^=&]+)=([^=&]+)") do
		key=decodeURI(key)
		value=decodeURI(value)
		console.debug("parsed uri argument '"..tostring(key).."'='"..tostring(value).."'",6)
	end

	argsStr=nil fslist=nil uri=nil
	collectgarbage()
	return filename, args, ext
end

function httpreq.parseHeader(payload)
	console.debug("trying to parse header from payload: "..tostring(payload),10)
	if not payload:find("\r\n\r\n",1,true) then --do a plain search
		console.debug("http header is incomplete")
		collectgarbage()
		return false, payload
	end
	console.debug("http header complete")
	local hEnd, bStart = payload:find("\r\n\r\n",1,true)
	local headerStr = payload:sub(1,hEnd) --get the whole header as string
	local bodyStr   = payload:sub(bStart+1) --the remaining part is the body
	local header = {opts={},args={}}
	header.method  = headerStr:gsub("^([A-Z]+) (.-) (HTTP[^ \r\n]+).*","%1",1) --regex: 1: method, 2: uri, 3: version
	header.uri     = headerStr:gsub("^([A-Z]+) (.-) (HTTP[^ \r\n]+).*","%2",1)
	header.version = headerStr:gsub("^([A-Z]+) (.-) (HTTP[^ \r\n]+).*","%3",1)

	console.debug("http request method is: "..tostring(header.method),6)
	console.debug("http request uri is: "..tostring(header.uri),6)
	console.debug("http request http version is: "..tostring(header.version),6)

	for key,value in headerStr:gmatch("([^:\r\n]+): ([^:\r\n]+)") do --parse all HTTP header options
		header.opts[key]=value
		console.debug("parsed header option '"..tostring(key).."'='"..tostring(value).."'",6)
	end
	if header.opts["Content-Length"] then
		header.contentLength=tonumber(header.opts["Content-Length"])
	end
	header.filename, header.args, header.ext = httpreq.parseURI(header.uri)
	headerStr=nil hEnd=nil bStart=nil payload=nil
	collectgarbage()
	return header, bodyStr
end


return console.moduleLoaded(...)
