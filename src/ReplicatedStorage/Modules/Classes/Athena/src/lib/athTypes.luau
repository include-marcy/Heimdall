-- This file is part of the Athena library and is licensed under MIT License; see LICENSE.md for details

local athTypes = {};

export type athHostCreateInfo = {
    projectRoot : ModuleScript; -- Descibes the project object
    projectClientRoot : ModuleScript; -- Describes the project object that is built for client contexts
    projectServerRoot : ModuleScript; -- Describes the project object that is built for server contexts

    projectTypes : ModuleScript; -- Describes the strict typing information of the project
    projectClasses : Folder; -- Describes the list of all classes in the project
    projectTokens : ModuleScript; -- Describes the list of all tokens in the project (Tokens are immutable fast flags for the project)
    projectTests : Folder; --- Describes the list of all tests in the project to be performed by Athena
    projectPackages : Folder; -- Describes the list of all packages in the project to be merged into the project by Athena
    projectNetcodeObjects : Folder; -- Describes the list of all netcode objects the project might want to expose
};

export type athMobileButtonType = "ATH_BUTTON_NORMAL" | "ATH_BUTTON_JOYSTICK";
export type athInformedInputType = "ATH_KEYBOARD" | "ATH_TOUCH_SCREEN" | "ATH_GAMEPAD" | "ATH_VR";

export type athCapturableInputs = Enum.KeyCode | Enum.UserInputType;

export type athInputStreamData = {
    inputString : string;
    began : boolean;
};

export type athInputStreamPathCreateInfo = {
    inputType : athInformedInputType;
    inputToCapture : string;
    inputMobileButtonType : athMobileButtonType?;
    transform : (athInputStreamData) -> (athInputStreamData)
};

export type athBenchCreateInfo = {
    athProject : any;
};

export type athTokenCreateInfo = {
    tokenName : string;
    tokenValue : any;
};

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