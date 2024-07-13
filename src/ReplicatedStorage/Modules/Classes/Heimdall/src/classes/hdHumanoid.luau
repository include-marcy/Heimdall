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
    disabledStates : {typeof(hdEnums.hdHumanoidState)};
}, {} :: typeof(hdHumanoid)));

function hdHumanoid.new(hdHumanoidCreateInfo : hdTypes.hdHumanoidCreateInfo) : hdHumanoid
    local humanoid : hdHumanoid = setmetatable({}, hdHumanoid);

    humanoid.humanoidState = hdEnums.hdHumanoidState.hdIdlingState;
    humanoid.disabledStates = {};
    humanoid.hdCharacter = hdHumanoidCreateInfo.hdCharacter;
    humanoid.hdHumanoidHandleType = hdHumanoidCreateInfo.hdHumanoidHandleType;

    return humanoid;
end

function hdHumanoid:hdApplyHandleType(hdHumanoidHandleType : hdEnums.hdEnum)
    
end

function hdHumanoid:hdMove(Direction : Vector3)
    
end

function hdHumanoid:hdMoveTo(PositionOrPart : Vector3 | BasePart)

end

--[==[
    Returns the current state of this humanoid.
]==]
function hdHumanoid:hdGetHumanoidState() : typeof(hdEnums.hdHumanoidState)
    local humanoid : hdHumanoid = self;

    return humanoid.humanoidState;
end

--[==[
    Attempts to enter the given humanoid state on this humanoid.
]==]
function hdHumanoid:hdSetHumanoidState(hdHumanoidState : typeof(hdEnums.hdHumanoidState))
    local humanoid : hdHumanoid = self;
    if humanoid:hdGetHumanoidState() == hdHumanoidState then
        return;
    end

    humanoid.humanoidState = hdHumanoidState;
end

--[==[
    Toggles whether the given hdHumanoidState is allowed to be entered by this humanoid.
]==]
function hdHumanoid:hdToggleStateEnabled(hdHumanoidState : typeof(hdEnums.hdHumanoidState))
    local humanoid : hdHumanoid = self;
    local disabledStates = humanoid.disabledStates;

    disabledStates[hdHumanoidState] = not disabledStates[hdHumanoidState];

    if humanoid:hdGetHumanoidState() == hdHumanoidState then
        hdHumanoidState:hdSetHumanoidState(hdEnums.hdHumanoidState.hdParalyzed);
    end
end

function hdHumanoid:Destroy()

end

return hdHumanoid;