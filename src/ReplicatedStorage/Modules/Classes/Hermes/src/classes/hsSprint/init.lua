--!strict
--!native
local hs = script.Parent.Parent;
local hsLib = hs.lib;
local hsTypes = require(hsLib.hsTypes);

local hsSprint = {};
hsSprint.__index = hsSprint;

export type hsSprint = typeof(setmetatable({} :: {}, {} :: typeof(hsSprint)));

--[=[
	Creates an hsSprint object, an abstract representation of a workload to be executed in parallel.

	@return hsSprint;
]=]
function hsSprint.new(hsSprintCreateInfo : hsTypes.hsSprintCreateInfo) : hsSprint
    return setmetatable({
        workingMethod = hsSprintCreateInfo.workingMethod;
        actorCount = hsSprintCreateInfo.actorCount;
    }, hsSprint);
end

function hsSprint:hsRunSprint(hsSprintRunConfig : hsTypes.hsSprintRunConfig)
    local workLoad = hsSprintRunConfig.workLoad;
    local actorCount = hsSprintRunConfig.actorCount;

    for actorIndex = 1, actorCount do
        self:hsAllocateActor(actorIndex, hsSprintRunConfig);
    end
end

function hsSprint:hsAllocateActor(actorIndex : number, hsSprintRunConfig : hsTypes.hsSprintRunConfig)
    
end

function hsSprint:hsPauseSprint()
    
end

return hsSprint;