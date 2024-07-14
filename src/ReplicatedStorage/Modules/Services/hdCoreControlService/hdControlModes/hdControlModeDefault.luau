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
local hdHumanoid = require(ReplicatedStorage.Modules.Classes.Heimdall.src.classes.hdHumanoid);

local hdControlModeDefault = {
    moveDirection = Vector3.zero;
};

function hdControlModeDefault:Update(deltaTime : number)
    local hdCharacter = hdCharacterService:hdGetCharacter(Players.LocalPlayer, 20);
    if not hdCharacter then
        return;
    end

    local humanoid : hdHumanoid.hdHumanoid = hdCharacter:hdGetHumanoid();
    local moveDirection = self:hdGetMoveDirection();

    hdHumanoid:hdMove(moveDirection);
end

function hdControlModeDefault:hdSetMoveDirection(moveDirection : Vector3)
    self.moveDirection = moveDirection;
end

function hdControlModeDefault:hdGetMoveDirection() : Vector3
    return self.moveDirection;
end

return hdControlModeDefault;