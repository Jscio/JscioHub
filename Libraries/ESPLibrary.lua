--<< Services >>--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--<< Variables >>--
local LocalPlayer = Players.LocalPlayer

local MainFolder = Instance.new("Folder", game:GetService("CoreGui"))
local NametagsFolder = Instance.new("Folder", MainFolder)
local ChamsFolder = Instance.new("Folder", MainFolder)

local loopConnection = true

local ESPObjects = {}

local defaultOptions = {
    Visible = true,
    Nametag = {
        Visible = true,
        AlwaysOnTop = true,
        MaxDistance = math.huge,
        Text = "text",
        TextSize = 14,
        Color = { Color3.new(1, 1, 1), 0 },
        OutlineColor = { Color3.new(0, 0, 0), 0.5 },
        Font = Enum.Font.Ubuntu,
        Offset = Vector3.new(0, 0, 0)
    },
    Cham = {
        Visible = true,
        AlwaysOnTop = true,
        Color = { Color3.new(1, 0, 0), 0.5 },
        OutlineColor = { Color3.new(1, 1, 1), 0 },
    },
    OnDestroy = function(ESPObject) print("Default") end
}

--<< Functions >>--
local function SetDefault(options, _defaultOptions)
	for i, v in pairs(_defaultOptions) do
		if type(v) == "table" then
			if options[i] == nil then
				options[i] = _defaultOptions[i]
			else
				SetDefault(options[i], _defaultOptions[i])
			end

			continue
		end
		
		if options[i] == nil then
			options[i] = v
		end
	end
end

local function UpdateTable(options, changes)
    for i, v in pairs(changes) do
        if type(v) == "table" then
            UpdateTable(options[i], v)
            continue
        end

        options[i] = v
    end
end

--<< Module >>--
local ESPLibrary = {}

function ESPLibrary.new(Target : Instance, options : table)
    if ESPLibrary.HasMark(Target) then
        return
    end
    ESPLibrary.Mark(Target)

    assert(Target, "missing argument #1 (Instance expected)")
    if options == nil then
        options = {}
    end
    SetDefault(options, defaultOptions)

    local self = {}
    self.Target = Target
    self.Options = options

    function self:Update(newOptions)
        UpdateTable(options, newOptions)

        local Nametag = options.Nametag do
            local Billboard = self.Nametag
            Billboard.Enabled = Nametag.Visible
            Billboard.AlwaysOnTop = Nametag.AlwaysOnTop
            Billboard.MaxDistance = Nametag.MaxDistance
            Billboard.StudsOffset = Nametag.Offset

            local TextLabel = Billboard.TextLabel
            TextLabel.TextSize = Nametag.TextSize
            TextLabel.Font = Nametag.Font
            TextLabel.TextColor3 = Nametag.Color[1]
            TextLabel.TextTransparency = Nametag.Color[2]
            TextLabel.TextStrokeColor3 = Nametag.OutlineColor[1]
            TextLabel.TextStrokeTransparency = Nametag.OutlineColor[2]
        end

        local Cham = options.Cham do
            local Highlight = self.Cham
            Highlight.Enabled = Cham.Visible
            Highlight.DepthMode = Cham.AlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
            Highlight.FillColor = Cham.Color[1]
            Highlight.FillTransparency = Cham.Color[2]
            Highlight.OutlineColor = Cham.OutlineColor[1]
            Highlight.OutlineTransparency = Cham.OutlineColor[2]
        end
    end

    function self:Destroy()
        if self.Observer then
            self.Observer:Disconnect()
        end

        self.Nametag:Destroy()
        self.Cham:Destroy()

        options.OnDestroy(self)
        table.remove(ESPObjects, table.find(ESPObjects, self))
        self = nil
    end

    function self:_construct()
        local Nametag = options.Nametag do
            local Billboard = Instance.new("BillboardGui")
            Billboard.Name = "Nametag"
            Billboard.ClipsDescendants = false
            Billboard.ResetOnSpawn = false
            Billboard.Enabled = Nametag.Visible
            Billboard.Size = UDim2.new(1, 0, 1, 0)
            Billboard.AlwaysOnTop = Nametag.AlwaysOnTop
            Billboard.MaxDistance = Nametag.MaxDistance
            Billboard.StudsOffset = Nametag.Offset

            local TextLabel = Instance.new("TextLabel")
            TextLabel.BackgroundTransparency = 1
            TextLabel.Size = UDim2.new(1, 0, 1, 0)
            TextLabel.Text = Nametag.Text
            TextLabel.TextSize = Nametag.TextSize
            TextLabel.Font = Nametag.Font
            TextLabel.TextColor3 = Nametag.Color[1]
            TextLabel.TextTransparency = Nametag.Color[2]
            TextLabel.TextStrokeColor3 = Nametag.OutlineColor[1]
            TextLabel.TextStrokeTransparency = Nametag.OutlineColor[2]

            TextLabel.Parent = Billboard
            Billboard.Adornee = Target:FindFirstChild("Head") or Target
            Billboard.Parent = NametagsFolder

            self.Nametag = Billboard
        end

        local Cham = options.Cham do
            local Highlight = Instance.new("Highlight")
            Highlight.Name = "Cham"
            Highlight.DepthMode = Cham.AlwaysOnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
            Highlight.FillColor = Cham.Color[1]
            Highlight.FillTransparency = Cham.Color[2]
            Highlight.OutlineColor = Cham.OutlineColor[1]
            Highlight.OutlineTransparency = Cham.OutlineColor[2]

            Highlight.Adornee = Target
            Highlight.Parent = ChamsFolder

            self.Cham = Highlight
        end
    end

    function self:_observeTarget()
        self.Observer = Target.AncestryChanged:Connect(function()
            if Target.Parent == nil then
                self:Destroy()
            end
        end)
    end
    
    self:_construct()
    self:_observeTarget()

    table.insert(ESPObjects, self)
    return self
end

function ESPLibrary.Mark(Object : Instance)
    Object:SetAttribute("Mark", true)
end

function ESPLibrary.HasMark(Object : Instance)
    return Object:GetAttribute("Mark")
end

function ESPLibrary:Unload()
    if loopConnection then
        loopConnection = false
    end
end

--<< Loop >>--
coroutine.wrap(function()
    while loopConnection do
        for _, ESPObject in ipairs(ESPObjects) do
            if ESPObject.Options.Nametag.Visible then
                local Target : Instance = ESPObject.Target

                local isBodyPart = false
                local Humanoid = Target:FindFirstChildWhichIsA("Humanoid") do
                    if Target.Parent ~= nil and not Humanoid then
                        if Target.Parent:FindFirstChildWhichIsA("Humanoid") then
                            isBodyPart = true
                            Humanoid = Target.Parent:FindFirstChildWhichIsA("Humanoid")
                        end
                    end
                end
                
                local distance = 0
                if Humanoid then
                    if isBodyPart then
                        distance = (workspace.CurrentCamera.CFrame.Position - Target.CFrame.Position).Magnitude
                    else
                        distance = (workspace.CurrentCamera.CFrame.Position - Target.HumanoidRootPart.CFrame.Position).Magnitude
                    end
                elseif Target:IsA("Model") then
                    distance = (workspace.CurrentCamera.CFrame.Position - Target.WorldPivot.Position).Magnitude
                else
                    distance = (workspace.CurrentCamera.CFrame.Position - Target.CFrame.Position).Magnitude
                end
                
                ESPObject.Nametag.TextLabel.Text = ESPObject.Options.Nametag.Text:gsub("{distance}", tostring(math.round(distance)))
            end
        end
    
        for i = 1, 5, 1 do
            RunService.Heartbeat:Wait()
        end
    end
end)()

return ESPLibrary