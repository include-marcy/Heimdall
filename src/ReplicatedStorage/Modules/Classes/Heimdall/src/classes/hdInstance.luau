-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdLib = script.Parent.Parent.lib;
local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);

local hdClasses = script.Parent;
local hdProtectedCallResultEmitter = require(hdClasses.hdProtectedCallResultEmitter);
local hdDebugMessenger = require(hdClasses.hdDebugMessenger);
local hdClient = require(hdClasses.hdClient);
local hdLaunchToken = require(hdClasses.hdLaunchToken);

local hdScene = require(hdClasses.hdScene);
local hdSceneWarper = require(hdClasses.hdSceneWarper);
local hdSceneParticipant = require(hdClasses.hdSceneParticipant);
local hdSceneHandle = require(hdClasses.hdSceneHandle);

local hdServiceManager = require(hdClasses.hdServiceManager);
local hdService = require(hdClasses.hdService);
local hdCompiledService = require(hdClasses.hdCompiledService);
local hdParallelService = require(hdClasses.hdParallelService);
local hdActor = require(hdClasses.hdActor);

local hdCoreModule = require(hdClasses.hdCoreModule);

local hdComponentManager = require(hdClasses.hdComponentManager);
local hdEntity = require(hdClasses.hdEntity);

--// Class Declaration
local hdInstance = {
	prototype = {};
};
hdInstance.__index = hdInstance;

export type hdInstance = typeof(setmetatable({} :: {
	debugMessenger : hdDebugMessenger.hdDebugMessenger;
	launchToken : hdLaunchToken.hdLaunchToken;
	protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter;
	serviceManager : hdServiceManager.hdServiceManager?;
	componentManager : hdComponentManager.hdComponentManager?;
	entities : {[string] : hdEntity.hdEntity};
}, {} :: typeof(hdInstance)));

--[=[
	@class hdInstance
	Creates a new hdInstance object with the specified hdInstanceCreateInfo as the singular argument.
	Accepts a debug messenger that will output Heimdall's errors

	:::info
	This function also generated the hdProtectedCallResultEmitter for the hdInstance behind the scenes.
	:::

	@param hdInstanceCreateInfo;
	@return hdInstance;
]=]
function hdInstance.new(hdInstanceCreateInfo : hdTypes.hdInstanceCreateInfo) : hdInstance
	local debugMessenger = hdInstanceCreateInfo.debugMessenger;
	local instance = setmetatable({}, hdInstance);

	instance.debugMessenger = debugMessenger;
	instance.launchToken = hdInstanceCreateInfo.launchToken;
	instance.entities = {};

	local hdProtectedCallResultEmitterCreateInfo : hdTypes.hdProtectedCallEmitterCreateInfo = {};
	instance.protectedCaller = hdProtectedCallResultEmitter.new(hdProtectedCallResultEmitterCreateInfo);

	return instance;
end

--[=[
	@class hdInstance
	Calls a protected call to the specified function with the specified arguments.
	Returns a protected call result and the result of the protected call.

	@param function name;
	@param ...
	@return hdProtectedCallResult;
]=]
function hdInstance.prototype._callInternal<a...>(instance : hdInstance, f, ...) : (hdTypes.hdProtectedCallResult, a...)
	local debugMessenger : hdDebugMessenger.hdDebugMessenger = instance.debugMessenger;
	local protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter = instance.protectedCaller;

	return debugMessenger:catch(f, protectedCaller:getProtectedCallResult(instance.prototype[f], instance, ...));
end

--[=[
	@class hdInstance
	Returns the hdLaunchToken associated with this hdInstance.

	@return hdLaunchToken;
]=]
function hdInstance:hdGetLaunchToken() : hdLaunchToken.hdLaunchToken
	local instance : hdInstance = self;

	return instance.launchToken;
end

--[=[
	@class hdInstance
	Creates a new hdServiceManager, a type of bootstrap class that will initialize all the services your game (or this hdInstance) manages

	@param hdServiceManagerCreateInfo;
	@return hdServiceManager;
]=]
function hdInstance:hdCreateServiceManager(hdServiceManagerCreateInfo : hdTypes.hdServiceManagerCreateInfo) : (hdTypes.hdProtectedCallResult, hdServiceManager.hdServiceManager)
	local instance : hdInstance = self;
	local hdPassResult, serviceManager = instance.prototype._callInternal(instance, "_createServiceManagerInternal", hdServiceManagerCreateInfo);

	return hdPassResult, serviceManager;
end

function hdInstance.prototype:_createServiceManagerInternal(hdServiceManagerCreateInfo : hdTypes.hdServiceManagerCreateInfo) : (hdServiceManager.hdServiceManager)
	local serviceManager = hdServiceManager.new(hdServiceManagerCreateInfo);

	local instance : hdInstance = self;
	instance:hdSetServiceManager(serviceManager);

	return serviceManager;
end

--[=[
	@class hdInstance
	Gets this hdInstance's internal hdServiceManager, a singleton class used behind the scenes to handle hdService operations.

	@return hdServiceManager;
]=]
function hdInstance:hdGetServiceManager() : hdServiceManager.hdServiceManager?
	local instance : hdInstance = self;
	return instance.serviceManager
end

--[=[
	@class hdInstance
	Sets this hdInstance's internal hdServiceManager, a singleton class used behind the scenes to handle hdService operations.

	@param hdServiceManager;
]=]
function hdInstance:hdSetServiceManager(serviceManager : hdServiceManager.hdServiceManager)
	local instance : hdInstance = self;
	instance.serviceManager = serviceManager;
end

--[=[
	@class hdInstance
	Returns a registered hdService with name serviceName, optional timeout to allow for cleaner boiler plate.

	@param serviceName;
	@param timeout;
	@return hdService;
]=]
function hdInstance:hdGetService(serviceName : string, timeout : number?) : hdService.hdService?
	local instance : hdInstance = self;
	local serviceManager = instance:hdGetServiceManager();

	if not serviceManager then
		return;
	end

	return serviceManager:hdGetService(serviceName, timeout);
end

--[=[
	@class hdInstance
	Creates a new hdService, a monobehavior which is designed to split up your game's behaviors into a variety of dedicated services.

	@param hdServiceCreateInfo;
	@return hdService;
]=]
function hdInstance:hdCreateService(hdServiceCreateInfo : hdTypes.hdServiceCreateInfo) : (hdTypes.hdProtectedCallResult, hdService.hdService)
	local instance : hdInstance = self;
	return instance.prototype._callInternal(instance, "_createServiceInternal", hdServiceCreateInfo);
end

function hdInstance.prototype:_createServiceInternal(hdServiceCreateInfo : hdTypes.hdServiceCreateInfo) : (hdService.hdService?)
	local instance : hdInstance = self;
	local serviceManager = instance:hdGetServiceManager();
	if not serviceManager then
		error(hdEnums.hdFailureTypes.hdServiceFailure);
		return;
	end

	if instance:hdGetService(hdServiceCreateInfo.name) then
		warn(hdServiceCreateInfo.name, " is a duplicated service! either use a different namespaced hdInstance or rename the service.")
		error(hdEnums.hdFailureTypes.hdDuplicateServiceFailure);
		return;
	end

	local service = hdService.new(hdServiceCreateInfo);

	if hdServiceCreateInfo.isVirtual then
		local hdResult = serviceManager:hdRegisterVirtualService(service);
		if not hdResult.Success then
			warn("Failed to register virtual service! :: ", service.name);
		end
	end

	return service;
end

--[=[
	@class hdInstance
	Creates a new hdCompiledService, a monobehavior which is dedicated to creating stacks of data accessed by other services.

	:::info
	It is recommended to use an hdCompiledService if you need to access large arrays of data prior to the Boot call on hdService lifetimes.
	:::

	@param hdCompiledServiceCreateInfo;
	@return hdCompiledService;
]=]
function hdInstance:hdCreateCompiledService(hdCompiledServiceCreateInfo : hdTypes.hdCompiledServiceCreateInfo) : (hdTypes.hdProtectedCallResult, hdCompiledService.hdCompiledService)
	local instance : hdInstance = self;
	local hdPassResult, service = instance.prototype._callInternal(instance, "_createCompiledServiceInternal", hdCompiledServiceCreateInfo);

	return hdPassResult, service;
end

function hdInstance.prototype:_createCompiledServiceInternal(hdCompiledServiceCreateInfo : hdTypes.hdCompiledServiceCreateInfo) : (hdCompiledService.hdCompiledService)
	local service = hdCompiledService.new(hdCompiledServiceCreateInfo);

	return service;
end

--[=[
	@class hdInstance
	Creates a new hdParallelService, a monobehavior which is dedicated to making it easier to create new Parallel Luau utilizations.

	@param hdParallelServiceCreateInfo;
	@return hdParallelService;
]=]
function hdInstance:hdCreateParallelService(hdParallelServiceCreateInfo : hdTypes.hdParallelServiceCreateInfo) : (hdTypes.hdProtectedCallResult, hdParallelService.hdParallelService)
	local instance : hdInstance = self;

	local hdPassResult, service = instance.prototype._callInternal(instance, "_createParallelServiceInternal", hdParallelServiceCreateInfo);

	return hdPassResult, service;
end

function hdInstance.prototype:_createParallelServiceInternal(hdParallelServiceCreateInfo : hdTypes.hdParallelServiceCreateInfo) : (hdParallelService.hdParallelService)
	local instance : hdInstance = self;
	local serviceManager = instance:hdGetServiceManager();
	if not serviceManager then
		error(hdEnums.hdFailureTypes.hdServiceFailure);
		return;
	end

	if instance:hdGetService(hdParallelServiceCreateInfo.name) then
		warn(hdParallelServiceCreateInfo.name, " is a duplicated service! either use a different namespaced hdInstance or rename the service.")
		error(hdEnums.hdFailureTypes.hdDuplicateServiceFailure);
		return;
	end

	local service = hdParallelService.new(hdParallelServiceCreateInfo);

	if hdParallelServiceCreateInfo.isVirtual then
		serviceManager.prototype._callInternal(serviceManager, "_registerVirtualServiceInternal", hdParallelService);
	end

	return service;
end

function hdInstance:hdCreateActor(hdActorCreateInfo : hdTypes.hdActorCreateInfo) : (hdActor.hdActor, Actor)
	local instance : hdInstance = self;
	hdActorCreateInfo.hdInstance = instance;
	local actor, hdParallelActor : Actor = hdActor.createActor(hdActorCreateInfo);

	return actor :: hdActor.hdActor, hdParallelActor;
end

function hdInstance:hdCreateCoreModuleManager(_ : hdTypes.hdCoreModuleManagerCreateInfo) : (hdTypes.hdProtectedCallResult)

end

function hdInstance:hdCreateCoreModule(hdCoreModuleCreateInfo : hdTypes.hdCoreModuleCreateInfo) : (hdTypes.hdProtectedCallResult, hdCoreModule.hdCoreModule)
	local instance : hdInstance = self;
	local hdPassResult, coreModule = instance.prototype._callInternal(instance, "_createCoreModuleInternal", hdCoreModuleCreateInfo);

	return hdPassResult, coreModule;
end

function hdInstance.prototype:_createCoreModuleInternal(hdCoreModuleCreateInfo : hdTypes.hdCoreModuleCreateInfo) : hdCoreModule.hdCoreModule
	local coreModule = hdCoreModule.new(hdCoreModuleCreateInfo);

	return coreModule;
end

--[=[
	@class hdInstance
	Creates a new hdComponentManager, a helper object designed for registering the "ideal" or "default" forms of known components.

	@param hdComponentManagerCreateInfo;
	@return hdComponentManager;
]=]
function hdInstance:hdCreateComponentManager(hdComponentManagerCreateInfo : hdTypes.hdComponentManagerCreateInfo) : (hdTypes.hdProtectedCallResult, hdComponentManager.hdComponentManager)
	local instance : hdInstance = self;
	local hdPassResult, componentManager = instance.prototype._callInternal(instance, "_createComponentManagerInternal", hdComponentManagerCreateInfo);

	return hdPassResult, componentManager;
end

function hdInstance.prototype:_createComponentManagerInternal(hdComponentManagerCreateInfo : hdTypes.hdComponentManagerCreateInfo)
	local componentManager = hdComponentManager.new(hdComponentManagerCreateInfo);

	return componentManager;
end

function hdInstance:hdSetComponentManager(componentManager : hdComponentManager.hdComponentManager)
	local instance : hdInstance = self;

	instance.componentManager = componentManager;
end

function hdInstance:hdGetComponentManager() : hdComponentManager.hdComponentManager?
	local instance : hdInstance = self;

	return instance.componentManager;
end

function hdInstance:hdCreateEntity(hdEntityCreateInfo : hdTypes.hdEntityCreateInfo) : hdEntity.hdEntity?
	local instance : hdInstance = self;
	local entities = instance.entities;
	local name = hdEntityCreateInfo.name;

	if instance:hdGetEntity(name) then
		warn("Repeat entity identity with name: ", name);
		return;
	end

	local entity = hdEntity.new(hdEntityCreateInfo);
	entities[name] = entity;

	return entity;
end

function hdInstance:hdGetEntity(name : string) : hdEntity.hdEntity?
	local instance : hdInstance = self;
	local entities = instance.entities;

	return entities[name];
end

function hdInstance:hdRemoveEntity(name : string)
	local instance : hdInstance = self;
	local entities = instance.entities;

	local entity = entities[name];
	entities[name] = nil;

	if entity and entity.alive then
		entity:hdDestroy();
	end
end

--[=[
	@class hdInstance
	Instantiates an hdClient object, which provides client credentials for other Heimdall objects.

	:::info
	It is recommended to use the hdInstance to generate an hdClient, to ensure that errors are protected/handled by your preferred debug messenger.
	:::

	@param hdClientCreateInfo;
	@return (hdProtectedCallResult, hdClient);
]=]
function hdInstance:hdCreateClient(hdClientCreateInfo : hdTypes.hdClientCreateInfo) : (hdTypes.hdProtectedCallResult, hdClient.hdClient)
	local instance : hdInstance = self;
	local hdPassResult, client = instance.prototype._callInternal(instance, "_createClientInternal", hdClientCreateInfo);

	return hdPassResult, client;
end

function hdInstance.prototype:_createClientInternal(hdClientCreateInfo : hdTypes.hdClientCreateInfo) : hdClient.hdClient
	local client = hdClient.new(hdClientCreateInfo);

	return client;
end

--[=[
	@class hdInstance
	Instantiates an hdScene object, the main interface for Heimdall scene objects.

	:::info
	It is recommended to use the hdInstance to generate an hdScene, to ensure that errors are protected/handled by your preferred debug messenger.
	:::

	@param hdSceneCreateInfo;
	@return (hdProtectedCallResult, hdScene);
]=]
function hdInstance:hdCreateScene(hdSceneCreateInfo : hdTypes.hdSceneCreateInfo) : (hdTypes.hdProtectedCallResult, hdScene.hdScene)
	local instance : hdInstance = self;
	local hdPassResult : hdTypes.hdProtectedCallResult, scene = instance.prototype._callInternal(instance, "_createSceneInternal", hdSceneCreateInfo);

	return hdPassResult, scene;
end

function hdInstance.prototype:_createSceneInternal(hdSceneCreateInfo : hdTypes.hdSceneCreateInfo) : hdScene.hdScene
	local scene = hdScene.new(hdSceneCreateInfo);

	return scene;
end

function hdInstance:hdCreateSceneWarper(hdSceneWarperCreateInfo : hdTypes.hdSceneWarperCreateInfo) : (hdTypes.hdProtectedCallResult, hdSceneWarper.hdSceneWarper)
	local instance : hdInstance = self;
	local hdPassResult : hdTypes.hdProtectedCallResult, sceneWarper = instance.prototype._callInternal(instance, "_createSceneWarperInternal", hdSceneWarperCreateInfo);

	return hdPassResult, sceneWarper
end

function hdInstance.prototype:_createSceneWarperInternal(hdSceneWarperCreateInfo : hdTypes.hdSceneWarperCreateInfo) : hdSceneWarper.hdSceneWarper
	local sceneWarper = hdSceneWarper.new(hdSceneWarperCreateInfo);

	return sceneWarper;
end

--[=[
	@class hdInstance
	Instantiates an hdSceneParticipant object, which is used to create scene participants for hdScene objects.

	:::info
	It is recommended to use the hdInstance to generate an hdSceneParticipant, to ensure that errors are protected/handled by your preferred debug messenger.
	:::

	@param hdSceneParticipantCreateInfo;
	@return (hdProtectedCallResult, hdSceneParticipant);
]=]
function hdInstance:hdCreateSceneParticipant(hdSceneParticipantCreateInfo : hdTypes.hdSceneParticipantCreateInfo) : (hdTypes.hdProtectedCallResult, hdSceneParticipant.hdSceneParticipant)
	local instance : hdInstance = self;
	local hdPassResult : hdTypes.hdProtectedCallResult, sceneParticipant : hdSceneParticipant.hdSceneParticipant = instance.prototype._callInternal(instance, "_createSceneParticipantInternal", hdSceneParticipantCreateInfo);

	return hdPassResult, sceneParticipant;
end

function hdInstance.prototype:_createSceneParticipantInternal(hdSceneParticipantCreateInfo : hdTypes.hdSceneParticipantCreateInfo)
	return hdSceneParticipant.new(hdSceneParticipantCreateInfo);
end

--[=[
	@class hdInstance
	Instantiates an hdSceneHandle object, which are entry points for hdSceneParticipant objects

	:::info
	It is recommended to use the hdInstance to generate an hdSceneHandle, to ensure that errors are protected/handled by your preferred debug messenger.
	:::

	@param hdSceneHandleCreateInfo;
	@return (hdProtectedCallResult, hdSceneHandle);
]=]
function hdInstance:hdCreateSceneHandle(hdSceneHandleCreateInfo : hdTypes.hdSceneHandleCreateInfo) : (hdTypes.hdProtectedCallResult, hdSceneHandle.hdSceneHandle)
	local instance : hdInstance = self;
	local hdPassResult : hdTypes.hdProtectedCallResult, sceneHandle : hdSceneHandle.hdSceneHandle = instance.prototype._callInternal(instance, "_createSceneHandleInternal", hdSceneHandleCreateInfo);

	return hdPassResult :: hdTypes.hdProtectedCallResult, sceneHandle :: hdSceneHandle.hdSceneHandle;
end

function hdInstance.prototype:_createSceneHandleInternal(hdSceneHandleCreateInfo : hdTypes.hdSceneHandleCreateInfo) : hdSceneHandle.hdSceneHandle
	return hdSceneHandle.new(hdSceneHandleCreateInfo);
end

return hdInstance;