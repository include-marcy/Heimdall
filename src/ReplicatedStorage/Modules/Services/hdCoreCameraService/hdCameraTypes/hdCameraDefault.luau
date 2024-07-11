local hdCameraDefault = {};

local cameraCFrameOffset = CFrame.new(0, 1, -10);
local userRotation =  Vector2.zero;

function hdCameraDefault:Update(deltaTime : number)
    local Character = self.parentService.Character;
    local Camera = workspace.CurrentCamera;

    if not Character then
        return;
    end

    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");
    local CameraOffset = hdCameraDefault:hdGetCameraCFrameOffset();

    Camera.CFrame = HumanoidRootPart.CFrame * CameraOffset;
end

function hdCameraDefault:hdSetCameraCFrameOffset(newCameraCFrameOffset)
    cameraCFrameOffset = newCameraCFrameOffset;
end

function hdCameraDefault:hdGetCameraCFrameOffset()
    return cameraCFrameOffset;
end

return hdCameraDefault;