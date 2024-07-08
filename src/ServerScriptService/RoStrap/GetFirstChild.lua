local function GetFirstChild(Parent, Name, Class, Value)
	if Parent then -- GetFirstChildWithNameOfClass with Value if non-nil
		local Objects = Parent:GetChildren()
		for a = 1, #Objects do
			local Object = Objects[a]
			if Object.Name == Name and Object.ClassName == Class and (Value == nil or Object.Value == Value) then
				return Object
			end
		end
	end

	local Child = Instance.new(Class)
	Child.Name = Name
	if Value then
		Child.Value = Value
	end
	Child.Parent = Parent
	return Child, true
end

return GetFirstChild
