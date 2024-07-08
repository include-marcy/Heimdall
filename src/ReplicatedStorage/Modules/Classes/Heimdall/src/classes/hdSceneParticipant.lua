--!strict
local trove = require(script.Parent.Parent.packages.trove);
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

local hdClasses = script.Parent;
local hdClient = require(hdClasses.hdClient);

local hdSceneParticipant = {};
hdSceneParticipant.__index = hdSceneParticipant;

export type hdSceneParticipant = typeof(setmetatable({}::{
	participantInstance : Model;
	participantClient : hdClient.hdClient;
	trove : typeof(setmetatable({}, {} :: typeof(trove)));
}, {} :: typeof(hdSceneParticipant)));

--[=[
	Creates an hdSceneParticipant, an object which directly wraps any ROBLOX character model.
	In order for players or NPCs to interact with an hdScene, they must use an hdSceneParticipant.

	@param hdSceneParticipantCreateInfo;
	@return hdSceneParticipant;
]=]
function hdSceneParticipant.new(hdSceneParticipantCreateInfo : hdTypes.hdSceneParticipantCreateInfo) : hdSceneParticipant?
	local participantClient = hdSceneParticipantCreateInfo.participantClient;
	local participantInstance = hdSceneParticipantCreateInfo.participantInstance;

	if not hdSceneParticipant._validateWrappedInstance(participantInstance) then
		error("failed to validate wrapped instance; make sure what you are passing is a valid ROBLOX character object!")
		return nil;
	end

	local participantTrove = trove.instanceTrove(participantInstance);
	local participant = setmetatable({
		participantInstance = participantInstance;
		participantClient = participantClient;
		trove = participantTrove;
	}, hdSceneParticipant);

	participant.trove:Add(participant);
	
	return participant;
end

function hdSceneParticipant._validateWrappedInstance(wrappedInstance : Model?) : boolean
	if not wrappedInstance then
		return false;
	end

	if not wrappedInstance:IsA("Model") then
		return false;
	end
	
	local humanoidObject = wrappedInstance:WaitForChild("Humanoid", 15);
	if not humanoidObject then
		return false;
	end
	
	local humanoidRootPart = wrappedInstance:WaitForChild("HumanoidRootPart", 15);
	if not humanoidRootPart then
		return false;
	end

	if wrappedInstance.Parent == nil then
		return false;
	end

	return true;
end

function hdSceneParticipant:hdGetModel()
	return self.participantInstance;
end

function hdSceneParticipant:Destroy()
	table.clear(self);
	setmetatable(self, nil);
end

return hdSceneParticipant;