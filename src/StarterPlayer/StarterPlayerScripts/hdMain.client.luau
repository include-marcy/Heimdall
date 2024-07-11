--!strict
--!native
--!optimize 2

--// ROBLOX Services
local RunService = game:GetService("RunService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

--// Dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local hdLib = hd.src.lib;
local hdClasses = hd.src.classes;
local Heimdall = require(hd);
local hdTypes = require(hdLib.hdTypes);
local hdFence = require(hdClasses.hdFence);

--// Local variables
local Player = Players.LocalPlayer;

--// An overview of the Heimdall initialization process:
--[[
	1. create the hdObject instance.
	2. create the hdDebugMessenger, as required by various Heimdall objects.
	3. create the hdInstance, this will act as a singleton by which we bootstrap most of Heimdall.
	4. create the hdServiceManager and hdCommandChain, both of which allow us to act on game services and their lifetime functions.
	5. create the hdClient object, which gives us client credentials in Heimdall and informs Heimdall about your access.
	6. create the hdSceneParticipant object, which bridges the gap between our character and the hdScene.
	7. Heimdall is now prepared for game and scene management. You can now use Heimdall to generate a new hdScene and connect new hdSceneParticipant objects to it.
--]]

--// First create the hdObject, or Heimdall instance.
local hdObjectCreateInfo : hdTypes.hdObjectCreateInfo = {};
local hdObject : Heimdall.hdObject = Heimdall.new(hdObjectCreateInfo);

--// Next, create the Heimdall debug messenger, the class which will output helpful debug messages.
local hdDebugMessengerCreateInfo : hdTypes.hdDebugMessengerCreateInfo = {
	name = "generalDebug";
	middleware = function(f : string, hdResult : hdTypes.hdProtectedCallResult, ...) -- a callback that executes when any Heimdall safe function is invoked.
		--warn(f, hdResult, ...);
	end;
	onError = function(f : string, hdResult : hdTypes.hdProtectedCallResult) -- a callback that executes when a Heimdall failure is raised.
		warn(f);
	end;
};
local hdDebugMessenger = hdObject:hdCreateDebugMessenger(hdDebugMessengerCreateInfo);

--// Then, create the Heimdall base instance.
local hdInstanceCreateInfo : hdTypes.hdInstanceCreateInfo = {
	debugMessenger = hdDebugMessenger;
};
local hdInstance = hdObject:hdCreateInstance(hdInstanceCreateInfo);

--// The next step in the Heimdall initialization process is the hdServiceManager and all of its dependency services.
--// We create the hdServiceManager with the following commands:
local hdServiceManagerCreateInfo : hdTypes.hdServiceManagerCreateInfo = {
	services = ReplicatedStorage.Modules.Services;
	debugMessenger = hdDebugMessenger;
};
local hdResult, hdServiceManager = hdInstance:hdCreateServiceManager(hdServiceManagerCreateInfo);
if not hdResult.Success then
	error("failed to create service manager!");
	return;
end

--// After creating the hdServiceManager, we want to use it's hdCompileServices function to build our list of game services like so:
local hdCompileServicesInfo : hdTypes.hdCompileServicesInfo = {};
hdCompileServicesInfo.timeOut = 30;
local hdCompileServicesResult = hdServiceManager:hdCompileServices(hdCompileServicesInfo);

if not hdCompileServicesResult.Success then
	error("failed to compile services!");
	return;
end
--// As long as that has succeeded, we can move on safely.

--// After creating the hdServiceManager, we need an hdCommandChain which our hdServiceManager will use to execute commands to our hdServices.
--local userhdCommandChainFunctionMap : hdTypes.hdCommandChainFunctionMap = {
--	HD_BOOT = "BootUser";
--	HD_COMP = "CompileUser";
--	HD_STRT = "StartUser";
--}

local hdCommandChainCreateInfo : hdTypes.hdCommandChainCreateInfo = {
	commandedStructs = hdServiceManager:hdGetServices();
	commandDirection = "HD_COMMAND_DIRECTION_LOWEST_FIRST";
	commandInfo = {
		name = "Startup";
		commandSafetyLevel = "HD_CMD_SAFETY_LEVEL_HIGH";
		commandInvocationType = "HD_CMD_INVOC_TYPE_ASYNC";
		commands = {
			"HD_COMP"; -- 1st command to be issued is the HD_COMP command, which will tell services which have a :Compile() function to run it.
			"HD_BOOT"; -- 2nd command is HD_BOOT, similarly calls :Boot()
			"HD_STRT"; -- 3rd command is HD_STRT, similarly calls :Start()
		};
		-- The name of the hdCommands can all be configured by including your own hdCommandChainFunctionMap:
		--commandChainFunctionMap = userhdCommandChainFunctionMap;
		-- By default, the hdCommandChainCreateInfo fills this with a constant mapping though.
		-- Recommended best practice for mapping an existing command chain function map with your own commands and relative names is to
		-- extrapolate the current hdCommandChainFunctionMap with hdCommandChain:hdGetCommandChainFunctionMap() and use a utility map to reconcile
		-- the hdCommandChainFunctionMap with your own, so that unlisted commands don't get lost in the transfer.
	};
	debugMessenger = hdDebugMessenger;
};
local hdCreateCommandChainResult, hdCommandChain = hdServiceManager:hdCreateCommandChain(hdCommandChainCreateInfo);
if not hdCreateCommandChainResult.Success then
	error("failed to create command chain!");
	return;
end

--// Now that the hdServiceManager has been successfully initialized, we can invoke its command chain to boot all the game services!
--// The hdCommandChain allows us to overwrite arrays of instructions for the hdServiceManager, so we will re-use this hdCommandChain object later on when we
--// need to call more commands on all services at once.
local hdFenceCreateInfo : hdTypes.hdFenceCreateInfo = {
	fenceInitialState = "HD_FENCE_UNSIGNALED";
};
local synchronization : hdFence.hdFence = hdFence.new(hdFenceCreateInfo);

local hdInvokeCommandResult = hdServiceManager:hdInvokeCommandChain(hdCommandChain, synchronization);
if not hdInvokeCommandResult.Success then
	error("failed to boot services!");
	return;
end

--// This hdFence will not signal until the entire command chain has successfully ran all of its callbacks on all of the commandStructs specified.
--// In this case, it means once every service has completed :Compile(), :Boot(), and :Start() assuming it has that callback.
synchronization:hdWaitForFence();
synchronization:hdResetFence();

--// After booting the services using our command chain, we will then run the player added event for client-sided services.
--// Again, we must reconfigure the command chain and invoke it.
local hdAddPlayerCommandInfo : hdTypes.hdCommandInfo = {
	name = "PlayerAddedCommand";
	commandSafetyLevel = "HD_CMD_SAFETY_LEVEL_HIGH";
	commandInvocationType = "HD_COMMAND_INVOC_TYPE_MIXED";
	commands = {
		"HD_ADD_PLR";
	};
};
local hdSetAddPlayerCommandInfo = hdCommandChain:hdSetCommandInfo(hdAddPlayerCommandInfo);
if not hdSetAddPlayerCommandInfo.Success then
	error("error while configuring command chain for adding player!");
end

local hdAddPlayerCommandResult = hdServiceManager:hdInvokeCommandChain(hdCommandChain, synchronization, Player);
if not hdAddPlayerCommandResult.Success then
	error("failed to add player!");
end

--// We can reuse the prior hdFence to await all :PlayerAdded() callbacks to complete as well.
synchronization:hdWaitForFence();

local hdCharacterService = hdInstance:hdGetService("hdCharacterService", 15);

local function hdAddHdCharacter(hdCharacter)
	local hdAddHdCharacterCommandInfo : hdTypes.hdCommandInfo = {
		name = "hdAddCharacter";
		commandSafetyLevel = "HD_CMD_SAFETY_LEVEL_HIGH";
		commandInvocationType = "HD_COMMAND_INVOC_TYPE_MIXED";
		commands = {
			"HD_ADD_HD_CHAR";
		};
	};

	local hdAddHdCharacterResult = hdCommandChain:hdSetCommandInfo(hdAddHdCharacterCommandInfo);
	if not hdAddHdCharacterResult.Success then
		error("failed to reconfigure command chain!");
	end

	local hdResult = hdServiceManager:hdInvokeCommandChain(hdCommandChain, nil, hdCharacter);
	if not hdResult.Success then
		error("failed to add hd character!");
	end
end

local hdCharacter = hdCharacterService:hdGetCharacter(Players.LocalPlayer);
if hdCharacter then
	hdAddHdCharacter(hdCharacter);
end

hdCharacterService.hdCharacterAdded:Connect(hdAddHdCharacter);

--// Since we want to utilize hdService's Update function each frame, we can now rebind the hdCommandChain to run the HD_UPDT command.
local hdUpdateCommandInfo : hdTypes.hdCommandInfo = {
	name = "Update";
	commandSafetyLevel = "HD_CMD_SAFETY_LEVEL_MEDIUM";
	commandInvocationType = "HD_COMMAND_INVOC_TYPE_MIXED";
	commands = {
		"HD_UPDT";
	};
};
local hdUpdateCommandResult = hdCommandChain:hdSetCommandInfo(hdUpdateCommandInfo);
if not hdUpdateCommandResult.Success then
	error("failed to reconfigure command chain!");
	return;
end

RunService.Heartbeat:Connect(function(deltaTime : number)
	if hdCommandChain:hdGetCommandChainState() == "HD_COMMAND_CHAIN_BUSY" then
		return;
	end

	local hdResult = hdServiceManager:hdInvokeCommandChain(hdCommandChain, nil, deltaTime);
	if not hdResult.Success then
		error("failed to update services!");
		return;
	end
end)

--// Since we are on the client, we should create an hdClient to interact with an hdScene using player credentials.
--// Heimdall by default doesn't differentiate between a Character that is owned by a player versus one that is not.
--// But, sometimes implementations deal with players differently from things like NPCs. So, providing a player credential can be important.
local hdClient;
local hdClientCreateInfo : hdTypes.hdClientCreateInfo = {
	player = Player;
};
local hdCreateClientResult, hdClientResult = hdInstance:hdCreateClient(hdClientCreateInfo);
if not hdCreateClientResult.Success then
	error("failed to create client socket!");
	return;
end

--// The hdClient object can be referenced on both the client and the server, but it usually is only useful on the server.
--// hdClient objects will be used further on when creating hdSceneHandles and hdSceneParticipants, while specifically involving players.
hdClient = hdClientResult;