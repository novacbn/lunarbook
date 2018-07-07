import cwd from process
import join from require "path"

-- ::ALLOWED_FRAGMENT_TYPES -> table
-- Represents which fragment types are parseable for the LunarBook
-- export
export ALLOWED_FRAGMENT_TYPES = {fragmentType, true for fragmentType in *{
    ".html"
    ".md"
}}

-- ::BOOK_HOME -> table
-- Represents the LunarBook related paths for the current book
-- export
export BOOK_HOME = with {}
    -- BOOK_HOME::home -> string
    -- Represents the home directory of the book
    --
    .home = cwd()

    -- BOOK_HOME::data -> string
    -- Represents the configuration directory for the book
    --
    .data = join(.home, ".lunarbook")

    -- BOOK_HOME::assets -> string
    -- Represents the directory for the user-shipped assets of the book
    --
    .assets = join(.data, "assets")

    -- BOOK_HOME::theme -> string
    -- Represents the directory for the local theme of the book
    --
    .theme = join(.data, "theme")

    -- BOOK_HOME::plugins -> table
    -- Represents the directory for the local LunarBook plugins
    --
    .plugins = join(.data, "plugins")

    -- BOOK_HOME::configuration -> string
    -- Represents the local configuration file of the book
    --
    .configuration = join(.data, "configuration.mprop")

-- ::BUILD_DIRS -> table
-- Represents the LunarBook build directories
-- export
export BUILD_DIRS = with {}
    -- ::BUILD_DIRS::scheme -> string
    --
    --
    .scheme = "build://"

    -- BUILD_DIRS::assets -> string
    --
    --
    .assets = .scheme.."assets"

    -- BUILD_DIRS::fragments -> string
    --
    --
    .fragments = .assets.."/fragments"

    -- BUILD_DIRS::scripts -> string
    --
    --
    .scripts = .assets.."/scripts"

    -- BUILD_DIRS::styles -> string
    --
    --
    .styles = .assets.."/styles"
