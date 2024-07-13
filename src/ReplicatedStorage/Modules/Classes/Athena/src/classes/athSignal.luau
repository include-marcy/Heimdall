-- This file is part of the Athena library and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

-- ROBLOX Services
local HttpService = game:GetService("HttpService");

local athTypes = require(script.Parent.Parent.lib.athTypes);

local athConnection = {};
athConnection.__index = athConnection;
export type athConnection = typeof(setmetatable({} :: {
	connectionId : string;
	signal : athSignal;
	callback : (any) -> (any);
}, {} :: typeof(athConnection)))

function athConnection.new(athConnectionCreateInfo : athTypes.athConnectionCreateInfo) : athConnection
	local connection = setmetatable({}, athConnection);

	connection.signal = athConnectionCreateInfo.signal;
	connection.connectionId = HttpService:GenerateGUID(false);
	connection.callback = athConnectionCreateInfo.callback;

	local signal : athSignal = connection.signal;
	signal.payload[connection.connectionId] = connection;
	
	return connection;
end

function athConnection:Disconnect()
	local connectionId = self.connectionId;
	local signal : athSignal = self.signal;
	
	signal.payload[connectionId] = nil;

	table.clear(self);
	setmetatable(self, nil);
end

local athSignal = {};
athSignal.__index = athSignal;

export type athSignal = typeof(setmetatable({} :: {
	payload : {[string] : athConnection};
}, {} :: typeof(athSignal)));

--[=[
	Creates an athSignal, a synchronization object in Heimdall that allows for the connection of callbacks and the firing of the signal to execute all
	connected callbacks.

	@return athSignal;
]=]
function athSignal.new() : athSignal
	local signal = setmetatable({}, athSignal);
	
	signal.payload = {};
	
	return signal;
end

--[=[
	Connects the provided callback to the athSignal, returning a clean-up object athConnection which can be used to remove the callback from the execution pool.

	@param func;
	@return athConnection;
]=]
function athSignal:Connect(func : any) : athConnection
	local athConnectionCreateInfo : athTypes.athConnectionCreateInfo = {
		signal = self;
		callback = func;
	};
	local athConnection : athConnection = athConnection.new(athConnectionCreateInfo);
	
	return athConnection;
end

--[=[
	Wraps the function so that it will connect to this signal and execute its callback, before promptly disconnecting itself after 1 execution.

	@param func;
	@return athConnection;
]=]
function athSignal:Once(func : any) : athConnection
	local signal : athSignal = self;
	local connection : athConnection; connection = signal:Connect(function()
		connection:Disconnect()
		func()
	end);
	
	return connection;
end

--[=[
	Fires the signal, causing all connected callbacks to execute once with the variadic arguments being passed on.

	@param ...;
	@return athSignal;
]=]
function athSignal:Fire(...)
	local signal : athSignal = self;
	local payload = signal.payload;
	local arguments = {...};

	for connectionId, connection in pairs(payload) do
		task.spawn(connection.callback, table.unpack(arguments));
	end
end

--[=[
	Destroys the signal and all connected athConnections.
]=]
function athSignal:Destroy()
	local signal : athSignal = self;
	local payload = signal.payload;
	
	for connectionId, connection in pairs(payload) do
		connection:Disconnect();
	end
	
	table.clear(self);
	setmetatable(self, nil);
end

return athSignal;