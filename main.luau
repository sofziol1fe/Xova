local _ENV = (getgenv or getrenv or getfenv)()

local fetcher, urls = {}, {}
local ALREADY_LOADED = _ENV.ALREADY_LOADED
local REQUIRE = _ENV.require
local HASH_FILE = "872b589351d1b30c6ec9701fc6b92b29ac86663cc9fa6c4cfe3ffafa14e7d68d"
local GAME_ID = 994732206

do
	if ALREADY_LOADED or game.GameId ~= GAME_ID then
		return nil
	end

	_ENV.ALREADY_LOADED = true
end

do
	urls.Owner = "https://raw.githubusercontent.com/sofziol1fe/"
	urls.Repository = urls.Owner .. "Xova/main/"
	urls.Public = urls.Repository .. "Public/"
	urls.JNK = "https://api.jnkie.com/api/v1/luascripts/public/"

	function fetcher:LOADK(path)
		local resolved_path = path:gsub("{(%w+)}", function(key)
			return urls[key] or ("{" .. key .. "}")
		end)

		resolved_path = resolved_path:gsub("^%.%./", "")

		return loadstring(game:HttpGet(resolved_path))()
	end
end

_ENV.require = function(path)
	if not path then return nil end

	if typeof(path) ~= 'string' then
		return REQUIRE(path)
	end

	return fetcher:LOADK(path)
end

return require(`../{"{JNK}"}{HASH_FILE}/download`)(fetcher, ...)
