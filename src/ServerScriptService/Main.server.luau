--!strict
--!native
--!optimize 2

-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");

-- Dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local hdLib = hd.src.lib;
local hdClasses = hd.src.classes;
local Heimdall = require(hd);
local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);
local hdUtils = require(hdLib.hdUtils);
local hdFence = require(hdClasses.hdFence);

--// Heimdall bootstrap
local hdObjectCreateInfo : hdTypes.hdObjectCreateInfo = {};
hdObjectCreateInfo.User = "global";
local hdObject : Heimdall.hdObject = Heimdall.new(hdObjectCreateInfo);

--// Create Launch Token
local hdVersion = hdUtils.hdMakeVersion(1, 0, 0,
	false
);
local hdLaunchTokenCreateInfo : hdTypes.hdLaunchTokenCreateInfo = {
	launchTitle = "Debug";
	hdVersion = hdVersion;
};
local launchToken = hdObject:hdCreateLaunchToken(hdLaunchTokenCreateInfo);

--// Create debug messenger
local hdDebugMessengerCreateInfo : hdTypes.hdDebugMessengerCreateInfo = {};
hdDebugMessengerCreateInfo.name = "generalDebugServer";
local hdDebugMessenger = hdObject:hdCreateDebugMessenger(hdDebugMessengerCreateInfo);

--// Create global Heimdall hdInstance
local hdInstanceCreateInfo : hdTypes.hdInstanceCreateInfo = {};
hdInstanceCreateInfo.debugMessenger = hdDebugMessenger;
hdInstanceCreateInfo.launchToken = launchToken;
local hdInstance = hdObject:hdCreateInstance(hdInstanceCreateInfo);

--// Output debug info
local hdLaunchToken = hdInstance:hdGetLaunchToken();
local hdVersion = hdLaunchToken:hdGetVersion();
print(`\nGAME VERSION: v{hdVersion.major}.{hdVersion.minor}.{hdVersion.patch}.{os.date("%d")}.{os.date("%m")}.{os.date("%y")}.{hdVersion.isRelease and "p" or "a"}`, `\nIS RELEASE?: {hdVersion.isRelease and "YES" or "NO"}\n-------------------------`);

--// Create Component Manager
local hdComponentManagerCreateInfo : hdTypes.hdComponentManagerCreateInfo = {
	debugMessenger = hdDebugMessenger;
}
local hdResult, hdComponentManager = hdInstance:hdCreateComponentManager(hdComponentManagerCreateInfo);
if not hdResult.Success then
	error("failed to create component manager!");
	return;
end

hdInstance:hdSetComponentManager(hdComponentManager);

--// Create hdServiceManager
local hdServiceManagerCreateInfo : hdTypes.hdServiceManagerCreateInfo = {
	services = ServerStorage.Modules.Services;
	debugMessenger = hdDebugMessenger;
};
local hdResult, hdServiceManager = hdInstance:hdCreateServiceManager(hdServiceManagerCreateInfo);
if hdResult.ProtectedCallResult ~= hdEnums.hdProtectedCallResults.Passed.Value then
	error("failed to create service manager!");
	return;
end

--// Compile hdServices
local hdCompileServicesInfo : hdTypes.hdCompileServicesInfo = {
	--async = true;
};
local hdResult = hdServiceManager:hdCompileServices(hdCompileServicesInfo);
if hdResult.ProtectedCallResult ~= hdEnums.hdProtectedCallResults.Passed.Value then
	error("failed to compile services!");
	return;
end

--// Create hdCommandChain
local hdCommandChainCreateInfo : hdTypes.hdCommandChainCreateInfo = {
	commandInfo = {
		name = "commands";
		commandInvocationType = "HD_COMMAND_INVOC_TYPE_MIXED";
		commandSafetyLevel = "HD_CMD_SAFETY_LEVEL_HIGH";
		commands = {
			"HD_COMP";
			"HD_BOOT";
			"HD_STRT";
		};
	};
	commandedStructs = hdServiceManager:hdGetServices();
	debugMessenger = hdDebugMessenger;
};
local hdResult, hdCommandChain = hdServiceManager:hdCreateCommandChain(hdCommandChainCreateInfo);
if hdResult.ProtectedCallResult ~= hdEnums.hdProtectedCallResults.Passed.Value then
	error("failed to create command chain!");
	return;
end

local hdFenceCreateInfo : hdTypes.hdFenceCreateInfo = {
	fenceInitialState = "HD_FENCE_UNSIGNALED";
};
local sync = hdFence.new(hdFenceCreateInfo);

--// Invoke hdCommandChain
local hdResult = hdServiceManager:hdInvokeCommandChain(hdCommandChain, sync);
if hdResult.ProtectedCallResult ~= hdEnums.hdProtectedCallResults.Passed.Value then
	error("failed to invoke command chain!");
	return;
end

sync:hdWaitForFence();

print("Successfully initialized Heimdall.");
local function addPlayer(player)
	local hdCommandInfo : hdTypes.hdCommandInfo = {
		name = "PlayerAddedCommand";
		commandInvocationType = "HD_CMD_INVOC_TYPE_ASYNC";
		commandSafetyLevel = "HD_CMD_SAFETY_LEVEL_HIGH";
		commands = {
			"HD_ADD_PLR";
		};
	};

	local hdResult = hdCommandChain:hdSetCommandInfo(hdCommandInfo);
	if not hdResult.Success then
		error("error while configuring command chain for adding player!");
	end

	hdServiceManager:hdInvokeCommandChain(hdCommandChain, nil, player);
end
for i, v in Players:GetPlayers() do
	task.spawn(addPlayer, v);
end
Players.PlayerAdded:Connect(addPlayer)