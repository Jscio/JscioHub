local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

----------<< Module >>----------
local AdditionalGUI = {}
AdditionalGUI.__index = AdditionalGUI

function AdditionalGUI:Construct()
	self.Constructed = true
	
	-----<< Time & Power GUI >>-----
	do
		local TimePowerGUI = Instance.new("ScreenGui") do
			TimePowerGUI.Name = "TimePowerGUI"
			TimePowerGUI.Enabled = false
			TimePowerGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			TimePowerGUI.IgnoreGuiInset = true
			TimePowerGUI.ResetOnSpawn = false
		end

		local Container = Instance.new("Frame") do
			Container.Name = "Container"
			Container.AnchorPoint = Vector2.new(0.5, 0.5)
			Container.Size = UDim2.new(0, 110, 0, 18)
			Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Container.BackgroundTransparency = 1
			Container.Position = UDim2.new(0.5, 0, 0, -15)
			Container.BorderSizePixel = 0
			Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Container.Parent = TimePowerGUI
		end
		
		local Time = Instance.new("TextLabel") do
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
		end

		local Power = Instance.new("TextLabel") do
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

			local PowerIcon = Instance.new("ImageLabel")
			PowerIcon.Name = "PowerIcon"
			PowerIcon.AnchorPoint = Vector2.new(1, 0.5)
			PowerIcon.Size = UDim2.new(0, 17, 0, 17)
			PowerIcon.BackgroundTransparency = 1
			PowerIcon.Position = UDim2.new(1, 0, 0.5, 0)
			PowerIcon.BorderSizePixel = 0
			PowerIcon.Image = "http://www.roblox.com/asset/?id=6034983849"
			PowerIcon.Parent = Container
		end
		
		local Separator = Instance.new("TextLabel") do
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
		end
		
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

		TimePowerGUI.Parent = gethui and gethui() or game:GetService("CoreGui")
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		
		self.TimePowerGUI = {
			["ScreenGui"] = TimePowerGUI,
			["Power"] = Power,
			["Time"] = Time,
			["OpenTween"] = TweenService:Create(Container, tweenInfo, {Position = UDim2.new(0.5, 0, 0, 11)}),
			["CloseTween"] = TweenService:Create(Container, tweenInfo, {Position = UDim2.new(0.5, 0, 0, -15)})
		}
		
		function self.TimePowerGUI:Open()
			self.ScreenGui.Enabled = true
			self.OpenTween:Play()
		end
		
		function self.TimePowerGUI:Close()
			self.CloseTween:Play()
			self.CloseTween.Completed:Wait()
			self.ScreenGui.Enabled = false
		end
		
		function self.TimePowerGUI:UpdateTime(totalSeconds : number)
			local minutes = math.floor(totalSeconds / 60)
			local seconds = totalSeconds % 60
			self.Time.Text = string.format("%02d:%02d", minutes, seconds)
		end
		
		function self.TimePowerGUI:UpdatePower(rawPower : number)
			local percentage = (rawPower / 1000) * 100
			self.Power.Text = math.round(percentage) .. "%"
		end
		
		function self.TimePowerGUI:Destroy()
			self.ScreenGui:Destroy()
		end
	end
	
	-----<< Supply Drop UI >>-----
	do
		local SupplyDropGUI = Instance.new("ScreenGui") do
			SupplyDropGUI.Name = "SupplyDropGUI"
			SupplyDropGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			SupplyDropGUI.ResetOnSpawn = false
		end
		
		local Container = Instance.new("Frame") do
			Container.Name = "Container"
			Container.AnchorPoint = Vector2.new(0.5, 0.5)
			Container.Size = UDim2.new(0.8, 300, 0.8, 300)
			Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
			Container.BackgroundTransparency = 1
			Container.Position = UDim2.new(0.5, 0, 0.5, 0)
			Container.BorderSizePixel = 0
			Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Container.Parent = SupplyDropGUI
		end

		local ItemsContainer = Instance.new("Frame") do
			ItemsContainer.Name = "ItemsContainer"
			ItemsContainer.AnchorPoint = Vector2.new(0.5, 0.6000000238418579)
			ItemsContainer.Size = UDim2.new(0.25, 0, 0.34, 0)
			ItemsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ItemsContainer.Position = UDim2.new(0.5, 0, 0.6, 0)
			ItemsContainer.BorderSizePixel = 0
			ItemsContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			ItemsContainer.Parent = Container

			local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			UIAspectRatioConstraint.AspectRatio = 1.4925177
			UIAspectRatioConstraint.Parent = ItemsContainer

			local UICorner = Instance.new("UICorner")
			UICorner.Parent = ItemsContainer

			local UIScale = Instance.new("UIScale")
			UIScale.Scale = 1.25
			UIScale.Parent = ItemsContainer

			local UIStroke = Instance.new("UIStroke")
			UIStroke.Thickness = 2
			UIStroke.Color = Color3.fromRGB(255, 255, 255)
			UIStroke.Parent = ItemsContainer

			local UIGradient1 = Instance.new("UIGradient")
			UIGradient1.Rotation = 90
			UIGradient1.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(125, 125, 125))
			UIGradient1.Parent = ItemsContainer
		end

		local Folder = Instance.new("Folder", Container)
		local ItemPlaceHolder = Instance.new("Frame") do
			ItemPlaceHolder.Name = "Item"
			ItemPlaceHolder.Size = UDim2.new(1, 0, 1, 0)
			ItemPlaceHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ItemPlaceHolder.BorderSizePixel = 0
			ItemPlaceHolder.BackgroundColor3 = Color3.fromRGB(175, 175, 175)
			ItemPlaceHolder.Parent = Folder
			ItemPlaceHolder.Visible = false

			local UICorner1 = Instance.new("UICorner")
			UICorner1.Parent = ItemPlaceHolder

			local UIGradient = Instance.new("UIGradient")
			UIGradient.Rotation = 90
			UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(125, 125, 125))
			UIGradient.Parent = ItemPlaceHolder

			local UIStroke1 = Instance.new("UIStroke")
			UIStroke1.Thickness = 2
			UIStroke1.Color = Color3.fromRGB(29, 29, 29)
			UIStroke1.Parent = ItemPlaceHolder

			local ImageButton = Instance.new("ImageButton")
			ImageButton.Size = UDim2.new(1, 0, 1, 0)
			ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
			ImageButton.BackgroundTransparency = 1
			ImageButton.BorderSizePixel = 0
			ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ImageButton.Image = "rbxassetid://2392313451"
			ImageButton.Parent = ItemPlaceHolder

			local CrossLabel = Instance.new("ImageLabel")
			CrossLabel.Name = "CrossLabel"
			CrossLabel.Visible = false
			CrossLabel.Size = UDim2.new(1, 0, 1, 0)
			CrossLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			CrossLabel.BackgroundTransparency = 1
			CrossLabel.BorderSizePixel = 0
			CrossLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			CrossLabel.ImageTransparency = 0.6
			CrossLabel.ImageColor3 = Color3.fromRGB(30, 30, 30)
			CrossLabel.Image = "rbxassetid://264596039"
			CrossLabel.Parent = ItemPlaceHolder
		end
		
		SupplyDropGUI.Parent = gethui and gethui() or game:GetService("CoreGui")

		self.SupplyDropGUI = {
			["ScreenGui"] = SupplyDropGUI,
			["ItemsContainer"] = ItemsContainer
		}

		function self.SupplyDropGUI:Open()
			UserInputService.MouseIconEnabled = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			self.ScreenGui.Enabled = true
		end

		function self.SupplyDropGUI:Close()
			UserInputService.MouseIconEnabled = false
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			self.ScreenGui.Enabled = false
		end

		function self.SupplyDropGUI:Clear()
			for _, v in ipairs(self.ItemsContainer:GetChildren()) do
				if v.Name:find("Item") then
					v:Destroy()
				end
			end
		end

		function self.SupplyDropGUI:AddItem(item, callback)
			local Item = ItemPlaceHolder:Clone()
			local connection

			Item.ImageButton.Image = "rbxassetid://" .. item.ImageID.Value
			Item.Visible = true
			
			if item.Taken.Value then
				Item.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
				Item.ImageButton.Active = false
				Item.ImageButton.ImageColor3 = Color3.fromRGB(0, 0, 0)
				Item.CrossLabel.Visible = true
			else
				connection = Item.ImageButton.MouseButton1Click:Connect(function()
					callback()
					connection:Disconnect()
					self:Close()
					self:Clear()
				end)
			end

			Item.Parent = self.ItemsContainer

			return connection
		end
	end
end

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
return AdditionalGUI