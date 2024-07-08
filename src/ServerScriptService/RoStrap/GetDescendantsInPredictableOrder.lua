local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function AlphabeticallyByName(a, b)
	return a.Name < b.Name
end

local function GetDescendantsInPredictableOrder(Object)
	--- Like GetChildren, but returns a table with all Descendants
	if Object.Name == "Resources" and Object.Parent == ReplicatedStorage then return {} end

	assert(typeof(Object) == "Instance", "Object is not an Instance")
	local Descendants = Object:GetChildren()
	local NumDescendants = #Descendants
	local Count = 0

	if NumDescendants > 0 then
		table.sort(Descendants, AlphabeticallyByName)
		repeat
			Count = Count + 1
			local GrandChildren = Descendants[Count]:GetChildren()
			local NumGrandChildren = #GrandChildren
			table.sort(GrandChildren, AlphabeticallyByName)
			for a = 1, NumGrandChildren do
				Descendants[NumDescendants + a] = GrandChildren[a]
			end
			NumDescendants = NumDescendants + NumGrandChildren
		until Count == NumDescendants
	end

	return Descendants
end

return GetDescendantsInPredictableOrder
