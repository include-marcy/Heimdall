--!strict
-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterPlayer = game:GetService("StarterPlayer");

-- Heimdall dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local hdLib = hd.src.lib;
local hdClasses = hd.src.classes;
local Heimdall = require(hd);
local hdTypes = require(hdLib.hdTypes);
local hdInstance = Heimdall.awaitHdInstance();
local hdCharacter = require(hdClasses.hdCharacter);

-- Service declaration
local ServiceCreateInfo : hdTypes.hdServiceCreateInfo = {
	name = "CharacterService";
	loadPriority = 2;
	moduleReference = script;
};

local _, CharacterService = hdInstance:hdCreateService(ServiceCreateInfo);

CharacterService.CharacterRootDirectory = workspace; --// The object that characters are parented to

function CharacterService:Boot()
	--// Create a default scene, where characters can reside.
	warn("booting character service...");
	local defaultSceneCreateInfo : hdTypes.hdSceneCreateInfo = {
		sceneName = "defaultScene";
		sceneOwner = nil; -- server owned.
		sceneDescription = game.ServerStorage.Scenes.defaultScene;
		debugMessenger = Heimdall.awaitHdDebugMessenger();
	};
	local defaultSceneResult, defaultScene = hdInstance:hdCreateScene(defaultSceneCreateInfo);
	if defaultSceneResult.Success then
		CharacterService.defaultScene = defaultScene;
	end

	local defaultSceneWarperCreateInfo : hdTypes.hdSceneWarperCreateInfo = {
		hdWarpType = "HD_DEFAULT_SET_ROOT_CFRAME_CALLBACK";
		debugMessenger = Heimdall.awaitHdDebugMessenger();
		hdScene = CharacterService.defaultScene;
	};
	local warperCreateResult, defaultWarper = hdInstance:hdCreateSceneWarper(defaultSceneWarperCreateInfo);
	warn("default warper: ", defaultWarper);
	if warperCreateResult.Success then
		CharacterService.defaultWarper = defaultWarper;
	end
end

function CharacterService:hdCreatePhysicalCharacter(Player : Player?)
	local StarterCharacter = StarterPlayer:FindFirstChild("StarterCharacter");
	local physicalCharacter;
	if StarterCharacter then
		physicalCharacter = StarterCharacter:Clone();
	else
		physicalCharacter = script.hdCharacter:Clone();
	end

	physicalCharacter.Name = Player and Player.Name or "hdCharacter";
	physicalCharacter.Parent = CharacterService.CharacterRootDirectory;

	if Player then
		Player.ReplicationFocus = physicalCharacter;
	end

	return physicalCharacter;
end

function CharacterService:PlayerAdded(Player : Player)
	print(Player, " is going to get a character now.");
	local physicalCharacter = CharacterService:hdCreatePhysicalCharacter(Player);
	local hdCharacterCreateInfo : hdTypes.hdCharacterCreateInfo = {
		physical = physicalCharacter;
	};
	local character = hdCharacter.new(hdCharacterCreateInfo);
	local hdSceneParticipantCreateInfo : hdTypes.hdSceneParticipantCreateInfo = {
		participantInstance = character:hdGetPhysicalCharacter();
		debugMessenger = Heimdall.awaitHdDebugMessenger;
	};
	local participantResult, hdSceneParticipant = hdInstance:hdCreateSceneParticipant(hdSceneParticipantCreateInfo);
	print(hdCharacter);
	if not participantResult.Success then
		error("Failed to create scene participant!");
		return;
	end

	local defaultWarper = CharacterService.defaultWarper;

	defaultWarper:Warp(CharacterService.defaultScene:hdGetRootHandle(), hdSceneParticipant);
end

return CharacterService;