import getmetatable, ipairs, pairs, setfenv, setmetatable, type from _G
import concat, insert, sort from table

import SELECTOR_PSEUDO_CLASSES, SELECTOR_PSEUDO_ELEMENTS from "novacbn/lunarviz/constants"
import dashcase from "novacbn/lunarviz/utilities"

-- ::ASTRoot(string name) -> ASTRoot
-- Represents the root of a LunarViz Style
--
ASTRoot = (name) -> {
    -- ASTRoot::name -> string
    -- Represents the name of the style
    --
    name: name

    -- ASTRoot::rules -> table
    -- Represents a table of ASTRule values
    --
    rules: {}
}

-- ::ASTProperty(string name, string or number value) -> ASTProperty
-- Represents a property of a style rule
--
ASTProperty = (name, value) -> {
    -- ASTProperty::name -> string
    -- Represents the name of the property
    --
    name: name

    -- ASTProperty::value -> string or number
    -- Represents the value of the property
    --
    value: value
}

-- ::ASTRule(string target, table modifiers?, table parents?, table properties?) -> ASTRule
-- Represents a rule of a LunarViz Style
--
ASTRule = (target, modifiers={}, parents={}, properties={}) -> {
    -- ASTRule::modifiers -> table
    -- Represents the element modifiers of the rule
    --
    modifiers: modifiers

    -- ASTRule::parents -> table
    -- Represents parent selectors of the rule
    --
    parents: parents

    -- ASTRule::properties -> table
    -- Represents the style properties of the rule
    --
    properties: properties

    -- ASTRule::target -> string
    -- Represents the target element type being targeted by the rule
    --
    target: target
}

-- ::sortProperties(ASTProperty a, ASTProperty b) -> boolean
-- Sorts rule properties by their name
--
sortProperties = (a, b) ->
    return a.name < b.name

-- ::RuleMeta -> table
-- Represents the LunarViz Style rule construction metatable
--
local RuleMeta
RuleMeta = {
    -- RuleMeta::__call(table properties) -> void
    -- Parses and adds the properties to the rule's style
    --
    __call: (self, properties) ->
        error("malformed properties table") unless type(properties) == "table" and getmetatable(properties) == nil

        sorted = {}
        for key, value in pairs(properties)
            error("malformed properties key '#{key}'") unless type(key) == "string"
            error("malformed properties value '#{key}'") unless type(value) == "string" or type(value) == "number"

            key = dashcase(key)
            insert(sorted, ASTProperty(key, value))

        sort(sorted, sortProperties)
        self.__ast.properties = sorted
        insert(self.__parent, self.__ast)

        return self

    -- RuleMeta::__index(string key) -> Rule
    -- Appends the selector modifier to the rule
    --
    __index: (self, key) ->
        error("malformed modifier key '#{key}'") unless type(key) == "string"

        key = dashcase(key)
        ast = self.__ast

        if SELECTOR_PSEUDO_CLASSES[key] then insert(ast.modifiers, ":"..key)
        elseif SELECTOR_PSEUDO_ELEMENTS[key] then insert(ast.modifiers, "::"..key)
        else insert(ast.modifiers, "."..key)

        return self

    -- RuleMeta::__mul(table rule) -> table
    -- Allows targeting elements within the main selector
    --
    __mul: (self, rule) ->
        error("malformed rule modifier") unless type(rule) == "table" and getmetatable(rule) == RuleMeta

        modifier                = " "..rule.__ast.target..concat(rule.__ast.modifiers, "")
        rule.__ast.target       = self.__ast.target
        rule.__ast.modifiers    = self.__ast.modifiers
        insert(rule.__ast.modifiers, modifier)

        return rule
}

-- ::compile(ASTRoot syntaxtree, boolean format?) -> string
-- Compiles a LunarViz Style Abstract Syntax Tree into a Stylesheet string
-- export
export compile = (syntaxtree, format=false) ->
    error("bad argument #1 to 'compile' (expected ASTRoot)") unless type(syntaxtree) == "table"
    error("bad argument #2 to 'compile' (expected boolean)") unless type(format) == "boolean"

    buffer  = {}
    index   = 0

    local append
    append = (value, next, ...) ->
        index           += 1
        buffer[index]   = value
        append(next, ...) if next

    for rule in *syntaxtree.rules
        -- If it's the root component, select only the root LunarViz Layout
        if rule.target == "root" then append("*[data-root]")
        else append(rule.target)

        -- Only select component's belonging to this LunarViz Layout
        -- e.g. [data-layout='3f19d616ab1973eab54443edad1f469f67e51a95']
        append("[data-layout='", syntaxtree.name, "']")
        append(modifier) for modifier in *rule.modifiers

        if format then append(" ")
        append("{")

        for property in *rule.properties
            if format then append("\n\t")

            append(property.name, ": ", property.value, ";")

        append("\n", "}", "\n")

    return concat(buffer, "")

-- ::parse(function chunk, string name, table chunkenv?, any ...) -> ASTRoot
-- Parses a LunarViz Style and returns the Abstract Syntax Tree
-- export
export parse = (chunk, name, chunkenv={}, ...) ->
    error("bad argument #1 to 'parse' (expected function)") unless type(chunk) == "function"
    error("bad argument #2 to 'parse' (expected string)") unless type(name) == "string"
    error("bad argument #3 to 'parse' (expected table)") unless type(chunkenv) == "table"

    name        = dashcase(name)
    syntaxtree  = ASTRoot(name)

    environment = {
        __index: (self, key) ->
            key = dashcase(key)
            return setmetatable({__ast: ASTRule(key), __parent: syntaxtree.rules}, RuleMeta)
    }

    setmetatable(chunkenv, environment)
    setfenv(chunk, chunkenv)

    chunk(...)
    return syntaxtree