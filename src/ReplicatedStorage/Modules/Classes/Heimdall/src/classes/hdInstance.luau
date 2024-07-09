--!strict
--!native
--!optimize 2

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

local hdCoreModuleManager = require(hdClasses.hdCoreModuleManager);
local hdCoreModule = require(hdClasses.hdCoreModule);

local hdComponentManager = require(hdClasses.hdComponentManager);
local hdEntity = require(hdClasses.hdEntity);

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

	instance.debugMessenger = hdInstanceCreateInfo.debugMessenger;
	instance.launchToken = hdInstanceCreateInfo.launchToken;
	instance.entities = {};

	local hdProtectedCallResultEmitterCreateInfo : hdTypes.hdProtectedCallEmitterCreateInfo = {};
	instance.protectedCaller = hdProtectedCallResultEmitter.new(hdProtectedCallResultEmitterCreateInfo);

	return instance;
end

--[=[
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

function hdInstance:hdGetLaunchToken() : hdLaunchToken.hdLaunchToken
	local instance : hdInstance = self;
	
	return instance.launchToken;
end

--[=[
	Creates a new hdServiceManager, a type of bootstrap class that will initialize all the services your game (or this hdInstance) manages
	
	@param hdServiceManagerCreateInfo;
	@return hdServiceManager;
]=]
function hdInstance:hdCreateServiceManager(hdServiceManagerCreateInfo : hdTypes.hdServiceManagerCreateInfo) : (hdTypes.hdProtectedCallResult, hdServiceManager.hdServiceManager)
	local instance : hdInstance = self;
	local hdPassResult, hdServiceManager = instance.prototype._callInternal(instance, "_createServiceManagerInternal", hdServiceManagerCreateInfo);

	return hdPassResult, hdServiceManager;
end

function hdInstance.prototype:_createServiceManagerInternal(hdServiceManagerCreateInfo : hdTypes.hdServiceManagerCreateInfo) : (hdServiceManager.hdServiceManager)
	local hdServiceManager = hdServiceManager.new(hdServiceManagerCreateInfo);

	local instance : hdInstance = self;
	instance:hdSetServiceManager(hdServiceManager);

	return hdServiceManager;
end

--[=[
	Gets this hdInstance's internal hdServiceManager, a singleton class used behind the scenes to handle hdService operations.
	
	@return hdServiceManager;
]=]
function hdInstance:hdGetServiceManager() : hdServiceManager.hdServiceManager?
	local instance : hdInstance = self;
	return instance.serviceManager
end

--[=[
	Sets this hdInstance's internal hdServiceManager, a singleton class used behind the scenes to handle hdService operations.
	
	@param hdServiceManager;
]=]
function hdInstance:hdSetServiceManager(serviceManager : hdServiceManager.hdServiceManager)
	local instance : hdInstance = self;
	instance.serviceManager = serviceManager;
end

--[=[
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
	Creates a new hdService, a monobehavior which is designed to split up your game's behaviors into a variety of dedicated services.
	
	@param hdServiceCreateInfo;
	@return hdService;
]=]
function hdInstance:hdCreateService(hdServiceCreateInfo : hdTypes.hdServiceCreateInfo) : (hdTypes.hdProtectedCallResult, hdService.hdService)
	local instance : hdInstance = self;
	local hdPassResult, hdService = instance.prototype._callInternal(instance, "_createServiceInternal", hdServiceCreateInfo);
	
	return hdPassResult, hdService;
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
	
	local hdService = hdService.new(hdServiceCreateInfo);	
	
	if hdServiceCreateInfo.isVirtual then
		--local protectedCallResult : hdTypes.hdProtectedCallResult = serviceManager:_callInternal("_registerVirtualServiceInternal", hdService);
		local hdResult = serviceManager:hdRegisterVirtualService(hdService);
		if not hdResult.Success then
			warn("Failed to register virtual service! :: ", hdService.name);
		end
	end
	
	return hdService;
end

--[=[
	Creates a new hdCompiledService, a monobehavior which is dedicated to creating stacks of data accessed by other services.
	
	:::info
	It is recommended to use an hdCompiledService if you need to access large arrays of data prior to the Boot call on hdService lifetimes.
	:::
	
	@param hdCompiledServiceCreateInfo;
	@return hdCompiledService;
]=]
function hdInstance:hdCreateCompiledService(hdCompiledServiceCreateInfo : hdTypes.hdCompiledServiceCreateInfo) : (hdTypes.hdProtectedCallResult, hdCompiledService.hdCompiledService)
	local instance : hdInstance = self;
	local hdPassResult, hdService = instance.prototype._callInternal(instance, "_createCompiledServiceInternal", hdCompiledServiceCreateInfo);

	return hdPassResult, hdService;
end

function hdInstance.prototype:_createCompiledServiceInternal(hdCompiledServiceCreateInfo : hdTypes.hdCompiledServiceCreateInfo) : (hdCompiledService.hdCompiledService)
	local hdCompiledService = hdCompiledService.new(hdCompiledServiceCreateInfo);

	return hdCompiledService;
end

--[=[
	Creates a new hdParallelService, a monobehavior which is dedicated to making it easier to create new Parallel Luau utilizations.
	
	:::info
	
	:::
	
	@param hdParallelServiceCreateInfo;
	@return hdParallelService;
]=]
function hdInstance:hdCreateParallelService(hdParallelServiceCreateInfo : hdTypes.hdParallelServiceCreateInfo) : (hdTypes.hdProtectedCallResult, hdParallelService.hdParallelService)
	local instance : hdInstance = self;

	local hdPassResult, hdParallelService = instance.prototype._callInternal(instance, "_createParallelServiceInternal", hdParallelServiceCreateInfo);

	return hdPassResult, hdParallelService;
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

	local hdParallelService = hdParallelService.new(hdParallelServiceCreateInfo);

	if hdParallelServiceCreateInfo.isVirtual then
		local protectedCallResult : hdTypes.hdProtectedCallResult = serviceManager.prototype._callInternal(serviceManager, "_registerVirtualServiceInternal", hdParallelService);
	end

	return hdParallelService;
end

function hdInstance:hdCreateActor(hdActorCreateInfo : hdTypes.hdActorCreateInfo) : (hdActor.hdActor, Actor)
	local instance : hdInstance = self;
	hdActorCreateInfo.hdInstance = instance;
	local hdActor, hdParallelActor : Actor = hdActor.createActor(hdActorCreateInfo);

	return hdActor :: hdActor.hdActor, hdParallelActor;
end

function hdInstance:hdCreateCoreModuleManager(hdCoreModuleManagerCreateInfo : hdTypes.hdCoreModuleManagerCreateInfo) : (hdTypes.hdProtectedCallResult)
	
end

function hdInstance:hdCreateCoreModule(hdCoreModuleCreateInfo : hdTypes.hdCoreModuleCreateInfo) : (hdTypes.hdProtectedCallResult, hdCoreModule.hdCoreModule)
	local instance : hdInstance = self;
	local hdPassResult, hdCoreModule = instance.prototype._callInternal(instance, "_createCoreModuleInternal", hdCoreModuleCreateInfo);
	
	return hdPassResult, hdCoreModule;
end

function hdInstance.prototype:_createCoreModuleInternal(hdCoreModuleCreateInfo : hdTypes.hdCoreModuleCreateInfo) : hdCoreModule.hdCoreModule
	local hdCoreModule = hdCoreModule.new(hdCoreModuleCreateInfo);
	
	return hdCoreModule;
end

--[=[
	Creates a new hdComponentManager, a helper object designed for registering the "ideal" or "default" forms of known components.
	
	:::info
	
	:::
	
	@param hdComponentManagerCreateInfo;
	@return hdComponentManager;
]=]
function hdInstance:hdCreateComponentManager(hdComponentManagerCreateInfo : hdTypes.hdComponentManagerCreateInfo) : (hdTypes.hdProtectedCallResult, hdComponentManager.hdComponentManager)
	local instance : hdInstance = self;
	local hdPassResult, componentManager = instance.prototype._callInternal(instance, "_createComponentManagerInternal", hdComponentManagerCreateInfo);
	
	return hdPassResult, componentManager;
end

function hdInstance.prototype:_createComponentManagerInternal(hdComponentManagerCreateInfo : hdTypes.hdComponentManagerCreateInfo)
	local instance : hdInstance = self;
	local componentManager = hdComponentManager.new(hdComponentManagerCreateInfo);
	
	return componentManager;
end

function hdInstance:hdSetComponentManager(hdComponentManager : hdComponentManager.hdComponentManager)
	local instance : hdInstance = self;

	instance.componentManager = hdComponentManager;
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
	Instantiates an hdClient object, which provides client credentials for other Heimdall objects.

	:::info
	It is recommended to use the hdInstance to generate an hdClient, to ensure that errors are protected/handled by your preferred debug messenger.
	:::

	@param hdClientCreateInfo;
	@return (hdProtectedCallResult, hdClient);
]=]
function hdInstance:hdCreateClient(hdClientCreateInfo : hdTypes.hdClientCreateInfo) : (hdTypes.hdProtectedCallResult, hdClient.hdClient)
	local instance : hdInstance = self;
	local hdPassResult, hdClient = instance.prototype._callInternal(instance, "_createClientInternal", hdClientCreateInfo);
	
	return hdPassResult, hdClient;
end

function hdInstance.prototype:_createClientInternal(hdClientCreateInfo : hdTypes.hdClientCreateInfo) : hdClient.hdClient
	local hdClient = hdClient.new(hdClientCreateInfo);
	
	return hdClient;
end

--[=[
	Instantiates an hdScene object, the main interface for Heimdall scene objects.

	:::info
	It is recommended to use the hdInstance to generate an hdScene, to ensure that errors are protected/handled by your preferred debug messenger.
	:::

	@param hdSceneCreateInfo;
	@return (hdProtectedCallResult, hdScene);
]=]
function hdInstance:hdCreateScene(hdSceneCreateInfo : hdTypes.hdSceneCreateInfo) : (hdTypes.hdProtectedCallResult, hdScene.hdScene)
	local instance : hdInstance = self;
	local hdPassResult : hdTypes.hdProtectedCallResult, hdScene = instance.prototype._callInternal(instance, "_createSceneInternal", hdSceneCreateInfo);

	return hdPassResult, hdScene;
end

function hdInstance.prototype:_createSceneInternal(hdSceneCreateInfo : hdTypes.hdSceneCreateInfo) : hdScene.hdScene
	local hdScene = hdScene.new(hdSceneCreateInfo);
	
	return hdScene;
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
	Instantiates an hdSceneParticipant object, which is used to create scene participants for hdScene objects.
	
	:::info
	It is recommended to use the hdInstance to generate an hdSceneParticipant, to ensure that errors are protected/handled by your preferred debug messenger.
	:::
	
	@param hdSceneParticipantCreateInfo;
	@return (hdProtectedCallResult, hdSceneParticipant);
]=]
function hdInstance:hdCreateSceneParticipant(hdSceneParticipantCreateInfo : hdTypes.hdSceneParticipantCreateInfo) : (hdTypes.hdProtectedCallResult, hdSceneParticipant.hdSceneParticipant)
	local instance : hdInstance = self;
	local hdPassResult : hdTypes.hdProtectedCallResult, hdSceneParticipant : hdSceneParticipant.hdSceneParticipant = instance.prototype._callInternal(instance, "_createSceneParticipantInternal", hdSceneParticipantCreateInfo);
	
	return hdPassResult, hdSceneParticipant;
end

function hdInstance.prototype:_createSceneParticipantInternal(hdSceneParticipantCreateInfo : hdTypes.hdSceneParticipantCreateInfo)
	return hdSceneParticipant.new(hdSceneParticipantCreateInfo);
end

--[=[
	Instantiates an hdSceneHandle object, which are entry points for hdSceneParticipant objects
	
	:::info
	It is recommended to use the hdInstance to generate an hdSceneHandle, to ensure that errors are protected/handled by your preferred debug messenger.
	:::
	
	@param hdSceneHandleCreateInfo;
	@return (hdProtectedCallResult, hdSceneHandle);
]=]
function hdInstance:hdCreateSceneHandle(hdSceneHandleCreateInfo : hdTypes.hdSceneHandleCreateInfo) : (hdTypes.hdProtectedCallResult, hdSceneHandle.hdSceneHandle)
	local instance : hdInstance = self;
	local hdPassResult : hdTypes.hdProtectedCallResult, hdSceneHandle : hdSceneHandle.hdSceneHandle = instance.prototype._callInternal(instance, "_createSceneHandleInternal", hdSceneHandleCreateInfo);
	
	return hdPassResult :: hdTypes.hdProtectedCallResult, hdSceneHandle :: hdSceneHandle.hdSceneHandle;
end

function hdInstance.prototype:_createSceneHandleInternal(hdSceneHandleCreateInfo : hdTypes.hdSceneHandleCreateInfo) : hdSceneHandle.hdSceneHandle
	return hdSceneHandle.new(hdSceneHandleCreateInfo);
end

return hdInstance;