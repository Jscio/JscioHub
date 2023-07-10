--[[
    The Rake Remastered - 2413927524
    by Jscio
]]--

--<< Services >>--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")


--<< Checks >>--
if not hookfunction or not hookmetamethod then
    game:GetService("Players").LocalPlayer:Kick("Functions missing #2 (`hookfunction`, `hookmetamethod` expected)")
    return
end

if Players.LocalPlayer.Character == nil or not Players.LocalPlayer.Character then
    warn("Unable to find localplayer character. Yielding...")
    Players.LocalPlayer.CharacterAdded:Wait()
    Players.LocalPlayer.Character:WaitForChild("Humanoid")
    Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    print("Localplayer character found!")
end


--<< Libraries >>--
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jscio/JscioHub/main/Libraries/ESPLibrary.lua"))()
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))() -- Arrayfield sucks, use Rayfield instead


--<< Variables >>--
local Hooks = {}
local ESPObjects = {
    Players = {},
    Rake = nil,
    FlareGun = nil,
    Scrap = {},
    Waypoint = {},
    SupplyCrate = {},
    Trap = {}
}


--<< Game Objects >>--
local LocalPlayer = Players.LocalPlayer

local Folders; Folders = {
    Filter = workspace:WaitForChild("Filter"),
    Debris = workspace:WaitForChild("Debris"),
    MapFolder = workspace:WaitForChild("Map")
}

local ScrapSpawns = Folders.Filter:WaitForChild("ScrapSpawns")
local LocationPoints = Folders.Filter:WaitForChild("LocationPoints")


--<< Config >>--
local Config = {
    Movement = {
        NoStaminaDrain = false,
        NoFallDamage = false
    },
    Render = {
        Players = {
            Nametag = {
                Visible = true,
                TextSize = 12,
                Color = { Color3.new(1, 1, 1), 0 },
                OutlineColor = { Color3.new(0, 1, 0), 0.8 },
                Offset = Vector3.new(0, 2, 0)
            },
            Cham = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(0, 1, 0), 0 }
            }
        },
        Rake = {
            Nametag = {
                Visible = true,
                TextSize = 12,
                Color = { Color3.new(1, 1, 1), 0 },
                OutlineColor = { Color3.new(1, 0, 0), 0.5 },
                Offset = Vector3.new(0, 2, 0)
            },
            Cham = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(1, 0, 0), 0 }
            }
        },
        FlareGun = {
            Nametag = {
                Visible = true,
                TextSize = 12,
                Color = { Color3.new(1, 1, 1), 0 },
                OutlineColor = { Color3.new(0, 0, 0), 0.5 },
                Offset = Vector3.new(0, 2, 0)
            },
            Cham = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(1, 0, 1), 0 }
            }
        },
        Scrap = {
            Nametag = {
                Visible = true,
                TextSize = 12,
                Color = { Color3.new(1, 1, 1), 0 },
                OutlineColor = { Color3.new(0, 0, 0), 0.5},
                Offset = Vector3.new(0, 2, 0)
            },
            Cham = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(1, 1, 0), 0 }
            }
        },
        Waypoint = {
            Nametag = {
                Visible = true,
                TextSize = 12,
                Color = { Color3.new(1, 1, 1), 0 },
                OutlineColor = { Color3.new(0, 0.5, 1), 0.7},
                Offset = Vector3.new(0, 2, 0)
            },
            Cham = {
                Visible = false
            }
        },
        SupplyCrate = {
            Nametag = {
                Visible = true,
                TextSize = 12,
                Color = { Color3.new(1, 1, 1), 0 },
                OutlineColor = { Color3.new(0, 0, 0), 0.5},
                Offset = Vector3.new(0, 2, 0)
            },
            Cham = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(1, 1, 0), 0 }
            }
        },
        Trap = {
            Nametag = {
                Visible = false,
                TextSize = 10,
                Color = { Color3.new(1, 1, 1), 0 },
                OutlineColor = { Color3.new(0, 0, 0), 0.5},
                Offset = Vector3.new(0, 2, 0)
            },
            Cham = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(1, 0, 0), 0 }
            }
        },
    }
}


--<< Functions >>--
-->> Movement:
local function ModifyStamina()
    for _, v in pairs(getloadedmodules()) do
		if v.Name == "M_H" then
			local module = require(v)
			Hooks.Stamina = hookfunction(module.TakeStamina, function(something, amount)
				if amount > 0 and Config.Movement.NoStaminaDrain then
					return Hooks.Stamina(something, -1)
				end
				
				return Hooks.Stamina(something, amount)
			end)
		end
	end
end

local function ModifyFallDamage()
    Hooks.FallDamage = hookmetamethod(game, "__namecall", function(...)
		if getnamecallmethod() == "FireServer" and Config.Movement.NoFallDamage then
			if tostring(...) == "FD_Event" then
				return
			end
		end
		
		return Hooks.FallDamage(...)
	end)
end

-->> Render:
local function UpdateIndex(category : string)
    assert(category, "Missing argument #1 (string expected)")
    assert(type(category), "Class not supported #1 (string expected)")

    if category == "Rake" or category == "FlareGun" then
        if ESPObjects[category] ~= nil then
            ESPObjects[category]:Update(Config.Render[category])
        end
        return
    end

    for _, ESPObject in ipairs(ESPObjects[category]) do
        ESPObject:Update(Config.Render[category])
    end
end

--<>><><><><><><><><>--
local function IndexPlayer(Character : Model)
    if not Character then
        return
    end

    local Options = Config.Render.Players

    local Object = ESPLibrary.new(Character, {
        Nametag = {
            Visible = Options.Nametag.Visible,
            Text = Character.Name .. " - {distance}",
            TextSize = Options.Nametag.TextSize,
            Color = Options.Nametag.Color,
            OutlineColor = Options.Nametag.OutlineColor,
            Offset = Options.Nametag.Offset
        },
        Cham = {
            Visible = Options.Cham.Visible,
            Color = Options.Cham.Color,
            OutlineColor = Options.Cham.OutlineColor,
        },
        OnDestroy = function(ESPObject)
            print("Player Index Destroy")
            table.remove(ESPObjects.Players, table.find(ESPObjects.Players, ESPObject))
        end
    })

    if Object then
        table.insert(ESPObjects.Players, Object)
    end
end

local function IndexAllPlayers()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer or not Player.Character or Player.Character == nil then
            continue
        end

        IndexPlayer(Player.Character)
    end
end

--<>><><><><><><><><>--
local function IndexRake()
    local Rake = workspace:FindFirstChild("Rake")

    if not Rake then
        return
    end

    local Options = Config.Render.Rake

    ESPObjects.Rake = ESPLibrary.new(Rake, {
        Nametag = {
            Visible = Options.Nametag.Visible,
            Text = "The Rake - {distance}",
            TextSize = Options.Nametag.TextSize,
            Color = Options.Nametag.Color,
            OutlineColor = Options.Nametag.OutlineColor,
            Offset = Options.Nametag.Offset
        },
        Cham = {
            Visible = Options.Cham.Visible,
            Color = Options.Cham.Color,
            OutlineColor = Options.Cham.OutlineColor,
        },
        OnDestroy = function(ESPObject)
            print("Rake Index Destroy")
            ESPObjects.Rake = nil
        end
    })
end

--<>><><><><><><><><>--
local function IndexFlareGun()
    local FlareGun = workspace:FindFirstChild("FlareGunPickUp")

    if not FlareGun then
        return
    end

    local Options = Config.Render.FlareGun

    ESPObjects.FlareGun = ESPLibrary.new(FlareGun, {
        Nametag = {
            Visible = Options.Nametag.Visible,
            Text = "Flare Gun - {distance}",
            TextSize = Options.Nametag.TextSize,
            Color = Options.Nametag.Color,
            OutlineColor = Options.Nametag.OutlineColor,
            Offset = Options.Nametag.Offset
        },
        Cham = {
            Visible = Options.Cham.Visible,
            Color = Options.Cham.Color,
            OutlineColor = Options.Cham.OutlineColor,
        },
        OnDestroy = function(ESPObject)
            print("FlareGun Index Destroy")
            ESPObjects.FlareGun = nil
        end
    })
end

--<>><><><><><><><><>--
local function GetAllScraps()
    local list = {}

    for _, Spawner in ipairs(ScrapSpawns:GetChildren()) do
        if not Spawner:FindFirstChildWhichIsA("Model") then
            continue
        end

        if Spawner:FindFirstChildWhichIsA("Model"):FindFirstChild("Scrap") then
            table.insert(list, Spawner:FindFirstChildWhichIsA("Model"):FindFirstChild("Scrap"))
        end
    end

    return list
end

local function IndexScrap(Scrap : Model)
    if not Scrap then
        return
    end

    local Options = Config.Render.Scrap

    local Object = ESPLibrary.new(Scrap, {
        Nametag = {
            Visible = Options.Nametag.Visible,
            Text = "Scrap - Lv." .. tostring(Scrap.Parent.LevelVal.Value) .. " - {distance}",
            TextSize = Options.Nametag.TextSize,
            Color = Options.Nametag.Color,
            OutlineColor = Options.Nametag.OutlineColor,
            Offset = Options.Nametag.Offset
        },
        Cham = {
            Visible = Options.Cham.Visible,
            Color = Options.Cham.Color,
            OutlineColor = Options.Cham.OutlineColor,
        },
        OnDestroy = function(ESPObject)
            print("Scrap Index Destroy")
            table.remove(ESPObjects.Scrap, table.find(ESPObjects.Scrap, ESPObject))
        end
    })

    if Object then
        table.insert(ESPObjects.Scrap, Object)
    end
end

local function IndexAllScraps()
    for _, Scrap in ipairs(GetAllScraps()) do
        IndexScrap(Scrap)
    end
end

--<>><><><><><><><><>--
local function IndexWaypoint(LocationPoint : Part)
    if not LocationPoint then
        return
    end

    local Options = Config.Render.Waypoint

    local text
    if LocationPoint.Name:find("Station") then
        text = "Power Station"
    else
        text = LocationPoint.Name:gsub("MSG", ""):gsub("(%l)(%u)", "%1 %2")
    end

    local Object = ESPLibrary.new(LocationPoint, {
        Nametag = {
            Visible = Options.Nametag.Visible,
            Text = "The " .. text .. " - {distance}",
            TextSize = Options.Nametag.TextSize,
            Color = Options.Nametag.Color,
            OutlineColor = Options.Nametag.OutlineColor,
            Offset = Options.Nametag.Offset
        },
        Cham = {
            Visible = Options.Cham.Visible
        },
        OnDestroy = function(ESPObject)
            print("Waypoint Index Destroy")
            table.remove(ESPObjects.Waypoint, table.find(ESPObjects.Waypoint, ESPObject))
        end
    })

    if Object then
        table.insert(ESPObjects.Waypoint, Object)
    end
end

local function IndexAllWaypoints()
    for _, LocationPoint in ipairs(LocationPoints:GetChildren()) do
        IndexWaypoint(LocationPoint)
    end
end

-->> Others:
local function CleanUp()
    warn("Clean Up?")

    for _, v in pairs(getloadedmodules()) do
		if v.Name == "M_H" then
			local module = require(v)
			hookfunction(module.TakeStamina, Hooks.Stamina)
		end
	end

    hookmetamethod(game, "__namecall", Hooks.FallDamage)

    for key, category in pairs(ESPObjects) do
        if type(category) == "table" then
            for idx, ESPObject in ipairs(category) do
                ESPObject:Destroy()
                table.remove(category, idx)
            end
        else
            category:Destroy()
            ESPObjects[key] = nil
        end
    end
end


--<< GUI >>--
local Window = Rayfield:CreateWindow({
    Name = "JscioHub - The Rake Remastered",
    LoadingTitle = "The Rake Remastered Script",
    LoadingSubtitle = "by JscioHub",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "JscioHub"
    }
})

local Tabs = {
    Movement = Window:CreateTab("Movement"),
    Render = Window:CreateTab("Render"),
    Utility = Window:CreateTab("Utility"),
    World = Window:CreateTab("World"),
    Misc = Window:CreateTab("Misc"),
    Settings = Window:CreateTab("Settings"),
    Credits = Window:CreateTab("Credits")
}

-->> Movement
do
    local Tab = Tabs.Movement

    Tab:CreateSection("Blatant") do
        local Options = Config.Movement

        Tab:CreateToggle({
            Name = "No Stamina Drain",
            CurrentValue = Options.NoStaminaDrain,
            Flag = "Movement.NoStaminaDrain",
            Callback = function(bool)
                Options.NoStaminaDrain = bool
                print(bool)
            end
        })

        Tab:CreateToggle({
            Name = "No Fall Damage",
            CurrentValue = Options.NoFallDamage,
            Flag = "Movement.NoFallDamage",
            Callback = function(bool)
                Options.NoFallDamage = bool
            end
        })
    end
end

-->> Render
do
    local Tab = Tabs.Render
    
    Tab:CreateSection("Players") do
        local Options = Config.Render.Players

        Tab:CreateToggle({
            Name = "Players Nametag Enabled",
            CurrentValue = Options.Nametag.Visible,
            Flag = "Render.Players.Nametag.Visible",
            Callback = function(bool)
                Options.Nametag.Visible = bool
                UpdateIndex("Players")
            end
        })

        Tab:CreateToggle({
            Name = "Players Cham Enabled",
            CurrentValue = Options.Cham.Visible,
            Flag = "Render.Players.Cham.Visible",
            Callback = function(bool)
                Options.Cham.Visible = bool
                UpdateIndex("Players")
            end
        })
    end

    Tab:CreateSection("Rake") do
        local Options = Config.Render.Rake

        Tab:CreateToggle({
            Name = "Rake Nametag Enabled",
            CurrentValue = Options.Nametag.Visible,
            Flag = "Render.Rake.Nametag.Visible",
            Callback = function(bool)
                Options.Nametag.Visible = bool
                UpdateIndex("Rake")
            end
        })

        Tab:CreateToggle({
            Name = "Rake Cham Enabled",
            CurrentValue = Options.Cham.Visible,
            Flag = "Render.Rake.Cham.Visible",
            Callback = function(bool)
                Options.Cham.Visible = bool
                UpdateIndex("Rake")
            end
        })
    end

    Tab:CreateSection("Flare Gun") do
        local Options = Config.Render.FlareGun

        Tab:CreateToggle({
            Name = "Flare Gun Nametag Enabled",
            CurrentValue = Options.Nametag.Visible,
            Flag = "Render.FlareGun.Nametag.Visible",
            Callback = function(bool)
                Options.Nametag.Visible = bool
                UpdateIndex("FlareGun")
            end
        })

        Tab:CreateToggle({
            Name = "Flare Gun Cham Enabled",
            CurrentValue = Options.Cham.Visible,
            Flag = "Render.FlareGun.Cham.Visible",
            Callback = function(bool)
                Options.Cham.Visible = bool
                UpdateIndex("FlareGun")
            end
        })
    end

    Tab:CreateSection("Scrap") do
        local Options = Config.Render.Scrap

        Tab:CreateToggle({
            Name = "Scrap Nametag Enabled",
            CurrentValue = Options.Nametag.Visible,
            Flag = "Render.Scrap.Nametag.Visible",
            Callback = function(bool)
                Options.Nametag.Visible = bool
                UpdateIndex("Scrap")
            end
        })

        Tab:CreateToggle({
            Name = "Scrap Cham Enabled",
            CurrentValue = Options.Cham.Visible,
            Flag = "Render.Scrap.Cham.Visible",
            Callback = function(bool)
                Options.Cham.Visible = bool
                UpdateIndex("Scrap")
            end
        })
    end

    Tab:CreateSection("Waypoint") do
        local Options = Config.Render.Waypoint

        Tab:CreateToggle({
            Name = "Waypoint Nametag Enabled",
            CurrentValue = Options.Nametag.Visible,
            Flag = "Render.Waypoint.Nametag.Visible",
            Callback = function(bool)
                Options.Nametag.Visible = bool
                UpdateIndex("Waypoint")
            end
        })
    end
end


--<< Initalize >>--
IndexAllPlayers()
IndexRake()
IndexFlareGun()
IndexAllScraps()
IndexAllWaypoints()

coroutine.wrap(function()
    task.wait(5)

    ModifyStamina()
    ModifyFallDamage()
end)()


--<< Indexer >>--
workspace.ChildAdded:Connect(function(child)
    if child.Name == "Rake" then
        child:WaitForChild("HumanoidRootPart")
        IndexRake()
    elseif child.Name == "FlareGunPickUp" then
        IndexFlareGun()
    end
end)

for _, Spawner in ipairs(ScrapSpawns:GetChildren()) do
    Spawner.ChildAdded:Connect(function(child)
        IndexScrap(child:WaitForChild("Scrap"))
    end)
end

coroutine.wrap(function()
    while task.wait(5) do
        IndexAllPlayers()
    end
end)()
