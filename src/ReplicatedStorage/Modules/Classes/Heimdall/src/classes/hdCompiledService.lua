--!strict
local hdTypes = require(script.Parent.Parent.lib.hdTypes);
local hdCompiledService = {};
hdCompiledService.__index = hdCompiledService;

export type hdCompiledService = typeof(setmetatable({} :: {
	name : string;
	loadPriority : number;
	IsService : boolean;
	compiledData : any;
	compiledRoot : Instance;
}, {} :: typeof(hdCompiledService)));

--[=[
	Creates an hdCompiledService, services with a special runtime priority for filling out large or complex arrays of data prior to service command initialization. 
	
	:::info
	An hdCompiledService is virtually identical to an hdService, with the exception of containing a :Compile() function which is expected to populate a
	field in the hdCompiledService based on a specified compileRoot argument passed to the instantiation of this class.
	
	Typically, the hdCommandChain will be configured so that the Compile function is mapped to run first, so that in boot phases the other services can use an
	hdCompileService's compiledData field to read out game data structs safely, like a list of items or abilities.
	:::

	@param hdCompiledServiceCreateInfo;
	@return hdCompiledService;
]=]
function hdCompiledService.new(hdCompiledServiceCreateInfo : hdTypes.hdCompiledServiceCreateInfo) : hdCompiledService
	local compiledService = setmetatable({}, hdCompiledService);
	
	local name = hdCompiledServiceCreateInfo.name;
	local compiledRoot = hdCompiledServiceCreateInfo.compileRoot;
	local loadPriority = hdCompiledServiceCreateInfo.loadPriority;
	
	compiledService.name = hdCompiledServiceCreateInfo.name;
	compiledService.compiledRoot = compiledRoot;
	compiledService.loadPriority = hdCompiledServiceCreateInfo.loadPriority;
	compiledService.IsService = true;
	compiledService.compiledData = {};
	
	return compiledService;
end

function hdCompiledService:Compile()
	local compiledService : hdCompiledService = self;
	local compiledRoot = compiledService.compiledRoot;
	for _, v in compiledRoot:GetDescendants() do
		if v:IsA("ModuleScript") then
			local source = require(v) :: any;
			if typeof(source) == "table" then
				for k, v in source do
					compiledService.compiledData[k] = v;
				end
			end
		end
	end
end

function hdCompiledService:Boot()
end

function hdCompiledService:Start()	
end

--function hdCompiledService:Update()
--end

return hdCompiledService;