-- This file is part of the Hera library and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

local heraTypes = {};

export type heraInterfaceCreateInfo = {
    gui : ScreenGui | BillboardGui | SurfaceGui | PluginGui
};

export type heraAnimatorCreateInfo = {
    objects : {
        GuiObject
    };
    keyframes : {
        heraTransitKeyframe
    };
};

export type heraTransitPlaybackStyle = "HERA_PLAYBACK_STYLE_LINEAR"   | "HERA_PLAYBACK_STYLE_QUAD" | "HERA_PLAYBACK_STYLE_EXPONENTIAL"
                                     | "HERA_PLAYBACK_STYLE_CIRCULAR" | "HERA_PLAYBACK_STYLE_BACK" | "HERA_PLAYBACK_STYLE_BOUNCE"
                                     | "HERA_PLAYBACK_STYLE_SPRING";

export type heraTransitAsset = Sound | ImageLabel | string
                             | GuiObject | Instance;

export type heraTransitStateType = UDim    | UDim2   | Color3
                                 | number  | string  | boolean
                                 | Vector2 | Vector3 | CFrame;

export type heraKeyframeType = "HERA_OBJECT_KEYFRAME" | "HERA_ANIMATION_MARKER_KEYFRAME";

export type heraTransitKeyframe = {
    object : GuiObject | Instance;
    time : number;
    name : string?;
    arg : any?;
    keyframeType : heraKeyframeType;
    tweenData : {
        easingStyle : Enum.EasingStyle;
        easingDirection : Enum.EasingDirection;
    };
    stateValues : {
        [string] : heraTransitStateType;
    };
};

--// A heraTransit is defined as a higher order preset animation played on a collection of gui objects in Roblox.
--// Defining a heraTransit and playing them back using code is designed to be made easy and simple with Hera.
export type heraTransit = {
    transitObjects : {
        GuiObject
    };
    transitAssets : {
        heraTransitAsset
    };
    transitKeyframes : {
        heraTransitKeyframe
    };
};

export type heraTransitInfo = {
    heraTransit : heraTransit;
    heraTransitPlaybackStyle : heraTransitPlaybackStyle;
    playbackSpeed : number;
};

return heraTypes;