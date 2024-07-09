--!strict
local hd = script.Parent.Parent;
local hdLib = hd.lib;
local hdClasses = hd.classes;

local hdTypes = require(hdLib.hdTypes);

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