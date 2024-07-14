-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

local Heimdall = require(script.Parent.Heimdall);

local HeimdallClient = {};
HeimdallClient.__index = HeimdallClient;
setmetatable(HeimdallClient, Heimdall);

export type hdObject = typeof(setmetatable({} :: {}, setmetatable({} :: typeof(HeimdallClient), {} :: typeof(Heimdall))));

return HeimdallClient;