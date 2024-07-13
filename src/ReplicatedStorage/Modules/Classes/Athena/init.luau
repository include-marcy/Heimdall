-- This file is part of the Athena library and is licensed under MIT License; see LICENSE.md for details

local ath = script;
local athsrc = ath.src;
local athClasses = athsrc.classes;

local Athena = {
    athHost = require(athClasses.athHost);
};

return Athena;