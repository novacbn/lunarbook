import resolve from require "path"

import Theme from "novacbn/lunarbook/api/Theme"

-- ::SERVER_ROUTES -> table
-- Represents the web server HTTP routes
--
SERVER_ROUTES = {
}

-- ::TEXT_COMMAND_DESCRIPTION -> string
-- Represents the description of the command
-- export
export TEXT_COMMAND_DESCRIPTION = "Starts a hot-reloading webserver"

-- ::TEXT_COMMAND_SYNTAX -> string
-- Represents the syntax of the command
-- export
export TEXT_COMMAND_SYNTAX = "[directory]"

-- ::TEXT_COMMAND_EXAMPLES -> string
-- Represents the examples of the command
-- export
export TEXT_COMMAND_EXAMPLES = {
    "./book"
}

-- ::configureCommand(Command command, Options options) -> void
-- Configures the input of the command
-- export
export configureCommand = (command, options) ->
    with options
        \string "server-host", "Sets the webserver's host", "0.0.0.0"
        \number "server-port", "Sets the webserver's port", 9090

config = {
    environment:
        title: "LunarBook"

    omnibar: {
        {text: "Guide", link: "/"}
        {text: "Configuration Reference", link: "/config"}
        {text: "Theming", link: "/themes"}
    }
}

-- ::executeCommand(Options options, string directory?) -> void
--
-- export
export executeCommand = (options, directory="book") ->
    theme   = Theme\new(".lunarbook/theme", config)
    render  = theme\parseComponent("Index", {})

    print("\nIndex")
    print(k, v) for k, v in pairs(render)