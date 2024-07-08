--!strict
local hd = script.Parent.Parent;
local hdLib = hd.lib;
local hdClasses = hd.classes;

local hdTypes = require(hdLib.hdTypes);

local hdDebugMessenger = require(hdClasses.hdDebugMessenger);
local hdProtectedCallResultEmitter = require(hdClasses.hdProtectedCallResultEmitter);
local hdComponentManager = require(hdClasses.hdComponentManager);
local hdComponent = require(hdClasses.hdComponent);
local hdInternalComponent = require(hdClasses.hdInternalComponent);
local trove = require(hd.packages.trove);

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
		-- entity.componentManager:hdLinkToInstance(entity.tiedTo);

		entity.trove = trove.instanceTrove(hdEntityCreateInfo.tiedTo);
		entity.trove:Add(entity, "hdDestroy");
	end
	
	for _, componentCreateInfo : hdTypes.hdComponentCreateInfo in hdEntityCreateInfo.components do
		entity:hdAddComponent(componentCreateInfo);
	end
	
	return entity;
end

function hdEntity:hdAddComponent(hdComponentCreateInfo : hdTypes.hdComponentCreateInfo) : hdTypes.hdProtectedCallResult
	local entity : hdEntity = self;
	local hdResult, hdInternalComponent = entity:hdGetComponent(hdComponentCreateInfo.name);
	if hdInternalComponent then
		return entity.prototype._callInternal(entity, "_mixinComponentInternal", hdComponentCreateInfo);
	else
		return entity.prototype._callInternal(entity, "_patchInComponentInternal", hdComponentCreateInfo);
	end
end

function hdEntity:hdRemoveComponent(name : string) : hdTypes.hdProtectedCallResult
	local entity : hdEntity = self;

	return entity.prototype._callInternal(entity, "_patchOutComponentInternal", name);
end

function hdEntity:hdGetComponent(name : string) : (hdTypes.hdProtectedCallResult, any?)
	local entity : hdEntity = self;

	return entity.prototype._callInternal(entity, "_accessComponentInternal", name);
end

function hdEntity:hdGetName() : string
	local entity : hdEntity = self;
	
	return entity.name;
end

function hdEntity:hdSetName(name : string) : hdTypes.hdProtectedCallResult
	local entity : hdEntity = self;
	
	return entity.prototype._callInternal(entity, "_setNameInternal", name);
end

function hdEntity:hdGetTiedInstance()
	local entity : hdEntity = self;
	
	return entity.tiedTo;
end

function hdEntity:hdSetTiedInstance(instance : Instance) : hdTypes.hdProtectedCallResult
	local entity : hdEntity = self;
	
	return entity.prototype._callInternal(entity, "_setTiedInstanceInternal", instance);
end

function hdEntity:hdGetTrove()
	local entity : hdEntity = self;
	
	return entity.trove;
end

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
	
	local entity : any = entity;
	table.clear(entity);
	setmetatable(entity, nil);
	entity = nil;
end

function hdEntity.prototype._callInternal(entity : hdEntity, f, ...) : (hdTypes.hdProtectedCallResult, ...any)
	local debugMessenger : hdDebugMessenger.hdDebugMessenger = entity.debugMessenger;
	local protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter = entity.protectedCaller;

	return debugMessenger:catch(f, protectedCaller:getProtectedCallResult(entity.prototype[f], entity, ...));
end

function hdEntity.prototype:_patchInComponentInternal(hdComponentCreateInfo : hdTypes.hdComponentCreateInfo)
	local entity : hdEntity = self;
	local componentManager = entity.componentManager;
	
	local hdResult, internalComponent = componentManager:hdCreateInternalComponentFromRegistration(hdComponentCreateInfo.name);

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