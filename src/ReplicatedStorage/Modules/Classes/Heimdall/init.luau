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

return hd;