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

do
    Players.LocalPlayer.CharacterAdded:Wait()
    Players.LocalPlayer.Character:WaitForChild("Humanoid")
    Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
end


--<< Libraries >>--
local ESPLibrary = loadstring(game:HttpGet(""))()
local KavoUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()


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
			local hook
			hook = hookfunction(module.TakeStamina, function(something, amount)
				if amount > 0 and Config.Movement.NoStaminaDrain then
					return hook(something, -1)
				end
				
				return hook(something, amount)
			end)
		end
	end
end

local function ModifyFallDamage()
    local hook
    hook = hookmetamethod(game, "__namecall", function(...)
		if getnamecallmethod() == "FireServer" and Config.Movement.NoFallDamage then
			if tostring(...) == "FD_Event" then
				return
			end
		end
		
		return hook(...)
	end)
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
            if bool then
                ModifyStamina()
            end
        end)

        Blatant:Toggle("No Fall Damage", "Removes damage from falling", function(bool)
            Config.Movement.NoFallDamage = bool
        end)
    end
end
