local hdTypes = require(script.Parent.Parent.lib.hdTypes);
local hdCoreModuleManager = {};
hdCoreModuleManager.__index = hdCoreModuleManager;

export type hdCoreModuleManager = typeof(setmetatable({} :: {}, {} :: typeof(hdCoreModuleManager)));

function hdCoreModuleManager.new(hdCoreModuleManagerCreateInfo : hdTypes.hdCoreModuleManagerCreateInfo) : hdCoreModuleManager
	local coreModuleManager = setmetatable({}, hdCoreModuleManager);
	
	return coreModuleManager;
end

return hdCoreModuleManager;