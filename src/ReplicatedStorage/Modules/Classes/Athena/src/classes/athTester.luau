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
local athTester = athUtils.Class();

export type athTester = typeof(setmetatable({} :: {}, {} :: typeof(athTester)));

function athTester.new(athTesterCreateInfo : athTypes.athTesterCreateInfo) : athTester
    local tester = setmetatable({}, athTester);

    return tester;
end

function athTester:athFoo()

end

return athTester :: athTester;