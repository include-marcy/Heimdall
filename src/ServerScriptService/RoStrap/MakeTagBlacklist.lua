local SharedData = require(script.Parent.SharedData)

local TagBlacklist = {}

function TagBlacklist.new(Func)
	SharedData.TagBlacklist = SharedData.TagBlacklist or setmetatable({t = {}, Func = Func}, TagBlacklist)
	return SharedData.TagBlacklist
end

function TagBlacklist:__newindex(i, v)
	self.t[i] = v
	self.Func()
end

function TagBlacklist:__index(i)
	return self.t[i]
end

return TagBlacklist.new
