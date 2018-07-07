import gsub, lower from string

-- ::dashcase(string value) -> string
-- Formats 'camelCaseString' to 'dash-case-string'
-- export
export dashcase = (value) ->
    return gsub(value, "%u", => "-"..lower(@))

-- ::makeTruthyMap(table tbl) -> table
--
-- export
export makeTruthyMap = (tbl) ->
    return {value, true for value in *tbl}

-- ::filter(table tbl, function predicate) -> table
--
--
export filter = (tbl, predicate) ->
    return [value for value in *tbl when predicate(value)]