--!strict
local hd = script.Parent.Parent;
local hdLib = hd.lib;
local hdClasses = hd.classes;
local hdTypes = require(hdLib.hdTypes);
local hdDebugMessenger = require(hdClasses.hdDebugMessenger);
local hdProtectedCallResultEmitter = require(hdClasses.hdProtectedCallResultEmitter);
local hdScene = require(hdClasses.hdScene);
local hdSceneHandle = require(hdClasses.hdSceneHandle);
local hdSceneParticipant = require(hdClasses.hdSceneParticipant);

local hdSceneWarper = {};
hdSceneWarper.__index = hdSceneWarper;

export type hdSceneWarper = typeof(setmetatable({} :: {
	hdScene : hdScene.hdScene;
	hdWarpType : hdTypes.hdWarpType;
	hdWarpCallback : hdTypes.hdWarpCallback;
}, {} :: typeof(hdSceneWarper)));

local function DEFAULT_HD_WARP_CALLBACK(sceneWarper : hdSceneWarper, hdSceneHandle : hdSceneHandle.hdSceneHandle, hdSceneParticipant : hdSceneParticipant.hdSceneParticipant) : hdTypes.hdProtectedCallResult
	local hdScene = sceneWarper.hdScene;
	local debugMessenger : hdDebugMessenger.hdDebugMessenger = hdScene.debugMessenger;
	local protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter = hdScene.protectedCaller;

	return debugMessenger:catch("hdDefaultWarp", protectedCaller:getProtectedCallResult(function()
		local hdSceneParticipantModel = hdSceneParticipant:hdGetModel();
		local hdSceneParticipantRootAssembly = hdSceneParticipantModel:WaitForChild("HumanoidRootPart", 25);
		if not hdSceneParticipantRootAssembly then
			return;
		end
		if not hdSceneParticipantRootAssembly:IsA("BasePart") then
			return;
		end

		local hdHandleCFrame = hdSceneHandle:hdGetHandleAssemblyCFrame();
		local hdHandleObjectSize = hdSceneHandle:hdGetHandleAssemblySize();

		hdSceneParticipantRootAssembly.CFrame = hdHandleCFrame * CFrame.new(0, 2 + hdHandleObjectSize.Y / 2, 0);

		return;
	end));
end

function hdSceneWarper.new(hdSceneWarperCreateInfo : hdTypes.hdSceneWarperCreateInfo) : hdSceneWarper
	local hdScene : hdScene.hdScene = hdSceneWarperCreateInfo.hdScene;
	local hdWarpType : hdTypes.hdWarpType = hdSceneWarperCreateInfo.hdWarpType;
	local hdWarpCallback = hdSceneWarperCreateInfo.hdWarpCallback;

	local sceneWarper = setmetatable({
		hdScene = hdScene;
		hdWarpType = hdWarpType;
		hdWarpCallback = hdWarpCallback or DEFAULT_HD_WARP_CALLBACK;
	}, hdSceneWarper);
	
	return sceneWarper;
end

function hdSceneWarper:Warp(hdSceneHandle : hdSceneHandle.hdSceneHandle, hdSceneParticipant : hdSceneParticipant.hdSceneParticipant) : hdTypes.hdProtectedCallResult
	local sceneWarper : hdSceneWarper = self;
	
	return sceneWarper:hdWarpCallback(hdSceneHandle, hdSceneParticipant);
end

return hdSceneWarper;