--!strict
local hd = script.Parent.Parent;
local hdLib = hd.lib;
local hdTypes = require(hdLib.hdTypes);

local hdComponent = {};
hdComponent.__index = hdComponent;

export type hdComponent = typeof(setmetatable({} :: {
	name : string;
	details : any;
}, {} :: typeof(hdComponent)));

function hdComponent.new(hdComponentCreateInfo : hdTypes.hdComponentCreateInfo) : hdComponent
	local component : hdComponent = setmetatable({
		name = hdComponentCreateInfo.name;
		details = hdComponentCreateInfo.details;
	}, hdComponent);
	
	return component;
end

return hdComponent;