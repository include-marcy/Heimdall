--!strict
local hdTypes = require(script.Parent.hdTypes);

local hdClasses = script.Parent.Parent.classes;
local hdFence = require(hdClasses.hdFence);

local hdUtils = {};

function hdUtils:hdWaitForFences(hdFences : {hdFence.hdFence}, timeOut : number?)
	if timeOut then
		local startTime = os.clock();
		local allFencesLoaded = false;

		local signaled : hdTypes.hdFenceState = "HD_FENCE_SIGNALED";
		repeat
			allFencesLoaded = true;
			for _, fence in hdFences do
				if fence:hdGetFenceState() ~= signaled then
					allFencesLoaded = false;
					break;
				end
			end
			if not allFencesLoaded then
				task.wait();
			end
		until allFencesLoaded or (os.clock() - startTime) > timeOut;

		if not allFencesLoaded then
			warn("Heimdall Debug Output: Timed out waiting for fences to load.");
		end
	else
		local allFencesLoaded = true;
		local signaled : hdTypes.hdFenceState = "HD_FENCE_SIGNALED";

		for _, fence in hdFences do
			if fence:hdGetFenceState() ~= signaled then
				allFencesLoaded = false;
				break;
			end
		end
		if not allFencesLoaded then
			for _, fence in hdFences do
				fence:hdWaitForFence();
			end
		end

	end
end

function hdUtils.hdMakeVersion(hdMajor, hdMinor, hdPatch, hdIsRelease) : hdTypes.hdVersion
	return {
		major = hdMajor,
		minor = hdMinor,
		patch = hdPatch,
		isRelease = hdIsRelease
	} :: hdTypes.hdVersion;
end

return hdUtils;