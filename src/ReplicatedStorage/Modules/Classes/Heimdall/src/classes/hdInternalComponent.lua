--!strict
local hd = script.Parent.Parent;
local hdLib = hd.lib;
local hdClasses = hd.classes;

local hdTypes = require(hdLib.hdTypes);

local hdComponent = require(hdClasses.hdComponent);

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
	
	local internalComponent : any = internalComponent;
	setmetatable(internalComponent, nil);
	table.clear(internalComponent);
	internalComponent = nil;
end

return hdInternalComponent;