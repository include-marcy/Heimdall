-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

--// Class Declaration
local hdCoreModuleManager = {};
hdCoreModuleManager.__index = hdCoreModuleManager;

export type hdCoreModuleManager = typeof(setmetatable({} :: {}, {} :: typeof(hdCoreModuleManager)));

function hdCoreModuleManager.new(hdCoreModuleManagerCreateInfo : hdTypes.hdCoreModuleManagerCreateInfo) : hdCoreModuleManager
	local coreModuleManager = setmetatable({}, hdCoreModuleManager);

	return coreModuleManager;
end

return hdCoreModuleManager;