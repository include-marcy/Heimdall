-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

local hdClasses = script.Parent;
local hdActor = require(hdClasses.hdActor);

--// Class Declaration
local hdParallelService = {};
hdParallelService.__index = hdParallelService;

export type hdParallelService = typeof(setmetatable({} :: {
	hdActors : {[number] : hdActor.hdActor};
	name : string;
	loadPriority : number;
	IsService : true;
}, {} :: typeof(hdParallelService)));

--[=[
	@class hdParallelService
	Creates an hdParallelService, services capable of/made for executing desynchronized parallel luau code.

	:::info
	An hdParallelService is virtually identical to an hdService, with the exception of containing a parallel luau execution methods.
	:::

	@param hdParallelServiceCreateInfo;
	@return hdParallelService;
]=]
function hdParallelService.new(hdParallelServiceCreateInfo : hdTypes.hdParallelServiceCreateInfo) : hdParallelService
	local parallelService = setmetatable({}, hdParallelService);

	local name = hdParallelServiceCreateInfo.name;
	local worker = hdParallelServiceCreateInfo.worker;
	local hdInstance = hdParallelServiceCreateInfo.hdInstance;
	local hdActorCount = hdParallelServiceCreateInfo.hdActorCount or 1;
	local hdActors : {[number] : hdActor.hdActor} = table.create(hdActorCount);

	local hdActorCreateInfo : hdTypes.hdActorCreateInfo = {
		hdParallelServiceObj = worker;
	};
	for i = 1, hdActorCount do
		local _ : hdActor.hdActor, hdParallelActor : Actor = hdInstance:hdCreateActor(hdActorCreateInfo);
		hdActors[i] = hdParallelActor;
	end

	parallelService.name = name;
	parallelService.loadPriority = hdParallelServiceCreateInfo.loadPriority;
	parallelService.IsService = true;
	parallelService.hdActors = hdActors;

	return parallelService :: hdParallelService;
end

function hdParallelService:Compute(computeArgs) : any
	local parallelService : hdParallelService = self;
	local computeData = {};

	local actorCount = #parallelService.hdActors;
	local computeCount = #computeArgs;

	local function getWorkSlice(n)
		local workSlice = {};
		for i = n, computeCount, actorCount do
			table.insert(workSlice, computeArgs[i]);
		end
		return workSlice;
	end

	for actorNumber, hdParallelActor : Actor in parallelService.hdActors do
		local slice = getWorkSlice(actorNumber);

		local computeReturn = hdParallelActor.hdActorEvent:Invoke("hdCompute", slice);

		for _, v in computeReturn do
			table.insert(computeData, v)
		end
	end

	return computeData
end

return hdParallelService;