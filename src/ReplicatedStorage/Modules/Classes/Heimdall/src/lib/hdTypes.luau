--!strict

--[=[
	The hdTypes module exports a series of important hdTypes that are re-used throughout Heimdall's environment, and are intended for safe usage outside of Heimdall's
	environment.

	@module hdTypes
	@__index prototype
]=]
local hdEnums = require(script.Parent.hdEnums);
local hdTypes = {};

export type hdObjectCreateInfo = {
	User : string?;
};

export type hdDebugMessengerCreateInfo = {
	name : string?;
	middleware : (string, hdProtectedCallResult) -> ()?;
	onError : (string, hdProtectedCallResult) -> ()?;
};

export type hdInstanceCreateInfo = {
	debugMessenger : any;
	launchToken : any;
};

export type hdClientCreateInfo = {
	player : Player;
};

export type hdVersion = {
	major : number;
	minor : number;
	patch : number;
	isRelease : boolean;
};

export type hdLaunchTokenCreateInfo = {
	launchTitle : string;
	hdVersion : hdVersion;
	settings : any;
};

export type hdFenceState = "HD_FENCE_SIGNALED" | "HD_FENCE_UNSIGNALED";

export type hdFenceCreateInfo = {
	fenceInitialState : hdFenceState?;
};

export type hdCommandInvocationType = "HD_CMD_INVOC_TYPE_ASYNC" | "HD_CMD_INVOC_TYPE_SYNC" | "HD_COMMAND_INVOC_TYPE_MIXED";
export type hdCommandSafetyLevel =
	"HD_CMD_SAFETY_LEVEL_HIGH" | --// All commands are executed with a safe hdProtectedCallResultEmitter object.
	"HD_CMD_SAFETY_LEVEL_MEDIUM" | --// All commands are executed with error handling, but no hdProtectedCallResultEmitter object results.
	"HD_CMD_SAFETY_LEVEL_NONE"; --// All commands are executed without error handling, meaning 1 error may interrupt the remaining chain's invoke queue.
export type hdCommand = "HD_COMP" | "HD_BOOT" | "HD_STRT" | "HD_UPDT" | "HD_ADD_CHR" | "HD_ADD_PLR";

export type hdCommandChainFunctionMap = {[hdCommand] : string};

export type hdCommandInfo = {
	name : string;
	commands : {hdCommand};
	commandInvocationType : hdCommandInvocationType;
	commandSafetyLevel : hdCommandSafetyLevel;
	commandChainFunctionMap : hdCommandChainFunctionMap?;
};

export type hdServiceManagerCreateInfo = {
	services : Folder;
	debugMessenger : any;
};

export type hdCompileServicesInfo = {
	timeOut : number?;
	--async : boolean?;
};

export type hdCommandDirection = "HD_COMMAND_DIRECTION_HIGHEST_FIRST" | "HD_COMMAND_DIRECTION_LOWEST_FIRST";
export type hdCommandDispatchMode = hdEnums.hdEnum;
export type hdCommandChainCreateInfo = {
	commandedStructs : {[string] : any};
	commandDirection : hdCommandDirection?;
	commandInfo : hdCommandInfo;
	debugMessenger : any;
};
export type hdCommandChainState = "HD_COMMAND_CHAIN_BUSY" | "HD_COMMAND_CHAIN_FREE";

export type hdServiceCreateInfo = {
	name : string;
	isVirtual : boolean?;
	commandDispatchMode : hdCommandDispatchMode?;
	loadPriority : number;
	moduleReference : ModuleScript?;
};

export type hdCompiledServiceCreateInfo = {
	compileRoot : Instance;
} & hdServiceCreateInfo;

export type hdParallelServiceCreateInfo = {
	hdActorCount : number;
} & hdServiceCreateInfo;

export type hdActorCreateInfo = {
	hdParallelServiceObj : ModuleScript;
};

export type hdEntityCreateInfo = {
	name : string;
	tiedTo : Instance?;
	components : {hdComponentCreateInfo};
	debugMessenger : any;
	componentManager : any;
};

export type hdComponentCreateInfo = {
	name : string;
	details : any;
};

export type hdComponentManagerCreateInfo = {
	debugMessenger : any;
};

export type hdInternalComponentCreateInfo = {
	refComponent : any;
};

export type hdCoreModuleManagerCreateInfo = {
	coreModules : Folder;
	debugMessenger : any;
};

export type hdWrappingCreateInfo = {
	instance : Instance;
};

export type hdCharacterCreateInfo = {
	physical : Model;
};

export type hdHumanoidCreateInfo = {
	hdCharacter : any;
};

export type hdCoreModuleRuntimeBehavior = "HD_CORE_CHARACTER" | "HD_CORE_PLAYER";

--// hd core modules extend the service type so that we can reuse hdCommandChain structure to execute hdCoreModule functions with the hdCoreModuleManager
export type hdCoreModuleCreateInfo = {
	runtimeBehavior : hdCoreModuleRuntimeBehavior;
} & hdServiceCreateInfo;

export type sceneOwner = string | number;
export type hdSceneCreateInfo = {
	sceneName : string;
	sceneOwner : sceneOwner;
	debugMessenger : any;
};

export type hdSceneHandleCreateInfo = {
	handleName : string;
	handleScene : any;
	handleCFrame : CFrame;
	handleMaxParticipants : number?;
	handleMinParticipants : number?;
	handleTags : any;
};

export type hdWarpType = "HD_DEFAULT_SET_ROOT_CFRAME_CALLBACK" | "HD_CUSTOM_WARP_CALLBACK";
export type hdWarpCallback = (hdSceneWarper : any, hdSceneHandle : any, hdSceneParticipant : any) -> (hdProtectedCallResult);
export type hdSceneWarperCreateInfo = {
	hdWarpType : hdWarpType;
	debugMessenger : any;
	hdScene : any;
	hdWarpCallback : hdWarpCallback?;
};

export type hdWarpToInfo = {
	Targets : {Model?};
};

export type hdSceneParticipantCreateInfo = {
	participantClient : any;
	participantInstance : Model;
	debugMessenger : any;
};

export type hdProtectedCallEmitterCreateInfo = {};

export type hdProtectedCallResult = HD_SUCCESS | HD_FAILURE;
export type hdFailureType = hdEnums.hdEnum;

export type hdSuccessCreateInfo = {};

export type hdFailureCreateInfo = {
	failureType : hdFailureType?;
	errorString : string?;
	traceback : string?;
	scr : Instance?;
};

export type HD_SUCCESS = typeof(setmetatable({} :: {
	scr : nil;
	FailureType : hdFailureType;
	ErrorString : string;
	Traceback : string;
	ProtectedCallResult : number;
	Success : boolean;
}, {
	__tostring = function()
		return "HD_SUCCESS";
	end;
	__eq = function(_, val)
		return val == "HD_SUCCESS";
	end;
} :: {
	__tostring : () -> "HD_SUCCESS";
	__eq : (any, string) -> boolean;
}));

export type HD_FAILURE = typeof(setmetatable({} :: {
	scr : Instance?;
	FailureType : hdFailureType;
	ErrorString : string;
	Traceback : string;
	ProtectedCallResult : number;
	Success : boolean;
}, {
	__tostring = function()
		return "HD_FAILURE";
	end;
	__eq = function(_, val)
		return val == "HD_FAILURE";
	end;
} :: {
	__tostring : () -> "HD_FAILURE";
	__eq : (any, string) -> boolean;
}));

export type hdConnectionCreateInfo = {
	signal : any;
	callback : (any) -> (any);
};

return hdTypes;