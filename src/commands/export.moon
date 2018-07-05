import mkdirSync from require "fs"
import join from require "path"
import isfileSync, isdirSync from "novacbn/luvit-extras/fs"

import Book from "novacbn/lunarbook/api/Book"
import BOOK_HOME from "novacbn/lunarbook/lib/constants"

-- ::TEXT_COMMAND_DESCRIPTION -> string
-- Represents the description of the command
-- export
export TEXT_COMMAND_DESCRIPTION = "Builds and exports the LunarBook"

-- ::TEXT_COMMAND_SYNTAX -> string
-- Represents the syntax of the command
-- export
export TEXT_COMMAND_SYNTAX = "[book directory] [build directory]"

-- ::TEXT_COMMAND_EXAMPLES -> string
-- Represents the examples of the command
-- export
export TEXT_COMMAND_EXAMPLES = {
    "./book"
}

-- ::executeCommand(Options options, string directory?, string out?) -> void
--
-- export
export executeCommand = (options, bookDirectory="book", buildDirectory="dist") ->
    mkdirSync(buildDirectory) unless isdirSync(buildDirectory)

    book = Book\new(bookDirectory, buildDirectory, BOOK_HOME.theme)
    book\processBook()

    print("LunarBook was exported to '#{buildDirectory}'")
    