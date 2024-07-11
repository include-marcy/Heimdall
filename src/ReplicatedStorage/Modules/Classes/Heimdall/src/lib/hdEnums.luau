--!strict

--[=[
	The hdEnums module is a container which holds references to a series of re-used data types across Heimdall.

	@module hdEnums
	@__index prototype
]=]

local hdEnums = {};

local enumDebugOutput = {
	__tostring = function(self)
		return self.Value;
	end;
};

export type hdEnum = typeof(setmetatable({} :: {
	Name : string;
	Value : any;
	HdEnumFamily : string;
}, {} :: typeof(enumDebugOutput)));

local function hdDefineEnum(enumData) : hdEnum
	return setmetatable(enumData, enumDebugOutput);
end

hdEnums["hdCameraType"] = {
	hdCameraDefault = hdDefineEnum {
		Name = "hdCameraDefault";
		Value = 1;
        HdEnumFamily = "hdCameraType";
	} :: hdEnum;
	hdCameraScriptable = hdDefineEnum {
		Name = "hdCameraScriptable";
		Value = 2;
        HdEnumFamily = "hdCameraType";
	} :: hdEnum;
};

hdEnums["hdHumanoidState"] = {
	hdIdling = hdDefineEnum { --// The hdHumanoid state which is enabled when not moving nor doing anything else
		Name = "hdIdling";
		Value = 1;
        HdEnumFamily = "hdHumanoidState";
	} :: hdEnum;
	hdWalking = hdDefineEnum { --// The hdHumanoid state which is enabled while moving
		Name = "hdWalking";
		Value = 2;
        HdEnumFamily = "hdHumanoidState";
	} :: hdEnum;
	hdJumping = hdDefineEnum { --// The hdHumanoid state which is enabled briefly after jumping
		Name = "hdJumping";
		Value = 3;
        HdEnumFamily = "hdHumanoidState";
	} :: hdEnum;
	hdFalling = hdDefineEnum { --// The hdHumanoid state which is enabled when falling in the air
		Name = "hdFalling";
		Value = 4;
        HdEnumFamily = "hdHumanoidState";
	} :: hdEnum;
	hdLanding = hdDefineEnum { --// The hdHumanoid state which is enabled when landing on the ground, briefly.
		Name = "hdLanding";
		Value = 5;
        HdEnumFamily = "hdHumanoidState";
	} :: hdEnum;
	hdSwimming = hdDefineEnum { --// The hdHumanoid state which is enabled while in water
		Name = "hdSwimming";
		Value = 6;
        HdEnumFamily = "hdHumanoidState";
	} :: hdEnum;
	hdRagdolling = hdDefineEnum { --// The hdHumanoid state which is functionally similar to hdParalyzed, but automatically creates constraints to cause joints to be freely rotated
		Name = "hdRagdolling";
		Value = 7;
        HdEnumFamily = "hdHumanoidState";
	} :: hdEnum;
	hdParalyzed = hdDefineEnum { --// The hdHumanoid state of free control; The same as your character being a rigid body in the scene
		Name = "hdParalyzed";
		Value = 8;
        HdEnumFamily = "hdHumanoidState";
	} :: hdEnum;
};

hdEnums["hdInstanceType"] = {
	hdRootInstance = hdDefineEnum {
		Name = "hdRootInstance";
		Value = 1;
		HdEnumFamily = "hdInstanceType";
	};
	hdClientInstance = hdDefineEnum {
		Name = "hdRootInstance";
		Value = 2;
		HdEnumFamily = "hdInstanceType";
	};
	hdServerInstance = hdDefineEnum {
		Name = "hdRootInstance";
		Value = 3;
		HdEnumFamily = "hdInstanceType";
	};
};

hdEnums["hdHandleType"] = {
	hdRootHandle = hdDefineEnum {
		Name = "hdRootHandle";
		Value = 1;
		HdEnumFamily = "hdHandleType";
	};
	hdHandle = hdDefineEnum {
		Name = "hdHandle";
		Value = 2;
		HdEnumFamily = "hdHandleType";
	};
};

hdEnums["hdProtectedCallResults"] = {
	Passed = hdDefineEnum {
		Name = "Passed";
		Value = 1;
		HdEnumFamily = "hdProtectedCallResults";
	} :: hdEnum;
	Failed = hdDefineEnum {
		Name = "Failed";
		Value = 2;
		HdEnumFamily = "hdProtectedCallResults";
	} :: hdEnum;
};

hdEnums["hdFailureTypes"] = {
	hdBadArgs = hdDefineEnum {
		Name = "hdBadArgs";
		Value = "HD_BAD_ARGS";
		HdEnumFamily = "hdFailureTypes";
	} :: hdEnum;
	hdServiceCompileFailure = hdDefineEnum {
		Name = "hdServiceCompileFailure";
		Value = "HD_SERVICE_CMP_FAILURE";
		HdEnumFamily = "hdFailureTypes";
	} :: hdEnum;
	hdServiceFailure = hdDefineEnum {
		Name = "hdServiceFailure";
		Value = "HD_SERVICE_FAILURE";
		HdEnumFamily = "hdFailureTypes";
	} :: hdEnum;
	hdDuplicateServiceFailure = hdDefineEnum {
		Name = "hdDuplicateServiceFailure";
		Value = "HD_SERVICE_DUPLICATE";
		HdEnumFamily = "hdFailureTypes";
	} :: hdEnum;
	hdCommandChainBusy = hdDefineEnum {
		Name = "hdCommandChainBusy";
		Value = "HD_COMMAND_CHAIN_BUSY";
		HdEnumFamily = "hdFailureTypes";
	} :: hdEnum;
	hdCommandChainStateSetFail = hdDefineEnum {
		Name = "hdCommandChainStateSetFail";
		Value = "HD_COMMAND_CHAIN_STATE_SET_FAIL";
		HdEnumFamily = "hdFailureTypes";
	} :: hdEnum;
	hdUnknown = hdDefineEnum {
		Name = "hdUnknown";
		Value = "HD_UNKNOWN";
		HdEnumFamily = "hdFailureTypes";
	} :: hdEnum;
}

hdEnums["hdCommandDispatchModes"] = {
	hdCommandDispatchModeSerial = hdDefineEnum {
		Name = "hdCommandDispatchModeSerial";
		Value = 1;
		HdEnumFamily = "hdCommandDispatchModes";
	} :: hdEnum;
	hdCommandDispatchModeParallel = hdDefineEnum {
		Name = "hdCommandDispatchModeParallel";
		Value = 2;
		HdEnumFamily = "hdCommandDispatchModes";
	} :: hdEnum;
};


return hdEnums;