local Library = {}

local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local ContentProvider = game:GetService('ContentProvider')
local TweenService = game:GetService('TweenService')
local CoreGui = game:GetService('CoreGui')

local Mobile = if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then true else false

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

function Library:Parent()
	if not RunService:IsStudio() then
		return (gethui and gethui()) or CoreGui
	end

	return PlayerGui
end

function Library:Draggable(a)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		local Tween = TweenService:Create(a, TweenInfo.new(0.3), {Position = pos})
		Tween:Play()
	end

	a.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPosition = a.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	a.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end

function Library:Button(Parent)
	local Click = Instance.new("TextButton")

	Click.Name = "Click"
	Click.Parent = Parent
	Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Click.BackgroundTransparency = 1.000
	Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Click.BorderSizePixel = 0
	Click.Size = UDim2.new(1, 0, 1, 0)
	Click.Font = Enum.Font.SourceSans
	Click.Text = ""
	Click.TextColor3 = Color3.fromRGB(0, 0, 0)
	Click.TextSize = 14.000
	Click.ZIndex = Parent.ZIndex + 3

	return Click
end

function Library:Tween(info)
	return TweenService:Create(info.v, TweenInfo.new(info.t, Enum.EasingStyle[info.s], Enum.EasingDirection[info.d]), info.g)
end

function Library:Effect(c, p)
	p.ClipsDescendants = true

	local Mouse = LocalPlayer:GetMouse()

	local relativeX = Mouse.X - c.AbsolutePosition.X
	local relativeY = Mouse.Y - c.AbsolutePosition.Y

	if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
		return
	end

	local ClickButtonCircle = Instance.new("Frame")
	ClickButtonCircle.Parent = p
	ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ClickButtonCircle.BackgroundTransparency = 0.95
	ClickButtonCircle.BorderSizePixel = 0
	ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	ClickButtonCircle.Position = UDim2.new(0, relativeX, 0, relativeY)
	ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
	ClickButtonCircle.ZIndex = p.ZIndex

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = ClickButtonCircle

	local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	local expandTween = TweenService:Create(ClickButtonCircle, tweenInfo, {
		Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
		BackgroundTransparency = 1
	})

	expandTween.Completed:Connect(function()
		ClickButtonCircle:Destroy()
	end)

	expandTween:Play()
end

function Library:Asset(rbx)
	if typeof(rbx) == 'number' then
		return "rbxassetid://" .. rbx
	end

	if typeof(rbx) == 'string' and rbx:find('rbxassetid://') then
		return rbx
	end

	return rbx
end

local function NewTemplate(p, t, d)
	local Template = Instance.new("Frame")
	local UICorner_1 = Instance.new("UICorner")
	local UIStroke_1 = Instance.new("UIStroke")
	local Text_1 = Instance.new("Frame")
	local Title_1 = Instance.new("TextLabel")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local UIPadding_1 = Instance.new("UIPadding")
	local Scaling_1 = Instance.new("Frame")
	local UIListLayout_2 = Instance.new("UIListLayout")

	Template.Name = "Template"
	Template.Parent = p
	Template.BackgroundColor3 = Color3.fromRGB(25,25,25)
	Template.BackgroundTransparency = 0.5
	Template.BorderColor3 = Color3.fromRGB(0,0,0)
	Template.BorderSizePixel = 0
	Template.Size = UDim2.new(0.98, 0,0, 40)

	UICorner_1.Parent = Template
	UICorner_1.CornerRadius = UDim.new(0,3)

	UIStroke_1.Parent = Template
	UIStroke_1.Color = Color3.fromRGB(255,255,255)
	UIStroke_1.Thickness = 0.5
	UIStroke_1.Transparency = 0.9

	Text_1.Name = "Text"
	Text_1.Parent = Template
	Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Text_1.BackgroundTransparency = 1
	Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Text_1.BorderSizePixel = 0
	Text_1.Position = UDim2.new(0, 0,0, 0)
	Text_1.Size = UDim2.new(1, 0,1, 0)

	Title_1.Name = "Title"
	Title_1.Parent = Text_1
	Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title_1.BackgroundTransparency = 1
	Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Title_1.BorderSizePixel = 0
	Title_1.Size = UDim2.new(0, 200,0, 14)
	Title_1.FontFace = Font.new(
		"rbxassetid://12187374537",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	Title_1.RichText = true
	Title_1.Text = t
	Title_1.TextColor3 = Color3.fromRGB(255,255,255)
	Title_1.TextSize = 14
	Title_1.TextTransparency = 0.3
	
	Title_1.TextXAlignment = Enum.TextXAlignment.Left
	Title_1.LayoutOrder = -999
	
	if d then
		local Desc_1 = Instance.new("TextLabel")
		
		Desc_1.Name = "Desc"
		Desc_1.Parent = Text_1
		Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Desc_1.BackgroundTransparency = 1
		Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Desc_1.BorderSizePixel = 0
		Desc_1.Size = UDim2.new(0.9, 0,0, 10)
		Desc_1.FontFace = Font.new(
			"rbxassetid://12187374537",
			Enum.FontWeight.Regular,
			Enum.FontStyle.Normal
		)
		Desc_1.RichText = true
		Desc_1.TextColor3 = Color3.fromRGB(145,145,145)
		Desc_1.TextSize = 10
		Desc_1.TextXAlignment = Enum.TextXAlignment.Left
		Desc_1.TextTruncate = Enum.TextTruncate.AtEnd
		Desc_1.Text = d
	end

	UIListLayout_1.Parent = Text_1
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

	UIPadding_1.Parent = Template
	UIPadding_1.PaddingLeft = UDim.new(0,12)
	UIPadding_1.PaddingRight = UDim.new(0,10)
	UIPadding_1.PaddingBottom = UDim.new(0, 2)

	Scaling_1.Name = "Scaling"
	Scaling_1.Parent = Template
	Scaling_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Scaling_1.BackgroundTransparency = 1
	Scaling_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Scaling_1.BorderSizePixel = 0
	Scaling_1.Size = UDim2.new(1, 0,1, 0)

	UIListLayout_2.Parent = Scaling_1
	UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

	return Template
end

function Library:Window(options)
	local Title = options.Title or "Xova"
	local SubTitle = options.Desc or "Made by s1nve"
	
	local SCALER = Mobile and 0.9 or 1.1

	local Xova = Instance.new("ScreenGui")
	local Background_1 = Instance.new("Frame")
	local UICorner_1 = Instance.new("UICorner")
	local Shadow_1 = Instance.new("ImageLabel")
	local ShadowCorner_1 = Instance.new("ImageLabel")
	local UIScale_1 = Instance.new("UIScale")
	
	UIScale_1.Scale = SCALER

	Xova.Name = "Xova"
	Xova.Parent = Library:Parent()
	Xova.ZIndexBehavior = Enum.ZIndexBehavior.Global
	Xova.IgnoreGuiInset = true

	Background_1.Name = "Background"
	Background_1.Parent = Xova
	Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Background_1.BackgroundColor3 = Color3.fromRGB(15,15,15)
	Background_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Background_1.BorderSizePixel = 0
	Background_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Background_1.Size = UDim2.new(0, 500,0, 350)

	UICorner_1.Parent = Background_1

	local sToggle = Instance.new("ScreenGui") do
		sToggle.Name = "Liquid"
		sToggle.Parent = self:Parent()
		sToggle.ZIndexBehavior = Enum.ZIndexBehavior.Global
		sToggle.IgnoreGuiInset = true
	end

	local On = true
	local closeopenui

	local Toggle = Instance.new("ImageLabel") do
		local Input_1 = Instance.new("TextButton")
		Toggle.Name = "Toggle"
		Toggle.Parent = sToggle
		Toggle.AnchorPoint = Vector2.new(0.5, 0.5)
		Toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Toggle.BackgroundTransparency = 1
		Toggle.BorderColor3 = Color3.fromRGB(0,0,0)
		Toggle.BorderSizePixel = 0
		Toggle.Position = UDim2.new(0.5, 0,0.025, 0)
		Toggle.Size = UDim2.new(0, 200,0, 7)
		Toggle.Image = "rbxassetid://80999662900595"
		Toggle.ImageTransparency = 0.699999988079071
		Toggle.ScaleType = Enum.ScaleType.Slice
		Toggle.SliceCenter = Rect.new(256, 256, 256, 256)
		Toggle.SliceScale = 0.38671875

		Input_1.Name = "Input"
		Input_1.Parent = Toggle
		Input_1.Active = true
		Input_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Input_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Input_1.BackgroundTransparency = 1
		Input_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Input_1.BorderSizePixel = 0
		Input_1.Position = UDim2.new(0.5, 0,0.5, 0)
		Input_1.Size = UDim2.new(1, 30,1, 30)
		Input_1.Font = Enum.Font.SourceSans
		Input_1.Text = ""
		Input_1.TextSize = 14
		Input_1.ZIndex = 99

		Input_1.MouseButton1Click:Connect(function()
			Background_1.Visible = not Background_1.Visible
		end)
	end

	Shadow_1.Name = "Shadow"
	Shadow_1.Parent = Background_1
	Shadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
	Shadow_1.BackgroundTransparency = 1
	Shadow_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Shadow_1.BorderSizePixel = 0
	Shadow_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Shadow_1.Size = UDim2.new(1, 120,1, 120)
	Shadow_1.ZIndex = 0
	Shadow_1.Image = "rbxassetid://8992230677"
	Shadow_1.ImageColor3 = Color3.fromRGB(0,0,0)
	Shadow_1.ImageTransparency = 0.5
	Shadow_1.ScaleType = Enum.ScaleType.Slice
	Shadow_1.SliceCenter = Rect.new(99, 99, 99, 99)

	ShadowCorner_1.Name = "ShadowCorner"
	ShadowCorner_1.Parent = Background_1
	ShadowCorner_1.AnchorPoint = Vector2.new(0.5, 0.5)
	ShadowCorner_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
	ShadowCorner_1.BackgroundTransparency = 1
	ShadowCorner_1.BorderColor3 = Color3.fromRGB(0,0,0)
	ShadowCorner_1.BorderSizePixel = 0
	ShadowCorner_1.Position = UDim2.new(0.5, 0,0.5, 3)
	ShadowCorner_1.Size = UDim2.new(1, 24,1, 24)
	ShadowCorner_1.ZIndex = 0
	ShadowCorner_1.Image = "rbxassetid://138260268144845"
	ShadowCorner_1.ImageColor3 = Color3.fromRGB(0,0,0)
	ShadowCorner_1.ImageTransparency = 0.5
	ShadowCorner_1.ScaleType = Enum.ScaleType.Slice
	ShadowCorner_1.SliceCenter = Rect.new(99, 99, 99, 99)

	UIScale_1.Parent = Xova

	local Header = Instance.new("Frame")
	local Window_1 = Instance.new("Frame")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local Corner_1 = Instance.new("Frame")
	local Info_1 = Instance.new("Frame")
	local UIListLayout_2 = Instance.new("UIListLayout")
	local UIPadding_1 = Instance.new("UIPadding")
	local Text_1 = Instance.new("Frame")
	local Title_1 = Instance.new("TextLabel")
	local UIListLayout_3 = Instance.new("UIListLayout")
	local Desc_1 = Instance.new("TextLabel")
	local Head_1 = Instance.new("Frame")
	local UIListLayout_4 = Instance.new("UIListLayout")
	local UIPadding_2 = Instance.new("UIPadding")
	local Profile_1 = Instance.new("Frame")
	local asset_1 = Instance.new("ImageLabel")
	local UICorner_1 = Instance.new("UICorner")
	local Text_2 = Instance.new("Frame")
	local Title_2 = Instance.new("TextLabel")
	local UIListLayout_5 = Instance.new("UIListLayout")
	local Desc_2 = Instance.new("TextLabel")
	local Return_1 = Instance.new("Frame")
	local Title_3 = Instance.new("TextLabel")
	local UIStroke_1 = Instance.new("UIStroke")
	local UICorner_2 = Instance.new("UICorner")
	local UIPadding_3 = Instance.new("UIPadding")

	Header.Name = "Header"
	Header.Parent = Background_1
	Header.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Header.BackgroundTransparency = 1
	Header.BorderColor3 = Color3.fromRGB(0,0,0)
	Header.BorderSizePixel = 0
	Header.Size = UDim2.new(1, 0,0, 45)

	Window_1.Name = "Window"
	Window_1.Parent = Header
	Window_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Window_1.BackgroundTransparency = 1
	Window_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Window_1.BorderSizePixel = 0
	Window_1.Size = UDim2.new(1, 0,1, 0)

	UIListLayout_1.Parent = Window_1
	UIListLayout_1.Padding = UDim.new(0,5)
	UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

	Corner_1.Name = "Corner"
	Corner_1.Parent = Window_1
	Corner_1.AnchorPoint = Vector2.new(0, 0.5)
	Corner_1.BackgroundColor3 = Color3.fromRGB(29,29,28)
	Corner_1.BackgroundTransparency = 1
	Corner_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Corner_1.BorderSizePixel = 0
	Corner_1.Position = UDim2.new(0, 0,0.5, 0)
	Corner_1.Size = UDim2.new(1, 0,0, 40)

	Info_1.Name = "Info"
	Info_1.Parent = Corner_1
	Info_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Info_1.BackgroundTransparency = 1
	Info_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Info_1.BorderSizePixel = 0
	Info_1.Size = UDim2.new(1, 0,1, 0)

	UIListLayout_2.Parent = Info_1
	UIListLayout_2.Padding = UDim.new(0,10)
	UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

	UIPadding_1.Parent = Info_1
	UIPadding_1.PaddingLeft = UDim.new(0,10)

	Text_1.Name = "Text"
	Text_1.Parent = Info_1
	Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Text_1.BackgroundTransparency = 1
	Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Text_1.BorderSizePixel = 0
	Text_1.Position = UDim2.new(0, 0,0.100000001, 0)
	Text_1.Size = UDim2.new(0, 111,0, 32)

	Title_1.Name = "Title"
	Title_1.Parent = Text_1
	Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title_1.BackgroundTransparency = 1
	Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Title_1.BorderSizePixel = 0
	Title_1.Size = UDim2.new(0, 200,0, 14)
	Title_1.FontFace = Font.new(
		"rbxassetid://12187374537",
		Enum.FontWeight.Medium,
		Enum.FontStyle.Normal
	)
	Title_1.RichText = true
	Title_1.Text = Title
	Title_1.TextColor3 = Color3.fromRGB(255,0,127)
	Title_1.TextSize = 14
	Title_1.TextXAlignment = Enum.TextXAlignment.Left

	UIListLayout_3.Parent = Text_1
	UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center

	Desc_1.Name = "Desc"
	Desc_1.Parent = Text_1
	Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Desc_1.BackgroundTransparency = 1
	Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Desc_1.BorderSizePixel = 0
	Desc_1.Size = UDim2.new(0, 200,0, 10)
	Desc_1.FontFace = Font.new(
		"rbxassetid://12187374537",
		Enum.FontWeight.Regular,
		Enum.FontStyle.Normal
	)
	Desc_1.RichText = true
	Desc_1.Text = SubTitle
	Desc_1.TextColor3 = Color3.fromRGB(145,145,145)
	Desc_1.TextSize = 10
	Desc_1.TextXAlignment = Enum.TextXAlignment.Left

	Head_1.Name = "Head"
	Head_1.Parent = Corner_1
	Head_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Head_1.BackgroundTransparency = 1
	Head_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Head_1.BorderSizePixel = 0
	Head_1.Size = UDim2.new(1, 0,1, 0)

	UIListLayout_4.Parent = Head_1
	UIListLayout_4.Padding = UDim.new(0,7)
	UIListLayout_4.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_4.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_4.VerticalAlignment = Enum.VerticalAlignment.Center

	UIPadding_2.Parent = Head_1
	UIPadding_2.PaddingRight = UDim.new(0,8)

	Profile_1.Name = "Profile"
	Profile_1.Parent = Head_1
	Profile_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Profile_1.BackgroundTransparency = 1
	Profile_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Profile_1.BorderSizePixel = 0
	Profile_1.LayoutOrder = 995
	Profile_1.Size = UDim2.new(0, 30,0, 30)

	local content, isReady = Players:GetUserThumbnailAsync(
		LocalPlayer.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size420x420
	)

	asset_1.Name = "asset"
	asset_1.Parent = Profile_1
	asset_1.AnchorPoint = Vector2.new(0.5, 0.5)
	asset_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	asset_1.BackgroundTransparency = 0.8999999761581421
	asset_1.BorderColor3 = Color3.fromRGB(0,0,0)
	asset_1.BorderSizePixel = 0
	asset_1.Position = UDim2.new(0.5, 0,0.5, 0)
	asset_1.Size = UDim2.new(1, 0,1, 0)
	asset_1.Image = content

	UICorner_1.Parent = asset_1
	UICorner_1.CornerRadius = UDim.new(1,0)

	Text_2.Name = "Text"
	Text_2.Parent = Head_1
	Text_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Text_2.BackgroundTransparency = 1
	Text_2.BorderColor3 = Color3.fromRGB(0,0,0)
	Text_2.BorderSizePixel = 0
	Text_2.Position = UDim2.new(0, 0,0.100000001, 0)
	Text_2.Size = UDim2.new(0, 111,0, 32)

	Title_2.Name = "Title"
	Title_2.Parent = Text_2
	Title_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title_2.BackgroundTransparency = 1
	Title_2.BorderColor3 = Color3.fromRGB(0,0,0)
	Title_2.BorderSizePixel = 0
	Title_2.Size = UDim2.new(0, 32,0, 14)
	Title_2.FontFace = Font.new(
		"rbxassetid://12187374537",
		Enum.FontWeight.Regular,
		Enum.FontStyle.Normal
	)
	Title_2.RichText = true
	Title_2.Text = "Unknow"
	Title_2.TextColor3 = Color3.fromRGB(255,255,255)
	Title_2.TextSize = 13
	Title_2.TextTransparency = 0.15000000596046448
	Title_2.TextXAlignment = Enum.TextXAlignment.Right

	UIListLayout_5.Parent = Text_2
	UIListLayout_5.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_5.VerticalAlignment = Enum.VerticalAlignment.Center

	Desc_2.Name = "Desc"
	Desc_2.Parent = Text_2
	Desc_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Desc_2.BackgroundTransparency = 1
	Desc_2.BorderColor3 = Color3.fromRGB(0,0,0)
	Desc_2.BorderSizePixel = 0
	Desc_2.Size = UDim2.new(0, 32,0, 10)
	Desc_2.FontFace = Font.new(
		"rbxassetid://12187374537",
		Enum.FontWeight.Regular,
		Enum.FontStyle.Normal
	)

	Desc_2.RichText = true

	do
		local name = LocalPlayer.Name
		local startCount = 2
		local endCount = 2

		if #name > startCount + endCount then
			local start = string.sub(name, 1, startCount)
			local ending = string.sub(name, -endCount)
			local stars = string.rep("*", #name - startCount - endCount)

			Desc_2.Text = "@" .. start .. stars .. ending
		else
			Desc_2.Text = "@" .. name
		end
	end
	
	do
		local name = LocalPlayer.DisplayName
		local startCount = 2
		local endCount = 2

		if #name > startCount + endCount then
			local start = string.sub(name, 1, startCount)
			local ending = string.sub(name, -endCount)
			local stars = string.rep("*", #name - startCount - endCount)

			Title_2.Text = start .. stars .. ending
		else
			Title_2.Text = name
		end
	end

	Desc_2.TextColor3 = Color3.fromRGB(145,145,145)
	Desc_2.TextSize = 10
	Desc_2.TextXAlignment = Enum.TextXAlignment.Right

	Return_1.Name = "Return"
	Return_1.Parent = Head_1
	Return_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Return_1.BackgroundTransparency = 0.949999988079071
	Return_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Return_1.BorderSizePixel = 0
	Return_1.LayoutOrder = 1000
	Return_1.Size = UDim2.new(0, 75,0, 25)
	Return_1.Visible = false

	Title_3.Name = "Title"
	Title_3.Parent = Return_1
	Title_3.AnchorPoint = Vector2.new(0.5, 0.5)
	Title_3.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title_3.BackgroundTransparency = 1
	Title_3.BorderColor3 = Color3.fromRGB(0,0,0)
	Title_3.BorderSizePixel = 0
	Title_3.Position = UDim2.new(0.5, 0,0.5, 0)
	Title_3.Size = UDim2.new(0, 32,0, 14)
	Title_3.FontFace = Font.new(
		"rbxassetid://12187374537",
		Enum.FontWeight.Regular,
		Enum.FontStyle.Normal
	)
	Title_3.RichText = true
	Title_3.Text = "Return"
	Title_3.TextColor3 = Color3.fromRGB(255,255,255)
	Title_3.TextSize = 13
	Title_3.TextTransparency = 0.15000000596046448

	UIStroke_1.Parent = Return_1
	UIStroke_1.Color = Color3.fromRGB(255,255,255)
	UIStroke_1.Thickness = 0.5
	UIStroke_1.Transparency = 0.85

	UICorner_2.Parent = Return_1
	UICorner_2.CornerRadius = UDim.new(0,5)

	UIPadding_3.Parent = Window_1
	UIPadding_3.PaddingLeft = UDim.new(0,4)
	UIPadding_3.PaddingRight = UDim.new(0,5)
	UIPadding_3.PaddingTop = UDim.new(0,3)

	local Scaler = Instance.new("Frame")
	local UIPadding_1 = Instance.new("UIPadding")
	local Page_1 = Instance.new("Frame")
	local UIPageLayout_1 = Instance.new("UIPageLayout")

	Scaler.Name = "Scaler"
	Scaler.Parent = Background_1
	Scaler.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Scaler.BackgroundTransparency = 1
	Scaler.BorderColor3 = Color3.fromRGB(0,0,0)
	Scaler.BorderSizePixel = 0
	Scaler.Size = UDim2.new(1, 0,1, 0)

	UIPadding_1.Parent = Scaler
	UIPadding_1.PaddingBottom = UDim.new(0,7)
	UIPadding_1.PaddingLeft = UDim.new(0,1)
	UIPadding_1.PaddingRight = UDim.new(0,1)
	UIPadding_1.PaddingTop = UDim.new(0,45)

	Page_1.Name = "Page"
	Page_1.Parent = Scaler
	Page_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Page_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Page_1.BackgroundTransparency = 1
	Page_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Page_1.BorderSizePixel = 0
	Page_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Page_1.Size = UDim2.new(1, 0,1, 0)
	Page_1.ClipsDescendants = true

	UIPageLayout_1.Parent = Page_1
	UIPageLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Right
	UIPageLayout_1.TweenTime = 0.5

	local Main = Instance.new("Frame")
	local TabsScrolling_1 = Instance.new("ScrollingFrame")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local UIPadding_1 = Instance.new("UIPadding")

	Main.Name = "Main"
	Main.Parent = Page_1
	Main.AnchorPoint = Vector2.new(0.5, 0.5)
	Main.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Main.BackgroundTransparency = 1
	Main.BorderColor3 = Color3.fromRGB(0,0,0)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.5, 0,0.5, 0)
	Main.Size = UDim2.new(1, 0,1, 0)

	TabsScrolling_1.Name = "TabsScrolling"
	TabsScrolling_1.Parent = Main
	TabsScrolling_1.Active = true
	TabsScrolling_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TabsScrolling_1.BackgroundTransparency = 1
	TabsScrolling_1.BorderColor3 = Color3.fromRGB(0,0,0)
	TabsScrolling_1.BorderSizePixel = 0
	TabsScrolling_1.Size = UDim2.new(1, 0,1, 0)
	TabsScrolling_1.ClipsDescendants = true
	TabsScrolling_1.AutomaticCanvasSize = Enum.AutomaticSize.None
	TabsScrolling_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
	TabsScrolling_1.CanvasPosition = Vector2.new(0, 0)
	TabsScrolling_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	TabsScrolling_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	TabsScrolling_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	TabsScrolling_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
	TabsScrolling_1.ScrollBarImageTransparency = 0
	TabsScrolling_1.ScrollBarThickness = 0
	TabsScrolling_1.ScrollingDirection = Enum.ScrollingDirection.XY
	TabsScrolling_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
	TabsScrolling_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
	TabsScrolling_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

	UIListLayout_1.Parent = TabsScrolling_1
	UIListLayout_1.Padding = UDim.new(0,5)
	UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.Wraps = true

	UIPadding_1.Parent = TabsScrolling_1
	UIPadding_1.PaddingBottom = UDim.new(0,5)
	UIPadding_1.PaddingLeft = UDim.new(0,10)
	UIPadding_1.PaddingRight = UDim.new(0,10)
	UIPadding_1.PaddingTop = UDim.new(0,5)

	local Window = {}

	function Window:Tabs(options)
		local Title = options.Title
		local Desc = options.Desc
		local Icon = options.Icon

		local AddTabs = Instance.new("Frame")
		local UICorner_1 = Instance.new("UICorner")
		local Banner_1 = Instance.new("ImageLabel")
		local UICorner_2 = Instance.new("UICorner")
		local Info_1 = Instance.new("Frame")
		local UIListLayout_1 = Instance.new("UIListLayout")
		local UIPadding_1 = Instance.new("UIPadding")
		local Logo_1 = Instance.new("ImageLabel")
		local Text_1 = Instance.new("Frame")
		local Title_1 = Instance.new("TextLabel")
		local UIListLayout_2 = Instance.new("UIListLayout")
		local Desc_1 = Instance.new("TextLabel")
		local UIStroke_1 = Instance.new("UIStroke")

		AddTabs.Name = "AddTabs"
		AddTabs.Parent = TabsScrolling_1
		AddTabs.BackgroundColor3 = Color3.fromRGB(10,10,10)
		AddTabs.BorderColor3 = Color3.fromRGB(0,0,0)
		AddTabs.BorderSizePixel = 0
		AddTabs.Size = UDim2.new(0, 236,0, 55)

		UICorner_1.Parent = AddTabs
		UICorner_1.CornerRadius = UDim.new(0,5)

		Banner_1.Name = "Banner"
		Banner_1.Parent = AddTabs
		Banner_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Banner_1.BackgroundTransparency = 1
		Banner_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Banner_1.BorderSizePixel = 0
		Banner_1.Size = UDim2.new(1, 0,1, 0)
		Banner_1.Image = "rbxassetid://125411502674016"
		Banner_1.ImageColor3 = Color3.fromRGB(255,0,128)
		Banner_1.ScaleType = Enum.ScaleType.Crop

		UICorner_2.Parent = Banner_1
		UICorner_2.CornerRadius = UDim.new(0,5)

		Info_1.Name = "Info"
		Info_1.Parent = AddTabs
		Info_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Info_1.BackgroundTransparency = 1
		Info_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Info_1.BorderSizePixel = 0
		Info_1.Size = UDim2.new(1, 0,1, 0)

		UIListLayout_1.Parent = Info_1
		UIListLayout_1.Padding = UDim.new(0,10)
		UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

		UIPadding_1.Parent = Info_1
		UIPadding_1.PaddingLeft = UDim.new(0,15)

		Logo_1.Name = "Logo"
		Logo_1.Parent = Info_1
		Logo_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Logo_1.BackgroundTransparency = 1
		Logo_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Logo_1.BorderSizePixel = 0
		Logo_1.LayoutOrder = -1
		Logo_1.Size = UDim2.new(0, 25,0, 25)
		Logo_1.Image = Library:Asset(Icon)
		Logo_1.ImageColor3 = Color3.fromRGB(255,0,127)

		Text_1.Name = "Text"
		Text_1.Parent = Info_1
		Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Text_1.BackgroundTransparency = 1
		Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Text_1.BorderSizePixel = 0
		Text_1.Position = UDim2.new(0.140350878, 0,0.209090903, 0)
		Text_1.Size = UDim2.new(0, 150,0, 32)

		Title_1.Name = "Title"
		Title_1.Parent = Text_1
		Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Title_1.BackgroundTransparency = 1
		Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Title_1.BorderSizePixel = 0
		Title_1.Size = UDim2.new(0, 150,0, 14)
		Title_1.FontFace = Font.new(
			"rbxassetid://12187374537",
			Enum.FontWeight.Medium,
			Enum.FontStyle.Normal
		)
		Title_1.RichText = true
		Title_1.Text = Title
		Title_1.TextColor3 = Color3.fromRGB(255,0,127)
		Title_1.TextSize = 18
		Title_1.TextXAlignment = Enum.TextXAlignment.Left

		UIListLayout_2.Parent = Text_1
		UIListLayout_2.Padding = UDim.new(0,2)
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

		Desc_1.Name = "Desc"
		Desc_1.Parent = Text_1
		Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Desc_1.BackgroundTransparency = 1
		Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Desc_1.BorderSizePixel = 0
		Desc_1.Size = UDim2.new(0.9, 0,0, 10)
		Desc_1.FontFace = Font.new(
			"rbxassetid://12187374537",
			Enum.FontWeight.Regular,
			Enum.FontStyle.Normal
		)
		Desc_1.RichText = true
		Desc_1.Text = Desc
		Desc_1.TextColor3 = Color3.fromRGB(255, 255, 255)
		Desc_1.TextTransparency = 0.2
		Desc_1.TextSize = 10
		Desc_1.TextXAlignment = Enum.TextXAlignment.Left

		UIStroke_1.Parent = AddTabs
		UIStroke_1.Color = Color3.fromRGB(75,0,38)
		UIStroke_1.Thickness = 1

		local Button = Library:Button(AddTabs)

		local AddPage = Instance.new("Frame")
		local Left_1 = Instance.new("ScrollingFrame")
		local UIListLayout_1 = Instance.new("UIListLayout")
		local UIPadding_1 = Instance.new("UIPadding")
		local UIListLayout_2 = Instance.new("UIListLayout")

		AddPage.Name = "AddPage"
		AddPage.Parent = Page_1
		AddPage.AnchorPoint = Vector2.new(0.5, 0.5)
		AddPage.BackgroundColor3 = Color3.fromRGB(255,255,255)
		AddPage.BackgroundTransparency = 1
		AddPage.BorderColor3 = Color3.fromRGB(0,0,0)
		AddPage.BorderSizePixel = 0
		AddPage.Position = UDim2.new(0.5, 0,0.5, 0)
		AddPage.Size = UDim2.new(1, 0,1, 0)
		AddPage.Visible = false

		Left_1.Name = "Left"
		Left_1.Parent = AddPage
		Left_1.Active = true
		Left_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Left_1.BackgroundTransparency = 1
		Left_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Left_1.BorderSizePixel = 0
		Left_1.Size = UDim2.new(1, 0,1, 0)
		Left_1.ClipsDescendants = true
		Left_1.AutomaticCanvasSize = Enum.AutomaticSize.None
		Left_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
		Left_1.CanvasPosition = Vector2.new(0, 0)
		Left_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		Left_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		Left_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		Left_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
		Left_1.ScrollBarImageTransparency = 0
		Left_1.ScrollBarThickness = 0
		Left_1.ScrollingDirection = Enum.ScrollingDirection.XY
		Left_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
		Left_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
		Left_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

		UIListLayout_1.Parent = Left_1
		UIListLayout_1.Padding = UDim.new(0, 10)
		UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

		UIPadding_1.Parent = Left_1
		UIPadding_1.PaddingBottom = UDim.new(0,1)
		UIPadding_1.PaddingTop = UDim.new(0,1)

		UIListLayout_2.Parent = AddPage
		UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

		local function updateSizes()
			local scale = UIScale_1.Scale or 1
			
			Left_1.CanvasSize = UDim2.new(0, 0, 0, (UIListLayout_1.AbsoluteContentSize.Y + 15) / scale)
		end

		UIListLayout_1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSizes)

		updateSizes()

		local function OnSelectPage()
			for _, v in pairs(Page_1:GetChildren()) do
				if v:IsA("Frame") then
					v.Visible = false
				end
			end

			Return_1.Visible = true
			AddPage.Visible = true
			UIPageLayout_1:JumpTo(AddPage)
		end

		Button.MouseButton1Click:Connect(OnSelectPage)

		local Section = {}

		function Section:Section(options)
			local Title = options.Title
			local Side = options.Side

			local Section = Instance.new("Frame")
			local UICorner_1 = Instance.new("UICorner")
			local UIStroke_1 = Instance.new("UIStroke")
			local UIListLayout_1 = Instance.new("UIListLayout")
			local HeadSection_1 = Instance.new("Frame")
			local Title_1 = Instance.new("TextLabel")

			Section.Name = "Section"
			Section.Parent = Left_1
			Section.BackgroundColor3 = Color3.fromRGB(20,20,20)
			Section.BorderColor3 = Color3.fromRGB(0,0,0)
			Section.BorderSizePixel = 0
			Section.Size = UDim2.new(0.95, 0,0, 300)

			UICorner_1.Parent = Section
			UICorner_1.CornerRadius = UDim.new(0,3)

			UIStroke_1.Parent = Section
			UIStroke_1.Color = Color3.fromRGB(255,255,255)
			UIStroke_1.Thickness = 1
			UIStroke_1.Transparency = 0.93

			UIListLayout_1.Parent = Section
			UIListLayout_1.Padding = UDim.new(0,5)
			UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

			HeadSection_1.Name = "HeadSection"
			HeadSection_1.Parent = Section
			HeadSection_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			HeadSection_1.BackgroundTransparency = 1
			HeadSection_1.BorderColor3 = Color3.fromRGB(0,0,0)
			HeadSection_1.BorderSizePixel = 0
			HeadSection_1.Size = UDim2.new(1, 0,0, 30)

			local Line_1 = Instance.new("Frame")
			Line_1.Name = "Line"
			Line_1.Parent = HeadSection_1
			Line_1.AnchorPoint = Vector2.new(0, 1)
			Line_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Line_1.BackgroundTransparency = 0.9300000071525574
			Line_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Line_1.BorderSizePixel = 0
			Line_1.Position = UDim2.new(0, 0,1, 0)
			Line_1.Size = UDim2.new(1, 0,0, 1)

			Title_1.Name = "Title"
			Title_1.Parent = HeadSection_1
			Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
			Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Title_1.BackgroundTransparency = 1
			Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Title_1.BorderSizePixel = 0
			Title_1.Position = UDim2.new(0.5, 0,0.5, 0)
			Title_1.Size = UDim2.new(0.95, 0,1, 0)
			Title_1.FontFace = Font.new(
				"rbxassetid://12187374537",
				Enum.FontWeight.Medium,
				Enum.FontStyle.Normal
			)
			Title_1.RichText = true
			Title_1.Text = Title
			Title_1.TextColor3 = Color3.fromRGB(255,255,255)
			Title_1.TextSize = 14
			Title_1.TextTransparency = 0.3
			Title_1.TextXAlignment = Enum.TextXAlignment.Left

			UIListLayout_1:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
				local scale = UIScale_1.Scale or 1

				Section.Size = UDim2.new(0.95, 0, 0, (UIListLayout_1.AbsoluteContentSize.Y + 5) / scale)
			end)

			local Class = {}

			function Class:Toggle(options)
				local Value = options.Value or false
				local Callback = options.Callback or (function( ... )
					return ...
				end)

				local Base = NewTemplate(Section, options.Title or "???", options.Desc or nil)

				local Button = Library:Button(Base)

				local Background = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local Highligh_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local UIGradient_1 = Instance.new("UIGradient")
				local ImageLabel_1 = Instance.new("ImageLabel")

				Background.Name = "Background"
				Background.Parent = Base.Scaling
				Background.BackgroundColor3 = Color3.fromRGB(10,10,10)
				Background.BorderColor3 = Color3.fromRGB(0,0,0)
				Background.BorderSizePixel = 0
				Background.Size = UDim2.new(0, 20,0, 20)

				UICorner_1.Parent = Background
				UICorner_1.CornerRadius = UDim.new(0,5)

				Highligh_1.Name = "Highligh"
				Highligh_1.Parent = Background
				Highligh_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Highligh_1.BackgroundColor3 = Color3.fromRGB(255,0,127)
				Highligh_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Highligh_1.BorderSizePixel = 0
				Highligh_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Highligh_1.Size = UDim2.new(0, 20,0, 20)

				UICorner_2.Parent = Highligh_1
				UICorner_2.CornerRadius = UDim.new(0,5)

				UIGradient_1.Parent = Highligh_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(44, 44, 44))}
				UIGradient_1.Rotation = 31

				ImageLabel_1.Parent = Highligh_1
				ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(0.45, 0,0.45, 0)
				ImageLabel_1.Image = "rbxassetid://86682186031062"

				local BaseTitle = Base.Text.Title

				local function OnChanged(value)
					if value then 
						ImageLabel_1.Size = UDim2.new(0.85, 0,0.85, 0)
						BaseTitle.TextColor3 = Color3.fromRGB(255, 0, 127)
						Callback(Value)
						Library:Tween({
							v = Highligh_1,
							t = 0.5,
							s = "Exponential",
							d = "Out",
							g = {
								BackgroundTransparency = 0
							}
						}):Play()

						Library:Tween({
							v = ImageLabel_1,
							t = 0.5,
							s = "Exponential",
							d = "Out",
							g = {
								ImageTransparency = 0
							}
						}):Play()

						Library:Tween({
							v = ImageLabel_1,
							t = 0.3,
							s = "Exponential",
							d = "Out",
							g = {
								Size = UDim2.new(0.5, 0,0.5, 0)
							}
						}):Play()
					else
						BaseTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
						Callback(Value)

						Library:Tween({
							v = Highligh_1,
							t = 0.5,
							s = "Exponential",
							d = "Out",
							g = {
								BackgroundTransparency = 1
							}
						}):Play()

						Library:Tween({
							v = ImageLabel_1,
							t = 0.5,
							s = "Exponential",
							d = "Out",
							g = {
								ImageTransparency = 1
							}
						}):Play()
					end

					Library:Effect(Button, Base)
				end

				local function Init()
					Value = not Value

					OnChanged(Value)
				end

				Button.MouseButton1Click:Connect(function()
					for _, v in pairs(Background_1:GetChildren()) do
						if v.Name == "Dropdown" and v.Visible then
							return
						end
					end

					Init()
				end)

				OnChanged(Value)
			end

			function Class:Button(options)
				local Title = options.Title
				local Callback = options.Callback

				local Button = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIGradient_1 = Instance.new("UIGradient")
				local Title_1 = Instance.new("TextLabel")

				Button.Name = "Button"
				Button.Parent = Section
				Button.BackgroundColor3 = Color3.fromRGB(255, 0, 127)
				Button.BorderColor3 = Color3.fromRGB(0,0,0)
				Button.BorderSizePixel = 0
				Button.Size = UDim2.new(0.98, 0,0, 25)

				UICorner_1.Parent = Button
				UICorner_1.CornerRadius = UDim.new(0,3)

				UIGradient_1.Parent = Button
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 60, 60))}
				UIGradient_1.Rotation = -90

				Title_1.Name = "Title"
				Title_1.Parent = Button
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Title_1.Size = UDim2.new(0.899999976, 0,1, 0)
				Title_1.FontFace = Font.new(
					"rbxassetid://12187374537",
					Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				)
				Title_1.RichText = true
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 14
				Title_1.TextTransparency = 0.15000000596046448

				local ButtonC = Library:Button(Button)

				ButtonC.MouseButton1Click:Connect(function()
					for _, v in pairs(Background_1:GetChildren()) do
						if v.Name == "Dropdown" and v.Visible then
							return
						end
					end

					Callback()
					Library:Effect(ButtonC, Button)
				end)
			end

			function Class:Slider(options)
				local Title = options.Title
				local Min = options.Min or 1
				local Max = options.Max or 10
				local Value = options.Value or Min
				local Rounding = options.Rounding or 0
				local Callback = options.Callback or (function( ... )
					return ...
				end)

				local Slider = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")
				local Text_1 = Instance.new("Frame")
				local Title_1 = Instance.new("TextLabel")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local UIPadding_1 = Instance.new("UIPadding")
				local Scaling_1 = Instance.new("Frame")
				local Slide_1 = Instance.new("Frame")
				local ColorBar_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local ColorBar_2 = Instance.new("Frame")
				local UICorner_3 = Instance.new("UICorner")
				local UIGradient_1 = Instance.new("UIGradient")
				local Circle_1 = Instance.new("Frame")
				local Boxvalue_1 = Instance.new("TextBox")

				Slider.Name = "Slider"
				Slider.Parent = Section
				Slider.BackgroundColor3 = Color3.fromRGB(25,25,25)
				Slider.BackgroundTransparency = 0.5
				Slider.BorderColor3 = Color3.fromRGB(0,0,0)
				Slider.BorderSizePixel = 0
				Slider.Size = UDim2.new(0.98, 0,0, 43)

				UICorner_1.Parent = Slider
				UICorner_1.CornerRadius = UDim.new(0,3)

				UIStroke_1.Parent = Slider
				UIStroke_1.Color = Color3.fromRGB(255,255,255)
				UIStroke_1.Thickness = 0.5
				UIStroke_1.Transparency = 0.9

				Text_1.Name = "Text"
				Text_1.Parent = Slider
				Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Text_1.BackgroundTransparency = 1
				Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Text_1.BorderSizePixel = 0
				Text_1.Position = UDim2.new(0, 0,0.0999998748, 0)
				Text_1.Size = UDim2.new(0, 111,0, 22)

				Title_1.Name = "Title"
				Title_1.Parent = Text_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(0, 200,0, 14)
				Title_1.FontFace = Font.new(
					"rbxassetid://12187374537",
					Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				)
				Title_1.RichText = true
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 14
				Title_1.TextTransparency = 0.30000001192092896
				
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				UIListLayout_1.Parent = Text_1
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				UIPadding_1.Parent = Slider
				UIPadding_1.PaddingBottom = UDim.new(0,1)
				UIPadding_1.PaddingLeft = UDim.new(0,10)
				UIPadding_1.PaddingRight = UDim.new(0,10)

				Scaling_1.Name = "Scaling"
				Scaling_1.Parent = Slider
				Scaling_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Scaling_1.BackgroundTransparency = 1
				Scaling_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Scaling_1.BorderSizePixel = 0
				Scaling_1.Size = UDim2.new(1, 0,1, 0)

				Slide_1.Name = "Slide"
				Slide_1.Parent = Scaling_1
				Slide_1.AnchorPoint = Vector2.new(0, 1)
				Slide_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Slide_1.BackgroundTransparency = 1
				Slide_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Slide_1.BorderSizePixel = 0
				Slide_1.Position = UDim2.new(0, 0,1, 0)
				Slide_1.Size = UDim2.new(1, 0,0, 23)

				ColorBar_1.Name = "ColorBar"
				ColorBar_1.Parent = Slide_1
				ColorBar_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ColorBar_1.BackgroundColor3 = Color3.fromRGB(10,10,10)
				ColorBar_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ColorBar_1.BorderSizePixel = 0
				ColorBar_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ColorBar_1.Size = UDim2.new(1, 0,0, 5)

				UICorner_2.Parent = ColorBar_1
				UICorner_2.CornerRadius = UDim.new(0,3)

				ColorBar_2.Name = "ColorBar"
				ColorBar_2.Parent = ColorBar_1
				ColorBar_2.BackgroundColor3 = Color3.fromRGB(255,0,127)
				ColorBar_2.BorderColor3 = Color3.fromRGB(0,0,0)
				ColorBar_2.BorderSizePixel = 0
				ColorBar_2.Size = UDim2.new(1, 0,0, 5)

				UICorner_3.Parent = ColorBar_2
				UICorner_3.CornerRadius = UDim.new(0,3)

				UIGradient_1.Parent = ColorBar_2
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(47, 47, 47))}
				UIGradient_1.Rotation = 90

				Circle_1.Name = "Circle"
				Circle_1.Parent = ColorBar_2
				Circle_1.AnchorPoint = Vector2.new(1, 0.5)
				Circle_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Circle_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Circle_1.BorderSizePixel = 0
				Circle_1.Position = UDim2.new(1, 0,0.5, 0)
				Circle_1.Size = UDim2.new(0, 5,0, 11)

				Boxvalue_1.Name = "Boxvalue"
				Boxvalue_1.Parent = Scaling_1
				Boxvalue_1.Active = true
				Boxvalue_1.AnchorPoint = Vector2.new(1, 0.5)
				Boxvalue_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Boxvalue_1.BackgroundTransparency = 1
				Boxvalue_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Boxvalue_1.BorderSizePixel = 0
				Boxvalue_1.Position = UDim2.new(1, -5,0.449000001, -2)
				Boxvalue_1.Size = UDim2.new(0, 60,0, 19)
				Boxvalue_1.FontFace = Font.new(
					"rbxassetid://12187374537",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				)
				Boxvalue_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
				Boxvalue_1.PlaceholderText = ""
				Boxvalue_1.Text = tostring(Value)
				Boxvalue_1.TextColor3 = Color3.fromRGB(255,255,255)
				Boxvalue_1.TextSize = 11
				Boxvalue_1.TextTransparency = 0.5
				Boxvalue_1.TextXAlignment = Enum.TextXAlignment.Right
				Boxvalue_1.TextTruncate = Enum.TextTruncate.AtEnd

				local function roundToDecimal(value, decimals)
					local factor = 10 ^ decimals
					return math.floor(value * factor + 0.5) / factor
				end

				local function updateSlider(value)
					value = math.clamp(value, Min, Max)
					value = roundToDecimal(value, Rounding)
					Library:Tween({
						v = ColorBar_2,
						t = 0.5,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)}
					}):Play()

					local startValue = tonumber(Boxvalue_1.Text) or 0
					local targetValue = value

					local steps = 5
					local currentValue = startValue

					for i = 1, steps do
						task.wait(0.01 / steps)
						currentValue = currentValue + (targetValue - startValue) / steps
						Boxvalue_1.Text = tostring(roundToDecimal(currentValue, Rounding))
					end

					Boxvalue_1.Text = tostring(roundToDecimal(targetValue, Rounding))

					Callback(value)
				end

				updateSlider(Value or 0)

				local function move(input)
					local sliderBar = ColorBar_1
					local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
					local value = relativeX * (Max - Min) + Min
					updateSlider(value)
				end

				local dragging = false

				local Button = Library:Button(Slider)

				Boxvalue_1.ZIndex = Button.ZIndex + 1

				Boxvalue_1.FocusLost:Connect(function()
					local value = tonumber(Boxvalue_1.Text) or Min
					updateSlider(value)
				end)

				Button.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						for _, v in pairs(Background_1:GetChildren()) do
							if v.Name == "Dropdown" and v.Visible then
								return
							end
						end

						dragging = true
						move(input)
					end
				end)

				Button.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

						dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						move(input)
					end
				end)
			end

			function Class:Textbox(options)
				local Text = options.Text
				local Callback = options.Callback

				local Template = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")
				local UIPadding_1 = Instance.new("UIPadding")
				local TextBox_1 = Instance.new("TextBox")

				Template.Name = "Template"
				Template.Parent = Section
				Template.BackgroundColor3 = Color3.fromRGB(15,15,15)
				Template.BackgroundTransparency = 0.5
				Template.BorderColor3 = Color3.fromRGB(0,0,0)
				Template.BorderSizePixel = 0
				Template.Size = UDim2.new(0.98, 0,0, 25)
				Template.ClipsDescendants = true

				UICorner_1.Parent = Template
				UICorner_1.CornerRadius = UDim.new(0,3)

				UIStroke_1.Parent = Template
				UIStroke_1.Color = Color3.fromRGB(255,255,255)
				UIStroke_1.Thickness = 0.5
				UIStroke_1.Transparency = 0.9

				UIPadding_1.Parent = Template
				UIPadding_1.PaddingLeft = UDim.new(0,15)
				UIPadding_1.PaddingRight = UDim.new(0,10)

				TextBox_1.Parent = Template
				TextBox_1.Active = true
				TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.BackgroundTransparency = 1
				TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextBox_1.BorderSizePixel = 0
				TextBox_1.CursorPosition = -1
				TextBox_1.Size = UDim2.new(1, 0,1, 0)
				TextBox_1.FontFace = Font.new(
					"rbxassetid://12187374537",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				)
				TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
				TextBox_1.PlaceholderText = "..."
				TextBox_1.Text = tostring(Text)
				TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.TextSize = 12
				TextBox_1.TextTransparency = 0.5
				TextBox_1.TextTruncate = Enum.TextTruncate.AtEnd

				TextBox_1.FocusLost:Connect(function()
					Callback(TextBox_1.Text)
				end)
			end

			function Class:Label(options)
				local Template = NewTemplate(Section, options.Title, options.Desc or nil)
				local BaseTitle = Template.Text.Title
				local BaseDesc = Template.Text.Desc
				
				local attribute = {}

				function attribute:Title(t)
					BaseTitle.Text = tostring(t)
				end

				function attribute:Sub(t)
					BaseDesc.Text = tostring(t)
				end

				return attribute 
			end

			function Class:Line()
				local Line = Instance.new("Frame")

				Line.Name = "Line"
				Line.Parent = Section
				Line.AnchorPoint = Vector2.new(0, 1)
				Line.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Line.BackgroundTransparency = 0.9300000071525574
				Line.BorderColor3 = Color3.fromRGB(0,0,0)
				Line.BorderSizePixel = 0
				Line.Position = UDim2.new(0, 0,1, 0)
				Line.Size = UDim2.new(1, 0,0, 1)

				return Line
			end

			function Class:List(options)
				local Title = options.Title or "Title"
				local List = options.List or {}
				local Value = options.Value or List[1] or "N/A"
				local Multi = options.Multi or false
				local Callback = options.Callback or (function( ... )
					return ...
				end)

				local Template = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIStroke_1 = Instance.new("UIStroke")
				local Text_1 = Instance.new("Frame")
				local Title_1 = Instance.new("TextLabel")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Desc_1 = Instance.new("TextLabel")
				local UIPadding_1 = Instance.new("UIPadding")
				local Scaling_1 = Instance.new("Frame")
				local UIListLayout_2 = Instance.new("UIListLayout")
				local ImageLabel_1 = Instance.new("ImageLabel")

				Template.Name = "Template"
				Template.Parent = Section
				Template.BackgroundColor3 = Color3.fromRGB(25,25,25)
				Template.BackgroundTransparency = 0.5
				Template.BorderColor3 = Color3.fromRGB(0,0,0)
				Template.BorderSizePixel = 0
				Template.Size = UDim2.new(0.98, 0,0, 40)
				Template.ClipsDescendants = true

				UICorner_1.Parent = Template
				UICorner_1.CornerRadius = UDim.new(0,3)

				UIStroke_1.Parent = Template
				UIStroke_1.Color = Color3.fromRGB(255,255,255)
				UIStroke_1.Thickness = 0.5
				UIStroke_1.Transparency = 0.9

				Text_1.Name = "Text"
				Text_1.Parent = Template
				Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Text_1.BackgroundTransparency = 1
				Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Text_1.BorderSizePixel = 0
				Text_1.Position = UDim2.new(0, 0,0, 0)
				Text_1.Size = UDim2.new(1, 0,1, 0)

				Title_1.Name = "Title"
				Title_1.Parent = Text_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(0, 200,0, 14)
				Title_1.FontFace = Font.new(
					"rbxassetid://12187374537",
					Enum.FontWeight.Medium,
					Enum.FontStyle.Normal
				)
				Title_1.RichText = true
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 14
				Title_1.TextTransparency = 0.3
				
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				UIListLayout_1.Parent = Text_1
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				Desc_1.Name = "Desc"
				Desc_1.Parent = Text_1
				Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Desc_1.BackgroundTransparency = 1
				Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Desc_1.BorderSizePixel = 0
				Desc_1.Size = UDim2.new(0.9, 0,0, 10)
				Desc_1.FontFace = Font.new(
					"rbxassetid://12187374537",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				)
				Desc_1.RichText = true
				Desc_1.TextColor3 = Color3.fromRGB(145,145,145)
				Desc_1.TextSize = 10
				Desc_1.TextXAlignment = Enum.TextXAlignment.Left
				Desc_1.TextTruncate = Enum.TextTruncate.AtEnd

				local function Settext()
					if typeof(Value) == 'table' then
						Desc_1.Text = table.concat(Value, ", ")
					else
						Desc_1.Text = tostring(Value)
					end
				end

				Settext()

				UIPadding_1.Parent = Template
				UIPadding_1.PaddingBottom = UDim.new(0,2)
				UIPadding_1.PaddingLeft = UDim.new(0,12)
				UIPadding_1.PaddingRight = UDim.new(0,10)

				Scaling_1.Name = "Scaling"
				Scaling_1.Parent = Template
				Scaling_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Scaling_1.BackgroundTransparency = 1
				Scaling_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Scaling_1.BorderSizePixel = 0
				Scaling_1.Size = UDim2.new(1, 0,1, 0)

				UIListLayout_2.Parent = Scaling_1
				UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Right
				UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

				ImageLabel_1.Parent = Scaling_1
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Size = UDim2.new(0, 20,0, 20)
				ImageLabel_1.Image = "rbxassetid://132291592681506"
				ImageLabel_1.ImageTransparency = 0.5

				local Button = Library:Button(Template)

				local Dropdown = Instance.new("Frame")
				local UIStroke_1 = Instance.new("UIStroke")
				local UICorner_1 = Instance.new("UICorner")
				local Shadow_1 = Instance.new("ImageLabel")
				local Scaler_1 = Instance.new("Frame")
				local Search_1 = Instance.new("Frame")
				local UIStroke_2 = Instance.new("UIStroke")
				local UICorner_2 = Instance.new("UICorner")
				local TextBox_1 = Instance.new("TextBox")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local UIPadding_1 = Instance.new("UIPadding")
				local Scrolling_1 = Instance.new("ScrollingFrame")
				local UIListLayout_2 = Instance.new("UIListLayout")

				Dropdown.Name = "Dropdown"
				Dropdown.Parent = Background_1
				Dropdown.AnchorPoint = Vector2.new(0.5, 0.5)
				Dropdown.BackgroundColor3 = Color3.fromRGB(15,15,15)
				Dropdown.BorderColor3 = Color3.fromRGB(0,0,0)
				Dropdown.BorderSizePixel = 0
				Dropdown.Position = UDim2.new(0.5, 0,0.35, 0)
				Dropdown.Size = UDim2.new(0, 200,0, 250)
				Dropdown.ZIndex = 56
				Dropdown.Visible = false

				UIStroke_1.Parent = Dropdown
				UIStroke_1.Color = Color3.fromRGB(255,255,255)
				UIStroke_1.Thickness = 1
				UIStroke_1.Transparency = 0.9

				UICorner_1.Parent = Dropdown
				UICorner_1.CornerRadius = UDim.new(0,3)

				Shadow_1.Name = "Shadow"
				Shadow_1.Parent = Dropdown
				Shadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Shadow_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
				Shadow_1.BackgroundTransparency = 1
				Shadow_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Shadow_1.BorderSizePixel = 0
				Shadow_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Shadow_1.Size = UDim2.new(1, 120,1, 120)
				Shadow_1.Image = "rbxassetid://8992230677"
				Shadow_1.ImageColor3 = Color3.fromRGB(0,0,0)
				Shadow_1.ScaleType = Enum.ScaleType.Slice
				Shadow_1.SliceCenter = Rect.new(99, 99, 99, 99)

				Scaler_1.Name = "Scaler"
				Scaler_1.Parent = Dropdown
				Scaler_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Scaler_1.BackgroundTransparency = 1
				Scaler_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Scaler_1.BorderSizePixel = 0
				Scaler_1.Size = UDim2.new(1, 0,1, 0)
				Scaler_1.ZIndex = 56

				Search_1.Name = "Search"
				Search_1.Parent = Scaler_1
				Search_1.BackgroundColor3 = Color3.fromRGB(10,10,10)
				Search_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Search_1.BorderSizePixel = 0
				Search_1.Size = UDim2.new(1, 0,0, 20)
				Search_1.ZIndex = 56

				UIStroke_2.Parent = Search_1
				UIStroke_2.Color = Color3.fromRGB(255,255,255)
				UIStroke_2.Thickness = 0.5
				UIStroke_2.Transparency = 0.9

				UICorner_2.Parent = Search_1
				UICorner_2.CornerRadius = UDim.new(0,3)

				TextBox_1.Parent = Search_1
				TextBox_1.Active = true
				TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.BackgroundTransparency = 1
				TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextBox_1.BorderSizePixel = 0
				TextBox_1.Size = UDim2.new(1, 0,1, 0)
				TextBox_1.ZIndex = 56
				TextBox_1.FontFace = Font.new(
					"rbxassetid://12187374537",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				)
				TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
				TextBox_1.PlaceholderText = "Search"
				TextBox_1.Text = ""
				TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.TextSize = 12
				TextBox_1.TextTransparency = 0.5

				UIListLayout_1.Parent = Scaler_1
				UIListLayout_1.Padding = UDim.new(0,5)
				UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

				UIPadding_1.Parent = Scaler_1
				UIPadding_1.PaddingBottom = UDim.new(0,5)
				UIPadding_1.PaddingLeft = UDim.new(0,5)
				UIPadding_1.PaddingRight = UDim.new(0,5)
				UIPadding_1.PaddingTop = UDim.new(0,5)

				Scrolling_1.Name = "Scrolling"
				Scrolling_1.Parent = Scaler_1
				Scrolling_1.Active = true
				Scrolling_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Scrolling_1.BackgroundTransparency = 1
				Scrolling_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Scrolling_1.BorderSizePixel = 0
				Scrolling_1.Size = UDim2.new(1, 0,0, 215)
				Scrolling_1.ZIndex = 56
				Scrolling_1.ClipsDescendants = true
				Scrolling_1.AutomaticCanvasSize = Enum.AutomaticSize.None
				Scrolling_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
				Scrolling_1.CanvasPosition = Vector2.new(0, 0)
				Scrolling_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
				Scrolling_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
				Scrolling_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
				Scrolling_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
				Scrolling_1.ScrollBarImageTransparency = 0
				Scrolling_1.ScrollBarThickness = 0
				Scrolling_1.ScrollingDirection = Enum.ScrollingDirection.XY
				Scrolling_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
				Scrolling_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
				Scrolling_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

				UIListLayout_2.Parent = Scrolling_1
				UIListLayout_2.Padding = UDim.new(0,3)
				UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

				UIListLayout_2:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
					Scrolling_1.CanvasSize = UDim2.new(0, 0,0, (UIListLayout_2.AbsoluteContentSize.Y + 15 / UIScale_1.Scale))
				end)

				local isOpen = false

				UserInputService.InputBegan:Connect(function(A)
					local mouse = LocalPlayer:GetMouse()
					local mx, my = mouse.X, mouse.Y
					local DBP, DBS = Dropdown.AbsolutePosition, Dropdown.AbsoluteSize

					local function inside(pos, size)
						return mx >= pos.X and mx <= pos.X + size.X and my >= pos.Y and my <= pos.Y + size.Y
					end

					if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
						if not inside(DBP, DBS) then
							isOpen = false
							Dropdown.Visible = false
							Dropdown.Position = UDim2.new(0.5, 0,0.35, 0)
						end
					end
				end)

				local function OnDropdownOpen()
					for _, v in pairs(Background_1:GetChildren()) do
						if v.Name == "Dropdown" and v.Visible then
							return
						end
					end

					isOpen = not isOpen

					Library:Effect(Button, Template)

					if isOpen then
						Dropdown.Visible = true

						Library:Tween({
							v = Dropdown,
							t = 0.3,
							s = "Back",
							d = "Out",
							g = {Position = UDim2.new(0.5, 0,0.5, 0)}
						}):Play()
					else
						Dropdown.Visible = false
						Dropdown.Position = UDim2.new(0.5, 0,0.3, 0)
					end
				end

				Button.MouseButton1Click:Connect(OnDropdownOpen)

				TextBox_1.Changed:Connect(function()
					local SearchT = string.lower(TextBox_1.Text)

					for i, v in pairs(Scrolling_1:GetChildren()) do
						if v:IsA("Frame") and v.Name == 'AddList' then
							local labelText = string.lower(v.Title.Text)
							if string.find(labelText, SearchT, 1, true) then
								v.Visible = true
							else
								v.Visible = false
							end
						end
					end
				end)

				local selectedItem

				local Setting = {}

				function Setting:Clear(a)
					local function shouldClear(v)
						if a == nil then
							return true
						elseif type(a) == "string" then
							return v.Title.Text == a
						elseif type(a) == "table" then
							for _, name in ipairs(a) do
								if v.Title.Text == name then
									return true
								end
							end
						end

						return false
					end

					for _, v in ipairs(Scrolling_1:GetChildren()) do
						if v:IsA("Frame") and shouldClear(v) then
							if selectedItem and v.Title.Text == selectedItem then
								selectedItem = nil
								Desc_1.Text = "N/A"
							end
							v:Destroy()
						end
					end

					if selectedItem == a or Desc_1.Text == a then
						selectedItem = nil
						Desc_1.Text = "N/A"
					end

					if a == nil then
						selectedItem = nil
						Desc_1.Text = "N/A"
					end
				end

				local selectedValues = {}

				local function isValueInTable(val, tbl)
					if type(tbl) ~= "table" then
						return false
					end

					for _, v in pairs(tbl) do
						if v == val then
							return true
						end
					end

					return false
				end

				function Setting:AddList(Name)
					local AddList = Instance.new("Frame")
					local UICorner_1 = Instance.new("UICorner")
					local Title_1 = Instance.new("TextLabel")

					AddList.Name = "AddList"
					AddList.Parent = Scrolling_1
					AddList.BackgroundColor3 = Color3.fromRGB(255,255,255)
					AddList.BackgroundTransparency = 1
					AddList.BorderColor3 = Color3.fromRGB(0,0,0)
					AddList.BorderSizePixel = 0
					AddList.Size = UDim2.new(1, 0,0, 25)
					AddList.ZIndex = 56
					
					local Click = Library:Button(AddList)

					UICorner_1.Parent = AddList
					UICorner_1.CornerRadius = UDim.new(0,3)

					Title_1.Name = "Title"
					Title_1.Parent = AddList
					Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
					Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Title_1.BackgroundTransparency = 1
					Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Title_1.BorderSizePixel = 0
					Title_1.Position = UDim2.new(0.5, 0,0.5, 0)
					Title_1.Size = UDim2.new(0.899999976, 0,1, 0)
					Title_1.ZIndex = 56
					Title_1.FontFace = Font.new(
						"rbxassetid://12187374537",
						Enum.FontWeight.Regular,
						Enum.FontStyle.Normal
					)
					Title_1.RichText = true
					Title_1.Text = Name
					Title_1.TextColor3 = Color3.fromRGB(255,255,255)
					Title_1.TextSize = 13
					Title_1.TextTransparency = 0.30000001192092896
					
					local Line_1 = Instance.new("Frame")
					Line_1.Name = "Line"
					Line_1.Parent = AddList
					Line_1.AnchorPoint = Vector2.new(0, 1)
					Line_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Line_1.BackgroundTransparency = 0.9300000071525574
					Line_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Line_1.BorderSizePixel = 0
					Line_1.Position = UDim2.new(0, 0,1, 0)
					Line_1.Size = UDim2.new(1, 0,0, 1)
					Line_1.ZIndex = 56

					local function OnValue(value)
						if value then
							Title_1.TextColor3 = Color3.fromRGB(255, 0, 127)
						else
							Title_1.TextColor3 = Color3.fromRGB(255, 255, 255)
						end
					end

					local function OnSelected()
						if Multi then
							if selectedValues[Name] then
								selectedValues[Name] = nil
								OnValue(false)
							else
								selectedValues[Name] = true
								OnValue(true)
							end

							local selectedList = {}

							for i, v in pairs(selectedValues) do
								table.insert(selectedList, i)
							end

							if #selectedList > 0 then
								table.sort(selectedList)
								Value = selectedList
								Settext()
							else
								Desc_1.Text = "N/A"
							end

							pcall(Callback, selectedList)
						else
							for i,v in pairs(Scrolling_1:GetChildren()) do
								if v:IsA("Frame") and v.Name == 'AddList' then
									v.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
								end
							end

							OnValue(true)
							Value = Name
							Settext()
							pcall(Callback, Value)
						end
					end

					delay(0,function()
						if Multi then
							if isValueInTable(Name, Value) then
								selectedValues[Name] = true

								OnValue(true)

								local selectedList = {}

								for i, v in pairs(selectedValues) do
									table.insert(selectedList, i)
								end

								if #selectedList > 0 then
									Settext()
								else
									Desc_1.Text = "N/A"
								end

								pcall(Callback, selectedList)
							end
						else
							if Name == Value then
								Value = Name
								OnValue(true)
								Settext()
								pcall(Callback, Value)
							end
						end
					end)

					Click.MouseButton1Click:Connect(OnSelected)
				end

				for _, name in ipairs(List) do
					Setting:AddList(name)
				end

				return Setting
			end

			return Class
		end

		return Section
	end

	local ClicKReturn = Library:Button(Return_1) do
		ClicKReturn.MouseButton1Click:Connect(function()
			Return_1.Visible = false

			for _, v in pairs(Page_1:GetChildren()) do
				if v:IsA("Frame") then
					v.Visible = false
				end
			end

			Main.Visible = true
			UIPageLayout_1:JumpTo(Main)
		end)
	end

	Library:Draggable(Background_1)

	UIListLayout_1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabsScrolling_1.CanvasSize = UDim2.new(0, 0, 0, (UIListLayout_1.AbsoluteContentSize.Y + 30 / UIScale_1.Scale))
	end)

	UIPageLayout_1:JumpTo(Main)
	
	local Large = 1.1
	local Medium = 0.945
	local Small = 0.875
	
	local function TweenScale(size)
		if size == "Large" then
			SCALER = Large
		elseif size == 'Medium' then
			SCALER = Medium
		elseif size == 'Small' then
			SCALER = Small
		end
		
		Library:Tween({
			v = UIScale_1,
			t = 0.3,
			s = "Back",
			d = "Out",
			g = {Scale = SCALER}
		}):Play()
	end
	
	function Window:Size(tab)
		return tab:List({
			Title = 'Interface Size',
			List = {"Large", "Medium", "Small"},
			Value = "Medium",
			Multi = false,
			Callback = TweenScale,
		})
	end

	return Window
end

return Library
