-- This file is part of the Athena library and is licensed under MIT License; see LICENSE.md for details

--!strict
--!native
--!optimize 2

local athena = script.Parent.Parent;
local athTypes = require(athena.lib.athTypes);
local athUtils = require(athena.lib.athUtils);

local athBench = athUtils.Class();

export type athBench = typeof(setmetatable({} :: {}, {} :: typeof(athBench)));

function athBench.new(athBenchCreateInfo : athTypes.athBenchCreateInfo) : athBench
    local bench = setmetatable({}, athBench);

    return bench;
end

function athBench:athFoo()

end

return athBench :: athBench;