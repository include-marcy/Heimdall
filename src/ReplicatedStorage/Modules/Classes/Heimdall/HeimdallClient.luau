local hdTypes = require(script.Parent.src.lib.hdTypes);
local Heimdall = require(script.Parent.Heimdall);

local HeimdallClient = {};
HeimdallClient.__index = HeimdallClient;
setmetatable(HeimdallClient, Heimdall);

export type hdObject = typeof(setmetatable({} :: {}, setmetatable({} :: typeof(HeimdallClient), {} :: typeof(Heimdall))));

return HeimdallClient;