-- Light-weight, Bezier-friendly Tweens
-- @readme https://github.com/RoStrap/Interpolation
-- @author Validark

local Lerps = require(script.Parent.Lerps)
local Easing = require(script.Parent.Easing)
local Enumeration = require(script.Parent.Enumeration)

local Heartbeat = game:GetService("RunService").Heartbeat

local Completed = Enum.TweenStatus.Completed
local Canceled = Enum.TweenStatus.Canceled

local Tween = {
	__index = {
		Running = false;
	}
}

local EasingFunctionEnums = Enumeration.EasingFunction:GetEnumerationItems()
local OpenTweens = {}

function Tween.new(Duration, EasingFunction, Callback, Arg)
	Duration = Duration or 1
	local EasingFunctionType = type(EasingFunction)
	if EasingFunctionType == "string" then
		EasingFunction = Easing[Enumeration.EasingFunction[EasingFunction].Name]
	elseif EasingFunctionType == "number" then
		EasingFunction = Easing[EasingFunctionEnums[EasingFunction + 1].Name]
	elseif EasingFunctionType == "userdata" then
		EasingFunction = Easing[EasingFunction.Name]
	end

	local ElapsedTime = 0
	local self = setmetatable({}, Tween)

	function self:ResetElapsedTime()
		ElapsedTime = 0
		return self
	end

	function self.Interpolator(Step)
		ElapsedTime = ElapsedTime + Step
		if Duration > ElapsedTime then
			Callback(EasingFunction(ElapsedTime, 0, 1, Duration), Arg)
		else
			Callback(1, Arg)
			self:Stop()
		end
	end

	return self:Resume()
end

function Tween.Start(_, Object, Property, EndValue, EasingDirection, EasingStyle, Duration, Override, Callback, PropertyType)
	-- @param Object object OR Table object OR Void Function receiver(String propertyName, Variant value),
	-- @param String Property,
	-- @param Variant EndValue
	-- @param Number time
	-- @param String EasingName

	-- EasingStyle == 0 and 5 or 4*EasingStyle + EasingDirection + 2

	local EasingFunction do
		local EasingStyleType = typeof(EasingStyle)
		local EasingDirectionType = typeof(EasingDirection)


		if EasingStyleType == "string" then
			EasingStyle = Enum.EasingStyle[EasingStyle].Value -- Convert strings to numbers
		elseif EasingStyleType == "EnumItem" then
			EasingStyle = EasingStyle.Value
		end

		if EasingDirectionType == "string" then
			EasingFunction = Easing[EasingDirection]
			if not EasingFunction then
				EasingDirection = Enum.EasingDirection[EasingDirection].Value -- Convert strings to numbers
			end
			if EasingStyleType == "number" then
				EasingStyle, Duration, Override, Callback, PropertyType = "", EasingStyle, Duration, Override, Callback
			end
		elseif EasingDirectionType == "EnumItem" then
			EasingDirection = EasingDirection.Value
		elseif EasingDirectionType == "number" then
			EasingFunction = Easing[EasingFunctionEnums[EasingDirection + 1].Name]
			EasingStyle, Duration, Override, Callback, PropertyType = "", EasingStyle, Duration, Override, Callback
		elseif EasingDirectionType == "userdata" then
			EasingFunction = Easing[EasingDirection.Name]
			EasingStyle, Duration, Override, Callback, PropertyType = "", EasingStyle, Duration, Override, Callback
		elseif EasingDirectionType == "function" then
			EasingFunction = EasingDirection

			if EasingStyleType == "number" then
				EasingStyle, Duration, Override, Callback, PropertyType = "", EasingStyle, Duration, Override, Callback
			end
		end

		if not EasingFunction then
			EasingFunction = Easing[EasingFunctionEnums[EasingStyle == 0 and 5 or 4*EasingStyle + EasingDirection + 2].Name]
		end
	end

	Duration = Duration or 1
	local StartValue = Object[Property]
	local Lerp = Lerps[PropertyType or typeof(EndValue)] or function() return EndValue end
	local ElapsedTime = 0
	local self = setmetatable({Callback = Callback; Object = Object; Property = Property}, Tween)
	local ObjectTable = OpenTweens[Object]

	if ObjectTable then
		local OpenTween = ObjectTable[Property]
		if OpenTween then
			if Override then
				OpenTween:Stop()
			else
				return self:Stop() -- warn("Could not Tween", tostring(Object) .. "." .. Property, "to", EndValue))
			end
		end
	else
		ObjectTable = {}
		OpenTweens[Object] = ObjectTable
	end

	function self:ResetElapsedTime()
		ElapsedTime = 0
		return self
	end

	function self.Interpolator(Step)
		ElapsedTime = ElapsedTime + Step
		if Duration > ElapsedTime then
			Object[Property] = Lerp(StartValue, EndValue, EasingFunction(ElapsedTime, 0, 1, Duration))
		else
			self:Stop(true)
			Object[Property] = EndValue
		end
	end

	ObjectTable[Property] = self
	self.ObjectTable = ObjectTable

	return self:Resume()
end

function Tween.__index:Stop(Finished)
	if self.Running then
		self.Connection:Disconnect()
		self.Running = false
		local ObjectTable = self.ObjectTable
		if ObjectTable then
			ObjectTable[self.Property] = nil -- This is for override checks
		end
	end
	local Callback = self.Callback
	if Callback == true then
		if Finished then
			self.Object:Destroy()
		end
	elseif Callback then
		Callback(Finished and Completed or Canceled)
	end
	return self
end

function Tween.__index:Resume()
	if not self.Running then
		self.Connection = Heartbeat:Connect(self.Interpolator)
		self.Running = true
		local ObjectTable = self.ObjectTable
		if ObjectTable then
			ObjectTable[self.Property] = self -- This is for override checks
		end
		return self
	end
end

function Tween.__index:Restart()
	return self:ResetElapsedTime():Resume()
end

function Tween.__index:Wait()
	repeat until not self.Running or not Heartbeat:Wait()
	return self
end

return setmetatable(Tween, {__call = Tween.Start})
