-- This file is part of the Athena library and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

-- ROBLOX Services

-- Athena Dependencies
local athena = script.Parent.Parent;
local athTypes = require(athena.lib.athTypes);

-- Class Definition
local athHost = {};
athHost.__index = athHost;

export type athHost = typeof(setmetatable({} :: {}, {} :: typeof(athHost)));

function athHost.new(athHostCreateInfo : athTypes.athHostCreateInfo) : athHost
    local host = setmetatable({}, athHost);

    return host :: athHost;
end

function athHost:athFoo()

end

return athHost;