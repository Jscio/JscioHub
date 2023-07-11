local TweenService = game:GetService("TweenService")

--<< Module >>--
local AdditionalGUI = {}
AdditionalGUI.__index = AdditionalGUI

function AdditionalGUI:Construct()
	self.Constructed = true
	
	-->> Time & Power UI
	do
		local AscGui = Instance.new("ScreenGui")
		AscGui.Name = "AscGui"
		AscGui.Enabled = false
		AscGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		AscGui.IgnoreGuiInset = true
		AscGui.ResetOnSpawn = false

		local Container = Instance.new("Frame")
		Container.Name = "Container"
		Container.AnchorPoint = Vector2.new(0.5, 0.5)
		Container.Size = UDim2.new(0, 110, 0, 18)
		Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Container.BackgroundTransparency = 1
		Container.Position = UDim2.new(0.5, 0, 0, -15)
		Container.BorderSizePixel = 0
		Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Container.Parent = AscGui

		local Time = Instance.new("TextLabel")
		Time.Name = "Time"
		Time.Size = UDim2.new(0.66, 0, 1, 0)
		Time.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Time.BackgroundTransparency = 1
		Time.Position = UDim2.new(0, 19, 0, 0)
		Time.BorderSizePixel = 0
		Time.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Time.FontSize = Enum.FontSize.Size14
		Time.TextSize = 13
		Time.TextColor3 = Color3.fromRGB(255, 255, 255)
		Time.Text = "99:99"
		Time.Font = Enum.Font.Ubuntu
		Time.TextXAlignment = Enum.TextXAlignment.Left
		Time.Parent = Container

		local TimeIcon = Instance.new("ImageLabel")
		TimeIcon.Name = "TimeIcon"
		TimeIcon.AnchorPoint = Vector2.new(0, 0.5)
		TimeIcon.Size = UDim2.new(0, 15, 0, 15)
		TimeIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TimeIcon.BackgroundTransparency = 1
		TimeIcon.Position = UDim2.new(0, 0, 0.5, 0)
		TimeIcon.BorderSizePixel = 0
		TimeIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TimeIcon.Image = "http://www.roblox.com/asset/?id=6034983856"
		TimeIcon.Parent = Container

		local PowerIcon = Instance.new("ImageLabel")
		PowerIcon.Name = "PowerIcon"
		PowerIcon.AnchorPoint = Vector2.new(1, 0.5)
		PowerIcon.Size = UDim2.new(0, 17, 0, 17)
		PowerIcon.BackgroundTransparency = 1
		PowerIcon.Position = UDim2.new(1, 0, 0.5, 0)
		PowerIcon.BorderSizePixel = 0
		PowerIcon.Image = "http://www.roblox.com/asset/?id=6034983849"
		PowerIcon.Parent = Container

		local Power = Instance.new("TextLabel")
		Power.Name = "Power"
		Power.AnchorPoint = Vector2.new(1, 0)
		Power.Size = UDim2.new(0.6, 0, 1, 0)
		Power.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Power.BackgroundTransparency = 1
		Power.Position = UDim2.new(0.6, 27, 0, 0)
		Power.BorderSizePixel = 0
		Power.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Power.FontSize = Enum.FontSize.Size14
		Power.TextSize = 13
		Power.TextColor3 = Color3.fromRGB(255, 255, 255)
		Power.Text = "0%"
		Power.Font = Enum.Font.Ubuntu
		Power.TextXAlignment = Enum.TextXAlignment.Right
		Power.Parent = Container

		local Separator = Instance.new("TextLabel")
		Separator.Name = "Separator"
		Separator.Size = UDim2.new(1, 0, 1, 0)
		Separator.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Separator.BackgroundTransparency = 1
		Separator.Position = UDim2.new(0, 1, 0, -1)
		Separator.BorderSizePixel = 0
		Separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Separator.FontSize = Enum.FontSize.Size14
		Separator.TextSize = 14
		Separator.TextColor3 = Color3.fromRGB(255, 255, 255)
		Separator.Text = "·"
		Separator.Font = Enum.Font.Unknown
		Separator.Parent = Container

		do
			local Background = Instance.new("Folder")
			Background.Name = "Background"
			Background.Parent = Container

			local RoundedPart = Instance.new("Frame")
			RoundedPart.Name = "RoundedPart"
			RoundedPart.ZIndex = 0
			RoundedPart.AnchorPoint = Vector2.new(0.5, 0.5)
			RoundedPart.Size = UDim2.new(0, 123, 0, 25)
			RoundedPart.BorderColor3 = Color3.fromRGB(0, 0, 0)
			RoundedPart.Position = UDim2.new(0.5, 0, 0, 9)
			RoundedPart.BorderSizePixel = 0
			RoundedPart.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
			RoundedPart.Parent = Background

			local UICorner = Instance.new("UICorner")
			UICorner.CornerRadius = UDim.new(1, 0)
			UICorner.Parent = RoundedPart

			local Square = Instance.new("Frame")
			Square.Name = "Square"
			Square.ZIndex = 0
			Square.AnchorPoint = Vector2.new(0.5, 0.5)
			Square.Size = UDim2.new(0, 123, 0, 25)
			Square.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Square.Position = UDim2.new(0.5, 0, 0, 0)
			Square.BorderSizePixel = 0
			Square.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
			Square.Parent = Background
		end

		AscGui.Parent = gethui and gethui() or game:GetService("CoreGui")
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		
		self.TimePowerUI = {
			["ScreenGui"] = AscGui,
			["Container"] = Container,
			["Power"] = Power,
			["Time"] = Time,
			["OpenTween"] = TweenService:Create(Container, tweenInfo, {Position = UDim2.new(0.5, 0, 0, 11)}),
			["CloseTween"] = TweenService:Create(Container, tweenInfo, {Position = UDim2.new(0.5, 0, 0, -15)})
		}
		
		function self.TimePowerUI:Open()
			self.ScreenGui.Enabled = true
			self.OpenTween:Play()
		end
		
		function self.TimePowerUI:Close()
			self.CloseTween:Play()
			self.CloseTween.Completed:Wait()
			self.ScreenGui.Enabled = false
		end
		
		function self.TimePowerUI:UpdateTime(totalSeconds : number)
			local minutes = math.floor(totalSeconds / 60)
			local seconds = totalSeconds % 60
			self.Time.Text = string.format("%02d:%02d", minutes, seconds)
		end
		
		function self.TimePowerUI:UpdatePower(rawPower : number)
			local percentage = (rawPower / 1000) * 100
			self.Power.Text = math.round(percentage) .. "%"
		end
		
		function self.TimePowerUI:Destroy()
			self.ScreenGui:Destroy()
		end
	end
	
	--> Supply Drop UI
	do
		
	end
end

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
return AdditionalGUI