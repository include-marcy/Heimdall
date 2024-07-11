--!strict
-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterGui = game:GetService("StarterGui");

-- Heimdall dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local hdLib = hd.src.lib;
local hdClasses = hd.src.classes;
local Heimdall = require(hd);
local hdTypes = require(hdLib.hdTypes);
local hdInstance = Heimdall.awaitHdInstance();
local hdCharacter = require(hdClasses.hdCharacter);
local hdSignal = require(hdClasses.hdSignal);

-- Service declaration
local ServiceCreateInfo : hdTypes.hdServiceCreateInfo = {
	name = "hdCharacterService";
	loadPriority = 2;
	moduleReference = script;
};

local _, hdCharacterService = hdInstance:hdCreateService(ServiceCreateInfo);

hdCharacterService.CharacterRootDirectory = Heimdall.settings.hdCharacterRootDirectory; --// The Roblox object that characters are parented to
hdCharacterService.hdCharacterCache = {};
hdCharacterService.hdCharacterAdded = hdSignal.new();

function hdCharacterService:hdGetPhysicalCharacter(Player : Player) : hdCharacter.hdPhysicalCharacterR6
	return hdCharacterService.CharacterRootDirectory:WaitForChild(Player.Name);
end

function hdCharacterService:hdGetCharacter(Player : Player, allowedYield : number?) : hdCharacter.hdCharacter?
    if allowedYield then
        local start = os.clock();
        while not (hdCharacterService.hdCharacterCache[Player.UserId]) do
            task.wait();

            if (os.clock() - start) >= allowedYield then
                break;
            end
        end
    end
    return hdCharacterService.hdCharacterCache[Player.UserId];
end

function hdCharacterService:hdSetCharacter(Player : Player, newCharacter : hdCharacter.hdCharacter, allowedYield : number?)
    local character : hdCharacter.hdCharacter = hdCharacterService:hdGetCharacter(Player, allowedYield);
    if character == hdCharacter then
        return;
    end

    if character ~= nil then
        character:Destroy();
    end

    hdCharacterService.hdCharacterCache[Player.UserId] = newCharacter;
    hdCharacterService.hdCharacterAdded:Fire(hdCharacter);
end

function hdCharacterService:PlayerAdded(Player : Player)
	--// Create the physical character, this will be their character in the Roblox workspace
    for i, v in StarterGui:GetChildren() do
        local clone = v:Clone();
        clone.Parent = Player:WaitForChild("PlayerGui");
    end
	local physicalCharacter = hdCharacterService:hdGetPhysicalCharacter(Player);
	local hdCharacterCreateInfo : hdTypes.hdCharacterCreateInfo = {
		physical = physicalCharacter;
		context = "client";
	};

	--// Create the hdCharacter Heimdall object. This will represent their character in Luau.
	local character = hdCharacter.new(hdCharacterCreateInfo);
    hdCharacterService:hdSetCharacter(Player, character);
end

function hdCharacterService:hdDecodeArg(instruction : buffer) : string
    local argline = buffer.readu8(instruction, 0);
    local args = {
        [0] = "hdWriteCharacterPosition";
    };

    return args[argline];
end

function hdCharacterService:hdDecodeBufferVariadics(instruction : buffer)
    local offset = 8;
    local variadicArgs = {};

    for i = offset, buffer.len(instruction), 16 do
        local arg = buffer.readu16(instruction, i);
        table.insert(variadicArgs, i);
    end

    return variadicArgs;
end

function hdCharacterService:hdWriteCharacterPosition(Player, p1, p2, p3)
    
end

function hdCharacterService:Boot()
    local characterNet = Heimdall.hdNet:UnreliableRemoteEvent("hdCharacterNet");
    characterNet.OnServerEvent:Connect(function(player : Player, instruction : buffer)
        local decodedFunctionName = hdCharacterService:hdDecodeArg(instruction);
        if not decodedFunctionName then
            return;
        end
        local rawFunc = hdCharacterService[decodedFunctionName];
        if not rawFunc then
            return;
        end

        local args = hdCharacterService:hdDecodeBufferVariadics(instruction);

        rawFunc(hdCharacterService, player, table.unpack(args));
    end)
end

return hdCharacterService;