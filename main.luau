local _ENV = (getgenv or getrenv or getfenv)()

local fetcher, urls = {}, {}
local ALREADY_LOADED = _ENV.ALREADY_LOADED
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

	function fetcher.load(path)
		local resolved_path = path:gsub("{(%w+)}", function(key)
			return urls[key] or ("{" .. key .. "}")
		end)

		resolved_path = resolved_path:gsub("^%.%./", "")

		return loadstring(game:HttpGet(resolved_path))
	end
end

return fetcher.load(`../{"{JNK}"}{HASH_FILE}/download`)(fetcher, ...)
