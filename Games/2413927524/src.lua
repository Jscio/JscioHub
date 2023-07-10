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
    }
}


--<< Functions >>--
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

local function CleanUp()
    for _, v in pairs(getloadedmodules()) do
		if v.Name == "M_H" then
			local module = require(v)
			hookfunction(module.TakeStamina, Hooks.Stamina)
		end
	end

    hookmetamethod(game, "__namecall", Hooks.FallDamage)
end

--<< GUI >>--
local Window = KavoUI.Window("The Rake Remastered - JscioHub", "DarkTheme")

local Tabs = {
    Movement = Window:Tab("Movement"),
    Render = Window:Tab("Render"),
    Utility = Window:Tab("Utility"),
    World = Window:Tab("World"),
    Others = Window:Tab("Others"),
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
    end
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
KavoUI.OnDestroy = CleanUp()

coroutine.wrap(function()
    task.wait(5)

    ModifyStamina()
    ModifyFallDamage()
end)()
