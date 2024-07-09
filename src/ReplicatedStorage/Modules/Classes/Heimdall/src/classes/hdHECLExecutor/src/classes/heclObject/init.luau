local hecl = script.Parent.Parent.Parent;
local heclLib = hecl.src.lib;
local heclTypes = require(heclLib.heclTypes);
local heclClasses = hecl.src.classes;

local heclObject = {};
heclObject.__index = heclObject;

export type heclObject = typeof(setmetatable({} :: {}, {} :: typeof(heclObject)));

function heclObject.new() : heclObject
	local obj = setmetatable({}, heclObject);

	return obj;
end

return heclObject;