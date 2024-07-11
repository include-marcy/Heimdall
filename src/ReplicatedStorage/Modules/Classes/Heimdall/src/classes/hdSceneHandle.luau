--!strict
local hdTypes = require(script.Parent.Parent.lib.hdTypes);
local hdSceneHandle = {};
hdSceneHandle.__index = hdSceneHandle;

export type hdSceneHandle = typeof(setmetatable({} :: {
	name : string;
	_handleTags : any;
	_CFrame : CFrame;
}, {} :: typeof(hdSceneHandle)));

--[=[
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

	local scene = hdSceneHandleCreateInfo.handleScene;

	return sceneHandle; --scene:hdCreateSceneHandle(hdSceneHandleCreateInfo);
end

-- returns the handle's world spaced CFrame, AKA the destination where scene participant's humanoid root part or assembly root will be moved to.
function hdSceneHandle:hdGetHandleAssemblyCFrame() : CFrame
	local sceneHandle : hdSceneHandle = self;
	
	return sceneHandle._CFrame;
end

function hdSceneHandle:hdGetHandleAssemblySize() : Vector3
	local sceneHandle : hdSceneHandle = self;

	return sceneHandle._Size;
end

function hdSceneHandle:hdGetHandleTag(handleTagName : string) : boolean
	local sceneHandle : hdSceneHandle = self;

	return sceneHandle._handleTags[handleTagName];
end

return hdSceneHandle;