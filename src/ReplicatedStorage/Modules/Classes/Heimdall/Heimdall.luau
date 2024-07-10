--!strict
--// ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

--// Dependencies
local hdTypes = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdTypes);
local hdEnums = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdEnums);

local hdClasses = script.Parent.src.classes;
local hdDebugMessenger = require(hdClasses.hdDebugMessenger);
local hdInstance = require(hdClasses.hdInstance);
local hdLaunchToken = require(hdClasses.hdLaunchToken);

local Heimdall = {
	hdTypes = hdTypes;
	hdEnums = hdEnums;
};
Heimdall.__index = Heimdall;

export type hdObject = typeof(setmetatable({} :: {
	_hdInstance : hdInstance.hdInstance?;
	debugMessenger : hdDebugMessenger.hdDebugMessenger?;
}, {} :: typeof(Heimdall)));

local hdObjects : {[string] : hdObject} = {};

local function getHdObjectForUser(user : string) : hdObject?
	return hdObjects[user];
end

--[=[
	Instantiates an hdObject instance, which is used to bootstrap the main objects of Heimdall.

	:::info
	By default, a User is provided so that only 1 hdObject singleton is generated per environment unless specified.
	InitializationArgs allow you to create multiple hdObject instances in one environment, thus initializing different types of hdObjects
	for different purposes.
	---
	Generally, it is suitable for most developers to just use 1 hdObject on the client and 1 hdObject on the server, though.
	:::

	@param InitializationArgs;
	@return hdObject;
]=]
function Heimdall.new(hdObjectCreateInfo : hdTypes.hdObjectCreateInfo) : hdObject
	local User : string? = hdObjectCreateInfo.User;
	local nameSpace;
	if User == nil then
		nameSpace = "global";
	else
		nameSpace = User;
	end

	local _hdObject = getHdObjectForUser(nameSpace);
	if _hdObject then
		return _hdObject;
	end

	local _hdObject = setmetatable({
		_user = nameSpace;
	}, Heimdall);

	hdObjects[nameSpace] = _hdObject;

	return _hdObject :: hdObject;
end

--[=[
	Creates the hdInstance object, the central object from which most other Heimdall objects are created.
	
	@param hdInstanceCreateInfo;
	@return hdInstance;
]=]
function Heimdall:hdCreateInstance(hdInstanceCreateInfo : hdTypes.hdInstanceCreateInfo) : hdInstance.hdInstance
	local object : hdObject = self;
	local instance = hdInstance.new(hdInstanceCreateInfo);
	object._hdInstance = instance;

	return instance :: hdInstance.hdInstance;
end

--[=[
	Creates a hdDebugMessenger object, which can be used to output helpful debug information at runtime.

	:::info
	You can create multiple hdDebugMessengers to split or categorize your outputs.
	:::

	@param hdDebugMessengerCreateInfo;
	@return hdDebugMessenger;
]=]
function Heimdall:hdCreateDebugMessenger(hdDebugMessengerCreateInfo : hdTypes.hdDebugMessengerCreateInfo) : hdDebugMessenger.hdDebugMessenger
	if self.debugMessenger then
		return self.debugMessenger;
	end

	local debugMessenger = hdDebugMessenger.new(hdDebugMessengerCreateInfo);
	self.debugMessenger = debugMessenger;

	return debugMessenger;
end

function Heimdall:awaitHdDebugMessenger(nameSpace) : hdDebugMessenger.hdDebugMessenger?
	local space : string = nameSpace;
	if space == nil then
		space = "global";
	end

	local object = hdObjects[space];
	if not object then
		repeat
			object = hdObjects[space];
			task.wait();
		until object
	end

	repeat
		task.wait();
	until object.debugMessenger ~= nil;

	return object.debugMessenger;
end

--[=[
	Returns the hdInstance object, which is the central object from which most other Heimdall objects are created.
	@return hdInstance;
]=]
function Heimdall:awaitHdInstance(nameSpace : string?) : hdInstance.hdInstance?
	local space : string = nameSpace;
	if space == nil then
		space = "global";
	end

	local object = hdObjects[space];
	if not object then
		repeat
			object = hdObjects[space];
			task.wait();
		until object
	end

	repeat
		task.wait();
	until object._hdInstance ~= nil;

	return object._hdInstance;
end

function Heimdall:hdCreateLaunchToken(hdLaunchTokenCreateInfo : hdTypes.hdLaunchTokenCreateInfo) : hdLaunchToken.hdLaunchToken
	return hdLaunchToken.new(hdLaunchTokenCreateInfo);
end

return Heimdall;