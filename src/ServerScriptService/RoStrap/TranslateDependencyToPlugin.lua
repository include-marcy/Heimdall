-- This is used for modules written by me, so it can make a lot of assumptions

local function GetSource(ModuleScript)
	local Source = ModuleScript.Source
	while Source == "" do
		wait()
		Source = ModuleScript.Source
	end
	return Source
end

local GetDependencies = require(script.Parent.GetDependencies)

local function TranslateDependencyToPlugin(Dependency, Dependencies)
	local t = {}

	for Library in next, GetDependencies(Dependency, Dependencies) do
		if Library ~= "Table" then
			table.insert(t, "local " .. Library .. " = require(script.Parent." .. Library .. ")")
		end
	end

	Dependency.Source = (table.concat(t, "\n") .. GetSource(Dependency)
		:gsub("local Resources = [^\n\r]+[\n\r]", "")
		:gsub("[^\n\r]+LoadLibrary[^\n\r]+[\n\r]", "")
		:gsub("[^\n\r]+require[^\n\r]+[\n\r]", "")
		:gsub("%-%-%[%[.-%]%]", "")
		:gsub("%-%-[^\n\r]+[\n\r]", ""))
		:gsub("Table%.Lock", "")
			-- :gsub("%s+", " ")
			-- :gsub(" = ", "=")
			-- :gsub("([;%),{}])%s", "%1")
			-- :gsub("(%b\"\") ", "%1")
end

return TranslateDependencyToPlugin
