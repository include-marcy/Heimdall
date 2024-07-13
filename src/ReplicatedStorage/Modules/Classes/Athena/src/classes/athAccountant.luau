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
local athAccountant = athUtils.Class();

export type athAccountant = typeof(setmetatable({} :: {}, {} :: typeof(athAccountant)));

function athAccountant.new(athAccountantCreateInfo : athTypes.athAccountantCreateInfo) : athAccountant
    local accountant = setmetatable({}, athAccountant);

    return accountant;
end

function athAccountant:athFoo()

end

return athAccountant :: athAccountant;