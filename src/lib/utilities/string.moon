import lower, gsub, sub from string

-- ::dashcase(string value) -> string
-- Formats 'camelCaseString' to 'dash-case-string'
-- export
export dashcase = (value) ->
    return gsub(value, "%u", => "-"..lower(@))

-- ::endswith(string value, string postfix) -> boolean
-- Returns if the value ends with the postfix
-- export
export endswith = (value, postfix) ->
    return sub(value, -1 * #postfix) == postfix

-- ::gsubwhile(string value, string pattern, string or function replacement) -> string
-- Performs replacements until no more are available
-- expor
export gsubwhile = (value, pattern, replacement) ->
    replacements = 1
    while replacements > 0
        value, replacements = gsub(value, pattern, replacement)

    return value

-- ::slugify(string value) -> string
-- Slugifies a string to for URL compatibility
-- export
export slugify = (value) ->
    value   = gsubwhile(value, "%c", "")
    value   = gsubwhile(value, "[^%w%-]", "-")
    value   = gsubwhile(value, "%-%-", "-")
    value   = gsub(value, "^%-*(.-)%-*$", "%1")
    return lower(value)