local GetDescendantsInPredictableOrder = require(script.Parent.GetDescendantsInPredictableOrder)

local function GetSource(ModuleScript)
	local Source = ModuleScript.Source
	while Source == "" do
		wait()
		Source = ModuleScript.Source
	end
	return Source
end

local function InsertComment(Package, Identifier, Id)
	local Descendants = GetDescendantsInPredictableOrder(Package)
	table.insert(Descendants, 1, Package)
	for i = 1, #Descendants do
		local Module = Descendants[i]
		if Module:IsA("LuaSourceContainer") then
			local Source = GetSource(Module)

			if Identifier then
				if not Source:find("-- " .. Identifier, 1, true) then
					local Pos = 0
					local _, b = Source:find("^%-%-[^\n\r]+[\n\r]")
					if b then
						Pos = b
						local _, a = Source:sub(Pos + 1):find("^%-%- @readme[^\n\r]+[\n\r]")
						if a then
							Pos = Pos + a
						end
					end
					Module.Source = Source:sub(1, Pos) .. "-- " .. Identifier:gsub("readme", "repo") .. " " .. Id .. "\n" .. Source:sub(Pos + 1)
				end
			else
				-- Insert comment at top
				if 1 ~= Source:find("-- " .. Id, 1, true) then
					Module.Source = "-- " .. Id .. "\n\n" .. Source
				end
			end
		end
	end
end

return InsertComment
