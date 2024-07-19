-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hdLib = script.Parent.Parent.lib;
local hdClasses = script.Parent;
local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);

local hdWrapping = require(hdClasses.hdWrapping);
local hdHumanoid = require(hdClasses.hdHumanoid);

--// Class Declaration
local hdCharacter = {};
hdCharacter.__index = hdCharacter;

export type hdCharacter = typeof(setmetatable({} :: {
    physical : hdPhysicalCharacterR6;
    wrapping : hdWrapping.hdWrapping;
    humanoid : hdHumanoid.hdHumanoid;
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
    character.context = hdCharacterCreateInfo.context;

    local wrappingInfo : hdTypes.hdWrappingCreateInfo = {
        instance = character.physical;
    };
    local wrapping = hdWrapping.new(wrappingInfo);
    local physical = hdCharacterCreateInfo.physical;
    local hipHeight = physical:GetExtentsSize().Y / 2;
    character.humanoid = wrapping:Create(hdHumanoid, {
        hdCharacter = character;
        hipHeight = hipHeight;
        hdHumanoidHandleType = hdEnums.hdHumanoidHandleType.hdHumanoidCapsule;
    })

    character.wrapping = wrapping;

    return character;
end

function hdCharacter:hdGetHumanoid() : hdHumanoid.hdHumanoid
    local character : hdCharacter = self;

    return character.humanoid;
end

function hdCharacter:hdGetPhysicalCharacter() : hdPhysicalCharacterR6?
    local character : hdCharacter = self;

    return character.physical;
end

function hdCharacter:Destroy()
    local character : hdCharacter = self;

    if character.physical then
        character.physical:Destroy();
        character.physical = nil;
    end

    if character.wrapping then
        character.wrapping:Destroy();
        character.wrapping = nil;
    end

    table.clear(character);
    setmetatable(character, nil);
    character = nil;
end

return hdCharacter;