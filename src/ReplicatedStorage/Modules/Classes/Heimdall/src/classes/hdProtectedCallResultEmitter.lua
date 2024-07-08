--!strict
local hdTypes = require(script.Parent.Parent.lib.hdTypes);
local hdEnums = require(script.Parent.Parent.lib.hdEnums);

local hdProtectedCallResultEmitter = {
	prototype = {};	
};

hdProtectedCallResultEmitter.__index = hdProtectedCallResultEmitter;

export type hdProtectedCallResultEmitter = typeof(setmetatable({}::{}, {} :: typeof(hdProtectedCallResultEmitter)));

--[=[
	Creates an hdProtectedCallResultEmitter, an internal tool used to safely call functions and emit internal pass/fail results

	@param hdProtectedCallResultEmitterCreateInfo;
	@return hdProtectedCallResultEmitter;
]=]
function hdProtectedCallResultEmitter.new(hdProtectedCallResultEmitterCreateInfo : hdTypes.hdProtectedCallEmitterCreateInfo) : hdProtectedCallResultEmitter
	local protectedCallResultEmitter = setmetatable({}, hdProtectedCallResultEmitter);
	
	-- foobar 2000!
	
	return protectedCallResultEmitter;
end

--[=[
	Calls the given callback with variadic arguments, returning an hdProtectedCallResult with a value of either HD_SUCCESS or HD_FAILURE, depending on if
	the callback executed without errors or not.

	@param callback;
	@param ...;
	@return hdProtectedCallResult;
	@return ...?;
]=]
function hdProtectedCallResultEmitter:getProtectedCallResult(callback : (any?) -> (any?), ...) : (hdTypes.hdProtectedCallResult, ...any?)
	local protectedCallResultEmitter : hdProtectedCallResultEmitter = self;
	local failureType;

	local error_handler = function(...)
		failureType = protectedCallResultEmitter.prototype._errorHandler(protectedCallResultEmitter, ...);
	end;

	local debugThread;
	local pass, result = xpcall(callback, error_handler, ...);
	
	if not pass then
		return protectedCallResultEmitter.prototype._handleFail(protectedCallResultEmitter, callback, result, failureType);
	else
		return protectedCallResultEmitter.prototype._handlePass(protectedCallResultEmitter), result;
	end
end

function hdProtectedCallResultEmitter.prototype._handleFail(protectedCallResultEmitter, callback, result, failureType)
	local debugInfo_script : string, debugInfo_line : number, debugInfo_name : string = debug.info(callback, "sln");
	if debugInfo_name == "" then
		debugInfo_name = "anonymous";
	end

	local traceback = debugInfo_script .. "\n line " .. debugInfo_line .. "\nfunction: " .. debugInfo_name;
	local scr;
	if debugInfo_script then
		scr = protectedCallResultEmitter.prototype:_getScriptForDebugInfo(debugInfo_script);
	end

	local hdFailureCreateInfo : hdTypes.hdFailureCreateInfo = {
		traceback = traceback;
		errorString = result;
		failureType = failureType;
		scr = scr;
	};

	return protectedCallResultEmitter.prototype._emitFailure(protectedCallResultEmitter, hdFailureCreateInfo);
end

function hdProtectedCallResultEmitter.prototype:_handlePass()
	local protectedCallResultEmitter : hdProtectedCallResultEmitter = self;
	local hdSuccessCreateInfo : hdTypes.hdSuccessCreateInfo = {};
	return protectedCallResultEmitter:_emitSuccess(hdSuccessCreateInfo);
end

function hdProtectedCallResultEmitter.prototype:_errorHandler(err)
	return err or "unhandledHdFailureType";
end

function hdProtectedCallResultEmitter.prototype:_getScriptForDebugInfo(debugInfo_script)
	local scr;
	local parent = game;
	local tree = string.split(debugInfo_script, ".");

	for i, v in tree do
		parent = parent:FindFirstChild(v);
		if parent == nil then
			break;
		end
	end

	if parent then
		scr = parent;
	end

	return scr;
end

function hdProtectedCallResultEmitter.prototype:_emitFailure(hdFailureCreateInfo : hdTypes.hdFailureCreateInfo) : hdTypes.HD_FAILURE
	local logger = {
		__tostring = function()
			return "HD_FAILURE";
		end;
		__eq = function(_, val)
			return val == "HD_FAILURE";
		end;
	} :: {
		__tostring : () -> "HD_FAILURE";
		__eq : (any, string) -> boolean;
	}

	local failureType : hdTypes.hdFailureType = hdFailureCreateInfo.failureType or hdEnums.hdFailureTypes.hdUnknown;
	local errorString = hdFailureCreateInfo.errorString
	
	if not errorString and typeof(failureType) == "string" then
		errorString = failureType;
		failureType = hdEnums.hdFailureTypes.hdUnknown;
	end
	
	local hdFailure : hdTypes.HD_FAILURE = setmetatable({
		ErrorString = errorString or "no error string available";
		Traceback = hdFailureCreateInfo.traceback or "no traceback available";
		FailureType = failureType;
		scr = hdFailureCreateInfo.scr;
		ProtectedCallResult = 2;
		Success = false;
	}, logger);
	
	return hdFailure :: hdTypes.HD_FAILURE;
end

function hdProtectedCallResultEmitter:_emitSuccess(hdSuccessCreateInfo : hdTypes.hdSuccessCreateInfo) : hdTypes.HD_SUCCESS
	local logger = {
		__tostring = function()
			return "HD_SUCCESS";
		end;
		__eq = function(_, val)
			warn(val);
			return val == "HD_SUCCESS";
		end;
	} :: {
		__tostring : () -> "HD_SUCCESS";
		__eq : (any, string) -> boolean;
	}

	local failureType : hdTypes.hdFailureType = hdEnums.hdFailureTypes.hdUnknown;
	local hdSuccess : hdTypes.HD_SUCCESS = setmetatable({
		ErrorString = "function was called successfully;;";
		Traceback = "no traceback available";
		FailureType = failureType;
		ProtectedCallResult = 1;
		Success = true;
	}, logger);

	return hdSuccess :: hdTypes.HD_SUCCESS;
end

return hdProtectedCallResultEmitter;