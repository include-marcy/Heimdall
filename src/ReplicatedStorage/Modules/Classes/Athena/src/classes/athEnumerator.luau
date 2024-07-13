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
local athEnumerator = athUtils.Class();

export type athEnumerator = typeof(setmetatable({} :: {}, {} :: typeof(athEnumerator)));

function athEnumerator.new(athEnumeratorCreateInfo : athTypes.athEnumeratorCreateInfo) : athEnumerator
    local enumerator = setmetatable({}, athEnumerator);

    return enumerator;
end

function athEnumerator:athFoo()

end

return athEnumerator :: athEnumerator;