-- UI manager
-- @see Validark

local UI = {}

local Maid = require(script.Parent.Maid)
local Tween = require(script.Parent.Tween)
local Bezier = require(script.Parent.Bezier)
local GitHub = require(script.Parent.GitHub)
local Blacklist = require(script.Parent.Blacklist)
local SharedData = require(script.Parent.SharedData)
local GetFirstChild = require(script.Parent.GetFirstChild)
local GetDependencies = require(script.Parent.GetDependencies)
local AsymmetricTransformation = require(script.Parent.AsymmetricTransformation)

local GlobalMaid = require(script.Parent.GlobalMaid)
local Button = require(script.Parent.Button)
local Snackbar = require(script.Parent.Snackbar)
local Colors = require(script.Parent.Colors)
local GetDescendantsInPredictableOrder = require(script.Parent.GetDescendantsInPredictableOrder)
local InsertComment = require(script.Parent.InsertComment)
local Shadow = require(script.Parent.Shadow)

local Debug = require(script.Parent.Debug)

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Heartbeat = RunService.Heartbeat

local Repository
local Open

local MAIN_COLOR = Colors.Green
local INSTALLED_COLOR = Colors.Teal
local SETTINGS_COLOR = Colors.Indigo

local function GetRepository()
	Repository = ServerStorage:FindFirstChild("Repository") or ServerScriptService:FindFirstChild("Repository")
	if Repository then
		return Repository
	else
		if Open then
			UI:CloseWindow()
		end
		return Instance.new("Folder")
	end
end

Repository = GetRepository()
local AvailableUpdates = 0

-- Curves
local Standard = Bezier.new(0.4, 0.0, 0.2, 1)

local function GetScreen(plug)
	local Screen = game:GetService("PluginGuiService"):FindFirstChild("RoStrap")
	Screen.Enabled = true
	return Screen
end


-- Data
wait()
local TagWhitelist = SharedData.TagWhitelist

function UI:Start(plug)
	-- Yields for 2.4 seconds
	local STUDIO_COLOR = Color3.fromRGB(0, 161, 255)
	local STUDIO_ImageRectOffset = Vector2.new(2, 0)
	local STUDIO_ImageRectSize = Vector2.new(48, 48)

	local ROSTRAP_COLOR = Colors.White
	local ROSTRAP_ImageRectOffset = Vector2.new(0, 0)
	local ROSTRAP_ImageRectSize = Vector2.new(64, 64)

	Open = true
	local Center = Vector2.new(0.5, 0.5)
	local Middle = Vector2.new(0.5, 0)

	local Window = Instance.new("Frame")
	Window.AnchorPoint = Center
	Window.BackgroundColor3 = MAIN_COLOR[900]
	Window.BorderSizePixel = 0
	Window.Position = UDim2.new(0.5, 0, 0.5, 0)
	Window.Size = UDim2.new(0, 120, 0, 120)
	Window.ZIndex = 3

	local Logo = Instance.new("ImageLabel")
	Logo.AnchorPoint = Center
	Logo.BackgroundTransparency = 1
	Logo.Position = UDim2.new(0.5, 0, 0, 112)
	-- Logo.Size = UDim2.new(0, 64, 0, 64)
	Logo.Image = "rbxassetid://941214330"
	Logo.ImageColor3 = STUDIO_COLOR
	Logo.ImageRectOffset = STUDIO_ImageRectOffset
	Logo.ImageRectSize = STUDIO_ImageRectSize
	Logo.ImageTransparency = 0
	Logo.ZIndex = 4

	local Shadow = Instance.new("Frame")
	Shadow.AnchorPoint = Center
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.Size = UDim2.new(1, 8, 1, 8)
	Shadow.Style = "DropShadow"
	Shadow.ZIndex = 2

	local Description = Instance.new("TextLabel")
	Description.AnchorPoint = Middle
	Description.BackgroundTransparency = 1
	Description.Position = UDim2.new(0.5, 0, 0, 220)
	Description.Size = UDim2.new(0, 0, 0, 0)
	Description.Rotation = 0
	Description.Font = "SourceSansBold"
	Description.Text = "Loading RoStrap"
	Description.TextColor3 = Colors.White
	Description.TextSize = 26
	Description.TextTransparency = 1
	Description.ZIndex = 5

	Description.Parent = Window
	Logo.Parent = Window
	Shadow.Parent = Window
	Window.Name = "Noodles"
	Window.Parent = GetScreen(plug)

	local Duration = 0.8
	local HeightStart = Duration*0.1
	local WidthDuration = Duration*0.75

	local Material, EndSize = Window, UDim2.new(0, 300, 0, 350) do
		-- Custom AsymmetricTransformation
		-- https://material.io/guidelines/motion/transforming-material.html#

		local StartX = Material.Size.X
		local StartY = Material.Size.Y
		local EndX = EndSize.X
		local EndY = EndSize.Y

		local XStartScale = StartX.Scale
		local XStartOffset = StartX.Offset
		local YStartScale = StartY.Scale
		local YStartOffset = StartY.Offset

		local XScaleChange = EndX.Scale - XStartScale
		local XOffsetChange = EndX.Offset - XStartOffset
		local YScaleChange = EndY.Scale - YStartScale
		local YOffsetChange = EndY.Offset - YStartOffset

		local ElapsedTime, Connection = 0

		Connection = Heartbeat:Connect(function(Step)
			ElapsedTime = ElapsedTime + Step
			if Duration > ElapsedTime then
				local XScale, XOffset, YScale, YOffset

				if WidthDuration > ElapsedTime then
					local WidthAlpha = Standard(ElapsedTime, 0, 1, WidthDuration)
					XScale = XStartScale + WidthAlpha*XScaleChange
					XOffset = StartX.Offset + WidthAlpha*XOffsetChange
				else
					XScale = Material.Size.X.Scale
					XOffset = Material.Size.X.Offset
				end

				if ElapsedTime > HeightStart then
					local HeightAlpha = Standard(ElapsedTime - HeightStart, 0, 1, Duration)
					YScale = YStartScale + HeightAlpha*YScaleChange
					YOffset = YStartOffset + HeightAlpha*YOffsetChange
				else
					YScale = YStartScale
					YOffset = YStartOffset
				end

				Material.Size = UDim2.new(XScale, XOffset, YScale, YOffset)
			else
				Connection:Disconnect()
				Material.Size = EndSize
			end
		end)
	end

	local KeepRunning = true
	local FinishedRunning = false
	local TransitionTime = 0.8

	spawn(function()
		wait(0.2)
		Tween(Logo, "Size", UDim2.new(0, 64, 0, 64), "Deceleration", 0.8)
		Tween(Logo, "Rotation", 14, "Deceleration", 1)
		wait(1)
		Tween(Description, "TextTransparency", 0, "Standard", TransitionTime, true)
		Tween(Logo, "ImageRectOffset", ROSTRAP_ImageRectOffset, "Standard", TransitionTime, true)
		Tween(Logo, "ImageRectSize", ROSTRAP_ImageRectSize, "Standard", TransitionTime, true)
		Tween(Logo, "ImageColor3", ROSTRAP_COLOR, "Standard", TransitionTime, true)
		Tween(Logo, "Rotation", 0, "Standard", TransitionTime, true)
		wait(1)

		while KeepRunning do
			Tween(Logo, "ImageRectOffset", STUDIO_ImageRectOffset, "Deceleration", TransitionTime, true)
			Tween(Logo, "ImageRectSize", STUDIO_ImageRectSize, "Deceleration", TransitionTime, true)
			Tween(Logo, "ImageColor3", STUDIO_COLOR, "Deceleration", TransitionTime, true)
			Tween(Logo, "Rotation", 14, "Deceleration", TransitionTime)
			wait(1)
			Tween(Logo, "ImageRectOffset", ROSTRAP_ImageRectOffset, "Standard", TransitionTime, true)
			Tween(Logo, "ImageRectSize", ROSTRAP_ImageRectSize, "Standard", TransitionTime, true)
			Tween(Logo, "ImageColor3", ROSTRAP_COLOR, "Standard", TransitionTime, true)
			Tween(Logo, "Rotation", 0, "Standard", TransitionTime, true)
			wait(1)
		end
		FinishedRunning = true
	end)
	-- wait(1)
	-- Tween(Logo, "ImageRectOffset", Vector2.new(2, 0), "Standard", TransitionTime, true)
	-- Tween(Logo, "ImageRectSize", Vector2.new(48, 48), "Standard", TransitionTime, true)
	-- Tween(Logo, "ImageColor3", Color3.fromRGB(0, 161, 255), "Standard", TransitionTime, true)
	-- Tween(Logo, "Rotation", 14, "Standard", TransitionTime, true)
	-- wait(1.2)
	-- Tween(Logo, "ImageRectOffset", Vector2.new(0, 0), "Standard", TransitionTime, true)
	-- Tween(Logo, "ImageRectSize", Vector2.new(64, 64), "Standard", TransitionTime, true)
	-- Tween(Logo, "ImageColor3", Colors.White, "Standard", TransitionTime, true)
	-- Tween(Logo, "Rotation", 0, "Standard", TransitionTime, true)

	return function()
		KeepRunning = false
		while not FinishedRunning do wait() end
		Shadow:Destroy()
		Tween(Logo, "ImageTransparency", 1, "Standard", TransitionTime - 0.2, true)
		Tween(Description, "TextTransparency", 1, "Standard", TransitionTime - 0.2, true)
		Tween(Window, "BackgroundTransparency", 1, "Standard", TransitionTime, true):Wait()
		Window:Destroy()
	end
end

-- Ink Ripple
local Circle = Instance.new("ImageLabel")
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.BackgroundTransparency = 1
Circle.Size = UDim2.new(0, 4, 0, 4)
Circle.Image = "rbxassetid://517259585"
Circle.ImageTransparency = 0.8
Circle.Name = "Ink"
Circle.ZIndex = 7

game:GetService("ContentProvider"):Preload(Circle.Image)

UI.Buttons = {}
local CurrentCircle

local function GiveFlatButtonRipple(Button)
	-- Adds FlatButton to Buttons and gives it a Ripple effect
	-- @param <TextButton, ImageButton> Button with Button.Corner
	local ButtonMaid = Maid.new()
	UI.Buttons[#UI.Buttons + 1] = Button
	local Corner = Button.Corner
	Corner.BackgroundColor3 = Button.TextColor3 -- Header.BackgroundColor3

	ButtonMaid:LinkToInstance(Button)

	ButtonMaid:GiveTask(Button.MouseButton1Down:Connect(function(X, Y)
		local PreviousCircle = CurrentCircle
		if PreviousCircle then
			Tween(PreviousCircle, "ImageTransparency", 1, "Deceleration", 1, false, function(EnumItem)
				if EnumItem.Name == "Completed" then
					PreviousCircle:Destroy()
				end
			end)
		end
		X, Y = X - Button.AbsolutePosition.X, Y - Button.AbsolutePosition.Y
		local AbsoluteSize = Button.AbsoluteSize
		local V, W = X - AbsoluteSize.X, Y - AbsoluteSize.Y
		local a, b, c, d = (X*X + Y*Y) ^ 0.5, (X*X + W*W) ^ 0.5, (V*V + Y*Y) ^ 0.5, (V*V + W*W) ^ 0.5 -- Calculate distance between mouse and corners
		local Diameter = 2*(a > b and a > c and a > d and a or b > c and b > d and b or c > d and c or d) + 2.5 -- Find longest distance between mouse and a corner

		local Circle = Circle:Clone()
		Circle.ImageColor3 = Button.TextColor3
		Circle.Position = UDim2.new(0, X, 0, Y)
		CurrentCircle = Circle
		Circle.Parent = Button

		Tween(Circle, "Size", UDim2.new(0, Diameter, 0, Diameter), "Deceleration", 0.5)
	end))

	ButtonMaid:GiveTask(Button.MouseButton1Up:Connect(function()
		local CurrentCircle = CurrentCircle
		if CurrentCircle then
			Tween(CurrentCircle, "ImageTransparency", 1, "Deceleration", 1, false, function(EnumItem)
				if EnumItem.Name == "Completed" then
					CurrentCircle:Destroy()
				end
			end)
		end
	end))

	ButtonMaid:GiveTask(Button.MouseEnter:Connect(function()
		Button.Corner.BackgroundTransparency = 0.88
		for a = 1, #UI.Buttons do
			local Button2 = UI.Buttons[a]
			if Button2 ~= Button then
				local Corner = Button2:FindFirstChild("Corner")
				if Corner then
					Corner.BackgroundTransparency = 1
				end
				local CurrentCircle = CurrentCircle
				if CurrentCircle and CurrentCircle == Button2:FindFirstChild("Ink") then -- Fade out Ripples in Buttons that are no longer being MouseOvered
					Tween(CurrentCircle, "ImageTransparency", 1, "Deceleration", 1, false, function(EnumItem)
						if EnumItem.Name == "Completed" then
							CurrentCircle:Destroy()
						end
					end)
				end
			end
		end
	end))
end

local TweenCompleted = Enum.TweenStatus.Completed

function UI:CreateSnackbar(Text, Override)
	if Open or Override then
		Snackbar.new(Text, game:GetService("PluginGuiService"):FindFirstChild("RoStrap"))
	end
end

function UI:PromptInstall()
	Open = true
	local DialogBox = Instance.new("ImageLabel", GetScreen())
	DialogBox.AnchorPoint = Vector2.new(0.5, 0.5)
	DialogBox.BackgroundColor3 = Colors.White
	DialogBox.BackgroundTransparency = 1
	DialogBox.BorderSizePixel = 0
	DialogBox.Position = UDim2.new(0.5, 0, 0, -774)
	DialogBox.Size = UDim2.new(0, 774, 0, 182)
	DialogBox.Image = "rbxasset://textures/ui/btn_newWhite.png"
	DialogBox.ImageTransparency = 1
	DialogBox.ScaleType = Enum.ScaleType.Slice
	DialogBox.SliceCenter = Rect.new(7, 7, 13, 13)

	local TitleText = Instance.new("TextLabel", DialogBox)
	TitleText.Text = "Install RoStrap's core Bootstrapper?"
	TitleText.BackgroundTransparency = 1
	TitleText.Name = "Title"
	TitleText.Position = UDim2.new(0, 27, 0, 27)
	TitleText.TextXAlignment = "Left"
	TitleText.TextYAlignment = "Top"
	TitleText.Font = Enum.Font.SourceSans
	TitleText.TextColor3 = Colors.Black
	TitleText.TextSize = 28
	TitleText.TextTransparency = 1

	local MessageText = TitleText:Clone()
	MessageText.Name = "Subtitle"
	MessageText.Position = UDim2.new(0, 27, 0, 72)
	MessageText.Size = UDim2.new(1, -48, 0, 44)
	MessageText.Text = "In order to install Libraries with this Package manager, you must install Resources.lua into ReplicatedStorage."
	MessageText.TextSize = 20
	MessageText.TextWrapped = true
	MessageText.Parent = DialogBox

	local InstallButton = Button.new("Flat")
	InstallButton.BackgroundTransparency = 1
	InstallButton.ClipsDescendants = true
	InstallButton.Font = Enum.Font.SourceSansBold
	InstallButton.TextSize = 18
	InstallButton.ZIndex = 3
	InstallButton.Name = "InstallButton"
	InstallButton.Position = UDim2.new(1, -96, 1, -44)
	InstallButton.Size = UDim2.new(0, 88, 0, 36)
	InstallButton.Text = "INSTALL"
	InstallButton.TextColor3 = Colors.Black
	InstallButton.TextTransparency = 1
	InstallButton.Parent = DialogBox

	local DenyButton = Button.new("Flat")
	DenyButton.BackgroundTransparency = 1
	DenyButton.ClipsDescendants = true
	DenyButton.Font = Enum.Font.SourceSansBold
	DenyButton.TextSize = 18
	DenyButton.ZIndex = 3
	DenyButton.TextColor3 = Colors.Black
	DenyButton.TextTransparency = 1
	DenyButton.Name = "DenyButton"
	DenyButton.Size = UDim2.new(0, 68, 0, 36)
	DenyButton.Text = "DENY"
	DenyButton.Position = UDim2.new(1, -172, 1, -44)
	DenyButton.Parent = DialogBox

	local SetRepositoryLocation = DialogBox:Clone()
	SetRepositoryLocation.Size = UDim2.new(0, 273, 0, 152)

	SetRepositoryLocation.Title.Text = "Set Repository Location"
	SetRepositoryLocation.Subtitle:Destroy()

	local ServerStorageButton = SetRepositoryLocation.InstallButton
	ServerStorageButton.Position = UDim2.new(0, 3, 0, 69)
	ServerStorageButton.Size = UDim2.new(1, -6, 0, 36)
	ServerStorageButton.Text = "ServerStorage"

	local ServerScriptServiceButton = SetRepositoryLocation.DenyButton
	ServerScriptServiceButton.Position = UDim2.new(0, 3, 0, 105)
	ServerScriptServiceButton.Size = UDim2.new(1, -6, 0, 36)
	ServerScriptServiceButton.Text = "ServerScriptService"

	Tween(DenyButton, "TextTransparency", 0.12, "Deceleration", nil, 0.5)
	Tween(InstallButton, "TextTransparency", 0.12, "Deceleration", nil, 0.5)
	Tween(MessageText, "TextTransparency", 0.46, "Deceleration", nil, 0.5)
	Tween(TitleText, "TextTransparency", 0.12, "Deceleration", nil, 0.5)
	Tween(DialogBox, "Position", UDim2.new(0.5, 0, 0.5, 0), "Deceleration", 0.5)
	Tween(DialogBox, "ImageTransparency", 0, "Deceleration", 0.5)

	local SuccessfullySetup
	local InstallButtonConnection, DenyButtonConnection
	local Resources
	DenyButtonConnection = DenyButton.MouseButton1Click:Connect(function()
		InstallButtonConnection:Disconnect()
		DenyButtonConnection:Disconnect()
		Open = false
		UI:CloseWindow()
		SuccessfullySetup = true

		DenyButton.Corner.ImageTransparency = 1
		InstallButton.Corner.ImageTransparency = 1
		Tween(DenyButton, "TextTransparency", 1, "Acceleration", nil, 0.5)
		Tween(InstallButton, "TextTransparency", 1, "Acceleration", nil, 0.5)
		Tween(MessageText, "TextTransparency", 1, "Acceleration", nil, 0.5)
		Tween(TitleText, "TextTransparency", 1, "Acceleration", nil, 0.5)
		Tween(DialogBox, "Position", UDim2.new(0.5, 0, 0.3, 0), "Acceleration", 0.5)
		Tween(DialogBox, "ImageTransparency", 1, "Acceleration", 0.5, false, function(Completed)
			if Completed == TweenCompleted then
				wait()
				DialogBox:Destroy()
			end
		end)
	end)

	InstallButtonConnection = InstallButton.MouseButton1Click:Connect(function()
		InstallButtonConnection:Disconnect()
		DenyButtonConnection:Disconnect()
		UI.Buttons = {}
		DenyButton.Corner.ImageTransparency = 1
		InstallButton.Corner.ImageTransparency = 1
		Tween(DenyButton, "TextTransparency", 1, "Acceleration", nil, 0.5)
		Tween(InstallButton, "TextTransparency", 1, "Acceleration", nil, 0.5)
		Tween(MessageText, "TextTransparency", 1, "Acceleration", nil, 0.5)
		Tween(TitleText, "TextTransparency", 1, "Acceleration", nil, 0.5)
		Tween(DialogBox, "Position", UDim2.new(0.5, 0, 0.3, 0), "Acceleration", 0.5)
		Tween(DialogBox, "ImageTransparency", 1, "Acceleration", 0.5, false, function(Completed)
			if Completed == TweenCompleted then
				wait()
				DialogBox:Destroy()
			end
		end)

		SetRepositoryLocation.Parent = GetScreen()

		Tween(ServerScriptServiceButton, "TextTransparency", 0.12, "Deceleration", nil, 0.5)
		Tween(ServerStorageButton, "TextTransparency", 0.12, "Deceleration", nil, 0.5)
		Tween(SetRepositoryLocation.Title, "TextTransparency", 0.12, "Deceleration", nil, 0.5)
		Tween(SetRepositoryLocation, "Position", UDim2.new(0.5, 0, 0.5, 0), "Deceleration", 0.5)
		Tween(SetRepositoryLocation, "ImageTransparency", 0, "Deceleration", 0.5)
		GiveFlatButtonRipple(ServerScriptServiceButton)
		GiveFlatButtonRipple(ServerStorageButton)

		local OldResources = ReplicatedStorage:FindFirstChild("Resources")
		if OldResources then
			OldResources.Source = ""
		end
		Resources = GitHub:Install("RoStrap/Resources", ReplicatedStorage)
		InsertComment(Resources, "@rostrap", "Resources")
		UI:CreateSnackbar("Created Resources.lua in ReplicatedStorage")

		local ServerScriptServiceButtonConnection
		local ServerStorageButtonConnection
		
		local function DestroyFirstChild(parent, name, className)
			local target = parent:FindFirstChild(name)
			if target and target:IsA(className) then
				target:Destroy()
				return true
			end
			return false
		end

		ServerScriptServiceButtonConnection = ServerScriptServiceButton.MouseButton1Click:Connect(function()
			ServerStorageButtonConnection:Disconnect()
			ServerScriptServiceButtonConnection:Disconnect()
			UI:CreateSnackbar("Created Repository Folder in ServerScriptService" .. (DestroyFirstChild(ServerStorage, "Repository", "Folder") and ". Destroying Repository in ServerStorage." or ""))
			Repository = GetFirstChild(ServerScriptService, "Repository", "Folder")
			UI.Buttons = {}
			ServerScriptServiceButton.Corner.ImageTransparency = 1
			ServerStorageButton.Corner.ImageTransparency = 1
			Tween(ServerScriptServiceButton, "TextTransparency", 1, "Deceleration", nil, 0.5)
			Tween(ServerStorageButton, "TextTransparency", 1, "Deceleration", nil, 0.5)
			Tween(SetRepositoryLocation.Title, "TextTransparency", 1, "Deceleration", nil, 0.5)
			Tween(SetRepositoryLocation, "Position", UDim2.new(0.5, 0, 0.3, 0), "Deceleration", 0.5)
			Tween(SetRepositoryLocation, "ImageTransparency", 1, "Deceleration", 0.5, false, function(Completed)
				if Completed == TweenCompleted then
					wait()
					SetRepositoryLocation:Destroy()
					SuccessfullySetup = true
				end
			end)
		end)

		ServerStorageButtonConnection = ServerStorageButton.MouseButton1Click:Connect(function()
			ServerStorageButtonConnection:Disconnect()
			ServerScriptServiceButtonConnection:Disconnect()
			UI:CreateSnackbar("Created Repository Folder in ServerStorage" .. (DestroyFirstChild(ServerScriptService, "Repository", "Folder") and ". Destroying Repository in ServerScriptService." or ""))
			Repository = GetFirstChild(ServerStorage, "Repository", "Folder")
			UI.Buttons = {}
			ServerScriptServiceButton.Corner.ImageTransparency = 1
			ServerStorageButton.Corner.ImageTransparency = 1
			Tween(ServerScriptServiceButton, "TextTransparency", 1, "Deceleration", nil, 0.5)
			Tween(ServerStorageButton, "TextTransparency", 1, "Deceleration", nil, 0.5)
			Tween(SetRepositoryLocation.Title, "TextTransparency", 1, "Deceleration", nil, 0.5)
			Tween(SetRepositoryLocation, "Position", UDim2.new(0.5, 0, 0.3, 0), "Deceleration", 0.5)
			Tween(SetRepositoryLocation, "ImageTransparency", 1, "Deceleration", 0.5, false, function(Completed)
				if Completed == TweenCompleted then
					wait()
					SetRepositoryLocation:Destroy()
					SuccessfullySetup = true
				end
			end)
		end)
	end)

	repeat wait() until SuccessfullySetup
	return Resources, Repository
end

local WindowGenerated
local StatusBar, VerticleScroller, VerticleScrollerOutline, Header

local Card = {}
local Cards = {}
local InstalledCards = {}
local Settings = {}
local Tab = {}
local CardSize = UDim2.new(0, 232, 0, 136)
local XSize = CardSize.X.Offset
local YSize = CardSize.Y.Offset

function UI:CloseWindow()
	Open = false
	if StatusBar then
		StatusBar:Destroy()
		Cards = setmetatable({Offset = -4}, Tab)
		InstalledCards = setmetatable({Offset = XSize * 4 + 12}, Tab)
		UI.Cards = Cards
		UI.InstalledCards = InstalledCards -- FIXME: Did I just break this?
		Settings = setmetatable({Offset = XSize * 8 + 24}, Tab)
		UI.Buttons = {}
		AvailableUpdates = 0
	end
	GetScreen().Enabled = false
end

UI.Card = Card
UI.Cards = Cards
UI.InstalledCards = InstalledCards -- FIXME: Did I just break this?
UI.Settings = Settings

local CurrentTab = Cards

local GIVE_SCROLLBAR_DURATION = 0.375

function UI:DecideWhetherScrollable()
	local Rows = math.floor((#CurrentTab - 1)*0.25) + 1
	Tween(VerticleScroller, "CanvasSize", UDim2.new(0, 0, 0, 414 + 136*(Rows - 3)), "Standard", GIVE_SCROLLBAR_DURATION, true)

	if Rows > 3 then
		VerticleScroller.ScrollingEnabled = true
		Tween(VerticleScroller, "ScrollBarThickness", 8, "Standard", GIVE_SCROLLBAR_DURATION, true)
		-- VerticleScrollerOutline.BackgroundTransparency = 0
		--Tween(StatusBar, "Size", UDim2.new(0, 945, 0, 0), "Standard", GIVE_SCROLLBAR_DURATION, true)
	else
		VerticleScroller.ScrollingEnabled = false
		Tween(VerticleScroller, "ScrollBarThickness", 0, "Standard", GIVE_SCROLLBAR_DURATION, true)
		-- VerticleScrollerOutline.BackgroundTransparency = 1
		--Tween(StatusBar, "Size", UDim2.new(0, 936, 0, 0), "Standard", GIVE_SCROLLBAR_DURATION, true)
	end
end

local CardTemplate, CardWorkspace

function UI:OpenWindow(Func)
	Open = true
	-- if WindowGenerated then
	-- 	StatusBar.Visible = true
	-- else
		-- Create UI Elements
		local HeaderShadow, Logo, Title, FindButton, InstalledButton, Seeker, Corner, CardBackground, Card, CardShadow, CardCorner, CardTitle, CardSubtitle, CardLearnMore, CardInstall, CardInstallCorner
		WindowGenerated = true

		StatusBar = Instance.new("Frame")
		StatusBar.Active = true
		--StatusBar.AnchorPoint = Vector2.new(0.5, 0)
		--StatusBar.Draggable = true
		StatusBar.BorderSizePixel = 0
		StatusBar.Name = "StatusBar"
		--StatusBar.Position = UDim2.new(0.5, 0, 0, 50)
		StatusBar.Size = UDim2.new(0, 945, 0, 0)

		Header = Instance.new("Frame", StatusBar)
		Header.Active = true
		Header.BackgroundColor3 = Colors.White
		Header.BorderSizePixel = 0
		--Header.Draggable = true
		Header.Name = "Header"
		Header.Position = UDim2.new(0, 0, 1, 0)
		Header.Size = UDim2.new(1, 0, 0, 108)
		Header.ZIndex = 5

		HeaderShadow = Instance.new("Frame", Header)
		HeaderShadow.Name = "Shadow"
		HeaderShadow.Position = UDim2.new(0, -4, 0, -4)
		HeaderShadow.Size = UDim2.new(1, 8, 1, 8)
		HeaderShadow.Style = Enum.FrameStyle.DropShadow
		HeaderShadow.ZIndex = 4

		local FullShadow = HeaderShadow:Clone()
		FullShadow.AnchorPoint = Vector2.new(0.5, 0)
		FullShadow.Size = UDim2.new(1, 8, 0, 530)
		FullShadow.Position = UDim2.new(0.5, 0, 0, -4)
		FullShadow.ZIndex = 1
		FullShadow.Parent = Header

		Logo = Instance.new("ImageLabel", Header)
		Logo.AnchorPoint = Vector2.new(1, 0)
		Logo.BackgroundTransparency = 1
		Logo.Name = "Logo"
		Logo.Image = "rbxassetid://941214330"
		-- Logo.ImageColor3 = Colors.Black
		--Logo.ImageTransparency = 0.8
		Logo.Position = UDim2.new(1, -8, 0, 8)
		Logo.Size = UDim2.new(0, 64, 0, 64)
		Logo.ZIndex = 6

		Title = Instance.new("TextLabel", Header)
		Title.AnchorPoint = Vector2.new(0.5, 0.5)
		Title.BackgroundTransparency = 1
		Title.Font = Enum.Font.SourceSans
		Title.Name = "Title"
		Title.Position = UDim2.new(0, 36, 0.5, 0)
		Title.Text = "RoStrap Package Manager"
		Title.TextColor3 = Colors.White
		Title.TextSize = 28
		Title.TextXAlignment = "Left"
		Title.TextYAlignment = "Bottom"
		Title.ZIndex = 6

		local MyTitle = Instance.new("TextLabel")
		MyTitle.AnchorPoint = Vector2.new(1, 1)
		MyTitle.BackgroundTransparency = 1
		MyTitle.Font = Enum.Font.SourceSansBold
		MyTitle.Name = "Title"
		MyTitle.Position = UDim2.new(1, 0, 1, 0)
		MyTitle.Size = UDim2.new(0, 200, 0, 30)
		MyTitle.Text = "https://rostrap.github.io/Libraries"
		MyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		MyTitle.TextSize = 14
		MyTitle.ZIndex = 6
		MyTitle.Parent = Header

		FindButton = Button.new("Flat", Header)
		FindButton.BackgroundTransparency = 1
		FindButton.ClipsDescendants = true
		FindButton.Font = Enum.Font.SourceSansBold
		FindButton.Name = "LIBRARIES"
		FindButton.Text = "LIBRARIES"
		FindButton.TextColor3 = Colors.White
		FindButton.TextSize = 18
		FindButton.Position = UDim2.new(0, 0, 1, -36)
		FindButton.Size = UDim2.new(0, 106, 0, 36)
		FindButton.ZIndex = 6

		Seeker = Instance.new("Frame", Header)
		Seeker.BorderSizePixel = 0
		Seeker.Name = "Seeker"
		Seeker.ZIndex = 10

		Corner = Instance.new("ImageLabel")
		Corner.BackgroundTransparency = 1
		Corner.Image = "rbxassetid://550542844"
		Corner.ImageColor3 = Header.BackgroundColor3
		Corner.Name = "Corner"
		Corner.ScaleType = Enum.ScaleType.Slice
		Corner.SliceCenter = Rect.new(7, 7, 14, 14)
		Corner.Size = UDim2.new(1, 0, 1, 0)
		Corner.ZIndex = 9

		InstalledButton = Button.new("Flat", Header)
		InstalledButton.BackgroundTransparency = 1
		InstalledButton.ClipsDescendants = true
		InstalledButton.Font = Enum.Font.SourceSansBold
		InstalledButton.Name = "INSTALLED"
		InstalledButton.TextColor3 = Colors.White
		InstalledButton.TextSize = 18
		InstalledButton.Size = UDim2.new(0, 110, 0, 36)
		InstalledButton.ZIndex = 6

		InstalledButton.Position = UDim2.new(0, FindButton.Position.X.Offset + FindButton.Size.X.Offset, 1, -36)
		InstalledButton.Text = "INSTALLED"
		InstalledButton.Parent = Header

		VerticleScroller = Instance.new("ScrollingFrame", Header)
		VerticleScroller.BackgroundColor3 = Color3.fromRGB(232, 232, 232)
		VerticleScroller.BorderSizePixel = 0
		VerticleScroller.Name = "VerticleScroller"
		VerticleScroller.Position = UDim2.new(0, 0, 1, 0)
		VerticleScroller.ScrollingEnabled = false
		VerticleScroller.ScrollBarThickness = 0
		VerticleScroller.Size = UDim2.new(1, 0, 0, 414)
		VerticleScroller.BottomImage = "rbxassetid://158362107"
		VerticleScroller.MidImage = "rbxassetid://158362107"
		VerticleScroller.TopImage = "rbxassetid://158362107"
		VerticleScroller.ZIndex = 2

		VerticleScrollerOutline = Instance.new("Frame", VerticleScroller)
		VerticleScrollerOutline.AnchorPoint = Vector2.new(1, 0)
		VerticleScrollerOutline.BackgroundColor3 = Colors.White
		VerticleScrollerOutline.BackgroundTransparency = 1
		VerticleScrollerOutline.Position = UDim2.new(1, 0, 0, 0)
		VerticleScrollerOutline.Size = UDim2.new(0, 8, 1, 0)
		VerticleScrollerOutline.Visible = false
		VerticleScrollerOutline.ZIndex = 4

		local NUM_TABS = 3

		CardBackground = Instance.new("ScrollingFrame", VerticleScroller)
		CardBackground.BackgroundColor3 = Color3.fromRGB(232, 232, 232)
		CardBackground.BorderSizePixel = 0
		CardBackground.ClipsDescendants = false
		CardBackground.Name = "CardBackground"
		CardBackground.Position = UDim2.new(0, 0, 0, 0)
		CardBackground.ScrollingEnabled = false
		CardBackground.ScrollBarThickness = 0
		CardBackground.Size = UDim2.new(1, 0, 0, 414)
		CardBackground.CanvasSize = UDim2.new(NUM_TABS, (NUM_TABS - 1) * 8, 0, 0) -- 3 tabs, 8 padding

		CardWorkspace = Instance.new("Frame", CardBackground)
		CardWorkspace.BackgroundTransparency = 1
		CardWorkspace.Position = UDim2.new(0, 8, 0, 6)
		CardWorkspace.Size = UDim2.new(1, 0, 1, 0)

		CardTemplate = HeaderShadow:Clone()
		CardTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
		--CardTemplate.Position = UDim2.new(0, 0, 0, 0)
		--CardTemplate.Size = CardSize
		CardTemplate.ZIndex = 2

		local CardFrame = Instance.new("Frame")
		CardFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		CardFrame.BackgroundColor3 = Colors.White
		CardFrame.BorderColor3 = Color3.fromRGB(210, 210, 210)
		CardFrame.BorderSizePixel = 0
		CardFrame.ClipsDescendants = true
		CardFrame.Name = "Card"
		CardFrame.Size = UDim2.new(1, 8, 1, 8)
		CardFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		CardFrame.ZIndex = 3
		CardFrame.Parent = CardTemplate

		CardCorner = Corner:Clone()
		CardCorner.ImageColor3 = CardBackground.BackgroundColor3
		CardCorner.Parent = CardFrame

		CardTitle = Instance.new("TextLabel", CardFrame)
		CardTitle.AnchorPoint = Vector2.new(0.5, 0)
		CardTitle.BackgroundTransparency = 1
		CardTitle.Font = Enum.Font.SourceSans
		CardTitle.Name = "Title"
		CardTitle.Position = UDim2.new(0, 16, 0, 16)
		CardTitle.Text = ""
		CardTitle.TextColor3 = Colors.Black
		CardTitle.TextSize = 20
		CardTitle.TextTransparency = 0.12
		CardTitle.TextXAlignment = "Left"
		CardTitle.TextYAlignment = "Top"
		CardTitle.ZIndex = 4

		CardSubtitle = Instance.new("TextLabel", CardTitle)
		CardSubtitle.BackgroundTransparency = 1
		CardSubtitle.Font = Enum.Font.SourceSans
		CardSubtitle.Name = "Subtitle"
		CardSubtitle.Position = UDim2.new(0, 0, 0, 24)
		CardSubtitle.Size = UDim2.new(0, 192, 0, 48) -- UDim2.new(0, 136, 0, 28)
		CardSubtitle.Text = ""
		CardSubtitle.TextColor3 = Colors.Black
		CardSubtitle.TextSize = 14
		CardSubtitle.TextTransparency = 0.46
		CardSubtitle.TextWrapped = true
		CardSubtitle.TextXAlignment = "Left"
		CardSubtitle.TextYAlignment = "Top"
		CardSubtitle.ZIndex = 5

		local SettingsButton = Button.new("Flat", Header)
		SettingsButton.BackgroundTransparency = 1
		SettingsButton.ClipsDescendants = true
		SettingsButton.Font = Enum.Font.SourceSansBold
		SettingsButton.Name = "SETTINGS"
		SettingsButton.TextColor3 = Colors.White
		SettingsButton.TextSize = 18
		SettingsButton.Size = UDim2.new(0, 101, 0, 36)
		SettingsButton.ZIndex = 5
		SettingsButton.Position = UDim2.new(0, InstalledButton.Position.X.Offset + InstalledButton.Size.X.Offset, 1, -36)
		SettingsButton.Text = "SETTINGS"
		SettingsButton.Visible = false
		SettingsButton.Parent = Header

		local SettingsFrame = Instance.new("Frame", CardBackground)
		SettingsFrame.BackgroundColor3 = Colors.White
		SettingsFrame.BorderSizePixel = 0
		SettingsFrame.Position = UDim2.new(0, 1896, 0, 8)
		SettingsFrame.Size = UDim2.new(0, 920, 0, 398)
		SettingsFrame.ZIndex = 10

		Seeker.Position = UDim2.new(0, FindButton.Position.X.Offset - 20, 1, -2)

		Shadow.new(3, SettingsFrame)

		local WIP = Instance.new("TextLabel", SettingsFrame)
		WIP.BackgroundTransparency = 1
		WIP.Font = Enum.Font.SourceSans
		WIP.Text = "[Work in Progress]"
		WIP.TextSize = 36
		WIP.Position = UDim2.new(0.5, 0, 0, 16)
		WIP.Size = UDim2.new(0, 0, 0, 18)
		WIP.ZIndex = 11

		local Link = CardTitle:Clone()
		Link.Name = "Link"
		Link.Visible = false
		Link.Parent = CardFrame

		StatusBar.Parent = GetScreen()

		-- 808 + 232
		-- 1056
		-- First element at x = 2000 on Settings tab
		--

		local Scrolling1, Scrolling2, Scrolling3
		local SCROLL_TIME = 0.375
		local FirstTime = true

		local function GoToLibrariesTab()
			if not Scrolling1 then
				Scrolling1 = true
				CurrentTab = Cards
				UI:DecideWhetherScrollable()
				local SCROLL_TIME = SCROLL_TIME

				if FirstTime then
					SCROLL_TIME = 0.5
					FirstTime = false
				end

				Tween(Header, "BackgroundColor3", MAIN_COLOR[900], "Deceleration", SCROLL_TIME, true)
				Tween(CardBackground, "CanvasPosition", Vector2.new(0*944, 0), "Deceleration", 0.375, true)
				Tween(VerticleScroller, "CanvasPosition", Vector2.new(0, 0), "Standard", SCROLL_TIME*0.5, true)
				Tween(Seeker, "BackgroundColor3", MAIN_COLOR.Accent[700], "Deceleration", SCROLL_TIME, true)
				Tween(Seeker, "Size", UDim2.new(0, FindButton.Size.X.Offset, 0, 2), "Deceleration", SCROLL_TIME, true)
				Tween(Seeker, "Position", UDim2.new(0, FindButton.Position.X.Offset, 1, -2), "Deceleration", SCROLL_TIME, true):Wait()
				Scrolling1 = false
			end
		end
		GlobalMaid:GiveTask(FindButton.MouseButton1Click:Connect(GoToLibrariesTab))
		delay(0.1, GoToLibrariesTab)

		GlobalMaid:GiveTask(InstalledButton.MouseButton1Click:Connect(function()
			if not Scrolling2 then
				Scrolling2 = true
				CurrentTab = InstalledCards
				UI:DecideWhetherScrollable()
				Tween(CardBackground, "CanvasPosition", Vector2.new(1*944, 0), "Deceleration", 0.375, true)
				Tween(Header, "BackgroundColor3", INSTALLED_COLOR[900], "Deceleration", 0.375, true)
				Tween(VerticleScroller, "CanvasPosition", Vector2.new(0, 0), "Standard", SCROLL_TIME*0.5, true)
				Tween(Seeker, "BackgroundColor3", INSTALLED_COLOR.Accent[700], "Deceleration", 0.375, true)
				Tween(Seeker, "Size", UDim2.new(0, InstalledButton.Size.X.Offset, 0, 2), "Deceleration", 0.375, true)
				Tween(Seeker, "Position", UDim2.new(0, InstalledButton.Position.X.Offset, 1, -2), "Deceleration", 0.375, true):Wait()
				Scrolling2 = false
			end
		end))

		GlobalMaid:GiveTask(SettingsButton.MouseButton1Click:Connect(function()
			if not Scrolling3 then
				Scrolling3 = true
				CurrentTab = Settings
				UI:DecideWhetherScrollable()
				Tween(CardBackground, "CanvasPosition", Vector2.new(2*944, 0), "Deceleration", 0.375, true)
				Tween(Header, "BackgroundColor3", SETTINGS_COLOR[900], "Deceleration", 0.375, true)
				Tween(VerticleScroller, "CanvasPosition", Vector2.new(0, 0), "Standard", SCROLL_TIME*0.5, true)
				Tween(Seeker, "BackgroundColor3", SETTINGS_COLOR.Accent[700], "Deceleration", 0.375, true)
				Tween(Seeker, "Size", UDim2.new(0, SettingsButton.Size.X.Offset, 0, 2), "Deceleration", 0.375, true)
				Tween(Seeker, "Position", UDim2.new(0, SettingsButton.Position.X.Offset, 1, -2), "Deceleration", 0.375, true):Wait()
				Scrolling3 = false
			end
		end))
	-- end
end

Cards.Offset = -4;
InstalledCards.Offset = XSize * 4 + 12;

Card.__index = Card
Tab.__index = Tab

function Tab:AddCard(Card)
	local Place = 1
	if Card.Name ~= "Resources" then
		if self[1] and self[1].Name == "Resources" then
			Place = 2
		end
		for a = Place, #self do
			if self[a].Name:lower() < Card.Name:lower() then
				Place = Place + 1
			else
				break
			end
		end
	end
	table.insert(self, Place, Card)
end

function Tab:RemoveCard(Card)
	for a = 1, #self do
		if self[a] == Card then
			local Card2 = table.remove(self, a)
			if Card ~= Card2 then
				print("[RoStrap] A fatal error occurred")
			end
		end
	end
end

local GlobalXOffset = XSize * 0.5
local GlobalYOffset = YSize * 0.5
local OpenOrders = 0

local function OrderBoth()
	Cards:OrderCards()
	InstalledCards:OrderCards()
end

function Tab:OrderCards(Card)
	OpenOrders = OpenOrders + 1
	local OrderNumber = OpenOrders
	local Offset = self.Offset
	local Yielding
	for a = 1, #self do
		local Position = UDim2.new(0, GlobalXOffset + Offset + XSize*((a - 1) % 4), 0, GlobalYOffset - 2 + YSize*(math.floor((a - 1) * 0.25)))
		local Tab = self[a]
		if Tab == Card then
			Yielding = true
			delay(0.5, function()
				if OrderNumber == OpenOrders then
					Tab.Object.Position = Position
				else
					OrderBoth()
				end
				OpenOrders = OpenOrders - 1
			end)
		else
			Tween(Tab.Object, "Position", Position, "Standard", 0.375, true)
		end
	end
	if not Yielding then
		OpenOrders = OpenOrders - 1
	end
end

setmetatable(Cards, Tab)
setmetatable(InstalledCards, Tab)

function Card:TransferTabs(From, To, Initial, Depth)
	-- Remove Card From
	if From then
		From:RemoveCard(self)
		From:OrderCards()
		AsymmetricTransformation(self.Object, UDim2.new())
	end

	if To then
		To:AddCard(self)
		if not Initial then
			To:OrderCards(self)
		end

		if Initial then
			self.Object.Size = UDim2.new()
			delay(0.3 + math.random() / 2, function()
				AsymmetricTransformation(self.Object, CardSize)
			end)
		else
			delay(0.5 + (Depth or 0) * 0.1, function()
				AsymmetricTransformation(self.Object, CardSize)
			end)
		end
	end

	if not Initial then UI:DecideWhetherScrollable() end

	if not From and not To and not Initial then
		OrderBoth()
		-- delay(math.random()*5, OrderBoth)
	end
end

function Card:Uninstall()
	local Card = self.Object:FindFirstChild("Card")
	if Card and Card.INSTALL.Text == "UNINSTALL" then
		self.Installed = false
		local LibraryName = self.Name
		UI:CreateSnackbar(LibraryName .. " is no longer installed in your Repository.")
		local Library = self.Library

		if Library then
			Blacklist:Remove(Library)
			TagWhitelist[Library] = true
			local Parent = Library.Parent
			Library:Destroy()
			while Parent and #Parent:GetChildren() == 0 and Parent.ClassName == "Folder" and Parent.Name ~= "Repository" do
				local Old = Parent
				Parent = Parent.Parent
				Old:Destroy()
			end
			self.Library = nil
		end

		if Open and Card then
			self:TransferTabs(InstalledCards, Cards)
			self.Object.Card.UPDATE.Visible = false
			self.Maid.UpdateConnection = nil
			delay(0.4, function()
				self:InstallButtonConnect()
			end)
		end
	end
end

function Card:UninstallButtonConnect()
	local Card = self.Object:FindFirstChild("Card")

	if Card then
		local INSTALL = Card:FindFirstChild("INSTALL")

		if INSTALL then
			INSTALL.Text = "UNINSTALL"
			INSTALL.TextColor3 = INSTALLED_COLOR[500]
			INSTALL.Corner.BackgroundColor3 = INSTALLED_COLOR[500]
			INSTALL.Size = UDim2.new(0, 108, 0, 36)
			if self.Name ~= "Resources" then
				Card.INSTALL.Visible = true
			end
	
			local LibraryName = self.Name
	
			local function Uninstall()
				self.Maid.InstallConnection = nil
				self.Maid.InstallConnection2 = nil
				self:Uninstall()
			end
	
			self.Maid.InstallConnection = INSTALL.MouseButton1Click:Connect(Uninstall)
			self.Maid.InstallConnection2 = self.Library.AncestryChanged:Connect(function(Object, Parent)
				if not Parent or not Parent:IsDescendantOf(GetRepository()) then
					Uninstall()
				end
			end)
		end
	end
end

local function GetFirstChild2(Parent, Name, Type)
	if Parent.Name == Name and Parent:IsA(Type) then
		return Parent
	else
		return GetFirstChild(Parent, Name, Type)
	end
end

local function InstallInto(Lib, Into)
	-- Keep going up on Lib's Parent's until we reach nil

	return GetFirstChild2(Lib.Parent and Lib.Parent.Name ~= "RoStrap" and InstallInto(Lib.Parent, Into) or Into, Lib.Name, "Folder")
end

function Card:Install(Bool, Repo, Parent, Override, Depth)
	local Card = self.Object
	local Name = self.Name

	if Repo then
		Blacklist:Remove(Repo)
		TagWhitelist[Repo] = true
	end

	if Override or (Card:FindFirstChild("Card") and Card.Card.INSTALL.Text == "INSTALL") then
		if not self.Installed then self:TransferTabs(Cards, InstalledCards, false, Depth) end
		self.Installed = true
		Card.Card.INSTALL.Text = ""
		Card.Card.INSTALL.Size = UDim2.new()
		if not Bool then
			UI:CreateSnackbar("Installing " .. Name .. " in your Repository...")
		end

		if Repo then
			UI:CreateSnackbar(Name .. " is installed in your Repository.")
		else
			local Repository = GetRepository()
			Parent = Parent or GetFirstChild(Repository, "Packages", "Folder")
			local OriginalParent = Parent

			local UpdatedLibrary = self.UpdatedLibrary

			if UpdatedLibrary.Parent and UpdatedLibrary.Parent.Name ~= "RoStrap" then
				-- Install UpdatedLibrary into Parent
				Parent = InstallInto(UpdatedLibrary.Parent, Parent)
			end

			Repo = UpdatedLibrary:Clone() -- GitHub:Install(self.URL, Parent)

			local CorrectPath = true

			for ParentName in self.ParentFolderPath:reverse():gmatch("[^%.]+") do
				ParentName = ParentName:reverse()

				if CorrectPath and Parent.Name == ParentName and Parent.ClassName == "Folder" then
					local PreviousParent = Parent
					Parent = Parent.Parent
					if PreviousParent:GetChildren()[1] == nil then
						PreviousParent:Destroy()
					end
				else
					CorrectPath = false
				end
			end

			for ParentName in self.ParentFolderPath:gmatch("[^%.]+") do
				Parent = GetFirstChild2(Parent, ParentName, "Folder")
			end

			Repo.Parent = Parent

			if Repository and #Repository:GetChildren() == 1 then
				GetFirstChild(Repository, "Game", "Folder")
			end

			local Dependencies = {}

			if Repo:IsA("LuaSourceContainer") then
				GetDependencies(Repo, Dependencies)
			end

			for _, Script in next, Repo:GetDescendants() do
				if Script:IsA("LuaSourceContainer") then
					GetDependencies(Script, Dependencies)
				end
			end

			local SecondDependency = next(Dependencies)

			if SecondDependency then
				local DependencyCount = 0
				for Dependency in next, Dependencies do
					for a = 1, #Cards do
						local Card = Cards[a]
						if Dependency == Card.Name then
							if Card.Object.Card:FindFirstChild("INSTALL") and Card.Object.Card.INSTALL.Text == "INSTALL" then
								DependencyCount = DependencyCount + 1
								SecondDependency = Dependency
							end
							Card:Install(true, nil, nil, nil, (Depth or 0) + 1)
							break
						end
					end
				end
				if not Bool then
					if DependencyCount > 1 then
						UI:CreateSnackbar(Name .. " and its dependencies are installed in your Repository.")
					else
						UI:CreateSnackbar(Name .. " and " .. SecondDependency .. " (" .. Name .. "'s dependency) are installed in your Repository.")
					end
				end
			elseif not Bool then -- FIXME: Rbx_CustomFont doesn't want to create a snackbar upon finish
				UI:CreateSnackbar(Name .. " is installed in your Repository.")
			end
		end

		local Author = (self.URL:sub(9) .. "/"):match("/(.-)/")
		-- local Readme = (self.URL:sub(9) .. "/"):match("/[^/]+/[^/]+/")

		InsertComment(Repo, nil, self.Description)

		if Author then
			InsertComment(Repo, "@author", Author == "RoStrap" and "Validark" or Author)
		end

		InsertComment(Repo, "@rostrap", self.Name)
		InsertComment(Repo, "@source", self.URL)

		if self.Documentation and self.Documentation:find("^https://") then
			InsertComment(Repo, "@documentation", self.Documentation or "https://rostrap.github.io/Libraries/" .. (Repo.Parent == OriginalParent and "" or Repo.Parent.Name .. "/") .. Repo.Name .. "/")
		end

		self.Library = Repo

		delay(0.4, function()
			self:UninstallButtonConnect()
		end)
	end
end

-- Get Resources Source
local function GetSource(ModuleScript)
	local Source = ModuleScript.Source
	while Source == "" do
		wait()
		Source = ModuleScript.Source
	end
	return Source
end

function Card:Update()
	local Library = self.Library
	local LibraryParent = Library.Parent

	Tween(self.Object.Card.UPDATE, "TextTransparency", 1, "Standard", 0.15, true, function()
		if self.Object:FindFirstChild("Card") then
			self.Object.Card.UPDATE.Visible = false
		end
	end)

	local PreviousBlacklist = Blacklist:IsMember(Library)
	Blacklist:Remove(Library)

	-- self.Installed = false

	self.Object.Card.INSTALL.Visible = false

	if Library.Name == "Resources" then
		local HackParent = Instance.new("Folder")
		self:Install(nil, nil, HackParent, true)
		self.Library = Library
		Library.Source = GetSource(HackParent:WaitForChild("Resources"))
		HackParent:Destroy()
	else
		self.Library = nil
		Library:Destroy()
		self:Install(nil, nil, LibraryParent, true)
	end

	-- Library = self.Library
	if PreviousBlacklist then
		-- Blacklist:Add(Library)
	end

	self.Uninstall = nil

	if self.Endorsement then
		self.Endorsement.Visible = true
	end
end

function Card:UpdateButtonConnect()
	AvailableUpdates = AvailableUpdates + 1
	if Open then
		local Card = self.Object.Card
		Card.UPDATE.Visible = true

		if self.Endorsement then
			self.Endorsement.Visible = false
		end

		if AvailableUpdates > 1 then
			UI:CreateSnackbar("There are multiple updates available. Please check the \"INSTALLED\" tab.")
		else
			UI:CreateSnackbar("There is an update available for " .. self.Name .. ".")
		end

		local Maid = self.Maid
		Maid.UpdateConnection = Card.UPDATE.MouseButton1Click:Connect(function()
			Maid.UpdateConnection = nil
			Maid.InstallConnection = nil
			Maid.InstallConnection2 = nil
			function self:Uninstall() end
			self:Update()
		end)
	end
end

function Card:InstallButtonConnect()
	if self.Object.Parent then
		local Card = self.Object.Card
		Card.INSTALL.Text = "INSTALL"
		Card.INSTALL.TextColor3 = MAIN_COLOR[500]
		Card.INSTALL.Corner.BackgroundColor3 = MAIN_COLOR[500]
		Card.INSTALL.Size = UDim2.new(0, 88, 0, 36)
		Card.INSTALL.Visible = true
		self.Maid.InstallConnection = Card.INSTALL.MouseButton1Click:Connect(function()
			self.Maid.InstallConnection = nil
			self:Install()
		end)		
	end
end

-- Source comparisons
local function IsSignificantDifferencePresent(Script1, Script2)
	-- Compares the Source of two scripts for differences
	-- local t2 = tick()

	local Source1 = Script1.Source:gsub("%-%-%[%[.-%]%]", ""):gsub("%-%-.-[\n\r]", ""):gsub("local [%u_]+ = [^\n\r]+", ""):gsub("%s+$", ""):gsub("^%s+", ""):gsub("%s+", " ")
	local Source2 = GetSource(Script2):gsub("%-%-%[%[.-%]%]", ""):gsub("%-%-.-[\n\r]", ""):gsub("local [%u_]+ = [^\n\r]+", ""):gsub("%s+$", ""):gsub("^%s+", ""):gsub("%s+", " ")

	-- Doesn't check comments (first 2 gsubs), constant configurables (e.g. `local NUM_AMOUNT = 5`, as in 3rd gsub), or whitespace (4th gsub)
	if Source1 ~= Source2 then
		-- print(t2 - tick())
		-- GetFirstChild(workspace, "SourceDiff1", "Script").Source = Source1
		-- GetFirstChild(workspace, "SourceDiff2", "Script").Source = Source2
		return true
	else
		-- No update
		return false
	end
end

local function AlphabeticallyByName(a, b)
	return a.Name < b.Name
end

local EndorsedAuthors do
	local t = {
		RoStrap = {
			Image = "rbxassetid://943988414"; --"rbxassetid://941214330" 64x64
			ImageColor3 = MAIN_COLOR[900];
		};

		Roblox = {
			Image = "rbxassetid://1081877841";
		};

		Evaera = {
			Image = "rbxassetid://2742509563";
		};
	}

	t.Validark = t.RoStrap
	t.Eryn = t.Evaera

	EndorsedAuthors = {}

	for i, v in next, t do
		local Endorsement = Instance.new("ImageLabel")
		Endorsement.AnchorPoint = Vector2.new(0, 1)
		Endorsement.BackgroundTransparency = 1
		Endorsement.Name = "Endorsement"
		Endorsement.Position = UDim2.new(0, 12, 1, -12)
		Endorsement.Size = UDim2.new(0, 24, 0, 24)
		Endorsement.ImageTransparency = 0.8;
		Endorsement.Visible = true
		Endorsement.ZIndex = 4

		for Prop, Value in next, v do
			Endorsement[Prop] = Value
		end

		EndorsedAuthors[i:lower()] = Endorsement;
	end
end

function Card.new(Title, Subtitle, Link, Library, UpdatedLibrary, Documentation, ParentFolderPath)
	-- Table Cards or InstalledCards
	-- Library is a library that is already installed
	-- UpdatedLibrary is the latest copy of the library

	-- Search Repo for Library
	-- local Repository = Repository or ServerStorage:FindFirstChild("Repository") or ServerScriptService:FindFirstChild("Repository")

	local CardObject = CardTemplate:Clone()
	CardObject.Parent = CardWorkspace
	local Main = CardObject.Card

	local self = setmetatable({
		Object = CardObject;
		Maid = Maid.new();
		Name = Title;
		URL = Link;
		Library = Library;
		UpdatedLibrary = UpdatedLibrary;
		Documentation = Documentation;
		Description = Subtitle or "No description";
		ParentFolderPath = ParentFolderPath or "";
	}, Card)

	self.Maid:LinkToInstance(CardObject)

	self.UpdatedLibrary.Name = Title
	Main.Title.Text = Title
	Main.Title.Subtitle.Text = self.Description

	Main.Link.Text = Link

	local Author = (self.URL:sub(9) .. "/"):match("/(.-)/")

	if Author then
		local EndorsedAuthor = EndorsedAuthors[Author:lower()]

		if EndorsedAuthor then
			self.Endorsement = EndorsedAuthor:Clone()
			self.Endorsement.Parent = Main
		end
	end

	local CardLearnMore = Button.new("Flat", Main)
	CardLearnMore.BackgroundTransparency = 1
	CardLearnMore.ClipsDescendants = true
	CardLearnMore.Font = Enum.Font.SourceSansBold
	CardLearnMore.Name = "UPDATE"
	CardLearnMore.Position = UDim2.new(1, -219, 1, -42)
	CardLearnMore.Size = UDim2.new(0, 86, 0, 36)
	CardLearnMore.Text = "UPDATE"
	CardLearnMore.TextColor3 = Colors.Black
	CardLearnMore.TextSize = 18
	CardLearnMore.TextTransparency = 0.12
	CardLearnMore.ZIndex = 4
	CardLearnMore.Visible = false

	local CardInstall = Button.new("Flat", Main)
	CardInstall.AnchorPoint = Vector2.new(1, 0)
	CardInstall.BackgroundTransparency = 1
	CardInstall.ClipsDescendants = true
	CardInstall.Font = Enum.Font.SourceSansBold
	CardInstall.TextSize = 18
	CardInstall.TextTransparency = 0.12
	CardInstall.ZIndex = 4
	CardInstall.Name = "INSTALL"
	CardInstall.Text = "INSTALL"
	CardInstall.TextColor3 = MAIN_COLOR[500]
	CardInstall.Position = UDim2.new(1, -6, 1, -42)
	CardInstall.Size = UDim2.new(0, 88, 0, 36)
	CardInstall.Visible = Title ~= "Resources"

	if Library then
		self.Installed = true
		self:TransferTabs(nil, InstalledCards, true)
		self:UninstallButtonConnect()

		-- If there is an update available
		local ThereIsAnUpdate do
			local Descendants = GetDescendantsInPredictableOrder(Library)
			local DescendantsCount = #Descendants + 1
			Descendants[DescendantsCount] = Library

			local Descendants2 = GetDescendantsInPredictableOrder(self.UpdatedLibrary)
			local Descendants2Count = #Descendants2 + 1
			Descendants2[Descendants2Count] = self.UpdatedLibrary

			if DescendantsCount == Descendants2Count then
				for a = 1, DescendantsCount do
					local Object = Descendants[a]
					local Object2 = Descendants2[a]

					if
						Object.Name ~= Object2.Name or
						Object.ClassName ~= Object2.ClassName or
						(Object:IsA("LuaSourceContainer") and IsSignificantDifferencePresent(Object, Object2)) or
						a ~= DescendantsCount and (Object.Parent and Object2.Parent and Object.Parent.Name ~= Object2.Parent.Name)
					then
						-- print(Object.Name, Object2.Name, Object.ClassName, Object2.ClassName, Object:IsA("LuaSourceContainer"), IsSignificantDifferencePresent(Object, Object2), a ~= DescendantsCount, Object.Parent.Name,  Object2.Parent.Name)
						ThereIsAnUpdate = true
						break
					end
				end
			else
				ThereIsAnUpdate = true
			end
		end

		if ThereIsAnUpdate then
			self:UpdateButtonConnect()
		end
	else
		self.Installed = false
		self:TransferTabs(nil, Cards, true)
		self:InstallButtonConnect()
	end

	return self
end

return UI
