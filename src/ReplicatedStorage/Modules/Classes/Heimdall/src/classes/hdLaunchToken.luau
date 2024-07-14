-- This file is part of the Heimdall Roblox Experience Framework and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

--// Heimdall Dependencies
local hd = script.Parent.Parent;
local hdLib = hd.lib;

local hdTypes = require(hdLib.hdTypes);

--// Class Declaration
local hdLaunchToken = {};
hdLaunchToken.__index = hdLaunchToken;

export type hdLaunchToken = typeof(setmetatable({} :: {
	launchTitle : string;
	hdVersion : hdTypes.hdVersion;
	settings : any;
}, {} :: typeof(hdLaunchToken)));

function hdLaunchToken.new(hdLaunchTokenCreateInfo : hdTypes.hdLaunchTokenCreateInfo) : hdLaunchToken
	local launchToken = setmetatable({}, hdLaunchToken);

	launchToken.hdVersion = hdLaunchTokenCreateInfo.hdVersion;
	launchToken.launchTitle = hdLaunchTokenCreateInfo.launchTitle;
	launchToken.settings = hdLaunchTokenCreateInfo.settings;

	return launchToken;
end

function hdLaunchToken:hdGetVersion() : hdTypes.hdVersion
	local launchToken : hdLaunchToken = self;

	return launchToken.hdVersion;
end

function hdLaunchToken:hdGetLaunchTitle() : string
	local launchToken : hdLaunchToken = self;

	return launchToken.launchTitle;
end

function hdLaunchToken:hdGetLaunchSettings() : any
	local launchToken : hdLaunchToken = self;

	return launchToken.settings;
end

return hdLaunchToken;