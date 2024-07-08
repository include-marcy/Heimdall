--!strict
local RunService = game:GetService("RunService");
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

local hdClasses = script.Parent;

local hdActor = {};
hdActor.__index = hdActor;

export type hdActor = typeof(setmetatable({} :: {
	hdParallelServiceObj : any;
	hdParallelConnection : RBXScriptConnection;
}, {} :: typeof(hdActor)));

function hdActor.new(hdActorCreateInfo : hdTypes.hdActorCreateInfo) : hdActor
	local hdParallelServiceObj = hdActorCreateInfo.hdParallelServiceObj;
	local hdParallelServiceRaw = require(hdParallelServiceObj) :: any;

	local hdParallelConnection = RunService.Heartbeat:ConnectParallel(function(deltaTime)
		if not hdParallelServiceRaw["Update"] then
			return;
		end

		hdParallelServiceRaw:Update(deltaTime);
	end)

	local actor : hdActor = setmetatable({
		hdParallelService = hdParallelServiceRaw;
		hdParallelConnection = hdParallelConnection;
	}, hdActor);

	return actor;
end

function hdActor:PerformCompute(computeRange)
	return self.hdParallelService:PerformCompute(computeRange);
end

function hdActor.createActor(hdActorCreateInfo : hdTypes.hdActorCreateInfo) : hdActor?
	local hdParallelActor = script.Parent.Parent.dependencies.hdActor:Clone();
	hdParallelActor.Parent = script.Parent.Parent.bin;

	local hdActorObj = hdParallelActor:WaitForChild("hdActorEvent"):Invoke("hdNewInstance", hdActorCreateInfo);
	setmetatable(hdActorObj, hdActor);
	
	return hdActorObj, hdParallelActor;
end

return hdActor;