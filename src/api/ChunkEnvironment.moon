import type from _G

import Object from require "core"

-- ChunkEnvironment::ChunkEnvironment()
-- Represents a function chunk environment with extension functionality
-- export
export ChunkEnvironment = with Object\extend()
    -- ChunkEnvironment::environment -> table
    -- Represents the environment of the function chunk environment
    --
    .environment = nil

    -- ChunkEnvironment::initialize() -> void
    -- Constructor for ChunkEnvironment
    --
    .initialize = () =>
        @environment = {}

    -- ChunkEnvironment::clone() -> table
    --
    --
    .clone = () =>
        return {key, value for key, value in pairs(@environment)}

    -- ChunkEnvironment::registerVariable(string name, any value) -> void
    -- Registers a value by name to the environment
    --
    .registerVariable = (name, value) =>
        error("bad argument #1 to 'registerVariable' (expected string)") unless type(name) == "string"
        error("bad argument #1 to 'registerVariable' (pre-existing name)") if @environment[name]

        @environment[name] = value



