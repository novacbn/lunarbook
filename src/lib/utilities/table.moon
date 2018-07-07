import pairs, type from _G

-- ::merge(table target, table source) -> table
-- Merges the source table with the target table
-- export
export merge = (target, source) ->
    for key, value in pairs(source)
        if type(target[key]) == "table" and type(value) == "table" then merge(target[key], value)
        elseif target[key] == nil then target[key] = value

    return target