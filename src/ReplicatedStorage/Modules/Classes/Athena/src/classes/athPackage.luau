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
local athPackage = athUtils.Class();

export type athPackage = typeof(setmetatable({} :: {}, {} :: typeof(athPackage)));

function athPackage.new(athPackageCreateInfo : athTypes.athPackageCreateInfo) : athPackage
    local package = setmetatable({}, athPackage);

    return package;
end

function athPackage:athFoo()

end

return athPackage :: athPackage;