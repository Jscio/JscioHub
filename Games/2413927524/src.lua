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
    Scraps = {},
    Waypoints = {},
    SupplyCrates = {},
    Traps = {}
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
        Nametag = {
            Players = {
                Visible = true,
                TextSize = 8,
                TextColor = { Color3.new(1, 1, 1), 0 },
                TextOutlineColor = { Color3.new(0, 1, 0), 0.8 }
            },
            Rake = {
                Visible = true,
                TextSize = 10,
                TextColor = { Color3.new(1, 1, 1), 0 },
                TextOutlineColor = { Color3.new(1, 0, 0), 0.5 }
            },
            FlareGun = {
                Visible = true,
                TextSize = 10,
                TextColor = { Color3.new(1, 1, 1), 0 },
                TextOutlineColor = { Color3.new(0, 0, 0), 0.5}
            },
            Scrap = {
                Visible = true,
                TextSize = 8,
                TextColor = { Color3.new(1, 1, 1), 0 },
                TextOutlineColor = { Color3.new(0, 0, 0), 0.5}
            },
            Waypoint = {
                Visible = true,
                TextSize = 10,
                TextColor = { Color3.new(1, 1, 1), 0 },
                TextOutlineColor = { Color3.new(0, 0.5, 1), 0.7}
            },
            SupplyCrate = {
                Visible = true,
                TextSize = 10,
                TextColor = { Color3.new(1, 1, 1), 0 },
                TextOutlineColor = { Color3.new(0, 0, 0), 0.5}
            },
            Trap = {
                Visible = false,
                TextSize = 8,
                TextColor = { Color3.new(1, 1, 1), 0 },
                TextOutlineColor = { Color3.new(0, 0, 0), 0.5}
            }
        },
        Cham = {
            Players = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(0, 1, 0), 0 }
            },
            Rake = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(1, 0, 0), 0 }
            },
            FlareGun = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(1, 0, 1), 0 }
            },
            Scrap = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(1, 1, 0), 0 }
            },
            SupplyCrate = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(1, 1, 0), 0 }
            },
            Trap = {
                Visible = true,
                Color = { Color3.new(1, 1, 1), 0.9 },
                OutlineColor = { Color3.new(1, 0, 0), 0 }
            }
        }
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
local function IndexPlayer(Character : Model)
    if not Character then
        return
    end

    local nametagConfig = Config.Render.Nametag.Players
    local chamConfig = Config.Render.Cham.Players

    local Object = ESPLibrary.new(Character, {
        Visible = true,
        Nametag = {
            Visible = nametagConfig.Visible,
            AlwaysOnTop = true,
            MaxDistance = math.huge,
            Text = Character.Name .. " - {distance}",
            TextSize = nametagConfig.TextSize,
            Color = nametagConfig.TextColor,
            OutlineColor = nametagConfig.TextOutlineColor,
            Font = Enum.Font.Ubuntu,
            Offset = Vector3.new(0, 1.5, 0)
        },
        Cham = {
            Visible = chamConfig.Visible,
            AlwaysOnTop = true,
            Color = chamConfig.Color,
            OutlineColor = chamConfig.OutlineColor,
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

        IndexPlayer(Player.Character:WaitForChild("Head"))
    end
end

local function UpdatePlayerIndex()
    
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
        Blatant:Toggle("No Stamina Drain", "Stamina will not be drained by running", function(bool)
            Config.Movement.NoStaminaDrain = bool
        end)

        Blatant:Toggle("No Fall Damage", "Removes damage from falling", function(bool)
            Config.Movement.NoFallDamage = bool
        end)

        Blatant:Label("")

        Blatant:Keybind("Quick Run", "Automatically run without accelerating", Enum.KeyCode.Q, function()
            
        end)
    end
end

-->> Render
do
    local Tab = Tabs.Render
end

-->> Settings
do
    local Tab = Tabs.Settings
    
    local Menu = Tab:Section("Menu") do
        Menu:Keybind("Toggle GUI", "Press the keybind to hide or show GUI", Enum.KeyCode.RightControl, function()
            KavoUI:ToggleUI()
        end)
    end

    local Themes = Tab:Section("Themes") do
        
    end
end

--<< Initialize >>--
-- KavoUI.OnDestroy = CleanUp() -- Got kicked instead?

IndexAllPlayers()

coroutine.wrap(function()
    task.wait(5)

    ModifyStamina()
    ModifyFallDamage()
end)()

--<< Loops >>--
coroutine.wrap(function()

end)()
