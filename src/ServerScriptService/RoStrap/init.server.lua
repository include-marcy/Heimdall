-- RoStrap Package Manager 3.0
-- The code is in a state of transition right now. Really messy.
-- Make it so Main is only created if actually installed
-- @author Validark

-- Services
local Debris = game:GetService("Debris")
local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Don't run in play mode
if RunService:IsRunning() or not RunService:IsClient() or RunService:IsRunMode() then return end

local ScreenGuiName = "RoStrap" -- Remove old instances of this plugin
while true do
	local Old = game:GetService("CoreGui"):FindFirstChild(ScreenGuiName)
	if Old then
		Old:Destroy()
	else
		break
	end
end

local Libraries

-- Create Toolbar
local Start = plugin:CreateToolbar("RoStrap"):CreateButton("RoStrap", "Bootstrapper and Package Manager", "rbxassetid://942038982")

-- Modules
local GitHub = require(script.GitHub)
local Blacklist = require(script.Blacklist)
local SharedData = require(script.SharedData)
local GetFirstChild = require(script.GetFirstChild)
local TranslateDependencyToPlugin = require(script.TranslateDependencyToPlugin)
local GetDescendantsInPredictableOrder = require(script.GetDescendantsInPredictableOrder)

-- Maids
local GlobalMaid = require(script.GlobalMaid)
-- local MarkLibrariesMaid = Maid.new()

local widgetSize = Vector2.new(953, 530)
Screen = plugin:CreateDockWidgetPluginGui(
	"RoStrap",
	DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		false,
		true,
		widgetSize.X,
		widgetSize.Y,
		widgetSize.X,
		widgetSize.Y
	)
)
Screen.Title = "RoStrap"
Screen.Name = Screen.Title
GlobalMaid:LinkToInstance(Screen)
Screen.Enabled = false

-- State
--local Open

-- Check whether RoStrap is installed
local Resources = ReplicatedStorage:FindFirstChild("Resources")

local function GetRepository()
	return ServerStorage:FindFirstChild("Repository") or ServerScriptService:FindFirstChild("Repository")
end

local Repository = GetRepository()

local function Debounce(Func)
	local IsRunning

	return function(...)
		if not IsRunning then
			IsRunning = true
			local args = table.pack(Func(...))
			IsRunning = false
			return unpack(args, 1, args.n)
		end
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

--[[
local function GenerateReplicatedLibrariesFolder()
	local ReplicatedLibraries = GetFirstChild(GetFirstChild(ServerStorage, "TagList", "Folder"), "ReplicatedLibraries", "Folder")
	local Color, GeneratedColor = GetFirstChild(ReplicatedLibraries, "Color", "Color3Value")
	if GeneratedColor then Color.Value = Color3.fromRGB(14, 252, 198) end
	local Group, GeneratedGroup = GetFirstChild(ReplicatedLibraries, "Group", "StringValue")
	if GeneratedGroup then Group.Value = "Code" end
	local Icon, GeneratedIcon = GetFirstChild(ReplicatedLibraries, "Icon", "StringValue")
	if GeneratedIcon then Icon.Value = "folder_feed" end
	local Visible, GeneratedVisible = GetFirstChild(ReplicatedLibraries, "Visible", "BoolValue")
	if GeneratedVisible then Visible.Value = false end
end

local function GenerateServerLibrariesFolder()
	local ServerLibraries = GetFirstChild(GetFirstChild(ServerStorage, "TagList", "Folder"), "ServerLibraries", "Folder")
	local Color, GeneratedColor = GetFirstChild(ServerLibraries, "Color", "Color3Value")
	if GeneratedColor then Color.Value = Color3.fromRGB(24, 104, 106) end
	local Group, GeneratedGroup = GetFirstChild(ServerLibraries, "Group", "StringValue")
	if GeneratedGroup then Group.Value = "Code" end
	local Icon, GeneratedIcon = GetFirstChild(ServerLibraries, "Icon", "StringValue")
	if GeneratedIcon then Icon.Value = "folder_database" end
	local Visible, GeneratedVisible = GetFirstChild(ServerLibraries, "Visible", "BoolValue")
	if GeneratedVisible then Visible.Value = false end
end

local TagFolderGenerators = {GenerateServerLibrariesFolder, GenerateReplicatedLibrariesFolder}
local Tags = {"ServerLibraries", "ReplicatedLibraries", "ServerStuff", "StarterPlayerScripts", "StarterCharacterScripts"}
--]]
local TagWhitelist = {} -- Modifiable tags

SharedData.TagWhitelist = TagWhitelist

local UI
local MakeCard
-- local Cards
-- local InstalledCards

local Repositories = {}
local Completed, UILibrariesLoaded
--[[
local LibraryTagsSources = {
	[3] = [====[return function(Modules, ModuleAmount)
	local ServerScriptService = game:GetService("ServerScriptService")
	local ServerStuff = ServerScriptService:FindFirstChild("Server") or Instance.new("Folder", ServerScriptService)
	ServerStuff.Name = "Server"
	for a = 1, ModuleAmount do
		Modules[a].Parent = ServerStuff
	end
end
]====];

	[4] = [====[return function(Modules, ModuleAmount)
	local StarterPlayerScripts = game:GetService("StarterPlayer"):FindFirstChildOfClass("StarterPlayerScripts")
	local Playerlist = game:GetService("Players"):GetPlayers()
	for a = 1, ModuleAmount do
		Modules[a].Parent = StarterPlayerScripts
	end

	-- Make sure that Players already loaded in receive this, doesn't work on Server
	for a = 1, #Playerlist do
		local PlayerScripts = Playerlist[a]:FindFirstChild("PlayerScripts")
		if PlayerScripts then
			for a = 1, ModuleAmount do
				local Clone = Modules[a]:Clone()
				Clone.Disabled = true
				Clone.Parent = PlayerScripts
				delay(0, function()
					Clone.Disabled = false
				end)
			end
		end
	end
end
]====];

	[5] = [====[return function(Modules, ModuleAmount)
	local StarterCharacterScripts = game:GetService("StarterPlayer"):FindFirstChildOfClass("StarterCharacterScripts")
	local Playerlist = game:GetService("Players"):GetPlayers()
	for a = 1, ModuleAmount do
		Modules[a].Parent = StarterCharacterScripts
	end

	-- Make sure that Characters already loaded in receive this
	for a = 1, #Playerlist do
		local Character = Playerlist[a].Character
		if Character then
			for a = 1, ModuleAmount do
				local Clone = Modules[a]:Clone()
				Clone.Disabled = true
				Clone.Parent = Character
				delay(0, function()
					Clone.Disabled = false
				end)
			end
		end
	end
end
]====];
}

local function AddTag(Instance, TagNumber)
	if not Blacklist:IsMember(Instance) then
		TagWhitelist[Instance] = true
		for a = 1, #Tags do
			if a == TagNumber then
				CollectionService:AddTag(Instance, Tags[a])
				if TagFolderGenerators[a] then delay(0.5, TagFolderGenerators[a]) end
			else
				CollectionService:RemoveTag(Instance, Tags[a])
			end
		end

		delay(0.2, function()
			TagWhitelist[Instance] = nil
		end)
	end
end

--]]

local MarkReplicatedLibraries
-- local TagConnections = {}

function MarkReplicatedLibraries()
	--[[
--	local ServerRepository, ServerStuff -- Repository folders
	local Boundaries = {} -- This is a system for keeping track of which items should be stored in ServerStorage (vs ReplicatedStorage)
	local Count, BoundaryCount = 0, 0
	local NumDescendants, CurrentBoundary = 1, 1
	local LowerBoundary, SetsEnabled
	Repository = GetRepository()
	if Repository then
		for i = 1, #Tags do
			local Tag = Tags[i]
			local TaggedLibraries = CollectionService:GetTagged(Tags[i])
			for j = 1, #TaggedLibraries do
				local Library = TaggedLibraries[j]
				if not Library:IsDescendantOf(Repository) then
					CollectionService:RemoveTag(Library, Tag)
				end
			end
		end

		local Libs = {Repository}

		repeat -- Most efficient way of iterating over every descendant of the Module Repository, believe it or not
			Count = Count + 1
			local Child = Libs[Count]
			-- print(Count, Child and Child:GetFullName() or Child)
			if not TagConnections[Child] then
				TagConnections[Child] = true
				GlobalMaid:GiveTask(Child:GetPropertyChangedSignal("Name"):Connect(MarkReplicatedLibraries))
				GlobalMaid:GiveTask(Child.AncestryChanged:Connect(MarkReplicatedLibraries))
			end
			local Name = Child.Name
			local ClassName = Child.ClassName
			local GrandChildren = Child:GetChildren()
			local NumGrandChildren = #GrandChildren

			if SetsEnabled then
				if not LowerBoundary and Count > Boundaries[CurrentBoundary] then
					LowerBoundary = true
				elseif LowerBoundary and Count > Boundaries[CurrentBoundary + 1] then
					CurrentBoundary = CurrentBoundary + 2
					local Boundary = Boundaries[CurrentBoundary]

					if Boundary then
						LowerBoundary = Count > Boundary
					else
						SetsEnabled = false
						LowerBoundary = false
					end
				end
			end

			local Server = LowerBoundary or Name:lower():find("server")

			if ClassName == "ModuleScript" then
				if Server then
					AddTag(Child, 1)
				else
					AddTag(Child, 2)
				end
			elseif ClassName == "LocalScript" then
				AddTag(Child, 4)
			else
				if NumGrandChildren ~= 0 then
					if Server then
						SetsEnabled = true
						Boundaries[BoundaryCount + 1] = NumDescendants
						BoundaryCount = BoundaryCount + 2
						Boundaries[BoundaryCount] = NumDescendants + NumGrandChildren
					end

					for a = 1, NumGrandChildren do
						Libs[NumDescendants + a] = GrandChildren[a]
					end
					NumDescendants = NumDescendants + NumGrandChildren
				end

				if ClassName ~= "Folder" and Child.Parent.ClassName == "Folder" then
					AddTag(Child, 3)
				end
			end
			Libs[Count] = nil
		until Count == NumDescendants
	end--]]
end

local function TaggedWithinCode(Object, Name)
	local Descendants = GetDescendantsInPredictableOrder(Object)
	table.insert(Descendants, 1, Object)
	for a = 1, #Descendants do
		local Descendant = Descendants[a]
		if Descendant:IsA("LuaSourceContainer") then
			if Name == Descendant.Source:match("%-%-%s+@rostrap%s+(%S+)") then
				return true
			end
		end
	end
end

--[[
local function RepositoryDescendantAdded(Descendant)
	TagWhitelist[Descendant] = true
	Blacklist:Remove(Descendant)
	MarkReplicatedLibraries()

	if Screen.Enabled then
		if Cards then
			local Class, Name = Descendant.ClassName, Descendant.Name
			for a = 1, #Cards do
				local Object = Cards[a].UpdatedLibrary
				if Object and Object.ClassName == Class and Object.Name == Name and TaggedWithinCode(Descendant, Name) then
					Cards[a]:Install(false, Descendant)
					break
				end
			end
		end
	end
end

local function RepositoryDescendantRemoving(Descendant)
	TagWhitelist[Descendant] = true
	Blacklist:Remove(Descendant)
	MarkReplicatedLibraries()
	if Screen.Enabled then
		if InstalledCards then
			local DescendantName = Descendant.Name
			for a = 1, #InstalledCards do
				-- print("InstalledCards[a]", typeof(InstalledCards[a]), InstalledCards[a], type(InstalledCards[a]) == "table" and InstalledCards[a].Name)
				local Card = InstalledCards[a]
				if not Card then
					table.foreach(InstalledCards, print)
					table.remove(InstalledCards, a)
					Card = InstalledCards[a]
				end

				if Card and Card.Name == DescendantName and Card.UpdatedLibrary.ClassName == Descendant.ClassName and Card.Installed then
					Card.UninstalledViaDescendantRemoving = true
					Card:Uninstall()
				end
			end
		end
	end
end

local function TagChanged(Instance)
	--print(TagWhitelist[Instance], "Tag", Instance:GetFullName())
	Repository = GetRepository()
	if Repository then
		if Instance.Name ~= "ModuleScript" and Instance:IsDescendantOf(Repository) and not TagWhitelist[Instance] then
			-- Blacklist:Add(Instance)
		end
	end
end

for a = 1, #Tags do
	local Tag = Tags[a]
	GlobalMaid:GiveTask(CollectionService:GetInstanceAddedSignal(Tag):Connect(function(Instance)
		if LibraryTagsSources[a] then
			Resources = ReplicatedStorage:FindFirstChild("Resources")
			local Module, Generated = GetFirstChild(GetFirstChild(Resources, "LibraryTags", "Folder"), Tags[a], "ModuleScript")
			if Generated then Module.Source = LibraryTagsSources[a] end
		end
		Repository = GetRepository()
		if Repository then
			if Instance.Name ~= "ModuleScript" and Instance:IsDescendantOf(Repository) and not TagWhitelist[Instance] then
				-- Blacklist:Add(Instance)
				for b = 1, #Tags do
					local Tag2 = Tags[b]
					if Tag2 ~= Tag then
						CollectionService:RemoveTag(Instance, Tag2)
					end
				end
			end
		end
	end))
	GlobalMaid:GiveTask(CollectionService:GetInstanceRemovedSignal(Tag):Connect(TagChanged))
end
--]]

-- local CardsMade
local ThreadOpened
--[[
if ReplicatedStorage:FindFirstChild("Resources") and GetRepository() then
	Repository = GetRepository()
	MarkReplicatedLibraries()
	GlobalMaid.RepositoryDescendantAdded = Repository.DescendantAdded:Connect(RepositoryDescendantAdded)
	GlobalMaid.RepositoryDescendantRemoving = Repository.DescendantRemoving:Connect(RepositoryDescendantRemoving)
end
--]]

local function GetSourceLibrary(UpdatedLibrary)
	if UpdatedLibrary:IsA("LuaSourceContainer") then
		return GetSource(UpdatedLibrary)
	else
		local Descendants = UpdatedLibrary:GetDescendants()
		for i = #Descendants, 1, -1 do
			local Object = Descendants[i]
			if Object:IsA("LuaSourceContainer") then
				return GetSourceLibrary(Object)
			end
		end
	end
end

local BadNames = {
	spec = true;
	main = true;
	["_"] = true;
	init = true;
	lib = true;
}

local FirstTime = true
local UpdatedResources

local OpenFirst = Debounce(function()
	local FinishLoader
	if Screen.Enabled then
		local Success, Data = pcall(HttpService.GetAsync, HttpService, "https://github.com")
		if Success and not Data:find("Http requests are not enabled", 1, true) then
			if not ThreadOpened then
				ThreadOpened = true

				if ReplicatedStorage:FindFirstChild("Resources") and (GetRepository()) then
					MarkReplicatedLibraries()
				end

				-- Install Libraries this Plugin uses :D

				FinishLoader = require(script.UI):Start(plugin)

				local TestService = game:GetService("TestService")
				local OverrideGitHub = game.CreatorId == 998796 and (TestService:FindFirstChild("RoStrapLibraries") or TestService:FindFirstChild("Libraries"))
				if OverrideGitHub and OverrideGitHub.ClassName == "ModuleScript" then
					Libraries = require(OverrideGitHub)
				else
					local LibrariesURL = "RoStrap/Libraries/blob/master/Libraries.lua"
					Libraries = require(GitHub:Install(LibrariesURL))
				end

				-- Libraries.Resources = {
				-- 	URL = "RoStrap/Resources";
				-- 	Documentation = "https://rostrap.github.io/Resources";
				-- 	ParentFolderPath = "ReplicatedStorage"
				-- }

				local Threads = {}
				-- print("[RoStrap] Requesting data from GitHub...")
				for Name, LibraryData in next, Libraries do
					-- print("\t[RoStrap] Grabbing " .. Name)
					coroutine.resume(coroutine.create(GitHub.InstallThenIndex), GitHub, LibraryData.URL, Threads, Name)
				end

				-- print("\t[RoStrap] Grabbing Resources")
				UpdatedResources = GitHub:Install("https://github.com/RoStrap/Resources/")
				-- print("[RoStrap] Finished")

				UILibrariesLoaded = true

				-- coroutine.resume(coroutine.create(GitHub.GetApprovedRepositories), GitHub, Threads)

				-- Yield until all threads complete
				repeat
					-- print(require(script.Debug).TableToString(Threads))
					local Done = 0
					local Count = #Threads
					for a = 1, Count do
						if Threads[a] then
							Done = Done + 1
						end
					end
				until Done == Count or not wait()
				
				-- print("Installing repos")

				if not Repositories then
					Repositories = {}
				end

				for URL, Object in next, GitHub.InstallableLibraries do
					Repositories[Object.Name] = {URL = URL; ClassName = Object.ClassName}
					-- Repositories[Object.ClassName .. " " .. Object.Name] = URL
				end

				Completed = true
				if Screen.Enabled and FirstTime then
				else
					FinishLoader()
				end
			end
		else
			Selection:Set{HttpService}
			local FeedbackScreen = Instance.new("ScreenGui", game:GetService("CoreGui"))
			local Feedback = Instance.new("TextLabel", FeedbackScreen)
				Feedback.AnchorPoint = Vector2.new(0.5, 0.5)
				Feedback.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Feedback.BorderSizePixel = 0
				Feedback.Position = UDim2.new(0.5, 0, 0.5, 0)
				Feedback.Size = UDim2.new(0, 375, 0, 50)
				Feedback.Font = "SourceSans"
				Feedback.Text = "Please enable HttpService.HttpEnabled to use RoStrap."
				Feedback.TextSize = 18
			Debris:AddItem(FeedbackScreen, 4)

			GlobalMaid.FeedbackScreen = FeedbackScreen
			-- Debris:AddItem(Screen, 15)
			return false
			-- return UI:CreateSnackbar("Please set HttpService.HttpEnabled to true to use RoStrap.", true)
		end
	end

	if Screen.Enabled then
		if not UI then
			UI = require(script.UI)
			MakeCard = UI.Card.new
			-- Cards = UI.Cards
			-- InstalledCards = UI.InstalledCards
			-- print(Cards)
			-- print(InstalledCards)
		end

		plugin:Activate(true)
		Resources = ReplicatedStorage:FindFirstChild("Resources")
		Repository = GetRepository()

		if not Resources or not Repository then
			-- Prompt to install RoStrap
			if FinishLoader then
				FinishLoader()
				FinishLoader = nil
			end

			Resources, Repository = UI:PromptInstall()
			local Main, Generated = GetFirstChild(ServerScriptService, "Main", "Script")

			if Generated then
				Main.Source = "local ReplicatedStorage = game:GetService(\"ReplicatedStorage\")\nlocal Resources = require(ReplicatedStorage:WaitForChild(\"Resources\"))\n"
			end

			if not Resources or not GetRepository() then
				Screen.Enabled = false
				ThreadOpened = false
				return UI:CreateSnackbar("RoStrap was not setup for this game instance", true)
			end

			FirstTime = true
		end

		MarkReplicatedLibraries()
		UI.Buttons = {}

		if FirstTime then
			FirstTime = false

			if FinishLoader then
				FinishLoader()
			else
				UI:Start(plugin)()
			end
		end

		local Mouse = plugin:GetMouse()

		GlobalMaid.MouseLeaveConnection = Mouse.Move:Connect(function()
			local X, Y = Mouse.X, Mouse.Y
			local Buttons = UI.Buttons

			for a = 1, #Buttons do
				local Button = Buttons[a]
				local Size = Button.AbsoluteSize
				local Position = Button.AbsolutePosition

				if X >= Position.X and Y >= Position.Y and X <= Size.X + Position.X and Y <= Size.Y + Position.Y then -- Not MouseOver
					Button.Corner.BackgroundTransparency = 0.88
				else
					Button.Corner.BackgroundTransparency = 1
					local CurrentCircle = Button:FindFirstChild("Ink")
					if Button:FindFirstChild("Ink") then -- Fade out Ripples in Buttons that are no longer being MouseOvered
						require(script.Tween)(CurrentCircle, "ImageTransparency", 1, require(script.Bezier).new(0, 0, 0.2, 1), 1, false, function(EnumItem)
							if EnumItem.Name == "Completed" then
								CurrentCircle:Destroy()
							end
						end)
					end
				end
			end
		end)

		UI:OpenWindow()

		local function Close(Message)
			UI:CreateSnackbar(Message, true)
			UI:CloseWindow()
			Screen.Enabled = false
			ThreadOpened = false
		end
		
		GlobalMaid.RepositoryRenamed = Repository:GetPropertyChangedSignal("Name"):Connect(function()
			spawn(function()
				if Repository.Parent then
					Repository.Name = "Repository"
					UI:CreateSnackbar("The Repository folder cannot be renamed!", true)	
				end
			end)
		end)
		
		GlobalMaid.ResourcesRenamed = Resources:GetPropertyChangedSignal("Name"):Connect(function()
			spawn(function()
				if Resources.Parent then
					Resources.Name = "Resources"
					UI:CreateSnackbar("The Resources module cannot be renamed!", true)	
				end
			end)
		end)

		GlobalMaid.RepositoryRemoved = Repository.Parent.ChildRemoved:Connect(function(Object)
			if Object == Repository then
				Close("Repository was removed, closing RoStrap")
			end
		end)

		GlobalMaid.ResourcesRemoved = ReplicatedStorage.ChildRemoved:Connect(function(Object)
			if Object == Resources then
				Close("Resources was removed, closing RoStrap")
			end
		end)
		-- GlobalMaid.RepositoryDescendantAdded = Repository.DescendantAdded:Connect(RepositoryDescendantAdded)
		-- GlobalMaid.RepositoryDescendantRemoving = Repository.DescendantRemoving:Connect(RepositoryDescendantRemoving)

		-- print("Yielding")
		repeat until Completed or not wait()
		-- print("Done yeilding")

		-- if not CardsMade then
			-- CardsMade = true
			-- local InstalledRepositories = GetInstalledLibrariesFromTable(Repositories)
		Repository = GetRepository()

		if Repository and Resources then
			local Objects = Repository:GetDescendants()
			local ObjectsCount = #Objects + 1
			Objects[ObjectsCount] = ReplicatedStorage:FindFirstChild("Resources")
			-- local Installed = {}

			for Name, Data in next, Repositories do
				local Class = Data.ClassName
				local Link = Data.URL

				-- print(Name, Link, Class)

				for LibName, LibraryData in next, Libraries do
					if "https://raw.githubusercontent.com" .. LibraryData.URL == Link or "https://github.com/" .. LibraryData.URL == Link then
						Name = LibName
					end
				end

				local UpdatedLibrary = GitHub.InstallableLibraries[Link] or GitHub:Install(Link)
				local Source = GetSourceLibrary(UpdatedLibrary)
				local Firstline = Source:match("([^\r\n]+)")
				local Entitled = Firstline and Firstline:match("([/%-_%w]+)%.lua")
				local Subtitle

				if BadNames[Name:lower()] then
					Name = Link:match(".-%.com/[^/]+/([^/]+)") or Name
				end

				local LibraryData = Libraries[Name] or {}

				Subtitle = LibraryData.Description or Subtitle or (Source:match("^%-%-%s*([^@%s][^\n\r]+)") or "No description"):gsub("%.$", "")
				local Docs = LibraryData.Documentation or ""
				local ParentFolderPath = LibraryData.ParentFolderPath

				if Link:find("https://github.com/", 1, true) ~= 1 and Link:find("https://raw.githubusercontent.com/", 1, true) ~= 1 then
					Link = "https://github.com/" .. Link
				end

				local Installed

				for a = 1, ObjectsCount do
					local Object = Objects[a]
					if Object and Object.ClassName == Class and Object.Name == Name and TaggedWithinCode(Object, Name) then
						MakeCard(Name, Subtitle, Link, Object, UpdatedLibrary, Docs, ParentFolderPath)
						Installed = true
						break
					end
				end

				if not Installed then
					MakeCard(Name, Subtitle, Link, nil, UpdatedLibrary, Docs, ParentFolderPath)
				end
			end

			local LastCard = MakeCard(
				"Resources",
				"The core resource manager and library loader for RoStrap",
				"https://github.com/RoStrap/Resources/",
				Resources,
				UpdatedResources,
				"https://rostrap.github.io/Resources/"
			)

			delay(0.3, function()
				-- print("a[1]")
				LastCard:TransferTabs()
			end)
		else
			Close("Resources or Repository does not exist, closing RoStrap")
		end
	end
end)

Start.Click:Connect(function()
	Screen.Enabled = not Screen.Enabled
	if not ThreadOpened then
		local ret = OpenFirst()
		if ret == false then
			Screen.Enabled = false
		end
	end
end)
