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
local KavoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jscio/JscioHub/main/Libraries/UILibrary.lua"))() -- Modified version of Kavo UI Library


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

    if type(ESPObjects[category]) == "table" then
        for _, ESPObject in ipairs(ESPObjects[category]) do
            ESPObject:Update(Config.Render[category])
        end
    else
        ESPObjects[category]:Update(Config.Render[category])
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
local Window = KavoUI.Window("The Rake Remastered - JscioHub", "DarkTheme")

local Tabs = {
    Movement = Window:Tab("Movement"),
    Render = Window:Tab("Render"),
    Utility = Window:Tab("Utility"),
    World = Window:Tab("World"),
    Misc = Window:Tab("Misc"),
    Settings = Window:Tab("Settings"),
    Credits = Window:Tab("Credits")
}

-->> Movement
do
    local Tab = Tabs.Movement

    local Blatant = Tab:Section("Blatant") do
        local Options = Config.Movement
        Blatant:Toggle("No Stamina Drain", "Stamina will not be drained by running", function(bool)
            Options.NoStaminaDrain = bool
        end)

        Blatant:Toggle("No Fall Damage", "Removes damage from falling", function(bool)
            Options.NoFallDamage = bool
        end)

        Blatant:Label("")

        Blatant:Keybind("Quick Run", "Immediately run without accelerating", Enum.KeyCode.Q, function()
            print("Quick Run!")
        end)
    end
end

-->> Render
do
    local Tab = Tabs.Render

    local SecPlayers = Tab:Section("Players") do
        local Options = Config.Render.Players

        SecPlayers:Toggle("Players Nametag Enabled", "Nametag that shows their name, distance, and health", function(bool)
            Options.Nametag.Visible = bool
            UpdateIndex("Players")
        end)

        SecPlayers:Toggle("Players Cham Enabled", "Cham that shows their glowing body through walls", function(bool)
            Options.Cham.Visible = bool
            UpdateIndex("Players")
        end)

        SecPlayers:Label("")
    end

    local SecRake = Tab:Section("Rake") do
        local Options = Config.Render.Rake

        SecRake:Toggle("Rake Nametag Enabled", "Nametag that shows The Rake name, distance, and health", function(bool)
            Options.Nametag.Visible = bool
            UpdateIndex("Rake")
        end)

        SecRake:Toggle("Rake Cham Enabled", "Cham that shows The Rake glowing body through walls", function(bool)
            Options.Cham.Visible = bool
            UpdateIndex("Rake")
        end)

        SecRake:Label("")
    end

    local SecFlareGun = Tab:Section("Flare Gun") do
        local Options = Config.Render.FlareGun

        SecFlareGun:Toggle("Flare Gun Nametag Enabled", "Nametag that shows its name and distance", function(bool)
            Options.Nametag.Visible = bool
            UpdateIndex("FlareGun")
        end)

        SecFlareGun:Toggle("Flare Gun Cham Enabled", "Cham that shows its glowing body through walls", function(bool)
            Options.Cham.Visible = bool
            UpdateIndex("FlareGun")
        end)

        SecFlareGun:Label("")
    end
end

-->> Settings
do
    local Tab = Tabs.Settings
    
    local Menu = Tab:Section("Menu") do
        Menu:Keybind("Toggle GUI", "Press the keybind to hide or show GUI", Enum.KeyCode.RightControl, function()
            KavoUI:ToggleUI()
        end)

        Menu:Label("")
    end

    local Themes = Tab:Section("Themes") do
        
    end
end


--<< Initalize >>--
IndexAllPlayers()
IndexRake()
IndexFlareGun()

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

coroutine.wrap(function()
    while task.wait(5) do
        IndexAllPlayers()
    end
end)()
