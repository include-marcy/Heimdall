--!strict
--!native
--!optimize 2
-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");
local ContextActionService = game:GetService("ContextActionService");
local TweenService = game:GetService("TweenService");

-- Heimdall dependencies
local Heimdall = require(ReplicatedStorage.Modules.Classes.Heimdall);
local hdTypes = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdTypes);
local hdEnums = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdEnums);
local hdInstance = Heimdall.awaitHdInstance();

local hdCharacterService = hdInstance:hdGetService("hdCharacterService", 20);

local hdCameraDefault = {};

local userRotation =  Vector3.zero;
local realUserRotation = Vector3.zero;
local userZoom = Instance.new("NumberValue");
userZoom.Value = 10;
local actualZoom = userZoom.Value;

local cameraCFrameOffset = CFrame.new(0, 1, -userZoom.Value) * CFrame.Angles(0, math.rad(180), 0);

local MAX_Y_ROTATION = 90;
local MIN_Y_ROTATION = -90;

local MIN_ZOOM = 0;
local MAX_ZOOM = 20;

local function Lerp(a, b, t)
	return a + (b - a) * t
end

function hdCameraDefault:Update(deltaTime : number)
    local Character = hdCharacterService:hdGetCharacter(Players.LocalPlayer, 15);
    local Camera = workspace.CurrentCamera;

    if not Character then
        return;
    end

    Character = Character:hdGetPhysicalCharacter();
    if not Character then
        return;
    end

    realUserRotation = realUserRotation:Lerp(userRotation, deltaTime * 20);

    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");
    local CameraOffset = hdCameraDefault:hdGetCameraCFrameOffset();

    local CameraGoalCFrame = (HumanoidRootPart.CFrame * CameraOffset) * CFrame.new(0, 0, -userZoom.Value) * CFrame.Angles(0, math.rad(180), 0);
    local Zoom = hdCameraDefault:hdGetOccludedCameraZoom(Character, HumanoidRootPart.CFrame, CameraGoalCFrame, userZoom.Value);
    actualZoom = Lerp(actualZoom, Zoom, deltaTime * 8);
    local FinalCFrame = (HumanoidRootPart.CFrame * CameraOffset) * CFrame.new(0, 0, -actualZoom) * CFrame.Angles(0, math.rad(180), 0);

    Camera.CFrame = FinalCFrame;
end

function hdCameraDefault:hdSetCameraCFrameOffset(newCameraCFrameOffset)
    cameraCFrameOffset = newCameraCFrameOffset;
end

function hdCameraDefault:hdGetOccludedCameraZoom(Character : Model, Origin : CFrame, CameraGoalCFrame : CFrame, Zoom : number) : CFrame
    local RaycastParameters = RaycastParams.new();
    RaycastParameters.FilterType = Enum.RaycastFilterType.Exclude;
    RaycastParameters.FilterDescendantsInstances = {Character};

    local RaycastResult = workspace:Raycast(Origin.Position, (CFrame.lookAt(Origin.Position, CameraGoalCFrame.Position).LookVector) * Zoom, RaycastParameters);
    if RaycastResult then
        return RaycastResult.Distance - 0.1;
    end

    return Zoom;
end

function hdCameraDefault:hdGetCameraCFrameOffset()
    local leftRight = -math.rad(realUserRotation.X);

    --// Calculate camera position and angle around the horizontal axis:
    local zoom = userZoom.Value;
    local xOffset = math.cos(leftRight) * zoom;
    local yOffset = math.sin(leftRight) * zoom;

    local yAngleOffset = -math.atan2(yOffset, xOffset);

    --// Use this axis to determine the two X and Z angles to multiply to obtain the proper vertical axis
    local CameraCFrame = CFrame.new(xOffset, 0, yOffset)
    * CFrame.Angles(0, math.rad(90), 0)
    * CFrame.Angles(0, yAngleOffset, 0);

    local X, Y, Z = CameraCFrame:ToOrientation();

    return CFrame.Angles(X, -Y, Z) * CFrame.Angles(math.rad(realUserRotation.Y), 0, 0);
end

local zoomInProgress = false;
function hdCameraDefault:hdZoom(Change)
    if zoomInProgress then
        return;
    end
    zoomInProgress = true;
    local newValue = math.clamp(userZoom.Value + Change, MIN_ZOOM, MAX_ZOOM);
    local Tween = TweenService:Create(userZoom, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
        Value = newValue;
    })
    local C; C = Tween.Completed:Connect(function()
        C:Disconnect();
        Tween:Destroy();
        Tween = nil;
        C = nil;
        zoomInProgress = false;
    end);

    Tween:Play();
end

-- local recentPosition;
-- local mouseDelta = Vector3.zero;

ContextActionService:BindAction("UpdateCameraUserOrientation", function(_, inputState : Enum.UserInputState, inputObject : InputObject)
    if inputState == Enum.UserInputState.Change then --and UserInputService.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition then
        --if recentPosition == nil then
        --    recentPosition = inputObject.position;
        --end

        -- mouseDelta = inputObject.Position - recentPosition;
        -- recentPosition = inputObject.Position;

        local mouseDelta = inputObject.Delta;

        userRotation = Vector3.new(
            userRotation.X + mouseDelta.X,
            math.clamp(userRotation.Y + mouseDelta.Y, MIN_Y_ROTATION, MAX_Y_ROTATION),
            0
        );
    end
end, false, Enum.UserInputType.MouseMovement);

ContextActionService:BindAction("CameraZoomMouse", function(_, inputState : Enum.UserInputState, inputObject : InputObject)
    if inputState == Enum.UserInputState.Change then
        -- hdCameraDefault:hdZoom(inputObject.Position.Z * 3);
    end
end, false, Enum.UserInputType.MouseWheel);

ContextActionService:BindAction("CameraZoomInKeyboard", function(_, inputState : Enum.UserInputState, _ : InputObject)
    if inputState == Enum.UserInputState.Begin then
        hdCameraDefault:hdZoom(-3);
    end
end, false, Enum.KeyCode.I);

ContextActionService:BindAction("CameraZoomOutKeyboard", function(_, inputState : Enum.UserInputState, _ : InputObject)
    if inputState == Enum.UserInputState.Begin then
        hdCameraDefault:hdZoom(3);
    end
end, false, Enum.KeyCode.O);

ContextActionService:BindAction("CameraPan", function(_, inputState : Enum.UserInputState, _ : InputObject)
    if inputState == Enum.UserInputState.Begin then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter;
    elseif inputState == Enum.UserInputState.End then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default;
    end
end, false, Enum.UserInputType.MouseButton2);

return hdCameraDefault;