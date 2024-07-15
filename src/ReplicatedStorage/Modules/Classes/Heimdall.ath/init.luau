-- This file is part of the Heimdall.ath Framework, and is licensed under the MIT license. Check the LICENSE.md file for more information
-- ROBLOX Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Athena Dependencies
local athTypes = require(ReplicatedStorage.Modules.Classes.Athena.src.lib.athTypes);
local athHost = require(ReplicatedStorage.Modules.Classes.Athena.src.classes.athHost);

-- Library Declaration
local hdSource = script.src;
local athHeimdallCreateInfo : athTypes.athHostCreateInfo = {
    projectRoot = hdSource.root;
    projectClientRoot = hdSource.client;
    projectServerRoot = hdSource.server;
    projectClasses = hdSource.classes;
    projectTypes = hdSource.lib.hdTypes;
    projectPackages = script["share.ath"];
};
local Heimdall = athHost.new(athHeimdallCreateInfo);

return Heimdall;