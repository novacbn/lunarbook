import pairs from _G
import gsub, lower, sub from string
import concat from table

import dashcase from "novacbn/lunarbook/lib/utilities/string"

-- ::TABLE_STATE_REPLACEMENTS -> table
-- Represents rule states that need replacing
--
TABLE_STATE_REPLACEMENTS = {
    normal: ""
}

-- ::encode(table data) -> string
-- Encodes a set of stylesheet rules into a CSS file
-- export
export encode = (data) ->
    buffer  = {}
    index   = 0

    append = (value) ->
        index           += 1
        buffer[index]   = value

    for name, states in pairs(data)
        name = dashcase(name)
        for state, rules in pairs(states)
            state   = lower(state)
            state   = TABLE_STATE_REPLACEMENTS[state] or state

            if #state > 0
                if sub(state, 1, 1) == "[" then append("."..name..state.."{")
                else append("."..name..":"..state.."{")
            else append("."..name.."{")

            append(dashcase(rule)..":"..value..";") for rule, value in pairs(rules)
            append("}")

    return concat(buffer, "")