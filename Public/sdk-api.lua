local _ENV = (getgenv or getrenv or getfenv)()

local Module, Utils = ...
local Configuration = Utils.Configuration
local AddConnect = Utils.AddConnect

local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService('UserInputService')
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService('Lighting')
local Players = game:GetService("Players")

local ChestModels = workspace:WaitForChild("ChestModels")
local WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Characters = workspace:WaitForChild("Characters")
local SeaBeasts = workspace:WaitForChild("SeaBeasts")
local Enemies = workspace:WaitForChild("Enemies")
local Boats = workspace:WaitForChild("Boats")
local Map = workspace:WaitForChild("Map")

local NPCs = workspace:WaitForChild('NPCs')
local ReplicatedNPCs = ReplicatedStorage:WaitForChild('NPCs')

local EnemySpawns = WorldOrigin:WaitForChild("EnemySpawns")
local Locations = WorldOrigin:WaitForChild("Locations")

local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat
local Stepped = RunService.Stepped
local LocalPlayer = Players.LocalPlayer

local Data = LocalPlayer:WaitForChild("Data")
local Level = Data:WaitForChild("Level")
local Fragments= Data:WaitForChild("Fragments")
local Money = Data:WaitForChild("Beli")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local SubmarineWorkerSpeak = Net:WaitForChild('RF/SubmarineWorkerSpeak')

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF = Remotes:WaitForChild("CommF_")
local CommE = Remotes:WaitForChild("CommE")

local BRING_TAG = _ENV._Bring_Tag or tostring(math.random(80, 2e4))
local KILLAURA_TAG = _ENV._KillAura_Tag or tostring(math.random(120, 2e4))

_ENV._Bring_Tag = BRING_TAG
_ENV._KillAura_Tag = KILLAURA_TAG

local function GetEnemyName(strings)
	return (strings:find("Lv. ") and strings:gsub(" %pLv. %d+%p", "") or strings):gsub(" %pBoss%p", "")
end

local function CreateDictionary(array, value)
	local Dictionary = {}

	for _, strings in ipairs(array) do
		Dictionary[strings] = type(value) == "table" and {} or value
	end

	return Dictionary
end

local function CheckData(filter, enemy)
	if filter == nil then
		return true
	end

	if type(filter) == "table" then
		return table.find(filter, enemy.Name) ~= nil
	end

	if type(filter) == "string" then
		return enemy.Name == filter
	end

	return false
end

local Cached = {
	Bring = {},
	Enemies = CreateDictionary({
		"__PirateRaid"
	}, {})
}

do
	Module.IsSuperBring = false
	Module.EnemyLocations = {}
	Module.SpawnLocations = {}
	Module.SeaName = { "Main", "Dressrosa", "Zou" }
end

do
	Module.RaidList = (function()
		local Success, RaidModule = pcall(require, ReplicatedStorage:WaitForChild("Raids"))

		if not Success or type(RaidModule) ~= "table" then
			return {
				"Phoenix", "Dough", "Flame", "Ice", "Quake", "Light";
				"Dark", "Spider", "Rumble", "Magma", "Buddha", "Sand";
			}
		end

		local AdvancedRaids = RaidModule.advancedRaids or {}
		local NormalRaids = RaidModule.raids or {}
		local RaidList = {}

		for i = 1, #AdvancedRaids do table.insert(RaidList, AdvancedRaids[i]) end
		for i = 1, #NormalRaids do table.insert(RaidList, NormalRaids[i]) end

		return RaidList
	end)()
	
	Module.Sea = (function()
		local Current = workspace:GetAttribute('MAP')

		if Current == 'Sea1' then
			return 1
		end

		if Current == 'Sea2' then
			return 2
		end

		if Current == 'Sea3' then
			return 3
		end

		if Current == 'Dungeons' then
			return 4
		end
	end)()
	
	Module.Boss = (function(Current)
		if Current == 1 then
			return {
				"The Gorilla King",
				"Chef",
				"Yeti",
				"Mob Leader",
				"Vice Admiral",
				"Warden",
				"Chief Warden",
				"Swan",
				"Magma Admiral",
				"Fishman Lord",
				"Wysper",
				"Thunder God",
				"Cyborg",
				"Saber Expert"
			}
		elseif Current == 2 then
			return {
				"Diamond",
				"Jeremy",
				"Orbitus",
				"Don Swan",
				"Smoke Admiral",
				"Cursed Captain",
				"Darkbeard",
				"Order",
				"Awakened Ice Admiral",
				"Tide Keeper"
			}
		elseif Current == 3 then
			return {
				"Stone",
				"Hydra Leader",
				"Kilo Admiral",
				"Captain Elephant",
				"Beautiful Pirate",
				"rip_indra True Form",
				"Longma",
				"Soul Reaper",
				"Cake Queen"
			}
		end

		return {}
	end)(Module.Sea)
	
	Module.Data = (function()
		local Data = {}

		Data['Island'] = {
			{
				['Pirate Starter'] = CFrame.new(1077, 16, 1439),
				['Marine Starter'] = CFrame.new(-2922, 41, 2111),
				['Jungle'] = CFrame.new(-1439, 62, 8),
				['Colosseum'] = CFrame.new(-1664, 151, -3245),
				['Frozen Village'] = CFrame.new(1221, 138, -1487),
				['Desert'] = CFrame.new(1058, 52, 4491),
				['Fountain City'] = CFrame.new(5269, 56, 4061),
				['Marine Fortress'] = CFrame.new(-5094, 263, 4414),
				['Middle Town'] = CFrame.new(-849, 74, 1625),
				['Pirate Village'] = CFrame.new(-1151, 65, 4160),
				['Underwater City'] = CFrame.new(61318, 19, 1525),
				['Whirlpool'] = CFrame.new(4344, 21, -1883),
				['Prison'] = CFrame.new(5316, 89, 699),
				['Lower Skyland'] = CFrame.new(-5050, 278, -2732),
				['Middle Skyland'] = CFrame.new(-4654, 873, -1762),
				['Upper Skyland'] = CFrame.new(-7654, 5623, -1071)
			},
			{
				['Kingdom of Rose'] = CFrame.new(-385, 319, 463),
				['Green Zone'] = CFrame.new(-2435, 73, -3250),
				['Hot and Cold'] = CFrame.new(-5507, 82, -5165),
				['Cursed Ship'] = CFrame.new(916, 126, 33073),
				['Snow Mountain'] = CFrame.new(1008, 446, -4906),
				['Ice Castle'] = CFrame.new(6146, 484, -6729),
				['Dark Arena'] = CFrame.new(3892, 14, -3616),
				['Graveyard Island'] = CFrame.new(-5722, 9, -963),
				['Forgotten Island'] = CFrame.new(-3026, 319, -10083),
				['North Pole'] = CFrame.new(-5397, 12, 1454),
			},
			{
				['Submerged Island'] = CFrame.new(9952, -1887, 9678),
				['Tiki Outpost'] = CFrame.new(9952, -1887, 9678),
				['Castle on the Sea'] = CFrame.new(-5086, 315, -2974),
				['Hydra Island'] = CFrame.new(5164, 1174, 222),
				['Peanut Island'] = CFrame.new(-2111, 193, -10243),
				['Ice Cream Island'] = CFrame.new(-801, 210, -10999),
				['Cake Loaf'] = CFrame.new(-1748, 489, -12360),
				['Chocolate Island'] = CFrame.new(256, 124, -12549),
				['North Pole'] = CFrame.new(-906, 89, -14666),
				['Port Town'] = CFrame.new(-390, 11, 5244),
				['Great Tree'] = CFrame.new(3295, 776, -6281),
				['Haunted Castle'] = CFrame.new(-9499, 500, 6009),
				['Floating Turtle'] = CFrame.new(-12310, 1163, -9968)
			},
			{}
		}

		local IslandString = {}

		do
			for name, _ in pairs(Data['Island'][Module.Sea]) do
				table.insert(IslandString, name)
			end
		end

		Module.IslandString = IslandString

		Data['Place'] = {
			{
				["Cyborg's Domain"] = CFrame.new(6271, 71, 4000),
				["Thunder God's Domain"] = CFrame.new(-7989, 5814, -2030),
				["Saber Expert's Domain"] = CFrame.new(-1425, 30, -14)
			},
			{
				['Cafe'] = CFrame.new(-377, 73, 290),
				['Basement Cafe'] = CFrame.new(-350, 16, 242),
				['Mansion'] = CFrame.new(-392, 374, 720),
				["Swan's Room"] = CFrame.new(2462, 15, 695),
				['Raid'] = CFrame.new(-6535, 310, -4745),
				['Labs'] = CFrame.new(-5548, 224, -5899),
				['Colosseum'] = CFrame.new(-1822, 46, 1411),
			},
			{
				["Beautiful Pirate's Domain"] = CFrame.new(5339, 22, -328),
				['Head Castle on the Sea'] = CFrame.new(-5421, 1090, -2666),
				['Mansion'] = CFrame.new(-12552, 337, -7504),
				['Dragon Dojo'] = CFrame.new(5701, 1207, 924),
				['Friendly Arena'] = CFrame.new(5012, 59, -1571),
				['Waterfall'] = CFrame.new(5174, 8, 1191),
				['Head of Great Tree'] = CFrame.new(3070, 2281, -7335)
			},
			{}
		}

		local PlaceString = {}

		do
			for name, _ in pairs(Data['Place'][Module.Sea]) do
				table.insert(PlaceString, name)
			end
		end

		Module.PlaceString = PlaceString

		Data['Material'] = {
			[1] = {
				["Magma Ore"]      = { "Military Soldier", "Military Spy" },
				["Leather"]        = { "Brute" },
				["Scrap Metal"]    = { "Brute" },
				["Angel Wings"]    = { "God's Guard" },
				["Fish Tail"]      = { "Fishman Warrior", "Fishman Commando" },
				["GunPowder"]      = { "Brute", "Pirate" }
			},
			[2] = {
				["Magma Ore"]              = { "Magma Ninja" },
				["Scrap Metal"]            = { "Swan Pirate" },
				["Radioactive Material"]   = { "Factory Staff" },
				["Vampire Fang"]           = { "Vampire" },
				["Mystic Droplet"]         = { "Water Fighter", "Sea Soldier" },
			},
			[3] = {
				["Mini Tusk"]      = { "Mythological Pirate" },
				["Fish Tail"]      = { "Fishman Raider", "Fishman Captain" },
				["Scrap Metal"]    = { "Jungle Pirate" },
				["Dragon Scale"]   = { "Dragon Crew Archer", "Dragon Crew Warrior" },
				["Conjured Cocoa"] = { "Cocoa Warrior", "Chocolate Bar Battler", "Sweet Thief", "Candy Rebel" },
				["Demonic Wisp"]   = { "Demonic Soul" },
				["Gunpowder"]      = { "Pistol Billionaire" }
			},
			[4] = {}
		}

		Data['Material List'] = (function(v)
			if v == 1 then
				return {
					"Magma Ore",
					"Leather",
					"Scrap Metal",
					"Angel Wings",
					"Fish Tail",
					'GunPowder'
				}
			end

			if v == 2 then
				return {
					"Magma Ore",
					"Scrap Metal",
					"Radioactive Material",
					"Vampire Fang",
					"Mystic Droplet",
				}
			end

			if v == 3 then
				return {
					"Mini Tusk",
					"Fish Tail",
					"Scrap Metal",
					"Dragon Scale",
					"Conjured Cocoa",
					"Demonic Wisp",
					"Gunpowder",
				}
			end

			return {}
		end)(Module.Sea)

		Data['Shop'] = {
			["Fighting Style"] = {
				["Buy Black Leg"] = { "BuyBlackLeg" },
				["Buy Electro"] = { "BuyElectro" },
				["Buy Fishman Karate"] = { "BuyFishmanKarate" },
				["Buy Dragon Claw"] = { "BlackbeardReward", "DragonClaw", "2" },
				["Buy Superhuman"] = { "BuySuperhuman" },
				["Buy Death Step"] = { "BuyDeathStep" },
				["Buy Sharkman Karate"] = { "BuySharkmanKarate" },
				["Buy Electric Claw"] = { "BuyElectricClaw" },
				["Buy Dragon Talon"] = { "BuyDragonTalon" },
				["Buy GodHuman"] = { "BuyGodhuman" },
				["Buy Sanguine Art"] = { "BuySanguineArt" },
				-- ["Buy Divine Art"] = { "BuyDivineArt" },
			},

			["Ability"] = {
				["Buy Geppo"] = { "BuyHaki", "Geppo" },
				["Buy Buso"] = { "BuyHaki", "Buso" },
				["Buy Soru"] = { "BuyHaki", "Soru" },
				["Buy Ken"] = { "KenTalk", "Buy" },
			},

			["Sword"] = {
				["Buy Katana"] = { "BuyItem", "Katana" },
				["Buy Cutlass"] = { "BuyItem", "Cutlass" },
				["Buy Dual Katana"] = { "BuyItem", "Dual Katana" },
				["Buy Iron Mace"] = { "BuyItem", "Iron Mace" },
				["Buy Triple Katana"] = { "BuyItem", "Triple Katana" },
				["Buy Pipe"] = { "BuyItem", "Pipe" },
				["Buy Dual-Headed Blade"] = { "BuyItem", "Dual-Headed Blade" },
				["Buy Soul Cane"] = { "BuyItem", "Soul Cane" },
				["Buy Bisento"] = { "BuyItem", "Bisento" },
			},

			["Gun"] = {
				["Buy Musket"] = { "BuyItem", "Musket" },
				["Buy Slingshot"] = { "BuyItem", "Slingshot" },
				["Buy Flintlock"] = { "BuyItem", "Flintlock" },
				["Buy Refined Slingshot"] = { "BuyItem", "Refined Slingshot" },
				["Buy Dual Flintlock"] = { "BuyItem", "Dual Flintlock" },
				["Buy Cannon"] = { "BuyItem", "Cannon" },
				["Buy Kabucha"] = { "BlackbeardReward", "Slingshot", "2" },
			},

			["Accessories"] = {
				["Buy Black Cape"] = { "BuyItem", "Black Cape" },
				["Buy Swordsman Hat"] = { "BuyItem", "Swordsman Hat" },
				["Buy Tomoe Ring"] = { "BuyItem", "Tomoe Ring" },
			},

			["Race"] = {
				["Ghoul Race"] = { "Ectoplasm", "Change", 4 },
				["Cyborg Race"] = { "CyborgTrainer", "Buy" },
			},
		}

		function Data:GetMaterail(a)
			return self['Material'][Module.Sea][a]
		end

		return Data
	end)()

	Module.EnemiesModule = (function()
		local EnemiesModule = {}
		
		local CacheEnemies = Cached.Enemies
		local SpawnLocations = Module.SpawnLocations
		local EnemyLocations = Module.EnemyLocations

		local SeaCastle = CFrame.new(-5556, 314, -2988)
		local Attachment = Instance.new("Attachment") do
			local AlignPosition = Instance.new("AlignPosition") do
				AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
				AlignPosition.Position = Vector3.new(0, 20, 0)
				AlignPosition.Responsiveness = 200
				AlignPosition.MaxForce = math.huge
				AlignPosition.Parent = Attachment
				AlignPosition.Attachment0 = Attachment
			end
		end

		local function New(list, NewEnemy)
			if table.find(list, NewEnemy) then return end

			local Humanoid = NewEnemy:WaitForChild("Humanoid")

			if Humanoid and Humanoid.Health > 0 then
				table.insert(list, NewEnemy)
				Humanoid.Died:Wait()

				local index = table.find(list, NewEnemy)
				if index then table.remove(list, index) end
			end
		end

		local function IsFromPiratesSea(Enemy)
			if not Enemy:WaitForChild("Humanoid") or Enemy.Humanoid.Health <= 0 then return end

			local HumanoidRootPart = Enemy:WaitForChild("HumanoidRootPart")

			if HumanoidRootPart and (Enemy.Name ~= "rip_indra True Form" and Enemy.Name ~= "Blank Buddy") then
				if (HumanoidRootPart.Position - SeaCastle.Position).Magnitude <= 750 then
					task.spawn(New, CacheEnemies.__PirateRaid, Enemy)
				end
			end
		end

		local function CreateNameTags(Enemy)
			return "__" .. tostring(Enemy)
		end

		local function NewEnemyAdded(Enemy)
			local EnemyName = Enemy.Name
			local Tags = CreateNameTags(Enemy)
			
			print(Tags, if CacheEnemies[Tags] then #CacheEnemies[Tags] else "N/A")
			
			if Module.Sea == 3 then
				task.spawn(IsFromPiratesSea, Enemy)
			end
			
			if CacheEnemies[Tags] then
				return task.spawn(New, CacheEnemies[Tags], Enemy)
			end
			
			CacheEnemies[Tags] = {}
			task.spawn(New, CacheEnemies[Tags], Enemy)
		end

		function EnemiesModule:GetTagged(Tags)
			return CacheEnemies[type(Tags) == "table" and "__" .. table.concat(Tags, "_") or "__" .. Tags]
		end

		function EnemiesModule:CalculateTags(Tags)
			return type(Tags) == "string" and { Tags } or Tags
		end

		function EnemiesModule:GetByTags(Tags)
			local TagList = self:CalculateTags(Tags)
			local Enemies = self:GetTagged(TagList)

			if not Enemies or #Enemies == 0 then
				return nil
			end

			for i = 1, #Enemies do
				local Enemy = Enemies[i]

				if Module:IsAlive(Enemy) then
					return Enemy
				end
			end

			return nil
		end

		function EnemiesModule:GetClosestByTags(Tags)
			local TagList = self:CalculateTags(Tags)
			local Enemies = self:GetTagged(TagList)

			if not Enemies or #Enemies == 0 then
				return nil
			end

			local Closest, Distance = nil, math.huge

			for i = 1, #Enemies do
				local Enemy = Enemies[i]

				if Module:IsAlive(Enemy) and Enemy.PrimaryPart then
					local Magnitude = LocalPlayer:DistanceFromCharacter(Enemy.PrimaryPart.Position)

					if Magnitude < Distance then
						Closest, Distance = Enemy, Magnitude
					end
				end
			end

			return Closest
		end
		
		function EnemiesModule:GetClosest(Max, EnemiesName)
			local Closest, Distance = nil, math.huge
			local EnemiesList = Enemies:GetChildren()

			for i = 1, #EnemiesList do
				local Enemy = EnemiesList[i]
				
				if not CheckData(EnemiesName, Enemy) then continue end
				if Enemy.Name == "Blank Buddy" then continue end
				if not Module:IsAlive(Enemy) then continue end
				if not Enemy.PrimaryPart then continue end

				local Magnitude = LocalPlayer:DistanceFromCharacter(Enemy.PrimaryPart.Position)

				if (not Max or Magnitude < Max) and Magnitude < Distance then
					Closest, Distance = Enemy, Magnitude
				end
			end

			return Closest
		end
		
		local function Bring(Enemy)
			local RootPart = Enemy:WaitForChild("HumanoidRootPart")
			local Humanoid = Enemy:WaitForChild("Humanoid")
			local EnemyName = Enemy.Name

			local CloneAttachment = Attachment:Clone()
			local AlignPosition = CloneAttachment.AlignPosition
			CloneAttachment.Parent = RootPart

			while Enemy and Enemy.Parent == Enemies and Enemy:HasTag(BRING_TAG) do
				if not Humanoid or Humanoid.Health <= 0 then break end
				if not RootPart or RootPart.Parent ~= Enemy then break end

				local Target = Cached.Bring[Module.IsSuperBring and "ALL_MOBS" or EnemyName]

				if Target and (Target.Position - RootPart.Position).Magnitude <= (Configuration["Bring Distance"] or 300) then
					if AlignPosition.Position ~= Target.Position then
						AlignPosition.Position = Target.Position
					end
				else
					break
				end;task.wait()
			end

			if Enemy and Enemy:HasTag(BRING_TAG) then Enemy:RemoveTag(BRING_TAG) end
			if CloneAttachment then CloneAttachment:Destroy() end
		end

		local function KillAura(Enemy)
			local Humanoid = Enemy:FindFirstChild("Humanoid")
			local RootPart = Enemy:FindFirstChild("HumanoidRootPart")

			pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)

			if Humanoid and RootPart then
				RootPart.CanCollide = false
				RootPart.Size = Vector3.new(60, 60, 60)
				Humanoid:ChangeState(15)
				Humanoid.Health = 0
				task.wait()
				Enemy:RemoveTag(KILLAURA_TAG)
			end
		end

		local function NewSpawn(Part)
			local EnemyName = GetEnemyName(Part.Name)
			EnemyLocations[EnemyName] = EnemyLocations[EnemyName] or {}
			
			local EnemySpawn = Part.CFrame + Vector3.new(0, 25, 0)
			SpawnLocations[EnemyName] = Part
			
			if not table.find(EnemyLocations[EnemyName], EnemySpawn) then
				table.insert(EnemyLocations[EnemyName], EnemySpawn)
			end
		end

		for _, Spawn in EnemySpawns:GetChildren() do NewSpawn(Spawn) end
		for _, Enemy in CollectionService:GetTagged("BasicMob") do NewEnemyAdded(Enemy) end
		
		AddConnect(CollectionService:GetInstanceAddedSignal("BasicMob"), NewEnemyAdded)
		AddConnect(CollectionService:GetInstanceAddedSignal(KILLAURA_TAG), KillAura)
		AddConnect(CollectionService:GetInstanceAddedSignal(BRING_TAG), Bring)
		AddConnect(EnemySpawns.ChildAdded, NewSpawn)
		
		return EnemiesModule
	end)()
	
	Module.RuntimeModule = (function()
		local RuntimeModule = {}
		
		function RuntimeModule:Chest()
			local Chests = CollectionService:GetTagged("_ChestTagged")
			local Distance, Nearest = math.huge, nil

			for i = 1, #Chests do
				local Chest = Chests[i]
				local Magnitude = LocalPlayer:DistanceFromCharacter(Chest:GetPivot().Position)
				
				if not Chest:GetAttribute("IsDisabled") and Magnitude < Distance then
					Distance, Nearest = Magnitude, Chest
				end
			end

			return Nearest
		end

		function RuntimeModule:Berry()
			local BerryBush = CollectionService:GetTagged("BerryBush")
			local Distance = math.huge
			local Nearest = nil

			for i = 1, #BerryBush do
				local Bush = BerryBush[i]

				for _, BerryName in pairs(Bush:GetAttributes()) do
					local BushPosition = Bush.Parent:GetPivot().Position
					local Magnitude = Module:Distance(BushPosition)

					if Magnitude < Distance then
						Nearest = Bush
						Distance = Magnitude
					end
				end
			end

			return Nearest
		end

		function RuntimeModule:Raid()
			for i = 5, 1, -1 do
				local Name = "Island " .. i

				for _, Island in ipairs(Locations:GetChildren()) do
					if Island.Name == Name and LocalPlayer:DistanceFromCharacter(Island.Position) < 3500 then
						return Island
					end
				end
			end
		end
		
		function RuntimeModule:GetLavaRocks(VolcanoRocks)
			local nearestRock = nil
			local shortestDistance = math.huge

			for _, v in pairs(VolcanoRocks:GetChildren()) do
				local LavaEffect = v:FindFirstChild("At1Beam", true)

				if LavaEffect and LavaEffect.Enabled and v:IsA("Model") then
					local distance = Module:Distance(v:GetPivot())

					if distance < shortestDistance then
						shortestDistance = distance
						nearestRock = v
					end
				end
			end

			return nearestRock
		end

		function RuntimeModule:GetExitDoor()
			local Dungeon = Map.Dungeon
			local LowNumber = nil
			local LowRoom = nil

			for _, v in pairs(Dungeon:GetChildren()) do
				local Number = tonumber(v.Name)

				if Number then
					if not LowNumber or Number < LowNumber then
						LowNumber = Number
						LowRoom = v
					end
				end
			end

			if LowNumber then
				local TargetNumber = LowNumber - 1
				local TargetRoom = Dungeon:FindFirstChild(tostring(TargetNumber))

				return TargetRoom, TargetNumber
			end

			return nil
		end

		function RuntimeModule:GetGift()
			for _, v in pairs(WorldOrigin:GetChildren()) do
				if v.Name == "Present" then
					local Name = v:FindFirstChild('Value', true)

					if tostring(Name.Value) == LocalPlayer.Name then
						return v
					end
				end
			end

			return nil
		end

		function RuntimeModule:ParseTime(timeText)
			local hours, minutes, seconds = timeText:match("(%d+):(%d+):(%d+)")
			
			if hours and minutes and seconds then
				return tonumber(hours) * 3600 + tonumber(minutes) * 60 + tonumber(seconds)
			end
			
			local mins, secs = timeText:match("(%d+):(%d+)")

			if mins and secs then
				return tonumber(mins) * 60 + tonumber(secs)
			end

			return 0
		end
		
		return RuntimeModule
	end)()
	
	Module.OceanModule = (function()
		local Ocean = {}

		local ZoneCoordinates = {
			['Infinite - ∞'] = {-9999999, 9999999},
			['Low - 1'] = {-21227, 4047},
			['Meduim - 2'] = {-24237, 6381},
			['High - 3'] = {-27105, 8959},
			['Extreme - 4'] = {-29350, 11744},
			['Crazy - 5'] = {-32404, 16208},
			['??? - 6'] = {-35611, 20548},
		}
		
		local TargetAnims = {
			"rbxassetid://8708225668",
			"rbxassetid://8708223619",
			"rbxassetid://8708222938"
		}

		function Ocean:GetZone()
			local coords = ZoneCoordinates[Configuration['Select Zone']]

			if coords then
				return CFrame.new(coords[1], 100, coords[2])
			end

			return CFrame.new(-9999999, 100, 9999999)
		end

		function Ocean:IsAlive(v)
			return v:FindFirstChild("Health") and v.Health.Value > 0
		end
		
		local function IsOwnerShip(model)
			local owner = model:FindFirstChild("Owner")
			if not owner or not owner:IsA("ObjectValue") or tostring(owner.Value) ~= LocalPlayer.Name then return end

			return true
		end

		function Ocean:GetPlayerShip(name)
			local Ship = nil
			local closestDistance = 5000
			local playerName = LocalPlayer.Name

			for _, model in pairs(Boats:GetChildren()) do
				if not model:GetAttribute("IsBoat") or model.Name ~= name then continue end

				local humanoid = model:FindFirstChild("Humanoid")
				if not humanoid or tonumber(humanoid.Value) <= 0 then continue end

				if IsOwnerShip(model) then
					local distance = Module:Distance(model:GetPivot())

					if distance < closestDistance then
						closestDistance = distance
						Ship = model
					end
				end
			end

			return Ship
		end

		function Ocean:Drive(v, Position)
			local seat = v:FindFirstChild("VehicleSeat")
			local pos = seat.Position
			local Distance = (Position.Position - v:GetPivot().Position).Magnitude

			local bp = seat:FindFirstChild("BodyPosition") do
				local bv = seat:FindFirstChild("BodyVelocity")
				if not bv and bp then return end
				
				bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
				bv.P = 0
				bp.MaxForce = Vector3.new(0, 0, 0)
			end

			local tw = TweenService:Create(seat, TweenInfo.new(Distance / 250, Enum.EasingStyle.Linear), {CFrame = Position})

			_ENV.StopShip = function()
				if tw then 
					tw:Cancel()
				end
			end

			seat.CFrame = CFrame.new(pos.X, 135, pos.Z)
			tw:Play()
		end

		function Ocean:GetSeabeast()
			local closest = nil
			local shortestDistance = 5000

			for _, seabeast in pairs(SeaBeasts:GetChildren()) do
				if not seabeast:IsA("Model") or not self:IsAlive(seabeast) then continue end

				local hrp = seabeast:FindFirstChild("HumanoidRootPart")
				if not hrp then continue end

				local distance = Module:Distance(hrp.Position)
				if distance < shortestDistance then
					shortestDistance = distance
					closest = seabeast
				end
			end

			return closest
		end

		function Ocean:IsSeaBeastHiding(animator)
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				if TargetAnims[track.Animation.AnimationId] then
					return true
				end
			end

			return false
		end

		function Ocean:GetEnemiesShip(Name)
			local closest = nil
			local shortestDistance = 5000

			for _, ship in pairs(Enemies:GetChildren()) do
				if not ship:IsA("Model") then continue end
				if not table.find(Name, ship.Name) then continue end
				if not self:IsAlive(ship) then continue end
				if not ship:FindFirstChild("Seat", true) then continue end

				local distance = Module:Distance(ship:GetPivot().Position)
				if distance < shortestDistance then
					shortestDistance = distance
					closest = ship
				end
			end

			return closest
		end

		function Ocean:GetIsland(name)
			return Map:FindFirstChild(name)
		end
		
		return Ocean
	end)()
	
	Module.Hooking = (function()
		local Hooking = {
			['index'] = {}
		}

		_ENV.Target = Vector3.new(0, 0, 0)

		function Hooking:Check()
			for _,v in pairs(self.index) do
				if Configuration[v] == true then
					return true 
				end 
			end 

			return false 
		end

		function Hooking:Import(Name)
			if not self.index[Name] then
				table.insert(self.index, Name)
			end
		end

		function Hooking:SetTarget(v3)
			_ENV.Target = (typeof(v3) == 'CFrame' and v3.Position) or v3
		end

		return Hooking
	end)()
	
	function Module:IsAlive(char)
		return char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0
	end
	
	function Module:ComF( ... )
		return CommF:InvokeServer( ... )
	end

	function Module:ComE( ... )
		return CommE:FireServer( ... )
	end

	function Module:TravelTo(Sea)
		self:ComF("Travel" .. self.SeaName[Sea])
	end

	function Module:BringEnemies(ToEnemy, SuperBring, CustomCFrame, Distance)
		if not Module:IsAlive(ToEnemy) or not ToEnemy.PrimaryPart then
			return nil
		end

		pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)

		if Distance or Configuration['Enabled Bring'] then
			Module.IsSuperBring = SuperBring and true or false

			local Name = ToEnemy.Name
			local BringPositionTag = SuperBring and "ALL_MOBS" or Name
			local Target = CustomCFrame or ToEnemy.PrimaryPart.CFrame
			local MaxDistance = Distance or Configuration['Bring Distance']

			if not Cached.Bring[BringPositionTag] or (Target.Position - Cached.Bring[BringPositionTag].Position).Magnitude > 25 then
				Cached.Bring[BringPositionTag] = Target
			end

			local EnemyList = Enemies:GetChildren()

			for i = 1, #EnemyList do
				local Enemy = EnemyList[i]

				if (SuperBring or Enemy.Name == Name)
					and Enemy.Parent == Enemies
					and not Enemy:HasTag(BRING_TAG)
					and Enemy:FindFirstChild("CharacterReady") then

					local PrimaryPart = Enemy.PrimaryPart

					if Module:IsAlive(Enemy) and PrimaryPart then
						if LocalPlayer:DistanceFromCharacter(PrimaryPart.Position) < MaxDistance then
							Enemy.Humanoid.WalkSpeed = 0
							Enemy.Humanoid.JumpPower = 0
							Enemy:AddTag(BRING_TAG)
						end
					end
				end
			end
		else
			if not Cached.Bring[ToEnemy] then
				Cached.Bring[ToEnemy] = ToEnemy.PrimaryPart.CFrame
			end

			ToEnemy.PrimaryPart.CFrame = Cached.Bring[ToEnemy]
		end
	end
end

do
	task.defer(function()
		if not _ENV._0riginal then
			local _Old

			_Old = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				
				if tostring(self) == "PlayerGui" then
					if method == "Destroy" or method == "Remove" or method == "ClearAllChildren" then
						return
					end
				end

				if method == "FireServer" or method == "InvokeServer" then
					local arg1, arg2 = ...

					if method == "InvokeServer" and arg1 == 'X' and typeof(arg2) == 'Vector3' and self.Name == "" then
						if Configuration['Aimbot Skill'] then
							return _Old(self, arg1, _ENV.Target)
						end

						if Module.Hooking:Check() then
							return _Old(self, arg1, _ENV.Target)
						end

						return _Old(self, ...)
					end

					if method == "FireServer" and self.Name == "RemoteEvent" and typeof(arg1) == "Vector3" and arg2 == nil then
						if Configuration['Aimbot Skill'] then
							return _Old(self, _ENV.Target)
						end

						if Module.Hooking:Check() then
							return _Old(self, _ENV.Target)
						end

						return _Old(self, ...)
					end
				end

				return _Old(self, ...)
			end)

			_ENV._0riginal = _Old

			do
				local Effect = ReplicatedStorage:WaitForChild('Effect')
				local Container = Effect:WaitForChild('Container')

				local Death = require(Container:WaitForChild('Death'))
				local Respawn = require(Container:WaitForChild('Respawn'))

				pcall(hookfunction, Death, function( ... )
					return ( ... )
				end)

				pcall(hookfunction, Respawn, function( ... )
					return ( ... )
				end)
			end
		end
	end)
end
