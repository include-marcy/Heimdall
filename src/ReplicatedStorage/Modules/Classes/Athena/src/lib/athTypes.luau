-- This file is part of the Athena library and is licensed under MIT License; see LICENSE.md for details

local athTypes = {};

export type athBenchCreateInfo = {

};

export type athTokenCreateInfo = {
    tokenName : string;
    tokenValue : any;
};

export type athMobileButtonType = "ATH_BUTTON_NORMAL" | "ATH_BUTTON_JOYSTICK";
export type athInformedInputType = "ATH_KEYBOARD" | "ATH_TOUCH_SCREEN" | "ATH_GAMEPAD" | "ATH_VR";

export type athMobileButtonCreateInfo = {
    name : string;
    organizationLayer : Frame;
    buttonType : athMobileButtonType?;
    displayText : string;
    displayIcon : string;
    systemSize : number;
    color : Color3?;
    textColor : Color3?;
    iconColor : Color3?;
    rich : boolean?;
    active : boolean?;
};

export type athPerformanceRatingDiagnosticInfo = {
    patient : any;
    diagnose : {string}; -- a list of function names to try
    athBench : any; -- an athBench instance
};

export type athPerformanceMedal = "ATH_P_MEDAL_GOLD" | "ATH_P_MEDAL_SILVER" | "ATH_P_MEDAL_BRONZE" | "ATH_P_MEDAL_NONE";

export type athConnectionCreateInfo = {
	signal : any;
	callback : (any) -> (any);
};

return athTypes;