--!strict
local hd = script.Parent.Parent;
local hdLib = hd.lib;
local hdClasses = hd.classes;

local hdTypes = require(hdLib.hdTypes);

local hdDebugMessenger = require(hdClasses.hdDebugMessenger);
local hdProtectedCallResultEmitter = require(hdClasses.hdProtectedCallResultEmitter);
local hdInternalComponent = require(hdClasses.hdInternalComponent);
local hdComponent = require(hdClasses.hdComponent);

local hdComponentManager = {
	prototype = {};
};
hdComponentManager.__index = hdComponentManager;

export type hdComponentManager = typeof(setmetatable({} :: {
	debugMessenger : hdDebugMessenger.hdDebugMessenger;
	protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter;
	components : {[string] : hdComponent.hdComponent};
}, {} :: typeof(hdComponentManager)));

--[=[
	Creates an hdComponentManager, a warehouse of hdComponent definitions
	
	:::info
		
	:::

	@param hdComponentManagerCreateInfo;
	@return hdComponentManager;
]=]
function hdComponentManager.new(hdComponentManagerCreateInfo : hdTypes.hdComponentManagerCreateInfo) : hdComponentManager
	local componentManager = setmetatable({}, hdComponentManager);

	componentManager.debugMessenger = hdComponentManagerCreateInfo.debugMessenger;
	componentManager.components = {};

	local hdProtectedCallResultEmitterCreateInfo : hdTypes.hdProtectedCallEmitterCreateInfo = {};
	componentManager.protectedCaller = hdProtectedCallResultEmitter.new(hdProtectedCallResultEmitterCreateInfo);

	return componentManager;
end

--[=[
	Takes an hdComponent and adds it to the internal registry, allowing it to be recognized by the hdComponentManager in creation of new real components.

	@param hdComponent;
	@return hdProtectedCallResult;
]=]
function hdComponentManager:hdRegisterComponent(hdComponent : hdComponent.hdComponent) : hdTypes.hdProtectedCallResult
	local componentManager : hdComponentManager = self;

	return componentManager.prototype._callInternal(componentManager, "_registerComponentInternal", hdComponent);
end

--[=[
	Takes a given name string and returns an hdComponent, if one is registered under that name.

	@param name : string;
	@return hdComponent?;
]=]
function hdComponentManager:hdReadComponent(name : string) : hdComponent.hdComponent?
	local componentManager : hdComponentManager = self;

	return componentManager.components[name];
end

--[=[
	Takes a given name string and returns a new hdInternalComponent, if there is a registered hdComponent with name

	@param name : string;
	@return hdInternalComponent?;
]=]
function hdComponentManager:hdCreateInternalComponentFromRegistration(name : string) : (hdTypes.hdProtectedCallResult, hdInternalComponent.hdInternalComponent?)
	local componentManager : hdComponentManager = self;
	
	return componentManager.prototype._callInternal(componentManager, "_createInternalComponentFromRegistrationInternal", name);
end

function hdComponentManager.prototype._callInternal(componentManager : hdComponentManager, f, ...) : (hdTypes.hdProtectedCallResult, ...any)
	local debugMessenger : hdDebugMessenger.hdDebugMessenger = componentManager.debugMessenger;
	local protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter = componentManager.protectedCaller;

	return debugMessenger:catch(f, protectedCaller:getProtectedCallResult(componentManager.prototype[f], componentManager, ...));
end

function hdComponentManager.prototype:_registerComponentInternal(hdComponent : hdComponent.hdComponent)
	local componentManager : hdComponentManager = self;
	local components = componentManager.components;
	
	if componentManager:hdReadComponent(hdComponent.name) then
		return;
	end
	
	components[hdComponent.name] = hdComponent;
end

function hdComponentManager.prototype:_createInternalComponentFromRegistrationInternal(name : string) : hdInternalComponent.hdInternalComponent?
	local componentManager : hdComponentManager = self;

	local hdComponent = componentManager:hdReadComponent(name);
	if not hdComponent then
		return;
	end
	
	return hdInternalComponent.new({
		refComponent = hdComponent
	});
end

return hdComponentManager;