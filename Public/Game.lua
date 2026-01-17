local _ENV = (getgenv or getrenv or getfenv)()

local Utils = ...
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

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local GunValidator = Remotes:WaitForChild("Validator2")
local CommF = Remotes:WaitForChild("CommF_")
local CommE = Remotes:WaitForChild("CommE")
local Net = Modules:WaitForChild("Net")

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

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local PlayerScripts = LocalPlayer.PlayerScripts
local Backpack = LocalPlayer.Backpack

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character and Character:WaitForChild('Humanoid', 10)
local HumanoidRootPart = Character and Character:WaitForChild('HumanoidRootPart', 10)
local Head = Character and Character:WaitForChild('Head', 10)

local StorageNPCs = ReplicatedStorage:WaitForChild('NPCs')
local ServerOwnerId = ReplicatedStorage:FindFirstChild("PrivateServerOwnerId")
local IsPrivateServer = ServerOwnerId and ServerOwnerId.Value ~= 0 or true
local Mobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and true) or false

local SubmarineWorkerSpeak = Net:WaitForChild('RF/SubmarineWorkerSpeak')

local EmptyFunction = (function(...) return (...) end)
local fireclickdetector = fireclickdetector or EmptyFunction
local hookfunction = hookfunction or EmptyFunction
local restorefunction = restorefunction or EmptyFunction
local fireproximityprompt = fireproximityprompt or EmptyFunction

local BRING_TAG = _ENV._Bring_Tag or tostring(math.random(80, 2e4))
local KILLAURA_TAG = _ENV._KillAura_Tag or tostring(math.random(120, 2e4))

_ENV._Bring_Tag = BRING_TAG 
_ENV._KillAura_Tag = KILLAURA_TAG

do
	AddConnect(LocalPlayer.CharacterAdded, function(v)
		Character = v
		Head = v:WaitForChild('Head', 10)
		Humanoid = v:WaitForChild("Humanoid", 10)
		HumanoidRootPart = v:WaitForChild("HumanoidRootPart", 10)
		Backpack = LocalPlayer.Backpack

		warn("Spawn", Character, Humanoid, HumanoidRootPart, Backpack)
	end)
end

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

local function ValidData(filter, enemy)
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

local function IsAlive()
	if not Character then return end
	if not Humanoid then return end
	if not HumanoidRootPart then return end
	if not Head then return end
	if not Backpack then return end

	return (Humanoid and Humanoid.Health > 0) or HumanoidRootPart ~= nil
end

local Module = {} do
	local Cached = {
		Bring = {},
		Enemies = {}
	}

	do
		Module.PirateRaid = 0
		Module.IsSuperBring = false
		Module.EnemyLocations = {}
		Module.SpawnLocations = {}
		Module.SeaName = { "Main", "Dressrosa", "Zou" }
		Module.IsPrivateService = IsPrivateServer
		Module.IsMobile = Mobile

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

		Module.GateList = {
			[1] = {
				Vector3.new(3864, 5, -1926), -- Gate
				Vector3.new(61163, 5, 1819), -- Under Water
				Vector3.new(-7894, 5545, -380), -- Sky 2
				Vector3.new(-4607, 872, -1667) -- Sky 1
			},
			[2] = {
				Vector3.new(923, 125, 32852), -- Ghost Ship
				Vector3.new(-288, 200, 611), -- Mansion
				Vector3.new(2283, 60, 905), -- Swan
				Vector3.new(-6505, 125, -130) -- Out Ghost Ship
			},
			[3] = {
				Vector3.new(-5076, 314, -3151), -- Castle on the Sea
				Vector3.new(5657, 1013, -338), -- Hydra
				Vector3.new(-12479, 375, -7566) -- Mansion 
			},
			[4] = {}
		}
		
		Module.Bosses = (function(Current)
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
					["Buy Divine Art"] = { "BuyDivineArt" },
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
	end

	Module.TweenBodyVelocity = (function()
		local BodyVelocity = Instance.new("BodyVelocity") do
			BodyVelocity.Velocity = Vector3.zero
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.P = 1000
		end

		local Highlight = Instance.new("Highlight") do
			Highlight.FillColor = Color3.fromRGB(255, 0, 127)
			Highlight.OutlineColor = Color3.fromRGB(255, 0, 127)
			Highlight.FillTransparency = 0.3
		end

		if _ENV.tween_bodyvelocity then
			_ENV.tween_bodyvelocity:Destroy()
		end

		if _ENV.highlight then
			_ENV.highlight:Destroy()
		end

		_ENV.highlight = Highlight
		_ENV.tween_bodyvelocity = BodyVelocity

		local CanCollideObjects = {}

		local function AddObjectToBaseParts(Object)
			if Object:IsA("BasePart") and Object.CanCollide then
				table.insert(CanCollideObjects, Object)
			end
		end

		local function RemoveObjectsFromBaseParts(BasePart)
			local index = table.find(CanCollideObjects, BasePart)

			if index then
				table.remove(CanCollideObjects, index)
			end
		end

		local function NewCharacter(Character)
			if not Character then return end

			table.clear(CanCollideObjects)

			for _, Object in Character:GetDescendants() do AddObjectToBaseParts(Object) end
			Character.DescendantAdded:Connect(AddObjectToBaseParts)
			Character.DescendantRemoving:Connect(RemoveObjectsFromBaseParts)
		end

		AddConnect(LocalPlayer.CharacterAdded, NewCharacter)
		task.spawn(NewCharacter, Character)

		local function NoClipOnStepped(Character)
			if _ENV.OnFarm then
				for i = 1, #CanCollideObjects do
					CanCollideObjects[i].CanCollide = false
				end
			elseif Character.PrimaryPart and not Character.PrimaryPart.CanCollide then
				for i = 1, #CanCollideObjects do
					CanCollideObjects[i].CanCollide = true
				end
			end
		end

		local function UpdateVelocityOnStepped(Character)
			local BasePart = Character:FindFirstChild("UpperTorso")
			local Humanoid = Character:FindFirstChild("Humanoid")
			local BodyVelocity = _ENV.tween_bodyvelocity
			local Highlight = _ENV.highlight

			if _ENV.OnFarm and BasePart and Humanoid and Humanoid.Health > 0 then
				if BodyVelocity.Parent ~= BasePart then
					BodyVelocity.Parent = BasePart
				end

				if Highlight.Parent ~= Character then
					Highlight.Parent = Character
				end
			elseif BodyVelocity.Parent then
				BodyVelocity.Parent = nil
				Highlight.Parent = nil
			end
			if BodyVelocity.Velocity ~= Vector3.zero and (not Humanoid or not Humanoid.SeatPart or not _ENV.OnFarm) then
				BodyVelocity.Velocity = Vector3.zero
				Highlight.Parent = nil
			end
		end

		AddConnect(RunService.Stepped, function()
			if IsAlive() then
				UpdateVelocityOnStepped(Character)
				NoClipOnStepped(Character)
			end
		end)

		return BodyVelocity
	end)()

	Module.Skill = (function()
		local SkillModule = {}

		local Skills = PlayerGui.Main.Skills

		local function GetEnabledSkills()
			return {
				['Melee'] = Configuration['Melee'] or {},
				['Sword'] = Configuration['Sword'] or {},
				['Gun'] = Configuration['Gun'] or {},
				['Blox Fruit'] = Configuration['Blox Fruit'] or {}
			}
		end

		local SkillDebounce = 0.2

		local CurrentTool = nil
		local LastSkillUse = 0

		local function IsAlive()
			return Character and Humanoid and HumanoidRootPart and Head and Humanoid.Health > 0
		end

		local function IsToolAllowed(Tool)
			if not Tool or not Tool:IsA("Tool") then return false end

			local EnabledSkills = GetEnabledSkills()
			return EnabledSkills[Tool.ToolTip] ~= nil
		end

		local function IsToolValid(ToolFrame)
			if not ToolFrame or not ToolFrame:IsA("Frame") then return false end

			local ToolName = ToolFrame.Name
			local Tool = Backpack:FindFirstChild(ToolName) or Character:FindFirstChild(ToolName)

			if not IsToolAllowed(Tool) then return false end

			local EnabledSkills = GetEnabledSkills()
			local EnabledList = EnabledSkills[Tool.ToolTip]
			if not EnabledList or #EnabledList == 0 then
				return false
			end

			return true
		end

		local function LoadToolUI(ToolName)
			local Tool = Backpack:FindFirstChild(ToolName)
			if not Tool or not IsToolAllowed(Tool) then return false end

			local EnabledSkills = GetEnabledSkills()
			local EnabledList = EnabledSkills[Tool.ToolTip]

			if not EnabledList or #EnabledList == 0 then
				return false
			end

			if Tool:GetAttribute("Locks") then
				Tool:SetAttribute("Locks", nil)
			end

			Humanoid:EquipTool(Tool)
			task.wait(0.1)

			Humanoid:UnequipTools()
			task.wait(0.1)
			return Skills:FindFirstChild(ToolName) ~= nil
		end

		local function IsSkillUnlocked(Skill)
			local Title = Skill:FindFirstChild("Title")
			return Title and Title.TextColor3 == Color3.fromRGB(255, 255, 255)
		end

		local function IsSkillOnCooldown(Skill)
			local Cooldown = Skill:FindFirstChild("Cooldown")
			return Cooldown and Cooldown.Size.X.Scale > 0
		end

		local function GetToolEnabledSkills(ToolName)
			local Tool = Backpack:FindFirstChild(ToolName) or Character:FindFirstChild(ToolName)
			if not Tool then return {} end

			local EnabledSkills = GetEnabledSkills()
			return EnabledSkills[Tool.ToolTip] or {}
		end

		local function IsSkillReady(Skill, ToolName)
			local EnabledList = GetToolEnabledSkills(ToolName)

			if not table.find(EnabledList, Skill.Name) then
				return false
			end

			return not IsSkillOnCooldown(Skill) and IsSkillUnlocked(Skill)
		end

		local function AreAllSkillsOnCooldown(ToolName)
			local ToolContainer = Skills:FindFirstChild(ToolName)
			if not ToolContainer then return false end

			local EnabledList = GetToolEnabledSkills(ToolName)
			if #EnabledList == 0 then return true end

			local HasValidSkills = false

			for _, Skill in pairs(ToolContainer:GetChildren()) do
				if Skill:IsA("Frame") and Skill.Name ~= "Template" then
					if table.find(EnabledList, Skill.Name) and IsSkillUnlocked(Skill) then
						HasValidSkills = true
						if not IsSkillOnCooldown(Skill) then
							return false
						end
					end
				end
			end

			return HasValidSkills
		end

		local function FindReadySkill(ToolContainer, ToolName)
			local EnabledList = GetToolEnabledSkills(ToolName)

			for _, Skill in pairs(ToolContainer:GetChildren()) do
				if Skill:IsA("Frame") and Skill.Name ~= "Template" and IsSkillReady(Skill, ToolName) then
					return Skill.Name
				end
			end

			return nil
		end

		local function FindLowestCooldownSkill(ToolContainer, ToolName)
			local LowestCooldown = math.huge
			local SelectedSkill = nil
			local EnabledList = GetToolEnabledSkills(ToolName)

			for _, Skill in pairs(ToolContainer:GetChildren()) do
				if Skill:IsA("Frame") and Skill.Name ~= "Template" then
					local Cooldown = Skill:FindFirstChild("Cooldown")
					if Cooldown and IsSkillUnlocked(Skill) and table.find(EnabledList, Skill.Name) then
						local CooldownScale = Cooldown.Size.X.Scale
						if CooldownScale < LowestCooldown then
							LowestCooldown = CooldownScale
							SelectedSkill = Skill.Name
						end
					end
				end
			end

			return SelectedSkill
		end

		local function GetNextAvailableTool()
			for _, Tool in pairs(Skills:GetChildren()) do
				if Tool:IsA("Frame") and Tool.Name ~= 'Container' and IsToolValid(Tool) then
					local SkillName = FindReadySkill(Tool, Tool.Name)
					if SkillName then
						return Tool.Name, SkillName
					end
				end
			end
			return nil, nil
		end

		local function GetBestSkill(CurrentToolName)
			if CurrentToolName then
				local ToolFrame = Skills:FindFirstChild(CurrentToolName)

				if not ToolFrame then
					local Tool = Backpack:FindFirstChild(CurrentToolName) or Character:FindFirstChild(CurrentToolName)
					if Tool and IsToolAllowed(Tool) then
						local EnabledSkills = GetEnabledSkills()
						local EnabledList = EnabledSkills[Tool.ToolTip]
						if EnabledList and #EnabledList > 0 then
							LoadToolUI(CurrentToolName)
							ToolFrame = Skills:FindFirstChild(CurrentToolName)
						end
					end
				end

				if not ToolFrame or not IsToolValid(ToolFrame) then
					CurrentTool = nil
					CurrentToolName = nil
				end
			end

			if CurrentToolName and AreAllSkillsOnCooldown(CurrentToolName) then
				return GetNextAvailableTool()
			end

			if CurrentToolName then
				local ToolContainer = Skills:FindFirstChild(CurrentToolName)
				if ToolContainer and IsToolValid(ToolContainer) then
					local SkillName = FindReadySkill(ToolContainer, CurrentToolName) or FindLowestCooldownSkill(ToolContainer, CurrentToolName)
					if SkillName then
						return CurrentToolName, SkillName
					end
				end
			end

			local BestTool, BestSkill = nil, nil
			local LowestCooldown = math.huge

			for _, Tool in pairs(Skills:GetChildren()) do
				if Tool:IsA("Frame") and Tool.Name ~= 'Container' and IsToolValid(Tool) then
					local SkillName = FindReadySkill(Tool, Tool.Name)
					if SkillName then
						return Tool.Name, SkillName
					end

					local LowSkill = FindLowestCooldownSkill(Tool, Tool.Name)
					if LowSkill then
						local Skill = Tool:FindFirstChild(LowSkill)
						local Cooldown = Skill and Skill:FindFirstChild("Cooldown")
						if Cooldown and Cooldown.Size.X.Scale < LowestCooldown then
							LowestCooldown = Cooldown.Size.X.Scale
							BestTool = Tool.Name
							BestSkill = LowSkill
						end
					end
				end
			end

			return BestTool, BestSkill
		end

		local function EquipTool(ToolName)
			if not IsAlive() or not Backpack then return false end

			local Tool = Backpack:FindFirstChild(ToolName)
			if not Tool or not Tool:IsA("Tool") then return false end

			if Tool:GetAttribute("Locks") then
				Tool:SetAttribute("Locks", nil)
			end

			if not Character:FindFirstChild(ToolName) then
				Humanoid:EquipTool(Tool)

				local Timeout = tick() + 1
				while not Character:FindFirstChild(ToolName) and tick() < Timeout do
					task.wait()
				end

				return Character:FindFirstChild(ToolName) ~= nil
			end

			return true
		end

		local function UseSkill(SkillKey)
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[SkillKey], false, game)
			task.wait(0.05)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[SkillKey], false, game)
		end

		function SkillModule:Use()
			if tick() - LastSkillUse < SkillDebounce then return end

			local ToolName, SkillName = GetBestSkill(CurrentTool)
			if not ToolName or not SkillName then return end

			if CurrentTool ~= ToolName then
				if not EquipTool(ToolName) then
					return Humanoid:UnequipTools()
				end

				CurrentTool = ToolName
				task.wait(0.15)
			end

			if not Character:FindFirstChild(ToolName) then
				CurrentTool = nil
				return
			end

			LastSkillUse = tick()
			UseSkill(SkillName)
		end

		return SkillModule
	end)()

	Module.Quest = (function()
		if Module.Sea == 4 then return {} end

		local Quest = {
			Quests = require(ReplicatedStorage:WaitForChild('Quests')),
			GuideModule = require(ReplicatedStorage:WaitForChild('GuideModule')),
			Blacklist = { "BartiloQuest", "MarineQuest", "CitizenQuest" },
		}

		function Quest:GetMonster(CurrentLevel)
			local Data, Levels = {}, {}
			local Maximum = ({ {0, 700}, {700, 1500}, {1500, math.huge} })[Module.Sea]

			for name, task in pairs(Quest.Quests) do
				if table.find(Quest.Blacklist, name) then continue end

				for num, mission in pairs(task) do
					local Level = mission.LevelReq
					local Monster, Value = next(mission.Task)
					if Level >= Maximum[1] and Level < Maximum[2] and CurrentLevel >= Level and Value > 1 then
						table.insert(Levels, Level)
						Data[tostring(Level)] = {
							Name = mission.Name,
							Level = num,
							Monster = Monster,
						}
					end
				end
			end

			return Data[tostring(math.max(unpack(Levels)))]
		end

		function Quest:NPCsData(CurrentLevel)
			local Data, Levels = {}, {}

			for _, Npcs in pairs(Quest.GuideModule['Data']['NPCList']) do
				local Level = Npcs.Levels[1]
				if CurrentLevel >= Level then
					table.insert(Levels, Level)
					Data[tostring(Level)] = {
						['Position'] = Npcs.Position,
						['Quest'] = Npcs.InternalQuestName,
					}
				end
			end

			return Data[tostring(math.max(unpack(Levels)))]
		end

		function Quest:GetQuest(CurrentLevel)
			local Level = CurrentLevel.Value

			if Level == 1 and Level <= 9 then
				if tostring(LocalPlayer.Team) == "Marines" then
					return {
						['Name'] = "Trainees",
						['Monster'] = "Trainee",
						['Level'] = 1,
						['Quest'] = "MarineQuest",
						['Position'] = CFrame.new(1059, 15, 1550),
					}
				elseif tostring(LocalPlayer.Team) == "Pirates" then
					return {
						['Name'] = "Bandits",
						['Monster'] = "Bandit",
						['Level'] = 1,
						['Quest'] = "BanditQuest1",
						['Position'] = CFrame.new(-2711, 24, 2104),
					}
				end

				return
			end

			local Data = self:GetMonster(Level)
			local NPCsData = self:NPCsData(Level)

			Data['Quest'] = NPCsData.Quest
			Data['Position'] = CFrame.new(NPCsData.Position)

			return Data
		end

		return Quest
	end)()

	Module.Combat = (function()
		local Combat = {
			RANGE = 50,
			HIT_FUNCTION = nil
		}

		local Data = {
			['Control-Control'] = function(remote, Unit)
				return remote:FireServer(Unit, 1, true)
			end,
		}

		local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
		local RegisterHit = Net:WaitForChild("RE/RegisterHit")

		task.defer(function()
			pcall(function()
				local LocalScript = PlayerScripts:FindFirstChildOfClass("LocalScript")

				while not LocalScript do
					LocalPlayer.PlayerScripts.ChildAdded:Wait()
					LocalScript = PlayerScripts:FindFirstChildOfClass("LocalScript")
				end

				if getsenv then
					local Success, Environtment = pcall(getsenv, LocalScript)

					if Success and Environtment then
						if Environtment._G.SendHitsToServer then
							Combat.HIT_FUNCTION = Environtment._G.SendHitsToServer
						end
					end
				end
			end)
		end)

		local function ProcessEnemy(Closet)
			local BladeHits = {}

			for _, Enemy in ipairs(Enemies:GetChildren()) do
				if Enemy ~= Closet and Module:IsAlive(Enemy) then
					local HumanoidRootPart = Enemy:FindFirstChild("HumanoidRootPart")

					if HumanoidRootPart then
						table.insert(BladeHits, { Enemy, HumanoidRootPart })
					end
				end
			end

			if Configuration['Attack Players'] then
				for _, Enemy in ipairs(Characters:GetChildren()) do
					if Enemy ~= Closet and Module:IsAlive(Enemy) then
						local HumanoidRootPart = Enemy:FindFirstChild("HumanoidRootPart")

						if HumanoidRootPart then
							table.insert(BladeHits, { Enemy, HumanoidRootPart })
						end
					end
				end
			end

			return BladeHits
		end

		local function Fired(target, enemyData)
			RegisterAttack:FireServer(0.5)

			if Combat.HIT_FUNCTION then
				return Combat.HIT_FUNCTION(target, enemyData)
			end

			RegisterHit:FireServer(target, enemyData)
		end

		local function Attack()
			local Folders = { Enemies, Configuration['Attack Players'] and Characters or nil }

			for _, folder in ipairs(Folders) do
				if not folder then continue end

				for _, target in pairs(folder:GetChildren()) do
					if target == Character then continue end
					if not Module:IsAlive(target) then continue end
					if Module:Distance(target:GetPivot()) >= Combat.RANGE then continue end

					local rootPart = target:FindFirstChild("HumanoidRootPart")
					if not rootPart then continue end

					Fired(rootPart, ProcessEnemy(target))
				end
			end
		end

		local function FruitAttack(a)
			local LeftClickRemote = a:FindFirstChild('LeftClickRemote')

			if not LeftClickRemote then return end

			local Folders = { Enemies, Configuration['Attack Players'] and Characters or nil }

			for _, folder in ipairs(Folders) do
				if not folder then continue end

				for _, target in pairs(folder:GetChildren()) do
					if target == Character then continue end
					if not Module:IsAlive(target) then continue end

					local rootPart = target:FindFirstChild("HumanoidRootPart")
					if not rootPart then continue end

					if Module:Distance(rootPart.Position) > Combat.RANGE then continue end

					local Unit = (rootPart.Position - HumanoidRootPart.Position).Unit

					if Data[tostring(a)] then
						Data[tostring(a)](LeftClickRemote, Unit)
					end
				end
			end
		end

		local function GetWeapons(a, Tip)
			if not IsAlive() then return end

			for _, Tool in a:GetChildren() do
				if Tool:IsA("Tool") and Tool.ToolTip == Tip then
					return Tool
				end
			end

			return nil
		end

		AddConnect(RenderStepped, function()
			if not Configuration['Fast Attack'] then return end
			if not IsAlive() then return end
			if not Backpack then return end

			local Equiped = Character and Character:FindFirstChildOfClass("Tool")
			if not Equiped then return end

			local Name = tostring(Equiped)

			if Name == 'Ice-Ice' or Name == 'Light-Light' then
				return pcall(Attack)
			end

			if Equiped.ToolTip == 'Blox Fruit' then
				return pcall(FruitAttack, Equiped)
			end

			local Type = Equiped and (Equiped.ToolTip == 'Melee' or Equiped.ToolTip == 'Sword')
			if not Type then return end

			pcall(Attack)
		end)

		return Combat
	end)()
	
	Module.Inventory = (function()
		local Cache = {
			['Unlocked'] = setmetatable({}, { __index = function() return false end }),
			['Mastery'] = setmetatable({}, { __index = function() return 0 end }),
			['Count'] = setmetatable({}, { __index = function() return 0 end }),
			['MasteryRequirements'] = {},
			['Items'] = {},
		}

		function Cache:Counts(str)
			return self.Count[str]
		end

		function Cache:HaveFruit()
			if not IsAlive() then return end
			if not Backpack then return end

			for _ ,v in pairs(LocalPlayer.Backpack:GetChildren()) do
				if string.find(v.Name,"Fruit")  then
					return true
				end
			end

			for _ ,v in pairs(Character:GetChildren()) do
				if string.find(v.Name,"Fruit")  then
					return true
				end
			end

			return false
		end

		function Cache:GetFruit(Notlower)
			local Fruits = {}

			for _, v in next, Module:ComF("GetFruits") do
				if (Notlower and v.Price >= 999999) or v.Price <= 999999 then
					Fruits[v.Name] = v.Price
				end
			end

			return Fruits
		end 

		function Cache:SearchFruits(High)
			local MaxValue, Fruits = math.huge, nil
			local List = self:GetFruit(High)

			for _ ,v in next, Module:ComF("getInventory") do
				if v['Type'] == "Blox Fruit" then
					for fruit, value in pairs(List) do
						if v.Name == fruit then
							if tonumber(value) < tonumber(MaxValue) then
								MaxValue = value
								Fruits = fruit
							end
						end
					end
				end
			end

			return Fruits
		end

		function Cache:BuyFruits(Fruits)
			return Module:ComF("PurchaseRawFruit", Fruits)
		end

		function Cache:UnStoreFruits(value)
			if value == "High" then
				local Fruits = self:SearchFruits(true)

				if self:HaveFruit() or not Fruits then return end

				return Module:ComF("LoadFruit", Fruits)
			end

			local Fruits = self:SearchFruits(false)

			if self:HaveFruit() or not Fruits then return end

			return Module:ComF("LoadFruit", Fruits)
		end

		function Cache:UpdateItem(item)
			if type(item) == "table" then
				if item.Type == "Wear" then
					item.Type = "Accessory"
				end

				local Name = item.Name

				self.Items[Name] = item

				if not self.Unlocked[Name] then self.Unlocked[Name] = true end
				if item.Count then self.Count[Name] = item.Count end
				if item.Mastery then self.Mastery[Name] = item.Mastery end
				if item.MasteryRequirements then self.MasteryRequirements[Name] = item.MasteryRequirements end
			end
		end

		function Cache:RemoveItem(ItemName)
			if type(ItemName) == "string" then
				self.Unlocked[ItemName] = nil
				self.Mastery[ItemName] = nil
				self.Count[ItemName] = nil
				self.Items[ItemName] = nil
			end
		end

		local function OnClientEvent(Method, ...)
			if Method == "ItemChanged" then
				Cache:UpdateItem(...)
			elseif Method == "ItemAdded" then
				Cache:UpdateItem(...)
			elseif Method == "ItemRemoved" then
				Cache:RemoveItem(...)
			end
		end

		task.spawn(function()
			AddConnect(CommE.OnClientEvent, OnClientEvent)

			local InventoryItems = nil

			repeat
				task.wait(1)
				InventoryItems = Module:ComF("getInventory")
			until type(InventoryItems) == "table"

			for index = 1, #InventoryItems do
				Cache:UpdateItem(InventoryItems[index])
			end
		end)

		return Cache
	end)()

	Module.EnemiesModule = (function()
		local EnemiesModule = CreateDictionary({
			"__CakePrince", "__PirateRaid", "__RaidBoss", "__TyrantSkies", "__Bones", "__Elite", "__Others", 
		}, {})

		local SeaCastle = CFrame.new(-5556, 314, -2988)

		local TagsMobs = {
			__Elite = CreateDictionary({ "Deandre", "Diablo", "Urban" }, true),
			__Bones = CreateDictionary({ "Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy" }, true),
			__CakePrince = CreateDictionary({ "Head Baker", "Baking Staff", "Cake Guard", "Cookie Crafter" }, true),
			__TyrantSkies = CreateDictionary({ "Sun-kissed Warrior", "Skull Slayer", "Isle Champion", "Serpent Hunter" }, true)
		}

		local Attachment = Instance.new("Attachment") do
			local AlignPosition = Instance.new("AlignPosition")
			AlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
			AlignPosition.Position = Vector3.new(0, 20, 0)
			AlignPosition.Responsiveness = 200
			AlignPosition.MaxForce = math.huge
			AlignPosition.Parent = Attachment
			AlignPosition.Attachment0 = Attachment
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
					task.spawn(New, EnemiesModule.__PirateRaid, Enemy)
					Module.PirateRaid = tick()
				end
			end
		end

		local function NewEnemyAdded(Enemy)
			local EnemyName = Enemy.Name
			local Others = EnemiesModule.__Others

			Others[EnemyName] = Others[EnemyName] or {}
			task.spawn(New, Others[EnemyName], Enemy)

			if Module.Sea == 3 then
				task.spawn(IsFromPiratesSea, Enemy)
			end

			if Enemy:GetAttribute("RaidBoss") then
				task.spawn(New, EnemiesModule.__RaidBoss, Enemy)
			elseif EnemiesModule["__" .. EnemyName] then
				task.spawn(New, EnemiesModule["__" .. EnemyName], Enemy)
			else
				for Tag, Mobs in pairs(TagsMobs) do
					if Mobs[EnemyName] then
						task.spawn(New, EnemiesModule[Tag], Enemy)
						break
					end
				end
			end
		end

		function EnemiesModule:IsSpawned(EnemyName)
			local Cached = Module.SpawnLocations[EnemyName]

			if Cached and Cached.Parent then
				return (Cached:GetAttribute("Active") or EnemiesModule:GetEnemyByTag(EnemyName)) and true or false
			end

			return EnemiesModule:GetEnemyByTag(EnemyName) and true or false
		end

		function EnemiesModule:GetTagged(TagName)
			return self["__" .. TagName] or self.__Others[TagName]
		end

		function EnemiesModule:GetEnemyByTag(TagName)
			local CachedEnemy = Cached.Enemies[TagName]

			if CachedEnemy and IsAlive(CachedEnemy) then
				return CachedEnemy
			end

			local Enemies = self:GetTagged(TagName)

			if Enemies and #Enemies > 0 then
				for i = 1, #Enemies do
					local Enemy = Enemies[i]

					if Module:IsAlive(Enemy) then
						Cached.Enemies[TagName] = Enemy
						return Enemy
					end
				end
			end
		end

		function EnemiesModule:GetClosest(Enemies)
			local SpecialTag = table.concat(Enemies, ".")
			local CachedEnemy = Cached.Enemies[SpecialTag]

			if CachedEnemy and Module:IsAlive(CachedEnemy) then
				return CachedEnemy
			end

			local Distance, Nearest = math.huge, nil

			for i = 1, #Enemies do
				local Enemy = self:GetClosestByTag(Enemies[i])
				local Magnitude = Enemy and LocalPlayer:DistanceFromCharacter(Enemy.PrimaryPart.Position)

				if Enemy and Magnitude <= Distance then
					Distance, Nearest = Magnitude, Enemy
				end
			end

			if Nearest then
				Cached.Enemies[SpecialTag] = Nearest
				return Nearest
			end
		end

		function EnemiesModule:GetClosestByTag(TagName)
			local CachedEnemy = Cached.Enemies[TagName]

			if CachedEnemy and Module:IsAlive(CachedEnemy) then
				return CachedEnemy
			end

			local Enemies = self:GetTagged(TagName)

			if Enemies and #Enemies > 0 then
				local Distance, Nearest = math.huge, nil

				local Position = Character and Character:GetPivot().Position

				for i = 1, #Enemies do
					local Enemy = Enemies[i]
					local PrimaryPart = Enemy.PrimaryPart

					if PrimaryPart and Module:IsAlive(Enemy) then
						local Magnitude = (Position - PrimaryPart.Position).Magnitude

						if Magnitude <= 15 then
							Cached.Enemies[TagName] = Enemy
							return Enemy
						elseif Magnitude <= Distance then
							Distance, Nearest = Magnitude, Enemy
						end
					end
				end

				if Nearest then
					Cached.Enemies[TagName] = Nearest
					return Nearest
				end
			end
		end
		
		function EnemiesModule:GetReplicated(name)
			local Nearest, Distance = nil, math.huge
			local EnemiesList = ReplicatedStorage:GetChildren()
			
			for i = 1, #EnemiesList do
				local Enemy = EnemiesList[i]
				
				if not Enemy:IsA('Model') then continue end
				if not Enemy.PrimaryPart then continue end
				if not ValidData(name, Enemy) then continue end

				if Module:IsAlive(Enemy) then
					local Magnitude = LocalPlayer:DistanceFromCharacter(Enemy.PrimaryPart.Position)
					
					if Enemy and Magnitude <= Distance then
						Distance, Nearest = Magnitude, Enemy
					end
				end
			end
			
			return Nearest
		end
		
		function EnemiesModule:GetEnemies(range, name)
			local Nearest, Distance = nil, math.huge
			local EnemiesList = Enemies:GetChildren()

			for i = 1, #EnemiesList do
				local Enemy = EnemiesList[i]

				if not Enemy.PrimaryPart then continue end
				if not ValidData(name, Enemy) then continue end

				if Module:IsAlive(Enemy) then
					local Magnitude = LocalPlayer:DistanceFromCharacter(Enemy.PrimaryPart.Position)

					if Enemy and (not range or Magnitude < range) and Magnitude < Distance then
						Distance, Nearest = Magnitude, Enemy
					end
				end
			end

			return Nearest
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

				if Target and (Target.Position - RootPart.Position).Magnitude <= Configuration["Bring Distance"] then
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

		for _, Enemy in CollectionService:GetTagged("BasicMob") do NewEnemyAdded(Enemy) end
		AddConnect(CollectionService:GetInstanceAddedSignal("BasicMob"), NewEnemyAdded)
		AddConnect(CollectionService:GetInstanceAddedSignal(KILLAURA_TAG), KillAura)
		AddConnect(CollectionService:GetInstanceAddedSignal(BRING_TAG), Bring)

		return EnemiesModule
	end)()

	Module.RuntimeModule = (function()
		local Runtime = {}

		function Runtime:Chest()
			local Chests = CollectionService:GetTagged("_ChestTagged")
			local Distance, Nearest = math.huge, nil

			for i = 1, #Chests do
				local Chest = Chests[i]
				local Magnitude = (Chest:GetPivot().Position - HumanoidRootPart.Position).Magnitude
				if not Chest:GetAttribute("IsDisabled") and Magnitude < Distance then
					Distance, Nearest = Magnitude, Chest
				end
			end

			return Nearest
		end

		function Runtime:Berry()
			local Position = HumanoidRootPart.Position
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

		function Runtime:RaidIsland()
			for i = 5, 1, -1 do
				local Name = "Island " .. i

				for _, Island in ipairs(Locations:GetChildren()) do
					if Island.Name == Name and LocalPlayer:DistanceFromCharacter(Island.Position) < 3500 then
						return Island
					end
				end
			end
		end

		function Runtime:Tree()
			local Tree = Map.TikiOutpost.IslandModel:FindFirstChild("EagleBossArena", true)
			local closestTree = nil
			local shortestDistance = math.huge

			for _, v in pairs(Tree:GetChildren()) do
				if v.Name == "Tree" and v:IsA("Model") and v.PrimaryPart ~= nil then
					local distance = Module:Distance(v.PrimaryPart.Position)
					if distance < shortestDistance then
						shortestDistance = distance
						closestTree = v
					end
				end
			end

			return closestTree
		end

		function Runtime:GetPlayers(MaxDistance)
			local closestEnemy = nil
			local shortestDistance = math.huge

			for _, enemy in pairs(Characters:GetChildren()) do
				if enemy ~= Character and Module:IsAlive(enemy) then
					local dist = Module:Distance(enemy:GetPivot())
					if (not MaxDistance or dist < MaxDistance) and dist < shortestDistance then
						closestEnemy = enemy
						shortestDistance = dist
					end
				end
			end

			return closestEnemy
		end

		function Runtime:GetShip(name)
			for _, v in pairs(Boats:GetChildren()) do
				if v.Name == name and v.Name ~= LocalPlayer.Name then
					return v
				end
			end

			return nil
		end

		function Runtime:GetLavaRocks(VolcanoRocks)
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

		function Runtime:GetGift()
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

		function Runtime:ParseTime(timeText)
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

		return Runtime
	end)()
	
	Module.Ocean = (function()
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

		function Ocean:RemoveBoatCollision(Boat)
			local Objects = Boat:GetDescendants()

			for i = 1, #Objects do
				local BasePart = Objects[i]
				if BasePart:IsA("BasePart") and BasePart.CanCollide then
					BasePart.CanCollide = false
				end
			end
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

			local tw = TweenService:Create(seat, TweenInfo.new(Distance / 300, Enum.EasingStyle.Linear), {CFrame = Position})

			_ENV.StopShip = function()
				if tw then 
					tw:Cancel()
				end
			end

			seat.CFrame = CFrame.new(pos.X, 100, pos.Z)
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

		function Ocean:GetClosestIsland(name)
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

	function Module:Distance(Position)
		return Position and ((typeof(Position) == 'CFrame' and LocalPlayer:DistanceFromCharacter(Position.Position)) or LocalPlayer:DistanceFromCharacter(Position))
	end

	function Module:IsPortal()
		return Module.Sea ~= 3 or self:HaveItem('Valkyrie Helm')
	end

	function Module:HaveItem(name)
		if not IsAlive() then return end
		if not Backpack then return end

		if Character and Character:FindFirstChild(name) then
			return true
		end

		if Backpack:FindFirstChild(name) then
			return true
		end

		local Inventory = Module:ComF("getInventoryWeapons")

		for _, v in pairs(Inventory) do
			if v.Name == name then
				return true
			end
		end

		return false
	end

	function Module:Equip(Name, Tooltip)
		if not IsAlive() then return end
		if not Backpack then return end

		for _, v in pairs(Backpack:GetChildren()) do
			if v:IsA("Tool") and ((Tooltip and v.ToolTip == Name) or (not Tooltip and v.Name == Name)) then
				if v:GetAttribute("Locks") then
					v:SetAttribute("Locks", nil)
				end

				if Character and not Character:FindFirstChild(v.Name) then
					Humanoid:EquipTool(v)
				end
			end
		end
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

			local EnemyList = (not SuperBring and self.EnemiesModule:GetTagged(Name)) or Enemies:GetChildren()

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

	task.spawn(function()
		local SpawnLocations = Module.SpawnLocations
		local EnemyLocations = Module.EnemyLocations

		local function NewIslandAdded(Island)
			if Island.Name:find("Island") then
				Cached.RaidIsland = nil
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
		AddConnect(EnemySpawns.ChildAdded, NewSpawn)
		AddConnect(Locations.ChildAdded, NewIslandAdded)

		local function ShouldStop(Breake)
			return not _ENV.OnFarm or not IsAlive() or (Breake and Breake())
		end

		local function WaitAtSpawnPoints(enemyName, spawnPoints, Breake, Teleport)
			if ShouldStop(Breake) then return end

			for _, spawnCFrame in pairs(spawnPoints) do
				if ShouldStop(Breake) then return end
				if Module.EnemiesModule:GetClosestByTag(enemyName) then return end

				Teleport(spawnCFrame)

				local waitStart = tick()
				local waitDelay = Configuration['Wait Enemies Delay'] or 0.75

				while tick() - waitStart < waitDelay do
					if ShouldStop(Breake) then return end
					if Module.EnemiesModule:GetClosestByTag(enemyName) then return end
					
					task.wait(0.1)
				end

				if Module.EnemiesModule:GetClosestByTag(enemyName) then
					return
				end

			end

			if not ShouldStop(Breake) and not Module.EnemiesModule:GetClosestByTag(enemyName) then
				WaitAtSpawnPoints(enemyName, spawnPoints, Breake, Teleport)
			end
		end

		local function WaitForEnemySpawn(Name, Breake, Teleport)
			if ShouldStop(Breake) then return end

			local enemyNames = type(Name) == "table" and Name or {Name}

			for _, enemyName in ipairs(enemyNames) do
				if ShouldStop(Breake) then return end
				if Module.EnemiesModule:GetClosestByTag(enemyName) then return end

				if Module.EnemiesModule:IsSpawned(enemyName) then
					local spawnPoints = EnemyLocations[enemyName]
					
					if spawnPoints then
						WaitAtSpawnPoints(enemyName, spawnPoints, Breake, Teleport)
					end
				end

				if ShouldStop(Breake) then return end
				if Module.EnemiesModule:GetClosestByTag(enemyName) then return end
			end
		end

		function Module:WaitForEnemy(Name, Breake, Teleport)
			return WaitForEnemySpawn(Name, Breake, Teleport)
		end
	end)
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
						if Module.Hooking:Check() then
							return _Old(self, arg1, _ENV.Target)
						end

						return _Old(self, ...)
					end

					if method == "FireServer" and self.Name == "RemoteEvent" and typeof(arg1) == "Vector3" and arg2 == nil then
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

return Module
