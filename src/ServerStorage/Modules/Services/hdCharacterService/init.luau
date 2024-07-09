--!strict
-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Heimdall dependencies
local hd = ReplicatedStorage.Modules.Classes.Heimdall;
local hdLib = hd.src.lib;
local Heimdall = require(hd);
local hdTypes = require(hdLib.hdTypes);
local hdEnums = require(hdLib.hdEnums);

local hdService = require(hd.src.classes.hdService);
local hdInstance = Heimdall.awaitHdInstance();

-- Service declaration

local ServiceCreateInfo : hdTypes.hdServiceCreateInfo = {
	name = "CharacterService";
	loadPriority = 2;
	moduleReference = script;
};

local hdPassed, CharacterService = hdInstance:hdCreateService(ServiceCreateInfo);

function CharacterService:PlayerAdded(Player : Player)
	print(Player, " is going to get a character now.");
	local entityCreateInfo : hdTypes.hdEntityCreateInfo = {
		name = `entity_{Player.UserId}`;
		components = {
			{
				name = "ServerCharacterRepresentation";
				details = {
					foo = "bar";
				};
			};
		};
		debugMessenger = hdInstance.debugMessenger;
		componentManager = hdInstance:hdGetComponentManager();
		tiedTo = Player;
	};
	local hdEntity = hdInstance:hdCreateEntity(entityCreateInfo);

	--Heimdall.hdNet:UnreliableRemoteEvent("Foo"):FireClient(Player);
end

return CharacterService;