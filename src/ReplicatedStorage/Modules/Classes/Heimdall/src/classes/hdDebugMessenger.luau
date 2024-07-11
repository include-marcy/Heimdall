--!strict
--!native
--!optimize 2

local hdTypes = require(script.Parent.Parent.lib.hdTypes);
local hdEnums = require(script.Parent.Parent.lib.hdEnums);

local hdDebugMessenger = {};
hdDebugMessenger.__index = hdDebugMessenger;

export type hdDebugMessenger = typeof(setmetatable({}::{
	onError : (string, hdTypes.hdProtectedCallResult) -> ()?;
	middleware : (string, hdTypes.hdProtectedCallResult) -> ()?;
	name : string
}, {} :: typeof(hdDebugMessenger)));

--[=[
	Creates a new hdDebugMessenger object. These are generic, reusable debugger objects that unify the framework's output.

	@param hdDebugMessengerCreateInfo;
	@return hdDebugMessenger;
]=]
function hdDebugMessenger.new(hdDebugMessengerCreateInfo : hdTypes.hdDebugMessengerCreateInfo ) : hdDebugMessenger
	return setmetatable({
		name = hdDebugMessengerCreateInfo.name or "debug";
		onError = hdDebugMessengerCreateInfo.onError or nil;
		middleware = hdDebugMessengerCreateInfo.middleware or nil;
	}, hdDebugMessenger);
end

--[=[
	Runs an error handler integration that is designed to go after hdProtectedCallResultEmitter emissions.

	:::info
	catch is designed to catch any errors that may have occurred in an hdProtectedCallResultEmitter, it doesn't safely run anything on its own.
	:::

	@param hdFunction;
	@param hdProtectedCallResult;
	@param ...;
	@return hdProtectedCallResult, ...;
]=]
function hdDebugMessenger:catch<a...>(hdFunction : string, hdProtectedCallResult : hdTypes.hdProtectedCallResult, ...) : (hdTypes.hdProtectedCallResult, a...)
	local debugMessenger : hdDebugMessenger = self;
	local middleware = debugMessenger.middleware or nil;
	local onError = debugMessenger.onError or nil;

	if middleware then
		middleware(hdFunction, hdProtectedCallResult, ...);
	end

	if tostring(hdProtectedCallResult) == "HD_SUCCESS" then
		return hdProtectedCallResult, ...;
	end

	if onError then
		onError(hdFunction, hdProtectedCallResult, ...);
	end
	
	debugMessenger:throw(hdProtectedCallResult);
	
	return hdProtectedCallResult, ...;
end

--[=[
	Throws an error to the debug messenger

	:::info
	It is not recommended to pass an HD_SUCCESS hdProtectedCallResult to this function
	:::

	@param hdFailure;
]=]
function hdDebugMessenger:throw(hdFailure : hdTypes.hdProtectedCallResult)
	local hdErrorMessage = "[[==[[\n";

	if hdFailure.FailureType then
		local Value = hdFailure.FailureType.Value;
		if Value then
			hdErrorMessage ..= `@@ hd Failure Type : {Value} was encountered\n`;
		else
			hdErrorMessage ..= `@@ hd Failure Type : {hdEnums.hdFailureTypes.hdUnknown.Value} was encountered\n`;
		end
	end
	
	if hdFailure.scr then
		warn("script (clickme): ", hdFailure.scr);
	end
	
	if hdFailure.ErrorString then
		hdErrorMessage ..= "@@ hd Failure Message : " .. hdFailure.ErrorString .. "\n";
	end
	
	if hdFailure.Traceback then
		hdErrorMessage ..= "@@ hd Failure Traceback : " .. hdFailure.Traceback .. "\n";
	end

	hdErrorMessage ..= "\n]]==]]";

	warn(hdErrorMessage);
end

return hdDebugMessenger;