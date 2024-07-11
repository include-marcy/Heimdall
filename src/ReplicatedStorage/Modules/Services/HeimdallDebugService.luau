--!strict
-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Heimdall dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local hdLib = hd.src.lib;
local hdClasses = hd.src.classes;
local Heimdall = require(hd);
local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);
local hdInstance = Heimdall.awaitHdInstance();
local hdWrapping = require(hdClasses.hdWrapping);

-- Service declaration
local HeimdallDebugServiceCreateInfo : hdTypes.hdServiceCreateInfo = {
	name = "HeimdallDebugService";
	loadPriority = 2;
	moduleReference = script;
};

local hdPassed, HeimdallDebugService = hdInstance:hdCreateService(HeimdallDebugServiceCreateInfo);
if not hdPassed.Success then
	error(hdEnums.hdFailureTypes.hdServiceFailure);
	return;
end

function HeimdallDebugService:Update(deltaTime)
	--// print(deltaTime);
end

function HeimdallDebugService:PlayerAdded(player : Player) : hdWrapping.hdWrapping
	local hdWrappingCreateInfo : hdTypes.hdWrappingCreateInfo = {
		instance = player;
	};
	local wrapping = hdWrapping.new(hdWrappingCreateInfo);

	return wrapping;
end

function HeimdallDebugService:Boot()

end

return HeimdallDebugService;