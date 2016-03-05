-- vim: ts=4 sw=4
--
-- assemble basic http header

return function(code, codeMsg, contentType, length, additionalHeaders)
	local header="HTTP/1.1 "..tostring(code).." "..tostring(codeMsg).."\r\n"
	header=header.."Server: NodeMCU simple httpserver (v0.1.0)\r\n"
	if type(contentType)=="string" then
		header=header.."Content-Type: "..tostring(contentType).."\r\n"
	end
	if type(length)=="number" then
		header=header.."Content-Length: "..tostring(length).."\r\n"
	end
	header=header.."Cache-Control: no-cache\r\n"
	header=header.."Connection: close\r\n"
	if additionalHeaders and type(additionalHeaders)=="string" then
		header = header..additionalHeaders
	end
	return header
end
