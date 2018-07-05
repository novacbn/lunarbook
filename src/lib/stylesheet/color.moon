import type from _G

import new from "luapower/color/exports"

-- ::alpha(string or table value, number alpha) -> string
--
-- export
export alpha = (value, alpha) ->
    error("bad argument #1 to 'alpha' (expected string)") unless type(value) == "string" or type(value) == "table"
    error("bad argument #2 to 'alpha' (expected number)") unless type(alpha) == "number"

    r, g, b = new(value)\rgb()
    r, g, b = r * 255, g * 255, b * 255
    color   = new("rgb", r, g, b, alpha)
    return color\format("#rrggbbaa")

-- ::darken(string or table value, number delta) -> string
-- Darkens a color value by the given 0..1 delta
-- export
export darken = (value, delta) ->
    error("bad argument #1 to 'darken' (expected string)") unless type(value) == "string" or type(value) == "table"
    error("bad argument #2 to 'darken' (expected number)") unless type(delta) == "number"

    color = new(value)
    return color\shade(delta)\format("#rrggbb")

-- ::desaturate(string value, number delta) -> string
--
-- export
export desaturate = (value, delta) ->
    error("bad argument #1 to 'desaturate' (expected string)") unless type(value) == "string" or type(value) == "table"
    error("bad argument #2 to 'desaturate' (expected number)") unless type(delta) == "number"

    color = new(value)
    return color\desaturate_by(delta)\format("#rrggbb")

-- ::lighten(string or table value, number delta) -> string
-- Lightens a color value by the given 0..1 delta
-- export
export lighten = (value, delta) ->
    error("bad argument #1 to 'lighten' (expected string)") unless type(value) == "string" or type(value) == "table"
    error("bad argument #2 to 'lighten' (expected number)") unless type(delta) == "number"

    color = new(value)
    return color\tint(delta)\format("#rrggbb")

-- ::toHex(string or table value) -> string
-- Converts a color value into a hex color string
-- export
export toHex = (value) ->
    error("bad argument #1 to 'toHex' (expected string)") unless type(value) == "string" or type(value) == "table"
    return new(value)\format("#rrggbb")