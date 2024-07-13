-- This file is part of the Athena library and is licensed under MIT License; see LICENSE.md for details

local athUtils = {};

function athUtils.Class()
    local Class = {};
    Class.__index = Class;

    return Class;
end

function athUtils.ClassType(Class)
    local typeCast = Class or {};
    return typeof(setmetatable({} :: {}, {} :: typeof(typeCast)));
end

return athUtils;