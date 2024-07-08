local hdHECLExecutor = {};
hdHECLExecutor.__index = hdHECLExecutor;

export type hdHECLExecutor = typeof(setmetatable({} :: {}, {} :: typeof(hdHECLExecutor)));

function hdHECLExecutor.new() : hdHECLExecutor
	local heclExecutor = setmetatable({}, hdHECLExecutor);

	return heclExecutor;
end

return hdHECLExecutor;