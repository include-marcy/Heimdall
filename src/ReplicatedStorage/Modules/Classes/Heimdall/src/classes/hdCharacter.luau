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

export type hdCharacter = typeof(setmetatable({} :: {}, {} :: typeof(hdCharacter)));

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

    return character;
end

return hdCharacter;