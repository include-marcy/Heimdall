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
local athLibrary = athUtils.Class();

export type athLibrary = typeof(setmetatable({} :: {}, {} :: typeof(athLibrary)));

--[==[
    @class athLibrary

    Creates a new athLibrary object, a housing for a generic library object that can be built and ran by an athHost.

    Internal components of the library are exposed to this object natively by the athHost, and external clients are required to
    slot into the athHost and negotiate with it to access the internal components.

    :::INFO
    If you are the creator of a library or a maintainer of a library which builds with Athena, please read this documentation.
    If you are a developer of an experience which includes Athena built libraries, you can safely ignore this file.
    :::
]==]
function athLibrary.new(athLibraryCreateInfo : athTypes.athLibraryCreateInfo) : athLibrary
    local library = setmetatable({}, athLibrary);

    return library;
end

--[==[
    @class athLibrary

    Sets the internal registry of classes in this athLibrary object.
]==]
function athLibrary:athSetClasses()

end

--[==[
    @class athLibrary

    Returns the internal registry of classes in this athLibrary object.
]==]
function athLibrary:athGetClasses()

end

--[==[
    @class athLibrary

    Sets the internal registry of types in this athLibrary object.
]==]
function athLibrary:athSetProjectTypes()

end

--[==[
    @class athLibrary

    Returns the internal registry of types in this athLibrary object.
]==]
function athLibrary:athGetProjectTypes()

end

--[==[
    @class athLibrary

    Makes the copy of a singleton of class in this athLibrary object stored under className.
]==]
function athLibrary:athCreateProjectSingleton(className, class)

end

--[==[
    @class athLibrary

    Returns the internal copy of a singleton of className in this athLibrary object
]==]
function athLibrary:athGetProjectSingleton(className)

end

return athLibrary :: athLibrary;