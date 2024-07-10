--!strict
--!native
--!optimize 2
local hdLib = script.Parent.Parent.lib;
local hdClasses = script.Parent;
local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);

local hdWrapping = require(hdClasses.hdWrapping);
local hdHumanoid = require(hdClasses.hdHumanoid);

local hdCharacter = {};
hdCharacter.__index = hdCharacter;

export type hdCharacter = typeof(setmetatable({} :: {
    physical : hdPhysicalCharacterR6;
    wrapping : hdWrapping.hdWrapping;
}, {} :: typeof(hdCharacter)));

export type hdPhysicalCharacterR6 = typeof(setmetatable({} :: {
    Head : BasePart;
    Torso : BasePart;
    ["Left Arm"] : BasePart;
    ["Right Arm"] : BasePart;
    ["Left Leg"] : BasePart;
    ["Right Leg"] : BasePart;
    HumanoidRootPart : BasePart;
}, {} :: typeof(getmetatable(Instance.new("Model")))));

function hdCharacter.new(hdCharacterCreateInfo : hdTypes.hdCharacterCreateInfo) : hdCharacter
    local character = setmetatable({}, hdCharacter);

    character.physical = hdCharacterCreateInfo.physical;

    local wrappingInfo : hdTypes.hdWrappingCreateInfo = {
        instance = character.physical;
    };
    local wrapping = hdWrapping.new(wrappingInfo);
    wrapping:Create(hdHumanoid, {
        hdCharacter = character;
    })

    character.wrapping = wrapping;

    return character;
end

function hdCharacter:hdGetPhysicalCharacter() : hdPhysicalCharacterR6?
    local character : hdCharacter = self;

    return character.physical;
end

return hdCharacter;