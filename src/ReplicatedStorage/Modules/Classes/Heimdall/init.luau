-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// ROBLOX Services
local RunService = game:GetService("RunService");

--// Local variables
local hd;
if RunService:IsServer() then
	hd = require(script.HeimdallServer);
else
	hd = require(script.HeimdallClient);
end

--// Type definitions
export type hdObject = hd.hdObject;

hd.hdNet = require(script.src.packages.net);
hd.settings = require(script.settings);

return hd;