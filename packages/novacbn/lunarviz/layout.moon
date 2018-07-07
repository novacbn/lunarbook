import pairs, type from _G
import rep from string
import concat, insert from table

import ELEMENT_VOID_TAGS from "novacbn/lunarviz/constants"
import dashcase, filter from "novacbn/lunarviz/utilities"

-- ::ASTRoot(string name, table nodes?) -> ASTRoot
-- Represents the root of the layout
--
ASTRoot = (name, nodes={}) -> {
    -- ASTRoot::name -> string
    -- Represents the name of the layout
    --
    name: name

    -- ASTRoot::isRoot -> boolean
    -- Represents if this node is the root node
    --
    isRoot: true

    -- ASTRoot::nodes -> table
    -- Represents the child nodes of the layout
    --
    nodes: nodes
}

-- ::ASTAttribute(string name, string or boolean value) -> ASTAttribute
-- Represents an attribute of an HTML Element
--
ASTAttribute = (name, value) -> {
    -- ASTAttribute::name -> string
    -- Represents the name of the attribute
    --
    name: name

    -- ASTAttribute::value -> string or boolean
    -- Represents the value of the attribute
    --
    value: value
}

-- ::ASTElementNode(string tag, table attributes?, table children?, boolean isVoidTag?) -> ASTElementNode
-- Represents a HTML Element node
--
ASTElementNode = (tag, attributes={}, children={}, isVoidTag=false) -> {
    -- ASTElementNode::attributes -> table
    -- Represents the attributes of the element
    --
    attributes: attributes

    -- ASTElementNode::isVoidTag -> boolean
    -- Represents if node's tag is of void class
    --
    isVoidTag: isVoidTag

    -- ASTElementNode::nodes -> table
    -- Represents the child elements of the element
    --
    nodes: children

    -- ASTElementNode::tag -> string
    -- Represents the HTML tag of the element
    --
    tag: tag
}

-- ::ASTTextNode(string text) -> ASTTextNode
-- Represents a Raw Text node
--
ASTTextNode = (text) -> {
    -- ASTTextNode::isTextNode -> boolean
    -- Represents if the node is just text
    --
    isTextNode: true

    -- ASTTextNode::text -> string
    -- Represents the text of the node
    --
    text: text
}

-- ::ChunksMeta -> table
-- Represents the LunarViz Layout construction metatable
--
ChunkMeta = {
    __index: (self, tag) ->
        if tag == "raw"
            return (value) ->
                insert(self.__nodes, ASTTextNode(value))


        tag         = dashcase(tag)
        astnode     = ASTElementNode(tag, nil, nil, ELEMENT_VOID_TAGS[tag] or false)
        parentNodes = self.__nodes
        insert(parentNodes, astnode)

        return (attributes, value) ->
            if type(attributes) == "function" or type(attributes) == "string"
                value       = attributes
                attributes  = nil

            if attributes
                for key, avalue in pairs(attributes)
                    error("malformed attribute name '#{key}'") unless type(key) == "string"
                    error("malformed attribute value for '#{key}'") unless type(avalue) == "string" or type(avalue) == "boolean"

                    key = dashcase(key)
                    insert(astnode.attributes, ASTAttribute(key, avalue))

            if type(value) == "string" then insert(astnode.nodes, ASTTextNode(value))
            elseif type(value) == "function"
                self.__nodes = astnode.nodes
                value()
                self.__nodes = parentNodes
}

-- ::filterText(table value) -> boolean
-- Filters out ASTTextNodes from the table
--
filterText = (value) ->
    return value.isTextNode == nil

-- ::compile(ASTRoot syntaxtree, boolean format?) -> string
-- Compiles a LunarViz Layout Abstract Syntax Tree into a HTML string
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

    traverse = (parent, name, level) ->
        for node in *parent.nodes
            if node.isTextNode
                append(node.text)
                continue

            if node.isRoot
                traverse(node, node.name, level)
                continue

            if format then append(rep("\t", level))

            append("<", node.tag)

            for attribute in *node.attributes
                if type(attribute.value) == "boolean" and attribute.value
                    append(attribute.name)
                    continue

                append(" ", attribute.name, "='", attribute.value, "'")

            -- Append the name of the layout and if it is a root element
            -- Used for scoped styling
            -- .e.g. <div data-layout='3f19d616ab1973eab54443edad1f469f67e51a95' data-root>
            append(" data-layout='", name, "'", parent.isRoot and " data-root")

            -- If the node is a void tag, skip collecting children
            -- .e.g. <link rel='stylesheet' href='/assets/styles/...' />
            if node.isVoidTag
                append(" />", format and "\n")
                continue

            append(">", format and #filter(node.nodes, filterText) > 0 and "\n")

            traverse(node, name, format and level + 1)
            if format and #filter(node.nodes, filterText) > 0 then append(rep("\t", level))

            append("</", node.tag, ">", format and "\n")

    traverse(syntaxtree, syntaxtree.name, 0)
    return concat(buffer, "")

-- ::parse(function chunk, string name, table chunkenv?, any ...) -> ASTRoot
-- Parses a LunarViz Layout and returns the Abstract Syntax Tree
-- export
export parse = (chunk, name, chunkenv={}, ...) ->
    error("bad argument #1 to 'parse' (expected function)") unless type(chunk) == "function"
    error("bad argument #2 to 'parse' (expected string)") unless type(name) == "string"
    error("bad argument #3 to 'parse' (expected table)") unless type(chunkenv) == "table"

    parentNodes = chunkenv.__nodes
    name        = dashcase(name)
    syntaxtree  = ASTRoot(name)
    insert(parentNodes, syntaxtree) if parentNodes

    chunkenv.__nodes = syntaxtree.nodes

    setmetatable(chunkenv, ChunkMeta)
    setfenv(chunk, chunkenv)

    chunk(...)

    if parentNodes then chunkenv.__nodes = parentNodes
    else return syntaxtree