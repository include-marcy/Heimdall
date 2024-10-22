--!strict
--!native
--!optimize 2

-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Heimdall dependencies
local Heimdall = require(ReplicatedStorage.Modules.Classes.Heimdall);
local hdTypes = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdTypes);
local hdEnums = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdEnums);
local hdInstance = Heimdall.awaitHdInstance();
local athInputStream = require(ReplicatedStorage.Modules.Classes.Athena.src.classes.athInputStream);

-- Service declaration
local hdCoreControlServiceCreateInfo : hdTypes.hdServiceCreateInfo = {
	name = "hdCoreControlService";
	loadPriority = 2;
	moduleReference = script;
};

local hdPassed, hdCoreControlService = hdInstance:hdCreateService(hdCoreControlServiceCreateInfo);
if not hdPassed then
	error("failed to create the hdCoreControlService!");
	return;
end

hdCoreControlService.CoreControlModeModules = {};

function hdCoreControlService:hdSetControlMode(hdControlMode : hdTypes.hdControlModeUnion)
	if hdCoreControlService.controlMode == hdControlMode then
		return;
	end

	hdCoreControlService.controlMode = hdControlMode;

	local module = hdCoreControlService:hdGetCoreControlModeModule(hdControlMode);
	if module then
		hdCoreControlService.controlModule = module;
	end
end

function hdCoreControlService:hdGetCoreControlModeModule(hdControlMode : hdTypes.hdControlModeUnion)
	local coreControlModeModule = hdCoreControlService.CoreControlModeModules[hdControlMode];

	if not coreControlModeModule then
		coreControlModeModule = require(script.hdControlModes:FindFirstChild(hdControlMode.Name));

		hdCoreControlService.CoreControlModeModules[hdControlMode] = coreControlModeModule;
	end

	return coreControlModeModule;
end

function hdCoreControlService:Update(deltaTime)
	local controlModule = hdCoreControlService.controlModule;

	if controlModule then
		controlModule:Update(deltaTime);
	end
end

function hdCoreControlService:Boot()
	hdCoreControlService:hdSetControlMode(hdEnums.hdControlMode.hdControlModeDefault);

	-- Use ath input stream; It is a cross-platform input manager which contains specialized outputs for all types of
	-- user input.
	local controlInputStream = athInputStream.new();
	controlInputStream:athInit();

	controlInputStream:athGetMovementSignal():Connect(function(MoveDirection : Vector3)
		local controlModule = hdCoreControlService.controlModule;

		if controlModule then
			controlModule:hdSetMoveDirection(MoveDirection);
		end
	end);
end

function hdCoreControlService:hdCharacterAdded(hdCharacter)
	hdCoreControlService.Character = hdCharacter;
end

return hdCoreControlService