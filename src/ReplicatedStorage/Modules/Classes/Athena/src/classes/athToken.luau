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
local athToken = athUtils.Class();

export type athToken = typeof(setmetatable({} :: {}, {} :: typeof(athToken)));

function athToken.new(athTokenCreateInfo : athTypes.athTokenCreateInfo) : athToken
    local token = setmetatable({}, athToken);

    return token;
end

function athToken:athFoo()

end

return athToken :: athToken;