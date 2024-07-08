local hdTypes = require(script.Parent.src.lib.hdTypes);
local Heimdall = require(script.Parent.Heimdall);

local HeimdallServer = {};
HeimdallServer.__index = HeimdallServer;
setmetatable(HeimdallServer, Heimdall);

export type hdObject = typeof(setmetatable({} :: {}, setmetatable({} :: typeof(HeimdallServer), {} :: typeof(Heimdall))));

return HeimdallServer;