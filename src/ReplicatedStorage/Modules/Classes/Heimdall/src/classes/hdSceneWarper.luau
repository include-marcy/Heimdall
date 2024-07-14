-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hd = script.Parent.Parent;
local hdLib = hd.lib;
local hdClasses = hd.classes;
local hdTypes = require(hdLib.hdTypes);

local hdDebugMessenger = require(hdClasses.hdDebugMessenger);
local hdProtectedCallResultEmitter = require(hdClasses.hdProtectedCallResultEmitter);
local hdScene = require(hdClasses.hdScene);
local hdSceneHandle = require(hdClasses.hdSceneHandle);
local hdSceneParticipant = require(hdClasses.hdSceneParticipant);

--// Constants
local function DEFAULT_HD_WARP_CALLBACK(sceneWarper : hdSceneWarper, sceneHandle : hdSceneHandle.hdSceneHandle, sceneParticipant : hdSceneParticipant.hdSceneParticipant) : hdTypes.hdProtectedCallResult
	local scene = sceneWarper.hdScene;
	local debugMessenger : hdDebugMessenger.hdDebugMessenger = scene.debugMessenger;
	local protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter = scene.protectedCaller;

	return debugMessenger:catch("hdDefaultWarp", protectedCaller:getProtectedCallResult(function()
		local hdSceneParticipantModel = sceneParticipant:hdGetModel();
		local hdSceneParticipantRootAssembly = hdSceneParticipantModel:WaitForChild("HumanoidRootPart", 25);
		if not hdSceneParticipantRootAssembly then
			return;
		end
		if not hdSceneParticipantRootAssembly:IsA("BasePart") then
			return;
		end

		local hdHandleCFrame = sceneHandle:hdGetHandleAssemblyCFrame();
		local hdHandleObjectSize = sceneHandle:hdGetHandleAssemblySize();

		hdSceneParticipantRootAssembly.CFrame = hdHandleCFrame * CFrame.new(0, 2 + hdHandleObjectSize.Y / 2, 0);

		return;
	end));
end

--// Class Declaration
local hdSceneWarper = {};
hdSceneWarper.__index = hdSceneWarper;

export type hdSceneWarper = typeof(setmetatable({} :: {
	hdScene : hdScene.hdScene;
	hdWarpType : hdTypes.hdWarpType;
	hdWarpCallback : hdTypes.hdWarpCallback;
}, {} :: typeof(hdSceneWarper)));

function hdSceneWarper.new(hdSceneWarperCreateInfo : hdTypes.hdSceneWarperCreateInfo) : hdSceneWarper
	local scene : hdScene.hdScene = hdSceneWarperCreateInfo.hdScene;
	local hdWarpType : hdTypes.hdWarpType = hdSceneWarperCreateInfo.hdWarpType;
	local hdWarpCallback = hdSceneWarperCreateInfo.hdWarpCallback;

	local sceneWarper = setmetatable({
		hdScene = scene;
		hdWarpType = hdWarpType;
		hdWarpCallback = hdWarpCallback or DEFAULT_HD_WARP_CALLBACK;
	}, hdSceneWarper);

	return sceneWarper;
end

function hdSceneWarper:Warp(sceneHandle : hdSceneHandle.hdSceneHandle, sceneParticipant : hdSceneParticipant.hdSceneParticipant) : hdTypes.hdProtectedCallResult
	local sceneWarper : hdSceneWarper = self;

	return sceneWarper:hdWarpCallback(sceneHandle, sceneParticipant);
end

return hdSceneWarper;