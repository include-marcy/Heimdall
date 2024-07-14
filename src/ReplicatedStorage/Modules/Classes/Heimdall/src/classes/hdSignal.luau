-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// ROBLOX Services
local HttpService = game:GetService("HttpService");

--// Heimdall Dependencies
local hdTypes = require(script.Parent.Parent.lib.hdTypes);

--// Class Declaration
local hdConnection = {};
hdConnection.__index = hdConnection;
export type hdConnection = typeof(setmetatable({} :: {
	connectionId : string;
	signal : hdSignal;
	callback : (any) -> (any);
}, {} :: typeof(hdConnection)))

function hdConnection.new(hdConnectionCreateInfo : hdTypes.hdConnectionCreateInfo) : hdConnection
	local connection = setmetatable({}, hdConnection);

	connection.signal = hdConnectionCreateInfo.signal;
	connection.connectionId = HttpService:GenerateGUID(false);
	connection.callback = hdConnectionCreateInfo.callback;

	local signal : hdSignal = connection.signal;
	signal.payload[connection.connectionId] = connection;

	return connection;
end

function hdConnection:Disconnect()
	local connectionId = self.connectionId;
	local signal : hdSignal = self.signal;

	signal.payload[connectionId] = nil;

	table.clear(self);
	setmetatable(self, nil);
end

local hdSignal = {};
hdSignal.__index = hdSignal;

export type hdSignal = typeof(setmetatable({} :: {
	payload : {[string] : hdConnection};
}, {} :: typeof(hdSignal)));

--[=[
	@class hdSignal
	Creates an hdSignal, a synchronization object in Heimdall that allows for the connection of callbacks and the firing of the signal to execute all
	connected callbacks.

	@return hdSignal;
]=]
function hdSignal.new() : hdSignal
	local signal = setmetatable({}, hdSignal);

	signal.payload = {};

	return signal;
end

--[=[
	@class hdSignal
	Connects the provided callback to the hdSignal, returning a clean-up object hdConnection which can be used to remove the callback from the execution pool.

	@param func;
	@return hdConnection;
]=]
function hdSignal:Connect(func : any) : hdConnection
	local hdConnectionCreateInfo : hdTypes.hdConnectionCreateInfo = {
		signal = self;
		callback = func;
	};
	local connection : hdConnection = hdConnection.new(hdConnectionCreateInfo);

	return connection;
end

--[=[
	@class hdSignal
	Wraps the function so that it will connect to this signal and execute its callback, before promptly disconnecting itself after 1 execution.

	@param func;
	@return hdConnection;
]=]
function hdSignal:Once(func : any) : hdConnection
	local signal : hdSignal = self;
	local connection : hdConnection; connection = signal:Connect(function()
		connection:Disconnect()
		func()
	end);

	return connection;
end

--[=[
	@class hdSignal
	Fires the signal, causing all connected callbacks to execute once with the variadic arguments being passed on.

	@param ...;
	@return hdSignal;
]=]
function hdSignal:Fire(...)
	local signal : hdSignal = self;
	local payload = signal.payload;
	local arguments = {...};

	for _, connection in pairs(payload) do
		task.spawn(connection.callback, table.unpack(arguments));
	end
end

--[=[
	Destroys the signal and all connected hdConnections.
]=]
function hdSignal:Destroy()
	local signal : hdSignal = self;
	local payload = signal.payload;

	for _, connection in pairs(payload) do
		connection:Disconnect();
	end

	table.clear(self);
	setmetatable(self, nil);
end

return hdSignal;