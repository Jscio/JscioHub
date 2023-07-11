--[[
    The Rake Remastered - 2413927524
    by Jscio
]]--

--[[
    TODO: Make `ESPObject:Update()` updates the only thing it gives.
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

print("JscioHub v0.1.8")

if Players.LocalPlayer.Character == nil or not Players.LocalPlayer.Character then
    warn("Unable to find localplayer character. Yielding...")
    Players.LocalPlayer.CharacterAdded:Wait()
    Players.LocalPlayer.Character:WaitForChild("Humanoid")
    Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    print("Localplayer character found!")
end


--<< Libraries >>--
local ESPLibrary = loadstring(game:HttpGet(getgenv().JscioHub .. "/Libraries/ESPLibrary.lua"))()
local GUILibrary = loadstring(game:HttpGet(getgenv().JscioHub .. "/Libraries/GUILibrary.lua" ))() -- Modified version of Rayfield
local AdditionalGUI = loadstring(game:HttpGet(getgenv().JscioHub .. "/Games/2413927524/AdditionalGUI.lua"))()


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
    Map = workspace:WaitForChild("Map")
}


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
                TextSize = 10,
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
                TextSize = 14,
                Color = { Color3.new(1, 1, 1), 0 },
                OutlineColor = { Color3.new(0, 0.5, 1), 0.7},
                Offset = Vector3.new(0, 6, 0)
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
    },
    World = {
        Borders = {
            CanCollide = true,
            Visible = false
        },
        NoFog = false,
        Sky = {
            AlwaysDay = false,
            AlwaysNight = false,
            NoBloodHour = false
        }
    },
    Misc = {
        TimeNPower = true
    }
}

local SecondaryConfig = {
    Render = {
        RakeNotification = true,
        FlareGunNotification = true,
        SupplyCrateNotification = true,
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

--<><><><><><><><><>--
local function IndexPlayer(Character : Model, displayName)
    if not Character then
        return
    end

    local Options = Config.Render.Players

    local text
    if Character.Name == displayName then
        text = displayName
    else
        text = displayName .. " - " .. Character.Name
    end

    local Object = ESPLibrary.new(Character, {
        Nametag = {
            Visible = Options.Nametag.Visible,
            Text = text .. " - {distance} studs - {health} hp",
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

        IndexPlayer(Player.Character, Player.DisplayName)
    end
end

--<><><><><><><><><>--
local function IndexRake()
    local Rake = workspace:FindFirstChild("Rake")

    if not Rake then
        return
    end

    local Options = Config.Render.Rake

    ESPObjects.Rake = ESPLibrary.new(Rake, {
        Nametag = {
            Visible = Options.Nametag.Visible,
            Text = "The Rake - {distance} studs - {health} hp",
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
            ESPObjects.Rake = nil
        end
    })

    if ESPObjects.Rake and SecondaryConfig.Render.RakeNotification then
        GUILibrary:Notify({
            Title = "The Rake Notifier",
            Content = "The Rake has emerged from its cave.",
            Duration = 3
        })
    end
end

--<><><><><><><><><>--
local function IndexFlareGun()
    local FlareGun = workspace:FindFirstChild("FlareGunPickUp")

    if not FlareGun then
        return
    end

    local Options = Config.Render.FlareGun

    ESPObjects.FlareGun = ESPLibrary.new(FlareGun, {
        Nametag = {
            Visible = Options.Nametag.Visible,
            Text = "Flare Gun - {distance} studs",
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
            ESPObjects.FlareGun = nil
        end
    })

    if ESPObjects.FlareGun and SecondaryConfig.Render.FlareGunNotification then
        GUILibrary:Notify({
            Title = "Flare Gun Notifier",
            Content = "Flare Gun has been dropped",
            Duration = 3
        })
    end
end

--<><><><><><><><><>--
local ScrapSpawns = Folders.Filter:WaitForChild("ScrapSpawns")

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
            Text = "Scrap - Lvl " .. tostring(Scrap.Parent.LevelVal.Value) .. " - {distance} studs",
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

--<><><><><><><><><>--
local LocationPoints = Folders.Filter:WaitForChild("LocationPoints"):GetChildren()

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
            Text = "The " .. text .. " - {distance} studs",
            TextSize = Options.Nametag.TextSize,
            Color = Options.Nametag.Color,
            OutlineColor = Options.Nametag.OutlineColor,
            Offset = Options.Nametag.Offset
        },
        Cham = {
            Visible = Options.Cham.Visible
        },
        OnDestroy = function(ESPObject)
            table.remove(ESPObjects.Waypoint, table.find(ESPObjects.Waypoint, ESPObject))
        end
    })

    if Object then
        table.insert(ESPObjects.Waypoint, Object)
    end
end

local function IndexAllWaypoints()
    for _, LocationPoint in ipairs(LocationPoints) do
        IndexWaypoint(LocationPoint)
    end
end

--<><><><><><><><><>--
local SupplyCrates = Folders.Debris:WaitForChild("SupplyCrates")

local function IndexSupplyCrate(Box : Model)
    if not Box then
        return
    end

    local Options = Config.Render.SupplyCrate

    local Object = ESPLibrary.new(Box, {
        Nametag = {
            Visible = Options.Nametag.Visible,
            Text = "Supply Crate - {distance} studs",
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
            table.remove(ESPObjects.SupplyCrate, table.find(ESPObjects.SupplyCrate, ESPObject))
        end
    })

    if Object then
        if SecondaryConfig.Render.SupplyCrateNotification then
            GUILibrary:Notify({
                Title = "Supply Crate Notifier",
                Content = "Supply Crate has been dropped",
                Duration = 3
            })
        end
        table.insert(ESPObjects.SupplyCrate, Object)
    end
end

local function IndexAllSupplyCrates()
    for _, Box in ipairs(SupplyCrates:GetChildren()) do
        IndexSupplyCrate(Box)
    end
end

--<><><><><><><><><>--
local TrapsFolder = Folders.Debris:WaitForChild("Traps")

local function IndexTrap(Trap : Model)
    if not Trap then
        return
    end

    local Options = Config.Render.Trap

    local Object = ESPLibrary.new(Trap, {
        Nametag = {
            Visible = Options.Nametag.Visible,
            Text = "Trap - {distance} studs",
            TextSize = Options.Nametag.TextSize,
            Color = Options.Nametag.Color,
            OutlineColor = Options.Nametag.OutlineColor,
            Offset = Options.Nametag.Offset
        },
        Cham = {
            Visible = Options.Cham.Visible
        },
        OnDestroy = function(ESPObject)
            table.remove(ESPObjects.Trap, table.find(ESPObjects.Trap, ESPObject))
        end
    })

    if Object then
        table.insert(ESPObjects.Trap, Object)
    end
end

local function IndexAllTraps()
    for _, Trap in ipairs(TrapsFolder:GetChildren()) do
        IndexTrap(Trap)
    end
end

-->> World:
local InvisibleWalls = Folders.Filter:WaitForChild("InvisibleWalls"):GetChildren() do
    for _, Border in ipairs(InvisibleWalls) do
        if Border:IsA("BasePart") or Border:IsA("Part") then
            Border.Material = Enum.Material.Neon
        end
    end
end

local function UpdateBorders()
    for _, Border in ipairs(InvisibleWalls) do
        if Border:IsA("BasePart") or Border:IsA("Part") then
            Border.CanCollide = Config.World.Borders.CanCollide
            Border.Transparency = Config.World.Borders.Visible and 0.8 or 1
            Border.Color = Color3.fromRGB(255, 0, 0)
        end
    end
end

--<><><><><><><><><>--
local CurrentLightingProperties = ReplicatedStorage:WaitForChild("CurrentLightingProperties")

local function EraseFog()
    Lighting.FogEnd = 9999
    CurrentLightingProperties.FogEnd.Value = 9999
end

--<><><><><><><><><>--
local DayProperties = ReplicatedStorage:WaitForChild("DayProperties"):GetChildren()
local NightProperties = ReplicatedStorage:WaitForChild("NightProperties"):GetChildren()
local BloodHourColor = Lighting:WaitForChild("BloodHourColor")

local NightValue = ReplicatedStorage:WaitForChild("Night")
local TurningToDay = ReplicatedStorage:WaitForChild("TurningToDay")

local function UpdateToDay()
    for _, value in ipairs(DayProperties) do
        Lighting[value.Name] = value.Value
        if CurrentLightingProperties:FindFirstChild(value.Name) then
            CurrentLightingProperties[value.Name].Value = value.Value
        end
    end
end

local function UpdateToNight()
    for _, value in ipairs(NightProperties) do
        Lighting[value.Name] = value.Value
        if CurrentLightingProperties:FindFirstChild(value.Name) then
            CurrentLightingProperties[value.Name].Value = value.Value
        end
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
local Window = GUILibrary:CreateWindow({
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

        Tab:CreateToggle({
            Name = "Rake Notifier",
            CurrentValue = SecondaryConfig.Render.RakeNotification,
            Flag = "Render.Rake.Notification",
            Callback = function(bool)
                SecondaryConfig.Render.RakeNotification = bool
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

        Tab:CreateToggle({
            Name = "Flare Gun Notifier",
            CurrentValue = SecondaryConfig.Render.FlareGunNotification,
            Flag = "Render.FlareGun.Notification",
            Callback = function(bool)
                SecondaryConfig.Render.FlareGunNotification = bool
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

    Tab:CreateSection("Supply Crates") do
        local Options = Config.Render.SupplyCrate

        Tab:CreateToggle({
            Name = "Supply Crate Nametag Enabled",
            CurrentValue = Options.Nametag.Visible,
            Flag = "Render.SupplyCrate.Nametag.Visible",
            Callback = function(bool)
                Options.Nametag.Visible = bool
                UpdateIndex("SupplyCrate")
            end
        })

        Tab:CreateToggle({
            Name = "Supply Crate Cham Enabled",
            CurrentValue = Options.Cham.Visible,
            Flag = "Render.SupplyCrate.Cham.Visible",
            Callback = function(bool)
                Options.Cham.Visible = bool
                UpdateIndex("SupplyCrate")
            end
        })

        Tab:CreateToggle({
            Name = "Supply Crate Notifier",
            CurrentValue = SecondaryConfig.Render.SupplyCrateNotification,
            Flag = "Render.SupplyCrate.Notification",
            Callback = function(bool)
                SecondaryConfig.Render.SupplyCrateNotification = bool
            end
        })
    end

    Tab:CreateSection("Trap") do
        local Options = Config.Render.Trap

        Tab:CreateToggle({
            Name = "Trap Nametag Enabled",
            CurrentValue = Options.Nametag.Visible,
            Flag = "Render.Trap.Nametag.Visible",
            Callback = function(bool)
                Options.Nametag.Visible = bool
                UpdateIndex("Trap")
            end
        })

        Tab:CreateToggle({
            Name = "Trap Cham Enabled",
            CurrentValue = Options.Cham.Visible,
            Flag = "Render.Trap.Cham.Visible",
            Callback = function(bool)
                Options.Cham.Visible = bool
                UpdateIndex("Trap")
            end
        })
    end
end

-->> World
do
    local Tab = Tabs.World

    Tab:CreateLabel("CLIENT SIDED: You are the only one affected.")

    Tab:CreateSection("Map Modification") do
        local Options = Config.World.Borders

        Tab:CreateToggle({
            Name = "Borders Collision Enabled",
            CurrentValue = Options.CanCollide,
            Flag = "World.Borders.CanCollide",
            Callback = function(bool)
                Options.CanCollide = bool
                UpdateBorders()
            end
        })

        Tab:CreateToggle({
            Name = "Show Borders",
            CurrentValue = Options.Visible,
            Flag = "World.Borders.Visible",
            Callback = function(bool)
                Options.Visible = bool
                UpdateBorders()
            end
        })

        Tab:CreateToggle({
            Name = "No Fog",
            CurrentValue = Config.World.NoFog,
            Flag = "World.NoFog",
            Callback = function(bool)
                Config.World.NoFog = bool

                if not bool then
                    if not NightValue.Value or TurningToDay.Value then
                        UpdateToDay()
                    elseif NightValue.Value and not TurningToDay.Value then
                        UpdateToNight()
                    end
                end
            end
        })
    end

    Tab:CreateSection("Sky Modification") do
        local Options = Config.World.Sky
        local identity = false

        Tab:CreateToggle({
            Name = "Always Day Time",
            CurrentValue = Options.AlwaysDay,
            Flag = "World.Sky.AlwaysDay",
            Callback = function(bool)
                Options.AlwaysDay = bool

                if bool then
                    if not identity and Options.AlwaysNight then
                        identity = true
                        GUILibrary.Flags["World.Sky.AlwaysNight"]:Set(false)
                        identity = false
                    end
                else
                    if not NightValue.Value or TurningToDay.Value then
                        UpdateToDay()
                    elseif NightValue.Value and not TurningToDay.Value then
                        UpdateToNight()
                    end
                end
            end
        })

        Tab:CreateToggle({
            Name = "Always Night Time",
            CurrentValue = Options.AlwaysNight,
            Flag = "World.Sky.AlwaysNight",
            Callback = function(bool)
                Options.AlwaysNight = bool

                if bool then
                    if not identity and Options.AlwaysDay then
                        identity = true
                        GUILibrary.Flags["World.Sky.AlwaysDay"]:Set(false)
                        identity = false
                    end
                else
                    if not NightValue.Value or TurningToDay.Value then
                        UpdateToDay()
                    elseif NightValue.Value and not TurningToDay.Value then
                        UpdateToNight()
                    end
                end
            end
        })

        Tab:CreateToggle({
            Name = "No Blood Hour Ambient",
            CurrentValue = Options.NoBloodHour,
            Flag = "World.Sky.NoBloodHour",
            Callback = function(bool)
                Options.NoBloodHour = bool
                BloodHourColor.Enabled = bool
            end
        })
    end
end

-->> Misc
do
    local Tab = Tabs.Misc
    local Options = Config.Misc

    Tab:CreateSection("Additional GUI") do
        Tab:CreateToggle({
            Name = "Time & Power GUI",
            CurrentValue = Options.TimeNPower,
            Flag = "Misc.TimeNPower",
            Callback = function(bool)
                Options.TimeNPower = bool

                if AdditionalGUI.Constructed then
                    if bool then
                        AdditionalGUI.TimePowerUI:Open()
                    else
                        AdditionalGUI.TimePowerUI:Close()
                    end
                end
            end
        })
    end
end


--<< Initalize >>--
AdditionalGUI:Construct() do
    if Config.Misc.TimeNPower then
        AdditionalGUI.TimePowerUI:Open()
    end
end

IndexAllPlayers()
IndexRake()
IndexFlareGun()
IndexAllScraps()
IndexAllWaypoints()
IndexAllSupplyCrates()
IndexAllTraps()

coroutine.wrap(function()
    task.wait(5)

    ModifyStamina()
    ModifyFallDamage()
end)()


--<< Updater >>--
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

SupplyCrates.ChildAdded:Connect(function(child)
    IndexSupplyCrate(child)
end)

TrapsFolder.ChildAdded:Connect(function(child)
    IndexTrap(child)
end)

local TimerValue = ReplicatedStorage:WaitForChild("Timer")
TimerValue:GetPropertyChangedSignal("Value"):Connect(function()
    if Config.Misc.TimeNPower and AdditionalGUI.Constructed then
        AdditionalGUI.TimePowerUI:UpdateTime(TimerValue.Value)
    end
end)

local PowerLevel = ReplicatedStorage:WaitForChild("PowerValues"):WaitForChild("PowerLevel")
PowerLevel:GetPropertyChangedSignal("Value"):Connect(function()
    if Config.Misc.TimeNPower and AdditionalGUI.Constructed then
        AdditionalGUI.TimePowerUI:UpdatePower(PowerLevel.Value)
    end
end)

coroutine.wrap(function()
    while task.wait(5) do
        IndexAllPlayers()
    end
end)()

--<< Game Loop >>--
while true do
    if Config.World.Sky.AlwaysDay then
        UpdateToDay()
    end

    if Config.World.Sky.AlwaysNight then
        UpdateToNight()
    end

    if Config.World.NoFog then
        EraseFog()
    end

    for i = 1, 3, 1 do
        RunService.Heartbeat:Wait()
    end
end
