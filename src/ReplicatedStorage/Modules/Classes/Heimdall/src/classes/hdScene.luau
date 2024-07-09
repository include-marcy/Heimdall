--!strict
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

local hdClasses = script.Parent;
local hdDebugMessenger = require(hdClasses.hdDebugMessenger);
local hdProtectedCallResultEmitter = require(hdClasses.hdProtectedCallResultEmitter);
local hdSceneHandle = require(hdClasses.hdSceneHandle);
local hdSceneParticipant = require(hdClasses.hdSceneParticipant);

local hdScene = {
	prototype = {};
};
hdScene.__index = hdScene;

export type hdScene = typeof(setmetatable({}::{
	debugMessenger : hdDebugMessenger.hdDebugMessenger;
	protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter;
	sceneHandles : {hdSceneHandle.hdSceneHandle};
	participants : {hdSceneParticipant.hdSceneParticipant};
}, {} :: typeof(hdScene)));

--[=[
	Returns a new hdScene, a built-in framework type of ROBLOX object that is designed to facilitate a predictable, error-free and advanced methodology
	for managing and orchestrating the loading and unloading of hypothetical scenes.
	
	The design philosophy of the hdScene object is loosely based on the following scenario:
		Imagine you wish to create a game that features a number of different possible scenes, each with their own unique set of objects, scripts and logic.
		
		However, you also want to ensure that these scenes are loaded and unloaded in a safe and error-free manner, without any unforeseen
		consequences or bugs.
		
		You also want to ensure that these scenes can be localized or globalized to anyone in the server, regardless of time or state.
		All of these scenes might co-exist with a larger game state or world seperate from the scenes, and should not interfere with each other.
		
		You probably also want to ensure that these scenes can be easily managed and orchestrated by a centralized server-side mastermind.

	The hdScene object and its dependencies provide a perfect solution to this problem, allowing instanced, server-side logic to orchestrate the
	loading and unloading of these scenes, while also providing a safe and error-free environment for developers to work within.

	@param hdSceneCreateInfo;
	@return hdScene;
]=]
function hdScene.new(hdSceneCreateInfo : hdTypes.hdSceneCreateInfo) : hdScene
	local scene = setmetatable({}, hdScene);
	
	scene.debugMessenger = hdSceneCreateInfo.debugMessenger;
	
	local hdProtectedCallResultEmitterCreateInfo : hdTypes.hdProtectedCallEmitterCreateInfo = {};
	scene.protectedCaller = hdProtectedCallResultEmitter.new(hdProtectedCallResultEmitterCreateInfo);
	scene.sceneHandles = {};
	scene.participants = {};

	return scene :: hdScene;
end

function hdScene.prototype._callInternal(scene : hdScene, f, ...) : hdTypes.hdProtectedCallResult
	local debugMessenger : hdDebugMessenger.hdDebugMessenger = scene.debugMessenger;
	local protectedCaller : hdProtectedCallResultEmitter.hdProtectedCallResultEmitter = scene.protectedCaller;

	return debugMessenger:catch(f, protectedCaller:getProtectedCallResult(scene.prototype[f], scene, ...));
end

function hdScene:hdGetSceneParticipants() : {hdSceneParticipant.hdSceneParticipant}
	local scene : hdScene = self;
	
	return scene.participants;
end

function hdScene:hdCreateSceneHandle(hdSceneHandleCreateInfo : hdTypes.hdSceneHandleCreateInfo) : hdTypes.hdProtectedCallResult
	local scene : hdScene = self;
	
	hdSceneHandleCreateInfo.handleScene = scene::hdScene;

	return scene.prototype._callInternal(scene, "_createSceneHandleInternal", hdSceneHandleCreateInfo);
end

function hdScene.prototype:_createSceneHandleInternal(hdSceneHandleCreateInfo : hdTypes.hdSceneHandleCreateInfo)
	local scene : hdScene = self;
	local hdSceneHandle = hdSceneHandle.new(hdSceneHandleCreateInfo);

	table.insert(scene.sceneHandles, hdSceneHandle);
end

function hdScene:hdAddSceneParticipant(sceneParticipant : hdSceneParticipant.hdSceneParticipant) : hdTypes.hdProtectedCallResult
	local scene : hdScene = self;
	
	return scene.prototype._callInternal(scene, "_addSceneParticipantInternal", sceneParticipant);
end

function hdScene.prototype:_addSceneParticipantInternal(sceneParticipant : hdSceneParticipant.hdSceneParticipant)
	local scene : hdScene = self;

	table.insert(scene.participants, sceneParticipant);
end

function hdScene:hdRemoveSceneHandle(sceneHandle : hdSceneHandle.hdSceneHandle) : hdTypes.hdProtectedCallResult
	local scene : hdScene = self;

	return scene.prototype._callInternal(scene, "_removeSceneHandleInternal", sceneHandle);
end

function hdScene.prototype:_removeSceneHandleInternal(sceneHandle : hdSceneHandle.hdSceneHandle)
	local scene : hdScene = self;

	local index = table.find(scene.sceneHandles, sceneHandle);
	if not index then
		return;
	end

	table.remove(scene.sceneHandles, index);
end

function hdScene:hdRemoveSceneParticipant(sceneParticipant : hdSceneParticipant.hdSceneParticipant) : hdTypes.hdProtectedCallResult
	local scene : hdScene = self;

	return scene.prototype._callInternal(scene, "_removeSceneParticipantInternal", sceneParticipant);
end

function hdScene.prototype:_removeSceneParticipantInternal(sceneParticipant : hdSceneParticipant.hdSceneParticipant)
	local scene : hdScene = self;

	local index = table.find(scene.participants, sceneParticipant);
	if not index then
		return;
	end

	table.remove(scene.participants, index);
end

return hdScene;