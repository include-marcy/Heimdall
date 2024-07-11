-- This file is part of the Hera library and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

local hera = game.ReplicatedStorage.Modules.Classes.Hera.src;
local heraClasses = hera.classes;
local heraTypes = require(hera.lib.heraTypes);

local heraAnimator = require(heraClasses.heraAnimator);

local heraInterface = {
    prototype = {};
};
heraInterface.__index = heraInterface;

export type heraInterface = typeof(setmetatable({} :: {
    gui : ScreenGui | SurfaceGui | BillboardGui | PluginGui;
}, {} :: typeof(heraInterface)));

function heraInterface.new(heraInterfaceCreateInfo : heraTypes.heraInterfaceCreateInfo) : heraInterface
    local interface = setmetatable({}, heraInterface);

    interface.gui = heraInterfaceCreateInfo.gui;

    return interface;
end

function heraInterface:heraTransit(heraTransitInfo : heraTypes.heraTransitInfo) : heraAnimator.heraAnimator
    if not self:heraValidateTransit(heraTransitInfo) then
        return;
    end

    return self.prototype._heraRunTransit(self, heraTransitInfo.heraTransit, heraTransitInfo.playbackSpeed) :: heraAnimator.heraAnimator;
end

function heraInterface:heraValidateTransit(heraTransitInfo : heraTypes.heraTransitInfo) : boolean
    local objects = heraTransitInfo.heraTransit.transitObjects;

    for _, object in objects do
        if not self:heraIsContainedWithin(object) then
            return false;
        end
    end

    return true;
end

function heraInterface:heraPlaySound(soundData : any)
    local sound = Instance.new("Sound");

    pcall(function()
        for i, v in soundData do
            sound[i] = v;
        end
    end)

    sound:Play();
    task.spawn(function()
        sound.Ended:Wait();
    end)

    return sound;
end

function heraInterface:heraIsContainedWithin(guiObject : GuiObject) : boolean
    return guiObject:IsDescendantOf(self.gui);
end

function heraInterface.prototype:_heraRunTransit(heraTransit : heraTypes.heraTransit, playbackSpeed : number) : heraAnimator.heraAnimator
    local objects = heraTransit.transitObjects;
    local keyframes = heraTransit.transitKeyframes;
    local assets = heraTransit.transitKeyframes;

    local heraAnimatorCreateInfo = {
        objects = objects;
        keyframes = keyframes;
    }
    local animator = heraAnimator.new(heraAnimatorCreateInfo);
    if playbackSpeed then
        animator:heraAdjustSpeed(playbackSpeed);
    end

    local markerConnections = {};
    for _, keyframe in keyframes do
        if keyframe.keyframeType == "HERA_ANIMATION_MARKER_KEYFRAME" then
            local signal = animator:heraGetAnimationMarkerReachedSignal(keyframe.name);
            local connection = signal:Connect(function()
                if keyframe.playSound then
                    local sound = assets[keyframe.sound];
                    if sound then
                        self:heraPlaySound(sound);
                    end
                end
            end);
            table.insert(markerConnections, connection);
        end
    end

    animator:heraPlay();
    task.spawn(function()
        animator.Ended:Wait();

        for _, connection in markerConnections do
            connection:Disconnect();
        end
    end);

    return animator;
end

return heraInterface;