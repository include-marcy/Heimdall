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
local hdComponentManager = require(hdClasses.hdComponentManager);
local hdInternalComponent = require(hdClasses.hdInternalComponent);
local trove = require(hd.packages.trove);

--// Class Declaration
local hdEntity = {
	prototype = {};
};
hdEntity.__index = hdEntity;

export type hdEntity = typeof(setmetatable({} :: {
	name : string;
	tiedTo : Instance?;
	components : {[string] : hdInternalComponent.hdInternalComponent};
	debugMessenger : hdDebugMessenger.hdDebugMessenger;
	componentManager : hdComponentManager.hdComponentManager;
	protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter;
	trove : typeof(trove.new())?;
	alive : boolean;
}, {} :: typeof(hdEntity)));

--[=[
	@class hdEntity
	Creates a new hdEntity object. hdEntities are used to store components under a namespace that can be globally accessible.

	@param hdEntityCreateInfo;
	@return hdEntity;
]=]
function hdEntity.new(hdEntityCreateInfo : hdTypes.hdEntityCreateInfo) : hdEntity
	local entity = setmetatable({
		name = hdEntityCreateInfo.name;
		tiedTo = hdEntityCreateInfo.tiedTo;
		components = {};
		debugMessenger = hdEntityCreateInfo.debugMessenger;
		componentManager = hdEntityCreateInfo.componentManager;
		alive = true;
	}, hdEntity)

	local hdProtectedCallResultEmitterCreateInfo : hdTypes.hdProtectedCallEmitterCreateInfo = {};
	entity.protectedCaller = hdProtectedCallResultEmitter.new(hdProtectedCallResultEmitterCreateInfo);

	if hdEntityCreateInfo.tiedTo then
		entity.trove = trove.instanceTrove(hdEntityCreateInfo.tiedTo);
		entity.trove:Add(entity, "hdDestroy");
	end

	for _, componentCreateInfo : hdTypes.hdComponentCreateInfo in hdEntityCreateInfo.components do
		entity:hdAddComponent(componentCreateInfo);
	end

	return entity;
end

--[=[
	@class hdEntity
	Attempts to add the defined component based on the hdComponentCreateInfo passed to this function.

	:::info
	hdComponents must be predefined in the Heimdall environment and given archetypical details.
	Components as they are inside an hdEntity are of a different internal form.
	:::

	@param hdComponentCreateInfo;
	@return hdProtectedCallResult;
]=]
function hdEntity:hdAddComponent(hdComponentCreateInfo : hdTypes.hdComponentCreateInfo) : hdTypes.hdProtectedCallResult
	local entity : hdEntity = self;
	local hdResult, internalComponent = entity:hdGetComponent(hdComponentCreateInfo.name);
	if not hdResult.Success then
		return hdResult;
	end

	if internalComponent then
		return entity.prototype._callInternal(entity, "_mixinComponentInternal", hdComponentCreateInfo);
	else
		return entity.prototype._callInternal(entity, "_patchInComponentInternal", hdComponentCreateInfo);
	end
end

--[=[
	@class hdEntity
	Clears the given component inside this hdEntity based on the name passed to this function.

	@param name : string;
	@return hdProtectedCallResult;
]=]
function hdEntity:hdRemoveComponent(name : string) : hdTypes.hdProtectedCallResult
	local entity : hdEntity = self;

	return entity.prototype._callInternal(entity, "_patchOutComponentInternal", name);
end

--[=[
	@class hdEntity
	Returns the internal component data associated with the given name.

	@param name : string;
	@return hdProtectedCallResult, hdInternalComponent?;
]=]
function hdEntity:hdGetComponent(name : string) : (hdTypes.hdProtectedCallResult, any?)
	local entity : hdEntity = self;

	return entity.prototype._callInternal(entity, "_accessComponentInternal", name);
end

--[=[
	@class hdEntity
	Returns the name of this hdEntity.


	@return name : string;
]=]
function hdEntity:hdGetName() : string
	local entity : hdEntity = self;

	return entity.name;
end

--[=[
	@class hdEntity
	Sets the name of this hdEntity.

	@param name : string;;
]=]
function hdEntity:hdSetName(name : string) : hdTypes.hdProtectedCallResult
	local entity : hdEntity = self;

	return entity.prototype._callInternal(entity, "_setNameInternal", name);
end

--[=[
	@class hdEntity
	Returns the instance that this hdEntity is representing.


	@return tiedTo : Instance?;
]=]
function hdEntity:hdGetTiedInstance()
	local entity : hdEntity = self;

	return entity.tiedTo;
end

--[=[
	@class hdEntity
	Changes the instance that this hdEntity is representing.


	@param Instance;
	@return hdProtectedCallResult;
]=]
function hdEntity:hdSetTiedInstance(instance : Instance) : hdTypes.hdProtectedCallResult
	local entity : hdEntity = self;

	return entity.prototype._callInternal(entity, "_setTiedInstanceInternal", instance);
end

--[=[
	@class hdEntity
	Returns the Trove object that is stored for the instance this hdEntity is representing.

	:::info
	When the instance is destroyed, this hdEntity is also destroyed.
	When the tied instance is changed, this Trove is cleared and rebuilt, but the hdEntity is not destroyed.
	:::

	@return trove?;
]=]
function hdEntity:hdGetTrove()
	local entity : hdEntity = self;

	return entity.trove;
end

--[=[
	@class hdEntity
	Cleans up and removes this hdEntity.
]=]
function hdEntity:hdDestroy()
	local entity : hdEntity = self;
	if not entity.alive then
		return;
	end

	entity.alive = false;
	entity.trove = nil;
	entity.tiedTo = nil;

	for name, internalComponent in entity.components do
		internalComponent:hdDestroy();
		entity.components[name] = nil;
	end

	local nEntity : any = entity;
	table.clear(nEntity);
	setmetatable(nEntity, nil);
	entity = nil;
	nEntity = nil;
end

function hdEntity.prototype._callInternal(entity : hdEntity, f, ...) : (hdTypes.hdProtectedCallResult, ...any)
	local debugMessenger : hdDebugMessenger.hdDebugMessenger = entity.debugMessenger;
	local protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter = entity.protectedCaller;

	return debugMessenger:catch(f, protectedCaller:getProtectedCallResult(entity.prototype[f], entity, ...));
end

function hdEntity.prototype:_patchInComponentInternal(hdComponentCreateInfo : hdTypes.hdComponentCreateInfo)
	local entity : hdEntity = self;
	local componentManager = entity.componentManager;

	local _, internalComponent = componentManager:hdCreateInternalComponentFromRegistration(hdComponentCreateInfo.name);

	if not internalComponent then
		return;
	end

	--// internalComponent.details = hdComponentCreateInfo.details;
	entity.components[hdComponentCreateInfo.name] = internalComponent;
end

function hdEntity.prototype:_patchOutComponentInternal()
	local entity : hdEntity = self;
end

function hdEntity.prototype:_mixinComponentInternal()
	local entity : hdEntity = self;

	warn("mix")
end

function hdEntity.prototype:_accessComponentInternal(name : string)
	local entity : hdEntity = self;

	return entity.components[name];
end

function hdEntity.prototype:_setTiedInstanceInternal(instance : Instance)
	local entity : hdEntity = self;

	entity.tiedTo = instance;
end

function hdEntity.prototype:_setNameInternal(name : string)
	local entity : hdEntity = self;

	entity.name = name;
end

return hdEntity;