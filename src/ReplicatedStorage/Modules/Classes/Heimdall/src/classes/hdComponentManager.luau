-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hd = script.Parent.Parent;
local hdLib = hd.lib;
local hdClasses = hd.classes;

local hdTypes = require(hdLib.hdTypes);

local hdDebugMessenger = require(hdClasses.hdDebugMessenger);
local hdProtectedCallResultEmitter = require(hdClasses.hdProtectedCallResultEmitter);
local hdInternalComponent = require(hdClasses.hdInternalComponent);
local hdComponent = require(hdClasses.hdComponent);

--// Class Declaration
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
	@class hdComponentManager
	Creates an hdComponentManager, a warehouse of hdComponent definitions

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
	@class hdComponentManager
	Takes an hdComponent and adds it to the internal registry, allowing it to be recognized by the hdComponentManager in creation of new real components.

	@param hdComponent;
	@return hdProtectedCallResult;
]=]
function hdComponentManager:hdRegisterComponent(component : hdComponent.hdComponent) : hdTypes.hdProtectedCallResult
	local componentManager : hdComponentManager = self;

	return componentManager.prototype._callInternal(componentManager, "_registerComponentInternal", component);
end

--[=[
	@class hdComponentManager
	Takes a given name string and returns an hdComponent, if one is registered under that name.

	@param name : string;
	@return hdComponent?;
]=]
function hdComponentManager:hdReadComponent(name : string) : hdComponent.hdComponent?
	local componentManager : hdComponentManager = self;

	return componentManager.components[name];
end

--[=[
	@class hdComponentManager
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

function hdComponentManager.prototype:_registerComponentInternal(component : hdComponent.hdComponent)
	local componentManager : hdComponentManager = self;
	local components = componentManager.components;

	if componentManager:hdReadComponent(component.name) then
		return;
	end

	components[component.name] = component;
end

function hdComponentManager.prototype:_createInternalComponentFromRegistrationInternal(name : string) : hdInternalComponent.hdInternalComponent?
	local componentManager : hdComponentManager = self;

	local component = componentManager:hdReadComponent(name);
	if not component then
		return;
	end

	return hdInternalComponent.new({
		refComponent = component
	});
end

return hdComponentManager;