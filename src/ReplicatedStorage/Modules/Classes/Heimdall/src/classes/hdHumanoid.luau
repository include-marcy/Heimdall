--!strict
--!native
--!optimize 2
local hdLib = script.Parent.Parent.lib;
local hdClasses = script.Parent;
local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);

local hdHumanoid = {};
hdHumanoid.__index = hdHumanoid;

export type hdHumanoid = typeof(setmetatable({} :: {
    humanoidState : typeof(hdEnums.hdHumanoidState);
}, {} :: typeof(hdHumanoid)));

function hdHumanoid.new(hdHumanoidCreateInfo : hdTypes.hdHumanoidCreateInfo) : hdHumanoid
    local humanoid : hdHumanoid = setmetatable({}, hdHumanoid);

    humanoid.humanoidState = hdEnums.hdHumanoidState.hdIdlingState;
    humanoid.hdCharacter = hdHumanoidCreateInfo.hdCharacter;

    return humanoid;
end

return hdHumanoid;