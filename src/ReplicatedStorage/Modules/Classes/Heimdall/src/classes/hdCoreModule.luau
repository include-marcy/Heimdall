-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

--// Class Declaration
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