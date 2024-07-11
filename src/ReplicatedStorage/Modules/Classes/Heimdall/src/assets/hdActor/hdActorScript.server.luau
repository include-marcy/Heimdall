--!strict
if not script.Parent:IsA("Actor") then return; end

--// ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

--// Heimdall dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local hdLib = hd.src.lib;
local Heimdall = require(hd);
local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);
local hdClasses = hd.src.classes;
local hdActor = require(hdClasses.hdActor);

--// Dependencies
local Trove = require(hd.src.packages.trove);

local hdParallelActor = script.Parent;
local hdActorEvent = hdParallelActor:WaitForChild("hdActorEvent");

local hdActorScriptTrove = Trove.instanceTrove(script);
local actor;

hdActorEvent.OnInvoke = function(command, ...)
	if command == "hdNewInstance" then
		if not actor then
			actor = hdActor.new(...);
		end
		
		return actor;
	elseif command == "hdCompute" then
		if actor then
			task.desynchronize();
			debug.profilebegin("hdWorkerParallel")
			local data = actor:PerformCompute(...)
			debug.profileend()
			task.synchronize();
			return data
		end
	end
end