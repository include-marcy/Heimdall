-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

--// Class Declaration
local hdClient = {};
hdClient.__index = hdClient;

export type hdClient = typeof(setmetatable({} :: {}, {} :: typeof(hdClient)));

--[=[
	Creates a new hdClient object. The hdClient object is responsible for providing client credentials within Heimdall.
	Any time a player must be present, the hdClient object should be used/interfaced into Heimdall to ensure 100% functionality with ROBLOX
	player objects.

	@param hdClientCreateInfo;
	@return hdClient;
]=]
function hdClient.new(hdClientCreateInfo : hdTypes.hdClientCreateInfo) : hdClient
	local client = setmetatable({}, hdClient);

	client.player = hdClientCreateInfo.player;

	return client :: hdClient;
end

return hdClient;