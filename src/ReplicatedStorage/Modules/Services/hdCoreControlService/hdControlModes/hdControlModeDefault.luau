--!strict
--!native
--!optimize 2
-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

-- Heimdall dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local Heimdall = require(hd);
local hdTypes = require(hd.src.lib.hdTypes);
local hdEnums = require(hd.src.lib.hdEnums);
local hdInstance = Heimdall.awaitHdInstance();
local hdHumanoid = require(hd.src.classes.hdHumanoid);

local hdCharacterService = hdInstance:hdGetService("hdCharacterService", 20);

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

    humanoid:hdMove(moveDirection);
end

function hdControlModeDefault:hdSetMoveDirection(moveDirection : Vector3)
    self.moveDirection = moveDirection;
end

function hdControlModeDefault:hdGetMoveDirection() : Vector3
    return self.moveDirection;
end

return hdControlModeDefault;