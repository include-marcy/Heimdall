-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hd = script.Parent.Parent;
local hdLib = hd.lib;
local hdClasses = hd.classes;

local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);
local hdUtils = require(hdLib.hdUtils);

local hdProtectedCallResultEmitter = require(hdClasses.hdProtectedCallResultEmitter);
local hdDebugMessenger = require(hdClasses.hdDebugMessenger);
local hdFence = require(hdClasses.hdFence);
local hdService = require(hdClasses.hdService);
local hdCommandChain = require(hdClasses.hdCommandChain);

--// Class Declaration
local hdServiceManager = {
	prototype = {};	
};
hdServiceManager.__index = hdServiceManager;

export type hdServiceManager = typeof(setmetatable({} :: {
	services : {[string] : hdService.hdService};
	servicesRoot : Folder;
	debugMessenger : hdDebugMessenger.hdDebugMessenger;
	protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter;
}, {} :: typeof(hdServiceManager)));

--[=[
	@class hdServiceManager
	Creates an hdServiceManager, the main housing of a Heimdall hdInstance for hdServices.

	:::info
	An hdServiceManager is fairly useless without the help of an hdCommandChain, which allows you to execute commands with
	varying degrees of properties on all or some services.
	:::

	@param hdServiceManagerCreateInfo;
	@return hdServiceManager;
]=]
function hdServiceManager.new(hdServiceManagerCreateInfo : hdTypes.hdServiceManagerCreateInfo) : hdServiceManager
	local serviceManager = setmetatable({
		services = {};
		servicesRoot = hdServiceManagerCreateInfo.services;
		debugMessenger = hdServiceManagerCreateInfo.debugMessenger;
	}, hdServiceManager);

	local hdProtectedCallResultEmitterCreateInfo : hdTypes.hdProtectedCallEmitterCreateInfo = {};
	serviceManager.protectedCaller = hdProtectedCallResultEmitter.new(hdProtectedCallResultEmitterCreateInfo);

	return serviceManager;
end

--[=[
	@class hdServiceManager
	Makes a protected call to the specified function with the specified arguments.
	Returns a protected call result and the result of the protected call.

	@param function name;
	@param ...
	@return hdProtectedCallResult;
]=]
function hdServiceManager.prototype._callInternal(serviceManager, f, ...) : (hdTypes.hdProtectedCallResult, ...any)
	local debugMessenger : hdDebugMessenger.hdDebugMessenger = serviceManager.debugMessenger;
	local protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter = serviceManager.protectedCaller;

	return debugMessenger:catch(f, protectedCaller:getProtectedCallResult(serviceManager.prototype[f], serviceManager, ...));
end

function hdServiceManager:hdCreateCommandChain(hdCommandChainCreateInfo : hdTypes.hdCommandChainCreateInfo) : (hdTypes.hdProtectedCallResult, hdCommandChain.hdCommandChain)
	local serviceManager : hdServiceManager = self;

	local hdResult, commandChain = serviceManager.prototype._callInternal(serviceManager, "_createCommandChainInternal", hdCommandChainCreateInfo);

	return hdResult, commandChain :: hdCommandChain.hdCommandChain;
end

function hdServiceManager.prototype:_createCommandChainInternal(hdCommandChainCreateInfo : hdTypes.hdCommandChainCreateInfo) : hdCommandChain.hdCommandChain
	local commandChain = hdCommandChain.new(hdCommandChainCreateInfo);

	return commandChain
end

--[=[
	@class hdServiceManager
	Invokes the given hdCommandChain, allowing you to execute a callback in varying ways on every or some loaded service(s) on this hdServiceManager.

	@param hdCommandChain;
	@return hdProtectedCallResult;
]=]
function hdServiceManager:hdInvokeCommandChain(commandChain : hdCommandChain.hdCommandChain, synchronization : hdFence.hdFence?, ...) : hdTypes.hdProtectedCallResult
	local serviceManager : hdServiceManager = self;

	return serviceManager.prototype._callInternal(serviceManager, "_invokeCommandChainInternal", commandChain, synchronization, ...);
end

function hdServiceManager.prototype:_invokeCommandChainInternal(commandChain : hdCommandChain.hdCommandChain, synchronization : hdFence.hdFence?, ...)
	local hdResult = commandChain:hdRunCommandChain(synchronization, ...);
	if hdResult.ProtectedCallResult ~= hdEnums.hdProtectedCallResults.Passed.Value then
		error("failed to run command chain!");
		return;
	end
end

--[=[
	@class hdServiceManager
	Compiles the internal services of this hdServiceManager. Run this function once at runtime to create a cache of services.
	This is required for the hdServiceManager to function properly.

	@param hdCompileServicesInfo;
	@return hdProtectedCallResult;
]=]
function hdServiceManager:hdCompileServices(hdCompileServicesInfo : hdTypes.hdCompileServicesInfo) : hdTypes.hdProtectedCallResult
	local serviceManager : hdServiceManager = self;

	return serviceManager.prototype._callInternal(serviceManager, "_compileServicesInternal", hdCompileServicesInfo);
end

function hdServiceManager.prototype:_compileServicesInternal(hdCompileServicesInfo : hdTypes.hdCompileServicesInfo)
	local serviceManager : hdServiceManager = self;
	local servicesRoot = serviceManager.servicesRoot;
	local fences = {};

	for _, serviceModuleScript in servicesRoot:GetChildren() do
		--// Create synchronization objects
		local hdFenceCreateInfo : hdTypes.hdFenceCreateInfo = {
			fenceInitialState = "HD_FENCE_UNSIGNALED";
		};
		local fence = hdFence.new(hdFenceCreateInfo);
		table.insert(fences, fence);

		--// Call compilation function on each service, passing in the appropriate synchronization object so that once it has finished compiling all services
		--// we can continue running code. (This way, each service will require at the same time but we won't initialize a command chain before they're all done);
		task.spawn(function()
			local protectedCallResult : hdTypes.hdProtectedCallResult = serviceManager.prototype._callInternal(serviceManager, "_compileServiceInternal", serviceModuleScript, fence);
			if not protectedCallResult.Success then
				warn("error while compiling " .. serviceModuleScript.Name .. "\n :: debug prompt thrown ::");
			end
		end)
	end

	hdUtils:hdWaitForFences(fences, hdCompileServicesInfo.timeOut);
end

function hdServiceManager:hdRegisterVirtualService(service : hdService.hdService) : hdTypes.hdProtectedCallResult
	local serviceManager : hdServiceManager = self;

	return serviceManager.prototype._callInternal(serviceManager, "_registerVirtualServiceInternal", service);
end

function hdServiceManager.prototype:_registerVirtualServiceInternal(service : hdService.hdService)
	local serviceManager : hdServiceManager = self;
	local services = serviceManager:hdGetServices();

	services[service.name] = service;
end

function hdServiceManager.prototype:_compileServiceInternal(serviceModuleScript : any, fence : hdFence.hdFence) : (hdTypes.hdProtectedCallResult, hdService.hdService?)
	local serviceManager : hdServiceManager = self;
	local services = serviceManager:hdGetServices();
	local serviceSource = require(serviceModuleScript) :: hdService.hdService?;

	if serviceSource == nil then
		local failure : hdTypes.hdFailureCreateInfo = {};
		failure.errorString = "service null value";
		return serviceManager.protectedCaller.prototype._emitFailure(serviceManager.protectedCaller, failure)
	end

	if not serviceSource.IsService then
		local failure : hdTypes.hdFailureCreateInfo = {};
		failure.errorString = `service {serviceModuleScript.Name} was not a service`;

		return serviceManager.protectedCaller.prototype._emitFailure(serviceManager.protectedCaller, failure);
	end

	services[serviceSource.name] = serviceSource;

	fence:hdSignalFence();

	local success : hdTypes.hdSuccessCreateInfo = {};
	return serviceManager.protectedCaller:_emitSuccess(success), serviceSource;
end

--[=[
	@class hdServiceManager
	Returns a list of compiled services on this hdServiceManager

	@return <T>hdServices<>;
]=]
function hdServiceManager:hdGetServices() : {[string] : hdService.hdService}
	local serviceManager : hdServiceManager = self;

	return serviceManager.services;
end

function hdServiceManager:hdGetService(serviceName : string, timeOut : number?) : hdService.hdService
	local serviceManager : hdServiceManager = self;
	local _, service = serviceManager.prototype._callInternal(serviceManager, "_getServiceInternal", serviceName, timeOut);

	return service;
end

function hdServiceManager.prototype:_getServiceInternal(serviceName : string, timeOut : number) : hdService.hdService
	local serviceManager : hdServiceManager = self;
	local hdServices = serviceManager:hdGetServices()

	if timeOut and not hdServices[serviceName] then
		local startTime = os.clock();
		repeat
			task.wait();
		until (os.clock() - startTime) >= timeOut or hdServices[serviceName];
	end

	return hdServices[serviceName];
end

return hdServiceManager;