--!strict
-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Heimdall dependencies
local Heimdall = require(ReplicatedStorage.Modules.Classes.Heimdall);
local hdTypes = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdTypes);
local hdEnums = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdEnums);
local hdInstance = Heimdall.awaitHdInstance();

-- Service declaration
local CoreCameraCreateInfo : hdTypes.hdCoreModuleCreateInfo = {
	name = "CoreCamera";
	runtimeBehavior = "HD_CORE_CHARACTER";
	loadPriority = 1;
};

local hdPassed, hdCoreCamera = hdInstance:hdCreateService(CoreCameraCreateInfo);
if not hdPassed then
	error("failed to create the HeimdallDebugService!");
	return;
end

return hdCoreCamera