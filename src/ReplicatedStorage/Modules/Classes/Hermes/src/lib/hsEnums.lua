--!strict
local hsEnums = {};

local enumDebugOutput = {
	__tostring = function(self)
		return self.Value;
	end;
};

export type hsEnum = typeof(setmetatable({} :: {
	Name : string;
	Value : any;
	HsEnumFamily : string;
}, {} :: typeof(enumDebugOutput)));

local function hsDefineEnum(enumData) : hsEnum
	return setmetatable(enumData, enumDebugOutput);
end

hsEnums["hsValue"] = {
	hsValue1 = hsDefineEnum {
		Name = "hsValue1";
		Value = 1;
		HsEnumFamily = "hsValue";
	};
};

return hsEnums;