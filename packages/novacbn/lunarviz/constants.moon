import makeTruthyMap from "novacbn/lunarviz/utilities"

-- ::SELECTOR_PSEUDO_CLASSES -> table
-- Represents selector names that are pseudo classes
-- export
export SELECTOR_PSEUDO_CLASSES = makeTruthyMap {
    "active", "checked", "default", "defined",
    "disabled", "empty", "enabled", "first",
    "first-child", "first-of-type", "focus", "focus-within",
    "host", "hover", "indeterminate", "in-range",
    "invalid", "last-child", "last-of-type", "left",
    "link", "only-child", "only-of-type", "optional",
    "out-of-range", "read-only", "read-write", "required",
    "right", "scope", "target", "valid", "visited"
}

-- ::SELECTOR_PSEUDO_ELEMENTS -> table
-- Represents selector names that are pseudo elements
-- export
export SELECTOR_PSEUDO_ELEMENTS = makeTruthyMap {
    "after", "backdrop", "before", "cue",
    "first-letter", "first-line"
}

-- ::ELEMENT_VOID_TAGS -> table
-- Represents HTML Element tags that are formatted as '<tag />' rather than '<tag></tag>'
-- export
export ELEMENT_VOID_TAGS = makeTruthyMap {
    "area", "base", "br", "col",
    "command", "embed", "hr", "img",
    "input", "keygen", "link", "meta",
    "param", "source", "track", "wbr",
}