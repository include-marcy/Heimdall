-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Heimdall dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local hdLib = hd.src.lib;
local Heimdall = require(hd);
local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);
local hdInstance = Heimdall.awaitHdInstance();

-- Service declaration
local HeimdallCompiledDebugServiceCreateInfo : hdTypes.hdCompiledServiceCreateInfo = {
	name = "HeimdallCompiledDebugService";
	loadPriority = 1;
	compileRoot = ReplicatedStorage.Modules.GameData.Cars
};

local hdPassed, HeimdallCompiledDebugService = hdInstance:hdCreateCompiledService(HeimdallCompiledDebugServiceCreateInfo);
if not hdPassed.Success then
	error(hdEnums.hdFailureTypes.hdServiceFailure);
	return;
end

function HeimdallCompiledDebugService:Boot()
	local compiledData = HeimdallCompiledDebugService.compiledData;
end

return HeimdallCompiledDebugService;