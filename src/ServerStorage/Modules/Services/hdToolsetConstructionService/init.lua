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

local hdComponentManager = require(hdClasses.hdComponentManager);
local hdComponent = require(hdClasses.hdComponent);
local hdInstance = Heimdall.awaitHdInstance();

-- Service declaration
local hdToolsetConstructionServiceCreateInfo : hdTypes.hdServiceCreateInfo = {
	name = "hdToolsetConstructionService";
	loadPriority = 1;
	moduleReference = script;
};

local hdPassed, hdToolsetConstructionService = hdInstance:hdCreateService(hdToolsetConstructionServiceCreateInfo);

function hdToolsetConstructionService:Compile()
	local componentManager : hdComponentManager.hdComponentManager = hdInstance:hdGetComponentManager();
	
	local hdComponentCreateInfo : hdTypes.hdComponentCreateInfo = {
		name = "ServerCharacterRepresentation";
		details = {
			HealthState = {
				Current = 0;
				Maximum = 100;
			};
			parts = {};
			rootPart = nil;
		};
	};
	local hdServerCharacterRepresentationComponent = hdComponent.new(hdComponentCreateInfo);
	local hdResult = componentManager:hdRegisterComponent(hdServerCharacterRepresentationComponent);
	
	if not hdResult then
		error("failed to create character representation!");
		return;
	end
end


return hdToolsetConstructionService;