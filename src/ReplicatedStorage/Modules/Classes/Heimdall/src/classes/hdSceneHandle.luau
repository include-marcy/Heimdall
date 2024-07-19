-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

--// Class Declaration
local hdSceneHandle = {};
hdSceneHandle.__index = hdSceneHandle;

export type hdSceneHandle = typeof(setmetatable({} :: {
	name : string;
	_handleTags : any;
	_CFrame : CFrame;
	_Size : Vector3;
}, {} :: typeof(hdSceneHandle)));

--[=[
	@class hdSceneHandle
	Creates an hdSceneHandle, an object which can be partitioned within an hdScene object.
	An hdSceneHandle acts as an entry point for any hdSceneParticipant object, therefore they are necessary for any character interaction with
	any hdScene.

	@param hdSceneHandleCreateInfo;
	@return hdSceneHandle;
]=]
function hdSceneHandle.new(hdSceneHandleCreateInfo : hdTypes.hdSceneHandleCreateInfo) : hdSceneHandle
	local sceneHandle = setmetatable({}, hdSceneHandle);

	sceneHandle.name = hdSceneHandleCreateInfo.handleName;
	sceneHandle._handleTags = hdSceneHandleCreateInfo.handleTags;
	sceneHandle._CFrame = hdSceneHandleCreateInfo.handleCFrame;
	sceneHandle._Size = hdSceneHandleCreateInfo.handleSize;

	sceneHandle.Properties = {
		MaxParticipants = hdSceneHandleCreateInfo.handleMaxParticipants or math.huge;
		MinParticipants = hdSceneHandleCreateInfo.handleMinParticipants or 1;
	};

	return sceneHandle;
end

--[=[
	@class hdSceneHandle
	Returns the handle's assembly CFrame.
	This is defined as the destination where a scene participant's humanoid root part or assembly root will be moved to.

	@return CFrame;
]=]
function hdSceneHandle:hdGetHandleAssemblyCFrame() : CFrame
	local sceneHandle : hdSceneHandle = self;

	return sceneHandle._CFrame;
end

--[=[
	@class hdSceneHandle
	Returns this hdSceneHandle's assembly size, which is used to calculate the final position of this handles destination.

	@return Vector3;
]=]
function hdSceneHandle:hdGetHandleAssemblySize() : Vector3
	local sceneHandle : hdSceneHandle = self;

	return sceneHandle._Size;
end

--[=[
	@class hdSceneHandle
	Returns whether the given handle tag name is present in this hdSceneHandle.

	@param handleTagName : string;
	@return boolean;
]=]
function hdSceneHandle:hdGetHandleTag(handleTagName : string) : boolean
	local sceneHandle : hdSceneHandle = self;

	return sceneHandle._handleTags[handleTagName];
end

return hdSceneHandle;