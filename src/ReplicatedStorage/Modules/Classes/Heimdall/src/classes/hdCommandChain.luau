-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdLib = script.Parent.Parent.lib;
local hdTypes = require(hdLib.hdTypes);
local hdUtils = require(hdLib.hdUtils);
local hdEnums = require(hdLib.hdEnums);

local hdClasses = script.Parent;
local hdProtectedCallResultEmitter = require(hdClasses.hdProtectedCallResultEmitter);
local hdDebugMessenger = require(hdClasses.hdDebugMessenger);
local hdFence = require(hdClasses.hdFence);

--// Constants
local HD_FUNCTIONS_COMMAND_MAP : hdTypes.hdCommandChainFunctionMap = {
	HD_BOOT = "Boot";
	HD_STRT = "Start";
	HD_COMP = "Compile";
	HD_UPDT = "Update";
	HD_ADD_CHR = "CharacterAdded";
	HD_ADD_PLR = "PlayerAdded";
	HD_ADD_HD_CHR = "hdCharacterAdded";
};

--// Class Declaration
local hdCommandChain = {
	prototype = {};
};
hdCommandChain.__index = hdCommandChain;

export type hdCommandChain = typeof(setmetatable({} :: {
	commandInfo : hdTypes.hdCommandInfo;
	commandedStructs : {any};
	commandDirection : hdTypes.hdCommandDirection;
	debugMessenger : hdDebugMessenger.hdDebugMessenger;
	commandChainState : hdTypes.hdCommandChainState;
	protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter;
}, {} :: typeof(hdCommandChain)));

--[=[
	Creates a hdCommandChain object, which can be used to execute commands on an hdServiceManager.
	
	:::info
	You can create 1 hdCommandChain at runtime and change out its internal command set to reuse the object and run different commands on all
	services at once.
	:::

	@param hdCommandChainCreateInfo;
	@return hdCommandChain;
]=]
function hdCommandChain.new(hdCommandChainCreateInfo : hdTypes.hdCommandChainCreateInfo) : hdCommandChain
	if not hdCommandChainCreateInfo.debugMessenger then
		error("command chain expects an hdDebugMessenger object in hdCommandChainCreateInfo!");
	end
	
	local commandedStructs = hdCommandChainCreateInfo.commandedStructs;
	local hdSortedStructs = {};

	for _, commandedStruct in commandedStructs do
		table.insert(hdSortedStructs, commandedStruct);
	end
	
	local hdProtectedCallResultEmitterCreateInfo : hdTypes.hdProtectedCallEmitterCreateInfo = {};
	local protectedCaller = hdProtectedCallResultEmitter.new(hdProtectedCallResultEmitterCreateInfo);
	local commandChainState : hdTypes.hdCommandChainState = "HD_COMMAND_CHAIN_FREE";
	local commandDirection : hdTypes.hdCommandDirection = hdCommandChainCreateInfo.commandDirection or "HD_COMMAND_DIRECTION_LOWEST_FIRST";

	local commandChain : hdCommandChain = setmetatable({
		commandInfo = hdCommandChainCreateInfo.commandInfo;
		commandedStructs = hdSortedStructs;
		commandDirection = commandDirection;
		debugMessenger = hdCommandChainCreateInfo.debugMessenger;
		commandChainState = commandChainState;
		protectedCaller = protectedCaller;
	}, hdCommandChain);
	
	commandChain:hdApplyCommandDirectionSorting()

	return commandChain :: hdCommandChain;
end

--[=[
	Calls a protected call to the specified function with the specified arguments.
	Returns a protected call result and the result of the protected call.

	@param function name;
	@param ...
	@return hdProtectedCallResult;
]=]
function hdCommandChain.prototype._callInternal<a...>(commandChain : hdCommandChain, f, ...) : (hdTypes.hdProtectedCallResult, a...)
	local debugMessenger : hdDebugMessenger.hdDebugMessenger = commandChain.debugMessenger;
	local protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter = commandChain.protectedCaller;

	return debugMessenger:catch(f, protectedCaller:getProtectedCallResult(commandChain.prototype[f], commandChain, ...));
end

function hdCommandChain:hdApplyCommandDirectionSorting()
	local hdCommandChain : hdCommandChain = self;
	local hdSortedStructs = hdCommandChain.commandedStructs;
	local commandDirection : hdTypes.hdCommandDirection = hdCommandChain.commandDirection;

	table.sort(hdSortedStructs, function(a : any, b : any)
		if not a.loadPriority or not b.loadPriority then
			return false
		end

		if commandDirection == "HD_COMMAND_DIRECTION_LOWEST_FIRST" then
			return a.loadPriority < b.loadPriority;
		elseif commandDirection == "HD_COMMAND_DIRECTION_HIGHEST_FIRST" then
			return a.loadPriority > b.loadPriority;
		else
			return a.loadPriority == b.loadPriority;
		end
	end);
end

function hdCommandChain:hdGetCommandChainState() : hdTypes.hdCommandChainState
	local hdCommandChain : hdCommandChain = self;
	
	return hdCommandChain.commandChainState;
end

function hdCommandChain:hdSetCommandChainState(hdCommandChainState : hdTypes.hdCommandChainState) : (hdTypes.hdProtectedCallResult)
	local hdCommandChain : hdCommandChain = self;
	
	return hdCommandChain.prototype._callInternal(hdCommandChain, "_setCommandChainStateInternal", hdCommandChainState);
end

function hdCommandChain.prototype:_setCommandChainStateInternal(hdCommandChainState : hdTypes.hdCommandChainState)
	local hdCommandChain : hdCommandChain = self;
	
	--if hdCommandChain:hdGetCommandChainState() == "HD_COMMAND_CHAIN_BUSY" then
	--	error(hdEnums.hdFailureTypes.hdCommandChainBusy);
	--	return;
	--end
	
	hdCommandChain.commandChainState = hdCommandChainState;
end

function hdCommandChain:hdGetCommandChainFunctionMap() : (hdTypes.hdProtectedCallResult, hdTypes.hdCommandChainFunctionMap)
	local hdCommandChain : hdCommandChain = self;
	
	local hdResult, hdCommandChainFunctionMap = hdCommandChain.prototype._callInternal(hdCommandChain, "_getCommandChainFunctionMap");
	
	return hdResult, hdCommandChainFunctionMap;
end

function hdCommandChain.prototype:_getCommandChainFunctionMap() : hdTypes.hdCommandChainFunctionMap?
	local hdCommandChain : hdCommandChain = self;
	
	return hdCommandChain.commandInfo.commandChainFunctionMap;
end

function hdCommandChain:hdSetCommandInfo(hdCommandInfo : hdTypes.hdCommandInfo) : (hdTypes.hdProtectedCallResult)
	local hdCommandChain : hdCommandChain = self;
	
	return hdCommandChain.prototype._callInternal(hdCommandChain, "_setCommandInfoInternal", hdCommandInfo);
end

function hdCommandChain.prototype:_setCommandInfoInternal(hdCommandInfo : hdTypes.hdCommandInfo)
	local hdCommandChain : hdCommandChain = self;
	
	hdCommandChain.commandInfo = hdCommandInfo;
end

function hdCommandChain:getCommandInvocationType() : hdTypes.hdCommandInvocationType
	local hdCommandChain : hdCommandChain = self;
	
	return hdCommandChain.commandInfo.commandInvocationType;
end

function hdCommandChain:hdSetCommandChainFunctionsMap(hdCommandChainFunctionMap : hdTypes.hdCommandChainFunctionMap) : hdTypes.hdProtectedCallResult
	local hdCommandChain : hdCommandChain = self;

	return hdCommandChain.prototype._callInternal(hdCommandChain, "_setCommandChainFunctionsMapInternal", hdCommandChainFunctionMap);
end

function hdCommandChain.prototype:_setCommandChainFunctionsMapInternal(hdCommandChainFunctionMap : hdTypes.hdCommandChainFunctionMap)
	local hdCommandChain : hdCommandChain = self;
	
	hdCommandChain.commandInfo.commandChainFunctionMap = hdCommandChainFunctionMap;
end

--[=[
	Runs the hdCommandChain as is with its currently set hdCommandInfo

	@param hdFence; -- an optional hdFence sync object that will signal when the command chain has completed running every command, regardless of invocation mode
	@param ...; -- arguments passed to the raw functions of each loaded module
	@return hdProtectedCallResult;
]=]
function hdCommandChain:hdRunCommandChain(fence : hdFence.hdFence?, ...) : hdTypes.hdProtectedCallResult
	local commandChain : hdCommandChain = self;

	return commandChain.prototype._callInternal(commandChain, "_runCommandChainInternal", fence, ...)
end

function hdCommandChain.prototype:_runCommandChainInternal(fence : hdFence.hdFence?, ...)
	local commandChain : hdCommandChain = self;

	if hdCommandChain:hdGetCommandChainState() == "HD_COMMAND_CHAIN_BUSY" then
		if fence then
			fence:hdSignalFence()
		end

		error(hdEnums.hdFailureTypes.hdCommandChainBusy);

		return;
	end

	--// print("attempting to run command chain, setting state to busy")
	local hdResult = commandChain:hdSetCommandChainState("HD_COMMAND_CHAIN_BUSY");
	if not hdResult.Success then
		error(hdEnums.hdFailureTypes.hdCommandChainStateSetFail);
		return;
	end

	local commandInfo = commandChain.commandInfo;
	local commandInvocationType : hdTypes.hdCommandInvocationType = commandInfo.commandInvocationType;
	local commandSafetyLevel : hdTypes.hdCommandSafetyLevel = commandInfo.commandSafetyLevel;
	local commands = commandInfo.commands

	for _, hdCommand : hdTypes.hdCommand in commands do
		local clock = os.clock();
		--// print("Running: ", hdCommand);
		commandChain.prototype._runCommand(commandChain, hdCommand, commandInvocationType, commandSafetyLevel, ...);
		--// print("Command ", hdCommand, " took ", os.clock() - clock, "s to run.")
	end

	--// print("finished running command chain, setting state to free")
	commandChain:hdSetCommandChainState("HD_COMMAND_CHAIN_FREE");

	if fence then
		-- warn("Command chain complete...")
		fence:hdSignalFence()
	end
end

function hdCommandChain.prototype:_runCommand(command : hdTypes.hdCommand, commandInvocationType : hdTypes.hdCommandInvocationType, commandSafetyLevel : hdTypes.hdCommandSafetyLevel, ...) : (hdTypes.hdProtectedCallResult)
	local commandChain : hdCommandChain = self;
	local hdFences : {hdFence.hdFence} = {};

	for _, hdService in commandChain.commandedStructs do
		local hdServiceFunction = commandChain.prototype._getServiceFunction(commandChain, hdService, command, commandSafetyLevel, ...);
		if not hdServiceFunction then
			continue
		end

		if commandInvocationType == "HD_COMMAND_INVOC_TYPE_MIXED" or commandInvocationType == "HD_CMD_INVOC_TYPE_ASYNC" then
			local fence : hdFence.hdFence
			if commandInvocationType == "HD_COMMAND_INVOC_TYPE_MIXED" then
				local hdFenceCreateInfo : hdTypes.hdFenceCreateInfo = {
					fenceInitialState = "HD_FENCE_UNSIGNALED"
				};
				fence = hdFence.new(hdFenceCreateInfo);

				table.insert(hdFences, fence);
			end
			task.spawn(hdServiceFunction, fence);
		elseif commandInvocationType == "HD_CMD_INVOC_TYPE_SYNC" then
			hdServiceFunction();
		end
	end

	if commandInvocationType == "HD_COMMAND_INVOC_TYPE_MIXED" then
		hdUtils:hdWaitForFences(hdFences);
	end

	local hdSuccessCreateInfo : hdTypes.hdSuccessCreateInfo = {};
	return commandChain.protectedCaller:_emitSuccess(hdSuccessCreateInfo);
end

function hdCommandChain.prototype:_getFunctionForCommand(command : hdTypes.hdCommand)
	local hdCommandChain : hdCommandChain = self;
	local commandInfo = hdCommandChain.commandInfo;
	local commandChainFunctionMap : hdTypes.hdCommandChainFunctionMap = commandInfo.commandChainFunctionMap or HD_FUNCTIONS_COMMAND_MAP;

	return commandChainFunctionMap[command];
end

function hdCommandChain.prototype:_getServiceFunction(hdService : hdService.hdService, command : hdTypes.hdCommand, commandSafetyLevel : hdTypes.hdCommandSafetyLevel, ...) : ((hdFence.hdFence?) -> (any))?
	local commandChain : hdCommandChain = self;
	local hdServiceFunctionName = self.prototype._getFunctionForCommand(commandChain, command);
	local hdServiceFunction = hdService[hdServiceFunctionName];

	if not hdServiceFunction then
		return nil;
	end

	local hdArgs = {...};

	return function(hdFence : hdFence.hdFence?)
		local debug_profile_string = hdService.name .. hdServiceFunctionName;
		--debug.profilebegin(debug_profile_string);

		local Result;
		if commandSafetyLevel == "HD_CMD_SAFETY_LEVEL_HIGH" then
			Result = commandChain.debugMessenger:catch(hdServiceFunctionName, commandChain.protectedCaller:getProtectedCallResult(hdServiceFunction, hdService, table.unpack(hdArgs)));
		elseif commandSafetyLevel == "HD_CMD_SAFETY_LEVEL_MEDIUM" then
			local Pass, Fail = pcall(function()
				hdServiceFunction(hdService, table.unpack(hdArgs));
			end);
			if not Pass then
				Result = Fail;
				warn(Fail);
			end
		elseif commandSafetyLevel == "HD_CMD_SAFETY_LEVEL_NONE" then
			local Pass, Fail = pcall(function()
				hdServiceFunction(hdService, table.unpack(hdArgs));
			end)

			if not Pass then
				--debug.profileend();

				if hdFence then
					hdFence:hdSignalFence();
				end

				error(Fail);

				return Fail
			end
		end

		--debug.profileend();

		if hdFence then
			hdFence:hdSignalFence();
		end
		
		return Result;
	end
end

return hdCommandChain;