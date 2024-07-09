local hecl = script.Parent.Parent.Parent;
local heclLib = hecl.src.lib;
local heclTypes = require(heclLib.heclTypes);
local heclClasses = hecl.src.classes;

local heclObject = require(heclClasses.heclObject);

local heclValue = {};
heclValue.__index = heclValue;

export type heclValue = typeof(setmetatable({} :: {
	heclValueType : heclTypes.heclValueType;
	boolean : boolean;
	num : number;
	obj : heclObject.heclObject;
}, {} :: typeof(heclValue)));

function heclValue.new() : heclValue
	local value = setmetatable({}, heclValue);

	return value;
end

function heclValue:heclDeconstruct()
	local value : heclValue = self;
	if value.heclValueType == "VAL_BOOL" then
		return value.boolean;
	elseif value.heclValueType == "VAL_NUMBER" then
		return value.num;
	elseif value.heclValueType == "VAL_NIL" then
		return "nil";
	end
end

return heclValue;