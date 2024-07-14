-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

local Heimdall = require(script.Parent.Heimdall);

local HeimdallServer = {};
HeimdallServer.__index = HeimdallServer;
setmetatable(HeimdallServer, Heimdall);

export type hdObject = typeof(setmetatable({} :: {}, setmetatable({} :: typeof(HeimdallServer), {} :: typeof(Heimdall))));

return HeimdallServer;