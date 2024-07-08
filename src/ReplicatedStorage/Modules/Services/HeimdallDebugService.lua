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
--
local hdWrapping = require(hdClasses.hdWrapping);
--HECL
local heclMachine = require(hdClasses.hdHECLExecutor.src.classes.heclMachine);

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

for i = 1, 50 do
	-- Service declaration
	local hdVirtualServiceCreateInfo : hdTypes.hdServiceCreateInfo = {
		name = "VirtualTestService" .. i;
		loadPriority = i;
		commandDispatchMode = hdEnums.hdCommandDispatchModes.hdCommandDispatchModeSerial;
		moduleReference = nil;
		isVirtual = true;
	};

	local hdPassed, hdVirtualTestService = hdInstance:hdCreateService(hdVirtualServiceCreateInfo);
	if not hdPassed.Success then
		warn(hdEnums.hdFailureTypes.hdServiceFailure);
		continue;
	end
	
	function hdVirtualTestService:Update()
		--print("Upda...", self.name)
	end

	--function hdVirtualTestService:Boot()
	--	warn(self.loadPriority);
	--end
end

function HeimdallDebugService:Update(deltaTime)
	--// print(deltaTime);
end

function HeimdallDebugService:PlayerAdded(player : Player) : hdWrapping.hdWrapping
	local hdWrappingCreateInfo : hdTypes.hdWrappingCreateInfo = {
		instance = player;
	};
	local wrapping = hdWrapping.new(hdWrappingCreateInfo);

	task.wait(5)


	return wrapping;
end

function HeimdallDebugService:Boot()

end

return HeimdallDebugService;