--// This local script is dedicated to configuring Heimdall to run with an ECS design locale.
--// For the simpler service command-chain setup, view the hdMain local script for a complete configuration breakdown.
--!strict
--// ROBLOX Services
local RunService = game:GetService("RunService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

--// Dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local hdLib = hd.src.lib;
local hdClasses = hd.src.classes;
local Heimdall = require(hd);
local hdTypes = require(hdLib.hdTypes);

local hdObjectCreateInfo : hdTypes.hdObjectCreateInfo = {};
local hdObject = Heimdall.new(hdObjectCreateInfo);
local hdInstance = hdObject:awaitHdInstance();
local debugMessenger = hdObject:awaitHdDebugMessenger();

local hdComponent = require(hdClasses.hdComponent);

local hdComponentManagerCreateInfo : hdTypes.hdComponentManagerCreateInfo = {
	debugMessenger = debugMessenger;
}
local hdResult, hdComponentManager = hdInstance:hdCreateComponentManager(hdComponentManagerCreateInfo);
if not hdResult.Success then
	error("failed to create component manager!");
	return;
end

hdInstance:hdSetComponentManager(hdComponentManager);

local heclMachine = require(hdClasses.hdHECLExecutor.src.classes.heclMachine);
local vm = heclMachine.new();
local source = require(hdClasses.hdHECLExecutor.src.classes.heclObject["debug.hc"])
local Rresult = vm:heclInterpret(source)
print(Rresult)

local hdComponentCreateInfo : hdTypes.hdComponentCreateInfo = {
	name = "Character";
	details = {
		HealthState = {
			Health = 0;
			MaxHealth = 100;
		};
		ControlState = {
			CurrentState = "Idling";
			States = {
				"Idling";
				"Walking";
				"Jumping";
				"Swimming";
				"Climbing";
				"Landing";
				"Ragdolling";
				"Sitting";
			};
		};
	};
};
local hdCharacterComponent = hdComponent.new(hdComponentCreateInfo);

local hdResult = hdComponentManager:hdRegisterComponent(hdCharacterComponent);
if not hdResult.Success then
	error("failed to register characters component!");
	return;
end