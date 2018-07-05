import getmetatable, pairs, setfenv, setmetatable, type from _G

import Object from require "core"

import encode from "novacbn/lunarbook/lib/stylesheet"

-- ::TABLE_INCLUDED_ENV -> table
--
--
TABLE_INCLUDED_ENV = {
    dependency "novacbn/lunarbook/lib/stylesheet/color"
}

-- ::StylesheetEnv -> table
--
--
StylesheetEnv = {
    tostring: tostring
}

StylesheetEnv.__index = StylesheetEnv

for exports in *TABLE_INCLUDED_ENV
    for key, value in pairs(getmetatable(exports).__index)
        StylesheetEnv[key] = value

-- ::Stylesheet(string name, function chunk, table env) -> Stylesheet
--
-- export
export Stylesheet = (name, chunk, env) ->
    error("bad argument #1 to 'Stylesheet' (expected string)") unless type(name) == "string"
    error("bad argument #2 to 'Stylesheet' (expected function)") unless type(chunk) == "function"
    error("bad argument #3 to 'Stylesheet' (expected table)") unless type(env) == "table"

    chunkenv            = setmetatable({env: env}, StylesheetEnv)
    chunkenv.__index    = chunkenv

    chunkenv    = setmetatable({}, chunkenv)
    chunk       = setfenv(chunk, chunkenv)
    rules       = chunk()

    classes     = {selector, "component-#{name}-#{selector}" for selector, states in pairs(rules)}
    contents    = {"component-#{name}-#{selector}", states for selector, states in pairs(rules)}
    contents    = encode(contents)

    return {
        -- Stylesheet::classes -> table
        --
        --
        classes: classes

        -- Stylesheet::contents -> string
        --
        --
        contents: contents
    }