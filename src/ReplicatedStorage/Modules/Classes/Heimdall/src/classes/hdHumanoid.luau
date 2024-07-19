-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdLib = script.Parent.Parent.lib;

local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);

--// Class Declaration
local hdHumanoid = {};
hdHumanoid.__index = hdHumanoid;

export type hdHumanoid = typeof(setmetatable({} :: {
    humanoidState : typeof(hdEnums.hdHumanoidState);
    disabledStates : {typeof(hdEnums.hdHumanoidState)};
    hdCharacter : any;
    hipHeight : number;
}, {} :: typeof(hdHumanoid)));

function hdHumanoid.new(hdHumanoidCreateInfo : hdTypes.hdHumanoidCreateInfo) : hdHumanoid
    local humanoid : hdHumanoid = setmetatable({}, hdHumanoid);

    humanoid.humanoidState = hdEnums.hdHumanoidState.hdIdlingState;
    humanoid.disabledStates = {};
    humanoid.hdCharacter = hdHumanoidCreateInfo.hdCharacter;
    humanoid.hdHumanoidHandleType = hdHumanoidCreateInfo.hdHumanoidHandleType;
    humanoid.hipHeight = hdHumanoidCreateInfo.hipHeight;

    humanoid:hdApplyHandleType(hdHumanoidCreateInfo.hdHumanoidHandleType);

    return humanoid;
end

function hdHumanoid:hdApplyHandleType(humanoidHandleType : typeof(hdEnums.hdHumanoidHandleType))
    local humanoid : hdHumanoid = self;
    local character = humanoid.hdCharacter;
    local physicalCharacter = character:hdGetPhysicalCharacter();
    local humanoidRootPart = physicalCharacter:WaitForChild("HumanoidRootPart");

    local function HD_CREATE_COLLIDER_OBJECT_GENERIC(Name : string, PartSize : Vector3, PartType : Enum.PartType, LocalOffset : CFrame) : Part
        local collider = Instance.new("Part");
        collider.Shape = PartType;
        collider.Transparency = 0.5;
        collider.Color = Color3.fromRGB(255, 90, 90);
        collider.CanCollide = true;
        collider.CanTouch = false;
        collider.CanQuery = false;
        collider.Anchored = false;
        collider.Size = PartSize;
        collider.CFrame = humanoidRootPart.CFrame * LocalOffset;
        collider.Name = Name;
        collider.Parent = physicalCharacter;

        local colliderWeld = Instance.new("Weld");
        colliderWeld.C0 = LocalOffset;
        colliderWeld.Part0 = humanoidRootPart;
        colliderWeld.Part1 = collider;
        colliderWeld.Parent = collider;

        return collider;
    end

    local height = humanoid.hipHeight * 2;

    if humanoidHandleType == hdEnums.hdHumanoidHandleType.hdHumanoidCapsule then
        HD_CREATE_COLLIDER_OBJECT_GENERIC("HD_COLLIDER_CAPSULE_TOP", Vector3.one * height, Enum.PartType.Ball, CFrame.new(0, height / 3, 0));
        HD_CREATE_COLLIDER_OBJECT_GENERIC("HD_COLLIDER_CAPSULE_MIDDLE", Vector3.new(height / 2, height / 2, 2), Enum.PartType.Cylinder, CFrame.Angles(math.rad(90), 0, 0));
        HD_CREATE_COLLIDER_OBJECT_GENERIC("HD_COLLIDER_CAPSULE_BOTTOM", Vector3.one * height, Enum.PartType.Ball, CFrame.new(0, -height / 3, 0));
    elseif humanoidHandleType == hdEnums.hdHumanoidHandleType.hdHumanoidCube then
        HD_CREATE_COLLIDER_OBJECT_GENERIC("HD_COLLIDER_CUBE", Vector3.new(2, 4, 2), Enum.PartType.Block, CFrame.identity);
    end
end

function hdHumanoid:hdGetHipCFrame() : CFrame?
    local humanoid : hdHumanoid = self;
    local character = humanoid.hdCharacter;
    local physicalCharacter = character:hdGetPhysicalCharacter();

    if not physicalCharacter then
        return;
    end

    local humanoidRootPart = physicalCharacter:FindFirstChild("HumanoidRootPart");
    if not humanoidRootPart then
        return;
    end

    local hipHeight = humanoid.hipHeight;
    print(hipHeight);
    local floorCastParams = RaycastParams.new();
    floorCastParams.FilterType = Enum.RaycastFilterType.Exclude;
    floorCastParams.FilterDescendantsInstances = {physicalCharacter};

    local floor = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -hipHeight, 0), floorCastParams);
    if not floor then
        return humanoidRootPart.CFrame;
    end

    local X, Y, Z = humanoidRootPart.CFrame:ToOrientation();
    return CFrame.new(floor.Position + Vector3.new(0, hipHeight, 0)) * CFrame.Angles(X, Y, Z);
end

function hdHumanoid:hdMove(Direction : Vector3, Delta : number?)
    local humanoid : hdHumanoid = self;
    local character = humanoid.hdCharacter;
    local physicalCharacter = character:hdGetPhysicalCharacter();

    if not physicalCharacter then
        return;
    end

    if Direction == Vector3.zero then
        humanoid:hdSetHumanoidState(hdEnums.hdHumanoidState.hdIdling);
        return;
    end

    local humanoidRootPart = physicalCharacter:FindFirstChild("HumanoidRootPart");
    local hipCFrame, floorMaterial = humanoid:hdGetHipCFrame();

    if floorMaterial == Enum.Material.Air then
        humanoid:hdSetHumanoidState(hdEnums.hdHumanoidState.hdFalling);
    else
        humanoid:hdSetHumanoidState(hdEnums.hdHumanoidState.hdWalking);
    end

    humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(hipCFrame * CFrame.new(Direction), Delta or 0.1);
end

function hdHumanoid:hdMoveTo(_ : Vector3 | BasePart)

end

--[==[
    @class hdHumanoid
    Returns the current state of this humanoid.

    @return hdHumanoidState
]==]
function hdHumanoid:hdGetHumanoidState() : typeof(hdEnums.hdHumanoidState)
    local humanoid : hdHumanoid = self;

    return humanoid.humanoidState;
end

--[==[
    @class hdHumanoid
    Attempts to enter the given humanoid state on this humanoid.

    @param hdHumanoidState;
]==]
function hdHumanoid:hdSetHumanoidState(hdHumanoidState : typeof(hdEnums.hdHumanoidState))
    local humanoid : hdHumanoid = self;
    if humanoid:hdGetHumanoidState() == hdHumanoidState then
        return;
    end

    humanoid.humanoidState = hdHumanoidState;
end

--[==[
    @class hdHumanoid
    Toggles whether the given hdHumanoidState is allowed to be entered by this humanoid.

    @param hdHumanoidState;
]==]
function hdHumanoid:hdToggleStateEnabled(hdHumanoidState : typeof(hdEnums.hdHumanoidState))
    local humanoid : hdHumanoid = self;
    local disabledStates = humanoid.disabledStates;

    disabledStates[hdHumanoidState] = not disabledStates[hdHumanoidState];

    if humanoid:hdGetHumanoidState() == hdHumanoidState then
        hdHumanoidState:hdSetHumanoidState(hdEnums.hdHumanoidState.hdParalyzed);
    end
end

--[==[
    @class hdHumanoid
    Removes this hdHumanoid from the Heimdall environment and from Luau.
]==]
function hdHumanoid:Destroy()

end

return hdHumanoid;