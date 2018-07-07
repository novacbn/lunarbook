import type from _G
import lower from string
import insert from table

import Object from require "core"
import endswith from "novacbn/lunarbook/lib/utilities/string"

-- ::pass(any ...) ->  any ...
-- Returns all input arguments
--
pass = (...) -> return ...

-- ::RegisteredTransformer(string ext, function transform, function post) -> RegisteredTransformer
-- Represents a registered transformer
--
RegisteredTransformer = (ext, transform, post) -> {
    -- RegisteredTransformers::ext -> string
    -- Represents the extension used by the transformer
    --
    ext: ext

    -- RegisteredTransformers::post -> function
    -- Represents the post processing function of the transformer
    --
    post: post

    -- RegisteredTransformers::transform -> function
    -- Represents the transformation function of the transformer
    --
    transform: transform
}

-- Transformers::Transformers()
-- Represents the transformers registered for LunarBook related files
-- export
export Transformers = with Object\extend()
    -- Transformers::fragmentTransformers -> table
    -- Represents the registered fragment transformers
    --
    .fragmentTransformers = nil

    -- Transformers::initialize() -> void
    -- Constructor for Transformer
    --
    .initialize = () =>
        @fragmentTransformers = {}

    -- Transformers::registerFragment(string ext, function transform, function post?) -> void
    -- Registers a fragment transformer
    --
    .registerFragment = (ext, transform, post=pass) =>
        error("bad argument #1 to 'registerFragment' (expected string)") unless type(ext) == "string"
        error("bad argument #2 to 'registerFragment' (expected function)") unless type(transform) == "function"
        error("bad argument #3 to 'registerFragment' (expected function)") unless type(post) == "function"

        ext = lower(ext)
        error("bad argument #1 to 'registerFragment' (pre-existing transformer)") if @fragmentTransformers[ext]

        insert(@fragmentTransformers, RegisteredTransformer(ext, transform, post))

    -- Transformers::processFragment(string file, boolean inDev, string contents) -> string
    -- Processes the book fragment into a HTML fragment
    --
    .processFragment = (file, inDev, contents) =>
        error("bad argument #1 to 'processFragment' (expected string)") unless type(file) == "string"
        error("bad argument #2 to 'processFragment' (expected boolean)") unless type(inDev) == "boolean"
        error("bad argument #3 to 'processFragment' (expected string)") unless type(contents) == "string"

        local selectedTransformer
        file = lower(file)

        for transformer in *@fragmentTransformers
            if endswith(file, transformer.ext)
                selectedTransformer = transformer
                break

        error("bad argument #1 to 'processFragment' (unexpected extension)") unless selectedTransformer
        contents    = selectedTransformer.transform(inDev, contents)
        contents    = selectedTransformer.post(inDev, contents)
        return contents