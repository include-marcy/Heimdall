--!strict
-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Heimdall dependencies
local Heimdall = require(ReplicatedStorage.Modules.Classes.Heimdall);
local hdTypes = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdTypes);
local hdEnums = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdEnums);
local hdInstance = Heimdall.awaitHdInstance();

-- Service declaration
local hdCoreCameraServiceCreateInfo : hdTypes.hdServiceCreateInfo = {
	name = "CoreCamera";
	loadPriority = 1;
	moduleReference = script;
};

local hdPassed, hdCoreCameraService = hdInstance:hdCreateService(hdCoreCameraServiceCreateInfo);
if not hdPassed then
	error("failed to create the hdCoreCameraService!");
	return;
end

hdCoreCameraService.CoreCameraTypeModules = {};

function hdCoreCameraService:hdSetCameraType(hdCameraType : hdTypes.hdCameraTypeUnion)
	if hdCoreCameraService.cameraType == hdCameraType then
		return;
	end

	hdCoreCameraService.cameraType = hdCameraType;

	local module = hdCoreCameraService:hdGetCoreCameraTypeModule(hdCameraType);
	if module then
		module.parentService = hdCoreCameraService;
		hdCoreCameraService.cameraModule = module;
	end
end

function hdCoreCameraService:hdGetCoreCameraTypeModule(hdCameraType : hdTypes.hdCameraTypeUnion)
	local coreCameraTypeModule = hdCoreCameraService.CoreCameraTypeModules[hdCameraType];

	if not coreCameraTypeModule then
		coreCameraTypeModule = require(script.hdCameraTypes:FindFirstChild(hdCameraType.Name));

		hdCoreCameraService.CoreCameraTypeModules[hdCameraType] = coreCameraTypeModule;
	end

	return coreCameraTypeModule;
end

function hdCoreCameraService:Update(deltaTime)
	local cameraModule = hdCoreCameraService.cameraModule;

	if cameraModule then
		cameraModule:Update(deltaTime);
	end
end

function hdCoreCameraService:Boot()
	hdCoreCameraService:hdSetCameraType(hdEnums.hdCameraType.hdCameraDefault);
end

function hdCoreCameraService:CharacterAdded(Character)
	hdCoreCameraService.Character = Character;
end

return hdCoreCameraService