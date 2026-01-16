local _ENV = (getgenv or getrenv or getfenv)()

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local VirtualUser = game:GetService('VirtualUser')
local TeleportService = game:GetService('TeleportService')

local Module = {}
local Forces = {}

local Configuration = {}
local Connections = _ENV.Connections or {} do
	_ENV.Connections = Connections

	for i = 1, #Connections do
		Connections[i]:Disconnect()
	end

	table.clear(Connections)
end

Module.Thread = (function()
	local Thread = {}
	
	local function ShowErrorMessage(ErrorMessage)
		_ENV.ISLOADED = false
		_ENV.OnFarm = false

		local text = (`error [ { _ENV.RunningOption or "Null" } ] { ErrorMessage }`)

		if _ENV.error_message then
			_ENV.error_message.Text ..= `\n\n{ text }`
			
			return nil
		end

		local Message = Instance.new("Message", workspace) do
			_ENV.error_message = Message
			Message.Text = text
		end
	end

	function Thread.RunQueue(Options)
		local Success, ErrorMessage = pcall(function()
			local function GetQueue()
				for _, Option in Options do
					_ENV.RunningOption = Option.Name
					
					local Method = Option.Function()

					if Method then
						if type(Method) == "string" then
							_ENV.RunningMethod = Method
						end
						
						return Method
					end
				end

				_ENV.RunningOption, _ENV.RunningMethod = nil, nil
			end

			while task.wait(0) do
				_ENV.OnFarm = if GetQueue() then true else false
			end
		end)

		ShowErrorMessage(ErrorMessage)
	end

	return Thread
end)()

Module.Configs = (function()
	local Configs = {
		folder = "Xova",
		Data = {}
	}

	local function build()
		local paths = {
			Configs.folder,
			Configs.folder .. "/settings"
		}

		for i = 1, #paths do
			local str = paths[i]

			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	local fullPath = Configs.folder .. "/settings/" .. game.PlaceId .. ".json"

	function Configs:def(index, value)
		if Configuration[index] == nil then
			Configuration[index] = value
		end
	end

	function Configs:save(index, value)
		if index ~= nil then
			Configuration[index] = value
		end

		if not isfolder(Configs.folder) then
			makefolder(Configs.folder)
		end

		if not isfolder(Configs.folder .. "/settings") then
			makefolder(Configs.folder .. "/settings")
		end

		writefile(fullPath, HttpService:JSONEncode(Configuration))
	end

	function Configs:load()
		if not isfile(fullPath) then
			Configs:save()
		end

		return HttpService:JSONDecode(readfile(fullPath))
	end

	function Configs:path()
		return fullPath
	end

	do
		build()
		Configs:def('Initialized', true)
	end

	return Configs
end)()

Module.Importer = (function()
	local Importer, urls = {}, {}
	
	urls.Owner = "https://raw.githubusercontent.com/sofziol1fe/"
	urls.Repository = urls.Owner .. "Scripts/refs/heads/main/"
	urls.Utils = urls.Repository .. "Utils/"
	
	local function CreateMessageError(Text)
		_ENV.ISLOADED = nil
		_ENV.OnFarm = false

		local Message = Instance.new("Message", workspace)
		Message.Text = string.gsub(Text, urls.Owner, "")
		_ENV.error_message = Message

		error(Text, 2)
	end
	
	local function formatUrl(Url)
		for key, path in urls do
			if Url:find("{" .. key .. "}") then
				return Url:gsub("{" .. key .. "}", path)
			end
		end

		return Url
	end

	function Importer.get(Url)
		local success, response = pcall(function()
			return game:HttpGet(formatUrl(Url))
		end)

		if success then
			return response
		else
			CreateMessageError(`[1] [{ identifyexecutor() }] failed to get http/url/raw: { Url }\n>>{ response }<<`)
		end
	end

	function Importer.load(Url, concat)
		local raw = Importer.get(Url) .. (if concat then concat else "")
		local runFunction, errorText = loadstring(raw)

		if type(runFunction) ~= "function" then
			CreateMessageError(`[2] [{ identifyexecutor() }] sintax error: { Url }\n>>{ errorText }<<`)
		else
			return runFunction
		end
	end
	
	return Importer
end)()

Module.TweenCreator = function()
	local TweenCreator = {}
	TweenCreator.__index = TweenCreator

	local tweens = {}
	local EasingStyle = Enum.EasingStyle.Linear

	function TweenCreator.new(obj, time, prop, value)
		local self = setmetatable({}, TweenCreator)

		self.tween = TweenService:Create(obj, TweenInfo.new(time, EasingStyle), { [prop] = value })
		self.tween:Play()
		self.value = value
		self.object = obj

		if tweens[obj] then
			tweens[obj]:destroy()
		end

		tweens[obj] = self
		return self
	end

	function TweenCreator:destroy()
		self.tween:Pause()
		self.tween:Destroy()

		tweens[self.object] = nil
		setmetatable(self, nil)
	end

	function TweenCreator:stopTween(obj)
		if obj and tweens[obj] then
			tweens[obj]:destroy()
		end
	end

	return TweenCreator
end

Module.Plugins = function(EnabledOptions, Options, Window)
	local Plugins = {}

	function Plugins:Tabs(Settings)
		return Window:Tabs({
			Title = Settings[1],
			Desc = Settings[2],
			Icon = Settings[3]
		})
	end

	function Plugins:Section(Tabs, Title)
		return Tabs:Section({ Title = Title })
	end

	function Plugins:Button(Section, Title, Callback)
		return Section:Button({
			Title = Title,
			Callback = Callback,
		})
	end

	function Plugins:Toggle(Section, Settings, Flag, Force, Callback)
		do
			if Force and not Forces[Flag] then
				table.insert(Forces, Flag)
			end
		end
		
		Options[Flag] = Section:Toggle({
			Title = Settings[1],
			Desc = Settings[2] or nil,
			Value = Configuration[Flag] or false,
			Callback = function(Value)
				Configuration[Flag] = Value
				EnabledOptions[Flag] = Value
				Module['Configs']:save(Flag, Value)

				if Callback then
					Callback(Value)
				end
			end,
		})
	end

	function Plugins:Slider(Section, Settings, Flag, Callback)
		return Section:Slider({
			Title = Settings[1],
			Min = Settings[2],
			Max = Settings[3],
			Rounding = Settings[4],
			Value = Configuration[Flag],
			Callback = function(Value)
				Configuration[Flag] = Value
				Module['Configs']:save(Flag, Value)

				if Callback then
					Callback(Value)
				end
			end,
		})
	end
	
	function Plugins:Textbox(Section, Flag, Callback)
		return Section:Textbox({
			Text = tostring(Configuration[Flag]),
			Callback = function(Value)
				Configuration[Flag] = Value
				Module['Configs']:save(Flag, Value)

				if Callback then
					Callback(Value)
				end
			end,
		})
	end
	
	function Plugins:Dropdown(Section, Title, List, Flag, Callback)
		return Section:List({
			Title = Title,
			List = List,
			Value = Configuration[Flag],
			Multi = typeof(Configuration[Flag]) == 'table' and true or false,
			Callback = function(Value)
				Configuration[Flag] = Value
				Module['Configs']:save(Flag, Value)

				if Callback then
					Callback(Value)
				end
			end,
		})
	end

	return Plugins
end

Configuration = Module['Configs']:load()

local Options = {}
local clonedEnabled = {}
local Functions = _ENV.FUNCTIONS or {}
local FarmFunctions = _ENV.FARM_FUNCTIONS or {}

local Enabled_Toggle_Debounce = false
local Enabled_New_Values = {}

local Library = Module.Importer.load("{Repository}Library/Initialized.luau")()

local function UpdateEnabledOptions()
	table.clear(FarmFunctions)

	for index, value in pairs(Enabled_New_Values) do
		clonedEnabled[index] = value or nil
		Enabled_New_Values[index] = nil
	end

	for i = 1, #Functions do
		local funcData = Functions[i]
		if clonedEnabled[funcData.Name] then
			table.insert(FarmFunctions, funcData)
		end
	end
end

local Enabled = _ENV.ENABLED_OPTIONS or setmetatable({}, {
	__newindex = function(self, index, value)
		Enabled_New_Values[index] = value or false

		if not Enabled_Toggle_Debounce then
			Enabled_Toggle_Debounce = false
			task.spawn(UpdateEnabledOptions)
		end
	end,
	__index = clonedEnabled
})

_ENV.FUNCTIONS = Functions
_ENV.ENABLED_OPTIONS = Enabled
_ENV.FARM_FUNCTIONS = FarmFunctions

if not _ENV.ISLOADED then
	_ENV.ISLOADED = true
	task.spawn(Module.Thread.RunQueue, FarmFunctions)
end

do
	table.clear(Functions)

	local index = {}

	local function NewOptionQueue(Tag, Function, Confirm)
		if Confirm ~= false then
			local Data = { ["Name"] = Tag, ["Function"] = Function }

			index[ Tag ] = Function
			table.insert(Functions, Data)
		end
	end
	
	local function fontcolors(text, color)
		if type(text) == "string" and typeof(color) == "Color3" then
			local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)

			return string.format('<font color="rgb(%d, %d, %d)">%s</font>', r, g, b, text)
		end

		return text
	end
	
	local function AddConnection(signal, callback)
		table.insert(Connections, signal:Connect(callback))
	end
	
	local function AddManager(Plugins)
		local Manager = Plugins:Tabs({ "Miscillinouse", "Performance, Server, Configs", 125928820284709})
		
		local Performance = Plugins:Section(Manager, "Performance") do
			Plugins:Toggle(Performance, { "3d Rendering [ White Screen ]", "Disables 3D rendering by applying a white overlay, improving performance on low-load mode."}, 'White Screen', nil, function(value)
				RunService:Set3dRenderingEnabled(if value then false else true)
			end)
			
			Plugins:Button(Performance, "Low Graphic Quality", function()
				local Terrain = workspace:FindFirstChildOfClass('Terrain') do
					Terrain.WaterWaveSize = 0
					Terrain.WaterWaveSpeed = 0
					Terrain.WaterReflectance = 0
					Terrain.WaterTransparency = 0
					game.Lighting.GlobalShadows = false
					game.Lighting.FogEnd = 9e9
					settings().Rendering.QualityLevel = 1
				end
			end)
		end
		
		local Server = Plugins:Section(Manager, "Server") do
			Module.Configs:def('JobId', game.JobId)
			
			Module.Server = (function()
				local server = {}

				function server:Reversed(cursor)
					local url = `https://games.roblox.com/v1/games/{game.PlaceId}/servers/Public?sortOrder=Asc&limit=100`

					if cursor then
						url ..= `&cursor={cursor}`
					end

					return HttpService:JSONDecode(game:HttpGet(url))
				end

				function server:Rejoin()
					if #Players:GetPlayers() <= 1 then
						Players.LocalPlayer:Kick("\nRejoining")
						wait()

						return TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
					end

					return TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
				end

				function server:Changed()
					local Server, Next

					return (function(a)
						repeat
							local Servers = server:Reversed(a)

							Server = Servers and Servers.data and Servers.data[1]
							Next = Servers and Servers.nextPageCursor
						until Server

						if not Server or not Server.id then return end
						return TeleportService:TeleportToPlaceInstance(game.PlaceId, Server.id, Players.LocalPlayer)
					end)(Next)
				end

				function server:Join(id)
					return TeleportService:TeleportToPlaceInstance(game.PlaceId, id, Players.LocalPlayer)
				end

				return server
			end)()
			
			Plugins:Textbox(Server, 'JobId')

			Plugins:Button(Server, "Join", function()
				Module.Server:Join(Configuration['JobId'])
			end)

			Plugins:Button(Server, "Rejoin", function()
				Module.Server:Rejoin()
			end)

			Plugins:Button(Server, "Change Server", function()
				Module.Server:Changed()
			end)
		end
	end
	
	do
		Module.NewOptionQueue = NewOptionQueue
		Module.Configuration = Configuration
		Module.AddConnect = AddConnection
		Module.AddManager = AddManager 
		Module.Colors = fontcolors
		Module.Forces = Forces
		Module.XOVA = { Enabled, Options }
	end
	
	AddConnection(Players.LocalPlayer.Idled, function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end

return Module
