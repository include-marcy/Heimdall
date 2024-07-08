-- Simple Snackbar Generator
-- @readme https://github.com/RoStrap/UI/blob/master/README.md
-- @author Validark

-- Snackbar.new(string Text, ScreenGui Screen)
--	Generates a SnackbarFrame with message Text
--	Expect more parameters in the future
-- @spec https://material.io/guidelines/components/snackbars-toasts.html

local TextService = game:GetService("TextService")

local HEIGHT = 48
local ENTER_TIME = 0.275
local DISPLAY_TIME = 2
local SMALLEST_WIDTH = 294

local Maid = require(script.Parent.Maid)
local Tween = require(script.Parent.Tween)

local TweenCompleted = Enum.TweenStatus.Completed

HEIGHT = HEIGHT + 6
local OpenSnackbar, OpenTween
local ExitPosition = UDim2.new(0.5, 0, 1, 0)
local EnterPosition = UDim2.new(0.5, 0, 1, -HEIGHT)

local DefaultSnackbar = Instance.new("ImageLabel")
DefaultSnackbar.AnchorPoint = Vector2.new(0.5, 0)
DefaultSnackbar.BackgroundTransparency = 1
DefaultSnackbar.Image = "rbxasset://textures/ui/btn_newWhite.png"
DefaultSnackbar.ImageColor3 = Color3.fromRGB(50, 50, 50)
DefaultSnackbar.Position = UDim2.new(0.5, 0, 1, 0)
DefaultSnackbar.ScaleType = Enum.ScaleType.Slice
DefaultSnackbar.Size = UDim2.new(0, 288 + 6, 0, HEIGHT)
DefaultSnackbar.SliceCenter = Rect.new(7, 7, 13, 13)
DefaultSnackbar.ZIndex = 4 + 10

local SnackbarText = Instance.new("TextLabel", DefaultSnackbar)
SnackbarText.AnchorPoint = Vector2.new(0, 0.5)
SnackbarText.Font = Enum.Font.SourceSans
SnackbarText.Name = "Label"
SnackbarText.Position = UDim2.new(0, 27, 0.5, 0)
SnackbarText.TextSize = 20
SnackbarText.TextColor3 = Color3.fromRGB(255, 255, 255)
SnackbarText.TextXAlignment = Enum.TextXAlignment.Left
SnackbarText.ZIndex = 5 + 10

local Snackbar = {}

local LARGE_FRAME_SIZE = Vector2.new(32767, 32767)

function Snackbar.new(Text, Screen)
	-- @param string Text the message you want to appear
	-- @param ScreenGui Screen the Parent of the Snackbar

	if OpenSnackbar then
		local PreviousSnackbar = OpenSnackbar
		local PreviousLabel = PreviousSnackbar:FindFirstChild("Label")

		if PreviousLabel then
			if PreviousLabel.Text == Text then
				return
			end
			PreviousLabel.ZIndex = 3 + 10
		end

		OpenTween:Stop()
		PreviousSnackbar.ZIndex = 2 + 10

		Tween(PreviousSnackbar, "Position", ExitPosition, "Acceleration", ENTER_TIME * 0.7, false, function(Completed)
			if Completed == TweenCompleted then
				PreviousSnackbar:Destroy()
				if OpenSnackbar == PreviousSnackbar then
					OpenSnackbar = nil
				end
			end
		end)
	end

	local SnackbarMaid = Maid.new()
	local SnackbarFrame = DefaultSnackbar:Clone()
	OpenSnackbar = SnackbarFrame
	local Label = SnackbarFrame:FindFirstChild("Label")

	if Label then
		Label.Text = Text
		SnackbarMaid:LinkToInstance(SnackbarFrame)
		local TextBounds = TextService:GetTextSize(Label.Text, Label.TextSize, Label.Font, LARGE_FRAME_SIZE)
		SnackbarFrame.Size = UDim2.new(0, TextBounds.X + HEIGHT > SMALLEST_WIDTH and TextBounds.X + HEIGHT or SMALLEST_WIDTH, 0, HEIGHT)
	end

	spawn(function()
		spawn(function()
			SnackbarFrame.Parent = Screen ~= nil and Screen.Enabled and Screen or (function()
				local FeedbackScreen = Instance.new("ScreenGui", game:GetService("CoreGui"))
				game:GetService("Debris"):AddItem(FeedbackScreen, 4)
				return FeedbackScreen
			end)()
		end)
	end)
	

	OpenTween = Tween(SnackbarFrame, "Position", EnterPosition, "Deceleration", ENTER_TIME, false, function(Completed)
		if Completed == TweenCompleted and wait(DISPLAY_TIME - ENTER_TIME) then
			Tween(SnackbarFrame, "Position", ExitPosition, "Acceleration", ENTER_TIME, false, function(Completed)
				if Completed == TweenCompleted then
					SnackbarFrame:Destroy()
					if OpenSnackbar == SnackbarFrame then
						OpenSnackbar = nil
					end
				end
			end)
		end
	end)

	return setmetatable({}, Snackbar)
end

return Snackbar
