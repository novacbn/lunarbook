import type, select from _G
import match from string

import dirname from require "path"

-- ::isdirSync(VirtualFileSystem vfs, string path) -> boolean
-- Returns if the path exists and is a directory on the VirtualFileSystem
-- export
export isdirSync = (vfs, path) ->
    error("bad argument #1 to 'isdirSync' (expected VirtualFileSystem)") unless type(vfs) == "table"
    error("bad argument #2 to 'isdirSync' (expected string)") unless type(path) == "string"
    return vfs\accessSync(path) and vfs\statSync(path).type == "directory"

-- ::isfileSync(VirtualFileSystem vfs, string path) -> boolean
-- Returns if the path exists and is a file on the VirtualFileSystem
-- export
export isfileSync = (vfs, path) ->
    error("bad argument #1 to 'isfileSync' (expected VirtualFileSystem)") unless type(vfs) == "table"
    error("bad argument #2 to 'isfileSync' (expected string)") unless type(path) == "string"
    return vfs\accessSync(path) and vfs\statSync(path).type == "file"

-- ::join(string parent, string path, ...) -> string
-- Concatenates VirtualFileSystem paths together
-- export
export join = (parent, path, ...) ->
    error("bad argument #1 to 'join' (expected string)") unless type(parent) == "string"
    error("bad argument #2 to 'join' (expected string)") unless type(path) == "string"

    local result
    if #path > 0
        if #parent > 0 then result = parent.."/"..path
        else result = path
    else result = parent

    return join(result, ...) unless select("#", ...) == 0
    return result

-- ::mkdirpSync(VirtualFileSystem vfs, string directory) -> void
-- Recursively creates the parent directories then makes the provided directory
-- export
export mkdirpSync = (vfs, directory) ->
    error("bad argument #1 to 'mkdirpSync' (expected VirtualFileSystem)") unless type(vfs) == "table"
    error("bad argument #2 to 'mkdirpSync' (expected string)") unless type(directory) == "string"

    parent = dirname(directory)
    if match(parent, "^[%w]+://")
        mkdirpSync(vfs, parent) unless vfs\accessSync(parent)

    vfs\mkdirSync(directory) unless vfs\accessSync(directory)