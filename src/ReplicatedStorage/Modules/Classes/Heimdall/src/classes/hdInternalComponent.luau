-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hd = script.Parent.Parent;
local hdLib = hd.lib;
local hdClasses = hd.classes;

local hdTypes = require(hdLib.hdTypes);

local hdComponent = require(hdClasses.hdComponent);

--// Class Declaration
local hdInternalComponent = {};
hdInternalComponent.__index = hdInternalComponent;

export type hdInternalComponent = typeof(setmetatable({} :: {
	name : string;
	details : any;
}, {} :: typeof(hdInternalComponent)));

function hdInternalComponent.new(hdInternalComponentCreateInfo : hdTypes.hdInternalComponentCreateInfo) : hdInternalComponent
	local internalComponent = setmetatable({
		name = "";
		details = {};
	}, hdInternalComponent);

	internalComponent:_buildFromReference(hdInternalComponentCreateInfo.refComponent);

	return internalComponent;
end

function hdInternalComponent:_buildFromReference(referenceComponent : hdComponent.hdComponent)
	local internalComponent : hdInternalComponent = self;

	internalComponent.name = referenceComponent.name;
	internalComponent.details = table.clone(referenceComponent.details);
end

function hdInternalComponent:hdDestroy()
	local internalComponent : hdInternalComponent = self;

	table.clear(internalComponent.details);

	local nInternalComponent : any = internalComponent;
	setmetatable(nInternalComponent, nil);
	table.clear(nInternalComponent);
	nInternalComponent = nil;
	internalComponent = nil;
end

return hdInternalComponent;