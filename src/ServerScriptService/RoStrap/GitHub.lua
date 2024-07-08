-- Universal Github Installer
-- @see Validark
-- function GitHub:Install(Link, Parent)
--		@returns <Folder/LuaSourceContainer> from Link found starting at Link into Parent
-- function GitHub:GetApprovedRepositories()
--		@returns table of Repositories with the "rostrap" tag that are approved by Validark and devSparkle

-- TODO: Make it so that modules with a name identical to the Folder you are creating will be placed inside.

local function GetFirstChild(Parent, Name, Class)
	if Parent then -- GetFirstChildWithNameOfClass
		local Objects = Parent:GetChildren()
		for a = 1, #Objects do
			local Object = Objects[a]
			if Object.Name == Name and Object.ClassName == Class then
				return Object
			end
		end
	end

	local Child = Instance.new(Class)
	Child.Name = Name
	Child.Parent = Parent
	return Child, true
end

-- Services
local HttpService = game:GetService("HttpService")

-- Module
local InstallableLibraries = {}
local GitHub = {
	InstallableLibraries = InstallableLibraries;
}

local DataSources = {}

-- Helper Functions
local ScriptTypes = {
	[""] = "ModuleScript";
	["local"] = "LocalScript";
	["module"] = "ModuleScript";
	["mod"] = "ModuleScript";
	["loc"] = "LocalScript";
	["server"] = "Script";
	["client"] = "LocalScript";
}

local function UrlDecode(Character)
	return string.char(tonumber(Character, 16))
end

local OpenGetRequests = 0

local function GetAsync(...)
	repeat until OpenGetRequests == 0 or not wait()
	local Success, Data = pcall(HttpService.GetAsync, HttpService, ...);

	if Success then
		return Data
	elseif Data:find("HTTP 429", 1, true) or Data:find("Number of requests exceeded limit", 1, true) then
		wait(math.random(5))
		warn("Too many requests")
		return GetAsync(...)
	elseif Data:find("Http requests are not enabled", 1, true) then
		OpenGetRequests = OpenGetRequests + 1
		repeat
			local Success, Data = pcall(HttpService.GetAsync, HttpService, ...)
		until Success and not Data:find("Http requests are not enabled", 1, true) or not wait(1)
		OpenGetRequests = 0
		return GetAsync(...)
	elseif Data:find("HTTP 503", 1, true) then
		warn(Data, (...))
		return ""
	elseif Data:find("HttpError: SslConnectFail", 1, true) then
		local t = math.random(2, 5)
		warn("HttpError: SslConnectFail error on " .. tostring((...)) .. " trying again in " .. t .. " seconds.")
		wait(t)
		return GetAsync(...)
	else
		error(Data .. (...), 0)
	end
end

local function GiveSourceToScript(Link, Script)
	DataSources[Script] = Link
	Script.Source = GetAsync(Link)
end

local function InstallRepo(Link, Directory, Parent, Routines, TypesSpecified)
	local Value = #Routines + 1
	Routines[Value] = false
	local MainExists

	local ScriptCount = 0
	local Scripts = {}

	local FolderCount = 0
	local Folders = {}

	local Data = GetAsync(Link)
	local success, json = pcall(function() return HttpService:JSONDecode(Data) end);
	
	--print(success, json);

	if success then
		local repo = json.payload.repo;
		--print("og:", Link);
		--print("reconstructed:", "https://github.com/" .. repo.ownerLogin .. "/" .. repo.name .. "/tree/" .. repo.defaultBranch);
		
		for _, item in ipairs(json.payload.tree.items) do
			if item.contentType == "directory" then
				FolderCount = FolderCount + 1;
				Folders[FolderCount] = "/" .. repo.ownerLogin .. "/" .. repo.name .. "/tree/" .. repo.defaultBranch .. "/" .. item.path;
			elseif item.contentType == "file" then
				local ScriptName, ScriptClass = item.name:match("([%w-_%%]+)%.?(%l*)%.lua$")
				local Link = "/" .. repo.ownerLogin .. "/" .. repo.name .. "/blob/" .. repo.defaultBranch .. "/" .. item.path

				if ScriptName and ScriptName:lower() ~= "install" and ScriptClass ~= "ignore" and ScriptClass ~= "spec" and ScriptName:lower() ~= "spec" then
					if ScriptClass == "mod" or ScriptClass == "module" then TypesSpecified = true end

					if ScriptName == "_" or ScriptName:lower() == "main" or ScriptName:lower() == "init" then
						ScriptCount = ScriptCount + 1;
						for a = ScriptCount, 2, -1 do
							Scripts[a] = Scripts[a - 1];
						end
						Scripts[1] = Link;
						MainExists = true;
					else
						ScriptCount = ScriptCount + 1;
						Scripts[ScriptCount] = Link;
					end
				end
			end
		end
	else
		local ShouldSkip = false
		local _, StatsGraph = Data:find("d-flex repository-lang-stats-graph", 1, true)

		if StatsGraph then
			ShouldSkip = Data:sub(StatsGraph + 1, (Data:find("</div>", StatsGraph, true) or 0 / 0) - 1):find("%ALua%A") == nil
		end

		if not ShouldSkip then
			--print(Data)
			-- <a title="src" aria-label="src, (Directory)" class="Link--primary" href="/Validark/Accelerated-Zig-Parser/tree/main/src">src</a>
			for Link in Data:gmatch("<a[^>]-class=\"Link%-%-primary\"[^>]-href=\"([^\"]+)\">") do
				--print(Link)
				if Link:find("/[^/]+/[^/]+/tree") then
					FolderCount = FolderCount + 1
					Folders[FolderCount] = Link
				elseif Link:find("/[^/]+/[^/]+/blob.+%.lua$") then
					local ScriptName, ScriptClass = Link:match("([%w-_%%]+)%.?(%l*)%.lua$")

					if ScriptName:lower() ~= "install" and ScriptClass ~= "ignore" and ScriptClass ~= "spec" and ScriptName:lower() ~= "spec" then
						if ScriptClass == "mod" or ScriptClass == "module" then TypesSpecified = true end

						if ScriptName == "_" or ScriptName:lower() == "main" or ScriptName:lower() == "init" then
							ScriptCount = ScriptCount + 1
							for a = ScriptCount, 2, -1 do
								Scripts[a] = Scripts[a - 1]
							end
							Scripts[1] = Link
							MainExists = true
						else
							ScriptCount = ScriptCount + 1
							Scripts[ScriptCount] = Link
						end
					end
				end
			end
		end
	end

	if ScriptCount > 0 then
		local ScriptLink = Scripts[1]
		local ScriptName, ScriptClass = ScriptLink:match("([%w-_%%]+)%.?(%l*)%.lua$")
		ScriptName = ScriptName:gsub("Library$", "", 1):gsub("%%(%x%x)", UrlDecode)
		local Sub = Link:sub(19)
		local Link = Sub:gsub("^(/[^/]+/[^/]+)/tree/[^/]+", "%1", 1)
		local LastFolder = Link:match("[^/]+$")
		LastFolder = LastFolder:match("^RBX%-(.-)%-Library$") or LastFolder

		if MainExists then
			local Directory = LastFolder:gsub("%%(%x%x)", UrlDecode)
			ScriptName, ScriptClass = Directory:match("([%w-_%%]+)%.?(%l*)%.lua$")
			if not ScriptName then ScriptName = Directory:match("^RBX%-(.-)%-Library$") or Directory end
			if ScriptClass == "mod" or ScriptClass == "module" then TypesSpecified = true end
		end

		-- if MainExists or ScriptCount ~= 1 or ScriptName ~= (LastFolder:match("^RBX%-(.-)%-Library$") or LastFolder) then
		if MainExists then Directory = Directory + 2 end -- :gsub("[^/]+$", "", 1) end
		local Count = 0

		local function LocateFolder(FolderName)
			Count = Count + 1
			if Count > Directory then
				Directory = Directory + 1
				if (Parent and Parent.Name) ~= FolderName and "Modules" ~= FolderName then
					-- local Success, Service = pcall(game.GetService, game, FolderName)
					-- if FolderName ~= "Lighting" and Success and Service then
					-- 	Parent = Service
					-- else
					local Generated
					Parent, Generated = GetFirstChild(Parent, FolderName, "Folder")
					if Generated then
						if not Routines[1] then Routines[1] = Parent end
						DataSources[Parent] = "https://github.com" .. (Sub:match(("/[^/]+"):rep(Directory > 2 and Directory + 2 or Directory)) or warn("[1]", Sub, Directory > 1 and Directory + 2 or Directory) or "")
					end
					-- end
				end
			end
		end

		Link:gsub("[^/]+$", ""):gsub("[^/]+", LocateFolder)

		if MainExists or ScriptCount ~= 1 or ScriptName ~= LastFolder then
			LocateFolder(LastFolder)
		end

		local Script = GetFirstChild(Parent, ScriptName, ScriptTypes[ScriptClass or TypesSpecified and "" or "mod"] or "ModuleScript")
		if not Routines[1] then Routines[1] = Script end
		coroutine.resume(coroutine.create(GiveSourceToScript), "https://raw.githubusercontent.com" .. ScriptLink:gsub("(/[^/]+/[^/]+/)blob/", "%1", 1), Script)

		if MainExists then
			Parent = Script
		end

		for a = 2, ScriptCount do
			local Link = Scripts[a]
			local ScriptName, ScriptClass = Link:match("([%w-_%%]+)%.?(%l*)%.lua$")
			local Script = GetFirstChild(Parent, ScriptName:gsub("Library$", "", 1):gsub("%%(%x%x)", UrlDecode), ScriptTypes[ScriptClass or TypesSpecified and "" or "mod"] or "ModuleScript")
			coroutine.resume(coroutine.create(GiveSourceToScript), "https://raw.githubusercontent.com" .. Link:gsub("(/[^/]+/[^/]+/)blob/", "%1", 1), Script)
		end
	end

	for a = 1, FolderCount do
		local Link = Folders[a]
		coroutine.resume(coroutine.create(InstallRepo), "https://github.com" .. Link, Directory, Parent, Routines, TypesSpecified)
	end

	Routines[Value] = true
end

local function InstallRepoOld(Link, Directory, Parent, Routines, TypesSpecified)
	local Value = #Routines + 1
	Routines[Value] = false
	local MainExists

	local ScriptCount = 0
	local Scripts = {}

	local FolderCount = 0
	local Folders = {}

	local Data = GetAsync(Link)
	local ShouldSkip = false
	local _, StatsGraph = Data:find("d-flex repository-lang-stats-graph", 1, true)

	if StatsGraph then
		ShouldSkip = Data:sub(StatsGraph + 1, (Data:find("</div>", StatsGraph, true) or 0 / 0) - 1):find("%ALua%A") == nil
	end

	if not ShouldSkip then
		for _, Link in Data:gmatch("<a class=\"js%-navigation%-open Link%-%-primary\" title=\"([^\"]+)\".-href=\"([^\"]+)\">%1</a>") do
			print(Link)
			if Link:find("/[^/]+/[^/]+/tree") then
				FolderCount = FolderCount + 1
				Folders[FolderCount] = Link
			elseif Link:find("/[^/]+/[^/]+/blob.+%.lua$") then
				local ScriptName, ScriptClass = Link:match("([%w-_%%]+)%.?(%l*)%.lua$")

				if ScriptName:lower() ~= "install" and ScriptClass ~= "ignore" and ScriptClass ~= "spec" and ScriptName:lower() ~= "spec" then
					if ScriptClass == "mod" or ScriptClass == "module" then TypesSpecified = true end

					if ScriptName == "_" or ScriptName:lower() == "main" or ScriptName:lower() == "init" then
						ScriptCount = ScriptCount + 1
						for a = ScriptCount, 2, -1 do
							Scripts[a] = Scripts[a - 1]
						end
						Scripts[1] = Link
						MainExists = true
					else
						ScriptCount = ScriptCount + 1
						Scripts[ScriptCount] = Link
					end
				end
			end
		end
	end

	if ScriptCount > 0 then
		local ScriptLink = Scripts[1]
		local ScriptName, ScriptClass = ScriptLink:match("([%w-_%%]+)%.?(%l*)%.lua$")
		ScriptName = ScriptName:gsub("Library$", "", 1):gsub("%%(%x%x)", UrlDecode)
		local Sub = Link:sub(19)
		local Link = Sub:gsub("^(/[^/]+/[^/]+)/tree/[^/]+", "%1", 1)
		local LastFolder = Link:match("[^/]+$")
		LastFolder = LastFolder:match("^RBX%-(.-)%-Library$") or LastFolder

		if MainExists then
			local Directory = LastFolder:gsub("%%(%x%x)", UrlDecode)
			ScriptName, ScriptClass = Directory:match("([%w-_%%]+)%.?(%l*)%.lua$")
			if not ScriptName then ScriptName = Directory:match("^RBX%-(.-)%-Library$") or Directory end
			if ScriptClass == "mod" or ScriptClass == "module" then TypesSpecified = true end
		end

		-- if MainExists or ScriptCount ~= 1 or ScriptName ~= (LastFolder:match("^RBX%-(.-)%-Library$") or LastFolder) then
		if MainExists then Directory = Directory + 2 end -- :gsub("[^/]+$", "", 1) end
		local Count = 0

		local function LocateFolder(FolderName)
			Count = Count + 1
			if Count > Directory then
				Directory = Directory + 1
				if (Parent and Parent.Name) ~= FolderName and "Modules" ~= FolderName then
					-- local Success, Service = pcall(game.GetService, game, FolderName)
					-- if FolderName ~= "Lighting" and Success and Service then
					-- 	Parent = Service
					-- else
					local Generated
					Parent, Generated = GetFirstChild(Parent, FolderName, "Folder")
					if Generated then
						if not Routines[1] then Routines[1] = Parent end
						DataSources[Parent] = "https://github.com" .. (Sub:match(("/[^/]+"):rep(Directory > 2 and Directory + 2 or Directory)) or warn("[1]", Sub, Directory > 1 and Directory + 2 or Directory) or "")
					end
					-- end
				end
			end
		end

		Link:gsub("[^/]+$", ""):gsub("[^/]+", LocateFolder)

		if MainExists or ScriptCount ~= 1 or ScriptName ~= LastFolder then
			LocateFolder(LastFolder)
		end

		local Script = GetFirstChild(Parent, ScriptName, ScriptTypes[ScriptClass or TypesSpecified and "" or "mod"] or "ModuleScript")
		if not Routines[1] then Routines[1] = Script end
		coroutine.resume(coroutine.create(GiveSourceToScript), "https://raw.githubusercontent.com" .. ScriptLink:gsub("(/[^/]+/[^/]+/)blob/", "%1", 1), Script)

		if MainExists then
			Parent = Script
		end

		for a = 2, ScriptCount do
			local Link = Scripts[a]
			local ScriptName, ScriptClass = Link:match("([%w-_%%]+)%.?(%l*)%.lua$")
			local Script = GetFirstChild(Parent, ScriptName:gsub("Library$", "", 1):gsub("%%(%x%x)", UrlDecode), ScriptTypes[ScriptClass or TypesSpecified and "" or "mod"] or "ModuleScript")
			coroutine.resume(coroutine.create(GiveSourceToScript), "https://raw.githubusercontent.com" .. Link:gsub("(/[^/]+/[^/]+/)blob/", "%1", 1), Script)
		end
	end

	for a = 1, FolderCount do
		local Link = Folders[a]
		coroutine.resume(coroutine.create(InstallRepo), "https://github.com" .. Link, Directory, Parent, Routines, TypesSpecified)
	end

	Routines[Value] = true
end

function GitHub:Install(Link, Parent, RoutineList)
	-- Installs Link into Parent

	if Link:byte(-1) == 47 then --gsub("/$", "")
		Link = Link:sub(1, -2)
	end

	-- Extract Link Data
	local Organization, Repository, Tree, ScriptName, ScriptClass
	local Website, Directory = Link:match("^(https://[raw%.]*github[usercontent]*%.com/)(.+)")
	Organization, Directory = (Directory or Link):match("^/?([%w-_%.]+)/?(.*)")
	Repository, Directory = Directory:match("^([%w-_%.]+)/?(.*)")

	if Website == "https://raw.githubusercontent.com/" then
		if Directory then
			Tree, Directory = Directory:match("^([^/]+)/(.+)")
			if Directory then
				ScriptName, ScriptClass = Directory:match("([%w-_%%]+)%.?(%l*)%.lua$")
			end
		end
	elseif Directory then
		--print("link:", Link, "Website:", Website, "Directory:", Directory, "Organization:", Organization, "Repository:", Repository
		local a, b = Directory:find("^[tb][rl][eo][eb]/[^/]+")
		if a and b then
			Tree, Directory = Directory:sub(6, b), Directory:sub(b + 1)
			if Directory == "" then Directory = nil end
			if Directory and Link:find("blob", 1, true) then
				ScriptName, ScriptClass = Directory:match("([%w-_%%]+)%.?(%l*)%.lua$")
			end
		else
			Directory = nil
		end
	end

	if ScriptName and (ScriptName == "_" or ScriptName:lower() == "main" or ScriptName:lower() == "init") then
		return GitHub:Install("https://github.com/" .. Organization .. "/" .. Repository .. "/tree/" .. (Tree or "master") .. "/" .. Directory:gsub("/[^/]+$", ""):gsub("^/", ""), Parent, RoutineList)
	end

	if not Website then Website = "https://github.com/" end
	Directory = Directory and ("/" .. Directory):gsub("^//", "/") or ""

	-- Threads
	local Routines = RoutineList or {false}
	local Value = #Routines + 1
	Routines[Value] = false

	local Garbage

	if ScriptName then
		Link = "https://raw.githubusercontent.com/" .. Organization .. "/" .. Repository .. "/" .. (Tree or "master") .. Directory
		local Source = GetAsync(Link)
		local Script = GetFirstChild(Parent and not RoutineList and Repository ~= ScriptName and Parent.Name ~= ScriptName and Parent.Name ~= Repository and GetFirstChild(Parent, Repository, "Folder") or Parent, ScriptName:gsub("Library$", "", 1):gsub("%%(%x%x)", UrlDecode), ScriptTypes[ScriptClass or "mod"] or "ModuleScript")
		DataSources[Script] = Link
		if not Routines[1] then Routines[1] = Script end
		Script.Source = Source
	elseif Repository then
		Link = Website .. Organization .. "/" .. Repository .. ((Tree or Directory ~= "") and ("/tree/" .. (Tree or "master") .. Directory) or "")
		if not Parent then Parent, Garbage = Instance.new("Folder"), true end
		coroutine.resume(coroutine.create(InstallRepo), Link, 1, Parent, Routines) -- "/" .. Repository .. Directory
	elseif Organization then
		Link = Website .. Organization
		local Data = GetAsync(Link .. "?tab=repositories")
		local Object = GetFirstChild(Parent, Organization, "Folder")

		if not Routines[1] then Routines[1] = Object end

		for Link, Data in Data:gmatch('href="(/' .. Organization .. '/[^/]+)" itemprop="name codeRepository"(.-)</div>') do
			--if not Data:find("Forked from", 1, true) and not Link:find("Plugin", 1, true) and not Link:find(".github.io", 1, true) then
				GitHub:Install(Link, Object, Routines)
			--end
		end
	end

	Routines[Value] = true

	if not RoutineList then
		repeat
			local Done = 0
			local Count = #Routines
			for a = 1, Count do
				if Routines[a] then
					Done = Done + 1
				end
			end
		until Done == Count or not wait()
		local Object = Routines[1]
		if Garbage then
			Object.Parent = nil
			Parent:Destroy()
		end
		DataSources[Object] = Link
		return Object
	end
end

function GitHub:IndexSublibraries(Parent)
	if Parent.ClassName == "Folder" then
		local Children = Parent:GetChildren()
		for a = 1, #Children do
			local Object = Children[a]
			if Object.ClassName == "Folder" then
				-- Check to see whether the Folder is a single installation
				-- True if multiple Modules within it have the same Name or if multiple modules contain the name of the folder

				local Name = Object.Name
				local FolderChildren = Object:GetDescendants()
				local Count = 0
				table.sort(FolderChildren, function(a, b)
					return a.Name < b.Name
				end)

				for a = 2, #FolderChildren do
					local ChildName = FolderChildren[a].Name
					if ChildName == FolderChildren[a - 1].Name then
						Count = 2
					end

					if ChildName:find(Name:gsub("s$", ""), 1, true) then
						Count = Count + 1
					end
				end

				if Count > 1 then
					-- Single module
					local Source = DataSources[Object]
					if Source then
						-- print("Placing", Source, "in InstallableLibraries", Object)
						InstallableLibraries[Source] = Object
						-- print("[1] Caching Source:", Source, "with", Object.ClassName, Object.Name)
					else
						print(Object.ClassName, Object.Name, "has no recorded source [1]")
					end
				else
					-- Individual modules
					for a = 1, #FolderChildren do
						local Library = FolderChildren[a]
						-- local LibraryParent = Library
						-- local Sublink = "/"
						-- repeat
						-- 	Sublink = "/" .. LibraryParent.Name .. Sublink
						-- 	LibraryParent = LibraryParent.Parent
						-- until LibraryParent == Parent
						local Source = DataSources[Library]
						if Source then
							-- print("Placing", Source, "in InstallableLibraries", Library)
							InstallableLibraries[Source] = Library
							-- print("[2] Caching Source:", Source, "with", Library.ClassName, Library.Name)
						else
							print(Library.ClassName, Library.Name, "has no recorded source [2]")
						end
					end
				end
			else
				local Source = DataSources[Object]
				if Source then
					-- print("Placing", Source, "in InstallableLibraries", Object)
					InstallableLibraries[Source] = Object
				else
					print(Object.ClassName, Object.Name, "has no recorded source [3]")
				end
			end
		end
	else
		local Source = DataSources[Parent]
		-- print(Parent:GetFullName(), "#Children:", #Parent:GetChildren(), "Source:", Source)
		if Source then
			-- print("Placing", Source, "in InstallableLibraries", Parent)
			InstallableLibraries[Source] = Parent
		else
			print(Source.ClassName, Source.Name, "has no recorded source [4]")
		end
	end
end

function GitHub:GetApprovedRepositories(Threads)
	local Value = #Threads + 1
	Threads[Value] = false

	local Success, Data = pcall(HttpService.GetAsync, HttpService, "https://api.github.com/search/repositories?q=topic:rostrap")

	if Success then
		local Repos = HttpService:JSONDecode(Data)

		for a = 1, Repos.total_count do
			local Repo = Repos.items[a]

			if Repo.owner.id ~= 22812966 then
				-- Don't grab from RoStrap
				local Success, Data = pcall(HttpService.GetAsync, HttpService, Repo.stargazers_url)
				if Success then
					local Stargazers = HttpService:JSONDecode(Data)
					local Validark, devSparkle

					for a = 1, #Stargazers do
						local Stargazer = Stargazers[a]
						if Stargazer.id == 15217173 then
							Validark = true
						elseif Stargazer.id == 6726742 then
							devSparkle = true
						end
					end

					if Validark and devSparkle then
						-- Repositories[Repo.name] = {
						-- 	Description = Repo.description;
						-- 	URL = Repo.html_url;
						-- }
						coroutine.resume(coroutine.create(GitHub.InstallThenIndex), GitHub, Repo.html_url, Threads)
					end
				end
			end
		end
	end
	Threads[Value] = true
end

function GitHub:InstallThenIndex(URL, Threads, Name)
	local Value = #Threads + 1
	Threads[Value] = false
	local Folder = Instance.new("Folder")
	local Success, Parent = pcall(GitHub.Install, GitHub, URL, Folder)
	if Success then
		-- GitHub:IndexSublibraries(Parent)
		-- print(DataSources[Parent], Parent)
		Parent.Name = Name
		InstallableLibraries[URL] = Parent
	else
		warn(Parent)
	end
	Threads[Value] = true

	return Parent
end

return GitHub
