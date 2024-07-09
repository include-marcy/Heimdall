local TweenService = game:GetService("TweenService");

local hera = game.ReplicatedStorage.Modules.Classes.Hera.src;
local heraTypes = require(hera.lib.heraTypes);
local heraClasses = hera.classes;

local heraSignal = require(heraClasses.heraSignal);

local heraAnimator = {
    prototype = {};
};
heraAnimator.__index = heraAnimator;

export type heraAnimator = typeof(setmetatable({} :: {
    objects : {
        GuiObject
    };
    keyframes : {
        heraTypes.heraTransitKeyframe
    };
    Played : heraSignal.heraSignal;
    Stopped : heraSignal.heraSignal;
    Ended : heraSignal.heraSignal;
    SpeedChanged : heraSignal.heraSignal;
    markers : {
        heraSignal.heraSignal
    };
    Position : number;
    IsPlaying : boolean;
}, {} :: typeof(heraAnimator)));

function heraAnimator.new(heraAnimatorCreateInfo : heraTypes.heraAnimatorCreateInfo) : heraAnimator
    local animator = setmetatable({}, heraAnimator);

    animator.keyframes = heraAnimatorCreateInfo.keyframes;
    animator.objects = heraAnimatorCreateInfo.objects;
    animator.Played = heraSignal.new();
    animator.Stopped = heraSignal.new();
    animator.Ended = heraSignal.new();
    animator.SpeedChanged = heraSignal.new();
    animator.markers = {};
    animator.Position = 0;
    animator.IsPlaying = false;
    animator._keyframeDataPool = {};

    for _, keyframe in animator.keyframes do
        if keyframe.keyframeType == "HERA_ANIMATION_MARKER_KEYFRAME" then
            local signal = heraSignal.new();

            animator.markers[keyframe.name] = signal;
        end
    end

    return animator;
end

function heraAnimator:heraPlay(fade : number, playbackSpeed : number)
    local animator : heraAnimator = self;
    animator.Played:Fire();

    if animator.IsPlaying then
        animator:heraStop(fade);
    end

    animator.IsPlaying = true;

    local timeElapsed = 0;
    while animator.IsPlaying do
        local deltaTime : number = task.wait();
        timeElapsed += deltaTime * playbackSpeed;

        animator.prototype._getFramesAndRunAt(animator, timeElapsed);
    end
end

function heraAnimator:heraStop(fade : number)
    local animator : heraAnimator = self;
    if not animator.IsPlaying then
        return;
    end

    animator.Stopped:Fire();
    animator.IsPlaying = false;
    animator.Position = 0;
    animator.Ended:Fire();
end

function heraAnimator:heraAdjustSpeed(speed : number)
    local animator : heraAnimator = self;
    animator.SpeedChanged:Fire();
end

function heraAnimator:heraGetAnimationMarkerReachedSignal(markerName : string) : heraSignal.heraSignal
    return self.markers[markerName];
end

function heraAnimator.prototype:_getFramesAndRunAt(time : number)
    local animator : heraAnimator = self;
    local frames = {};

    for _, keyframe in animator.keyframes do
        if not keyframe.played and keyframe.time <= time then
            keyframe.played = true;
            table.insert(frames, keyframe);
        end
    end

    for _, keyframe in frames do
        animator.prototype._updateKeyframe(animator, keyframe);
    end
end

function heraAnimator.prototype:_updateKeyframe(keyframe : heraTypes.heraTransitKeyframe)
    local animator : heraAnimator = self;
    local object = keyframe.object;
    local keyframeType = keyframe.keyframeType;
    local stateValues = keyframe.stateValues;

    if keyframeType == "HERA_ANIMATION_MARKER_KEYFRAME" then
        local signal = animator:heraGetAnimationMarkerReachedSignal(keyframe.name);
        signal:Fire(keyframe.arg);
    elseif keyframeType == "HERA_OBJECT_KEYFRAME" then
        local time = animator.prototype._getKeyframeTweenTime(animator, keyframe);
        local tweenData = keyframe.tweenData;
        local tween = TweenService:Create(object, TweenInfo.new(time, tweenData.easingStyle, tweenData.easingDirection), stateValues);
        tween:Play();

        local connection; connection = tween.Stopped:Connect(function()
            connection:Disconnect();
            tween:Destroy();
        end);
    end
end

function heraAnimator.prototype:_getKeyframeData(keyframe)
    local keyframeData = self._keyframeDataPool[keyframe];

    if not keyframeData then
        keyframeData = {
            lastUpdate = os.clock();
        };
    end

    return keyframeData;
end

function heraAnimator.prototype:_getKeyframeTweenTime(keyframe)
    local keyframeData = self.prototype._getKeyframeDataPool(self, keyframe);

    return self.playbackSpeed * (os.clock() - keyframeData.lastUpdate);
end

return heraAnimator;