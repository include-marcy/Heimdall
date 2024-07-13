--!strict
--!native
--!optimize 2
-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

-- Heimdall dependencies
local Heimdall = require(ReplicatedStorage.Modules.Classes.Heimdall);
local hdTypes = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdTypes);
local hdEnums = require(ReplicatedStorage.Modules.Classes.Heimdall.src.lib.hdEnums);
local hdInstance = Heimdall.awaitHdInstance();

local hdCharacterService = hdInstance:hdGetService("hdCharacterService", 20);

local hdControlModeDefault = {};

function hdControlModeDefault:Update(deltaTime : number)
    local hdCharacter = hdCharacterService:hdGetCharacter(Players.LocalPlayer, 20);
    if not hdCharacter then
        return;
    end

    local hdHumanoid = hdCharacter:hdGetHumanoid()
end

return hdControlModeDefault;