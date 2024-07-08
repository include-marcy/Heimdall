local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Blacklist = {}
local GetFirstChild = require(script.Parent.GetFirstChild)
local EXEMPTION_FOLDER_NAME = "AutoAssignmentExemptions"

function Blacklist:IsMember(Object)
	local Resources = ReplicatedStorage:FindFirstChild("Resources")

	if Resources then
		local ExemptionFolder = Resources:FindFirstChild(EXEMPTION_FOLDER_NAME)

		if ExemptionFolder then
			local Children = ExemptionFolder:GetChildren()
			for i = 1, #Children do
				local Child = Children[i]
				if Child.ClassName == "ObjectValue" and Child.Value == Object then
					return true
				end
			end
		end
	end
end

function Blacklist:Add(Object)
	local Resources = ReplicatedStorage:FindFirstChild("Resources")

	if Resources then
		GetFirstChild(GetFirstChild(Resources, EXEMPTION_FOLDER_NAME, "Folder"), Object.Name, "ObjectValue", Object)
	end
end

function Blacklist:Remove(Object)
	local Resources = ReplicatedStorage:FindFirstChild("Resources")

	if Resources then
		local ExemptionFolder = Resources:FindFirstChild(EXEMPTION_FOLDER_NAME)

		if ExemptionFolder then
			local Children = ExemptionFolder:GetChildren()
			for i = 1, #Children do
				local Child = Children[i]
				if Child.ClassName == "ObjectValue" and Child.Value == Object then
					Child:Destroy()
				end
			end
			if #ExemptionFolder:GetChildren() == 0 then
				ExemptionFolder:Destroy()
			end
		end
	end
end

return Blacklist
