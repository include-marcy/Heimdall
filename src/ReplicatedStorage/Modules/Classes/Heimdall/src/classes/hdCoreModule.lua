--!strict
local hdTypes = require(script.Parent.Parent.lib.hdTypes);
local hdCoreModule = {};
hdCoreModule.__index = hdCoreModule;

export type hdCoreModule = typeof(setmetatable({} :: {
	name : string;
	loadPriority : number;
	runtimeBehavior : hdTypes.hdCoreModuleRuntimeBehavior;
}, {} :: typeof(hdCoreModule)));

function hdCoreModule.new(hdCoreModuleCreateInfo : hdTypes.hdCoreModuleCreateInfo) : hdCoreModule
	local coreModule = setmetatable({
		name = hdCoreModuleCreateInfo.name;
		loadPriority = hdCoreModuleCreateInfo.loadPriority;
		runtimeBehavior = hdCoreModuleCreateInfo.runtimeBehavior;
	}, hdCoreModule);

	return coreModule;
end

return hdCoreModule;