local athUtils = {};

function athUtils.Class()
    local Class = {};
    Class.__index = Class;

    return Class;
end

function athUtils.ClassType(Class)
    return typeof(setmetatable({} :: {}, {} :: typeof(Class)));
end

return athUtils;