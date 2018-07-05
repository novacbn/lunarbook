import ipairs, pairs, setfenv, setmetatable, tostring, type from _G
import concat, insert from table

import dashcase from "novacbn/lunarbook/lib/utilities/string"

-- ::LayoutEnv -> table
-- Represents chunk environment available to layouts
--
LayoutEnv = {
    ipairs:     ipairs
    print:      print
    pairs:      pairs
    tostring:   tostring
}

LayoutEnv.__index = LayoutEnv

-- ::Layout(function chunk, table env, table stylesheet?) -> function
--
-- export
export Layout = (chunk, env, stylesheet={}) ->
    error("bad argument #1 to 'Layout' (expected function)") unless type(chunk) == "function"
    error("bad argument #2 to 'Layout' (expected table)") unless type(env) == "table"
    error("bad argument #3 to 'Layout' (expected table)") unless type(stylesheet) == "table"

    local buffer
    tag = (name, attributes, value) ->
        insert(buffer, "<"..name)

        attributesType = type(attributes)
        if attributesType == "function" or attributesType == "string"
            value       = attributes
            attributes  = nil

        if attributes
            for attribute, value in pairs(attributes)
                attribute = dashcase(attribute)
                if value == true then insert(buffer, " "..attribute)
                else insert(buffer, " "..attribute.."='"..tostring(value).."'")

        valueType = type(value)
        if valueType == "string" then insert(buffer, ">"..value.."</"..name..">")
        elseif valueType == "function"
            insert(buffer, ">")
            value()
            insert(buffer, "</"..name..">")

        else insert(buffer, " />")

    chunkenv = {
        __index: (self, key) ->
            return LayoutEnv[key] if LayoutEnv[key] ~= nil
            return (...) -> tag(dashcase(key), ...)
    }

    chunkenv    = setmetatable({}, chunkenv)
    chunk       = setfenv(chunk, chunkenv)()

    return (state) ->
        buffer = {}
        chunk(state, env, stylesheet)
        output = concat(buffer, "")
        buffer = nil
        return output