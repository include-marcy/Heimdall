-- This file is part of the Athena library and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

-- ROBLOX Services

-- Athena Dependencies
local athena = script.Parent.Parent;
local athTypes = require(athena.lib.athTypes);
local athUtils = require(athena.lib.athUtils);

-- Class Definition
local athCaller = athUtils.Class();

export type athCaller = typeof(setmetatable({} :: {}, {} :: typeof(athCaller)));

function athCaller.new(athCallerCreateInfo : athTypes.athCallerCreateInfo) : athCaller
    local caller = setmetatable({}, athCaller);

    return caller;
end

function athCaller:athFoo()

end

return athCaller :: athCaller;