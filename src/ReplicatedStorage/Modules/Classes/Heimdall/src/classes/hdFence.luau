-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

local hdClasses = script.Parent;
local hdSignal = require(hdClasses.hdSignal);

--// Class Declaration
local hdFence = {};
hdFence.__index = hdFence;

export type hdFence = typeof(setmetatable({} :: {
	state : hdTypes.hdFenceState;
	signal : hdSignal.hdSignal;
}, {} :: typeof(hdFence)));

--[=[
	Creates an hdFence, used to synchronize hdCommandChain execution methods.

	:::info
	The hdFence class is largely for internal use.
	It has a simple internally flagged state which can be used by heimdall's tools to signal when a synchronization event is completed.
	:::

	@param hdFenceCreateInfo;
	@return hdFence;
]=]
function hdFence.new(hdFenceCreateInfo : hdTypes.hdFenceCreateInfo) : hdFence
	local initialState : hdTypes.hdFenceState = hdFenceCreateInfo.fenceInitialState or "HD_FENCE_UNSIGNALED";
	local fence = setmetatable({
		state = initialState;
	}, hdFence);

	fence.signal = hdSignal.new();

	return fence :: hdFence;
end

function hdFence:hdWaitForFence()
	local fence : hdFence = self;

	if fence.state == "HD_FENCE_SIGNALED" then
		return;
	end

	local waiting = true;
	local connection : hdSignal.hdConnection;
	connection = fence.signal:Connect(function(state)
		if state == "HD_FENCE_SIGNALED" then
			connection:Disconnect();
			waiting = false;
		end
	end);

	repeat
		task.wait();
	until not waiting;
end

function hdFence:hdSignalFence()
	local fence : hdFence = self;

	if fence.state == "HD_FENCE_SIGNALED" then
		return;
	end

	fence.state = "HD_FENCE_SIGNALED";
	fence.signal:Fire(fence.state);
end

function hdFence:hdResetFence()
	local fence : hdFence = self;

	if fence.state == "HD_FENCE_UNSIGNALED" then
		return;
	end

	fence.state = "HD_FENCE_UNSIGNALED";
end

function hdFence:hdGetFenceState() : hdTypes.hdFenceState
	local fence : hdFence = self;

	return fence.state
end

function hdFence:Destroy()
	local fence : hdFence = self;

	fence.signal:Destroy();

	table.clear(self);
	setmetatable(self, nil);
end

return hdFence