-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

--// Class Declaration
local hdService = {};
hdService.__index = hdService;

export type hdService = typeof(setmetatable({} :: {
	name : string;
	loadPriority : number;
	IsService : true;
	moduleReference : ModuleScript;
}, {} :: typeof(hdService)));

--[=[
	@class hdService
	Creates an hdService, a core class of Heimdall which all services in Heimdall inherit from.
	All game logic can and should be created within hdServices.

	@param hdServiceCreateInfo;
	@return hdService;
]=]
function hdService.new(hdServiceCreateInfo : hdTypes.hdServiceCreateInfo) : hdService
	local service = setmetatable({}, hdService);

	service.name = hdServiceCreateInfo.name;
	service.loadPriority = hdServiceCreateInfo.loadPriority;
	service.IsService = true;
	service.moduleReference = hdServiceCreateInfo.moduleReference;

	return service;
end

function hdService:Boot()

end

function hdService:Start()

end

function hdService:Update(_ : number)

end

return hdService;