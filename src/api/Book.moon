import pairs, type from _G
import lower from string

import Object from require "core"
import readFileSync from require "fs"
import basename, dirname, extname from require "path"
import decode from "novacbn/properties/exports"
import VirtualFileSystem from "novacbn/luvit-extras/vfs"
import FileSystemAdapter from "novacbn/luvit-extras/adapters/FileSystemAdapter"
fsx = dependency "novacbn/luvit-extras/fs"

import Theme from "novacbn/lunarbook/api/Theme"
import PluginManager from "novacbn/lunarbook/api/PluginManager"
import ALLOWED_FRAGMENT_TYPES, BOOK_HOME, BUILD_DIRS from "novacbn/lunarbook/lib/constants"
import extractSections, extractTitle from "novacbn/lunarbook/lib/utilities"
import endswith, slugify from "novacbn/lunarbook/lib/utilities/string"
import isdirSync, isfileSync, join from "novacbn/lunarbook/lib/utilities/vfs"
import LunarConfig from "novacbn/lunarbook/schemas/LunarConfig"

-- ::ProcessedFragment(string render, string link, string title, table sections) -> ProcessedFragments
-- Represents a book fragment that's been processed
--
ProcessedFragment = (render, link, title, sections) -> {
    -- ProcessedFragment::link -> string
    -- Represents the canonical URL link of the fragment
    --
    link: link

    -- ProcessedFragment::render -> string
    -- Represents the rendered layout of the fragment
    --
    render: render

    -- ProcessedFragment::title -> string
    -- Represents the extracted title of the fragment
    --
    title: title

    -- ProcessedFragment::sections -> table
    -- Represents the extract header sections of the fragment
    --
    sections: sections
}

-- Book::Book()
-- Represents a LunarBook build
-- export
export Book = with Object\extend()
    -- Book::cache -> table
    -- Represents a lookup table of previously-processed fragments
    --
    .cache = nil

    -- Book::configuration -> table
    -- Represents the configuration of the current book
    --
    .configuration = nil

    -- Book::layoutEnvironment -> table
    -- Represents the environment of for LunarViz Layouts
    --
    .layoutEnvironment = nil

    -- Book::plugins -> PluginManager
    -- Represents the plugins loaded for this book
    --
    .plugins = nil

    -- Book::styleEnvironment -> table
    -- Represents the environment of for LunarViz Styles
    --
    .styleEnvironment = nil

    -- Book::theme -> Theme
    -- Represents the theme of the LunarBook
    --
    .theme = nil

    -- Book::vfs -> VirtualFileSystem
    -- Represents the VirtualFileSystem used for the book
    --
    .vfs = nil

    -- Book::initialize(string bookDirectory, string buildDirectory, string themeDirectory) -> void
    -- Constructor for Book
    --
    .initialize = (bookDirectory, buildDirectory, themeDirectory) =>
        error("bad argument #1 to 'initialize' (expected string)") unless type(bookDirectory) == "string"
        error("bad argument #2 to 'initialize' (expected string)") unless type(buildDirectory) == "string"

        local configuration
        if fsx.isfileSync(BOOK_HOME.configuration)
            contents        = readFileSync(BOOK_HOME.configuration)
            configuration   = decode(contents, propertiesEncoder: "moonscript")

        @configuration, err = LunarConfig\transform(configuration)
        error("bad dispatch to 'initialize' (malformed book config)\n#{err}") if err

        @cache      = {}
        @plugins    = PluginManager\new()
        @theme      = Theme\new(themeDirectory, @configuration.theme)

        @vfs = VirtualFileSystem\new()
        @vfs\mount("book", FileSystemAdapter\new(bookDirectory))
        @vfs\mount("build", FileSystemAdapter\new(buildDirectory))

        -- Create the missing asset directories if needed
        @vfs\mkdirSync(BUILD_DIRS.assets) unless isdirSync(@vfs, BUILD_DIRS.assets)
        @vfs\mkdirSync(BUILD_DIRS.fragments) unless isdirSync(@vfs, BUILD_DIRS.fragments)
        @vfs\mkdirSync(BUILD_DIRS.scripts) unless isdirSync(@vfs, BUILD_DIRS.scripts)
        @vfs\mkdirSync(BUILD_DIRS.styles) unless isdirSync(@vfs, BUILD_DIRS.styles)

        @initializePlugins()
        @initializeAssets()

    -- Book::initializeAssets() -> void
    --
    --
    .initializeAssets = () =>
        for asset in *@theme\getIncludedAssets()
            @vfs\writeFileSync(join(BUILD_DIRS.assets, asset.name), asset.contents)

        @theme.configuration.environment.scripts = ["assets/"..asset.name for asset in *@theme\getIncludedAssets() when endswith(lower(asset.name), ".js")]
        @theme.configuration.environment.styles = ["assets/"..asset.name for asset in *@theme\getIncludedAssets() when endswith(lower(asset.name), ".css")]

    -- Book::initializePlugins() -> void
    -- Initializes the user-supplied plugins
    --
    .initializePlugins = () =>
        @plugins\processConfiguration(@configuration.plugins)

        @transformers           = @plugins\configureTransformers()
        @layoutEnvironment      = @plugins\configureLayoutEnvironment()\clone()
        @styleEnvironment       = @plugins\configureStyleEnvironment()\clone()

    -- Book::createFragment(string file, table fragments) -> void
    -- Creates the fragment in the build directory
    --
    .createFragment = (file, fragments) =>
        fragment    = @processFragment(file)
        layout      = @theme\render("Index", true, @layoutEnvironment, fragment: fragment.render, navigation: fragments)

        link = join(BUILD_DIRS.fragments, fragment.link)
        @vfs\mkdirSync(link) unless isdirSync(@vfs, link)
        @vfs\writeFileSync(join(link, "index.html"), fragment.render)

        @vfs\mkdirSync(BUILD_DIRS.scheme..fragment.link) unless isdirSync(@vfs, BUILD_DIRS.scheme..fragment.link)
        @vfs\writeFileSync(BUILD_DIRS.scheme..join(fragment.link, "index.html"), layout)

    -- Book::processBook() -> void
    -- Processes the directory of the LunarBook
    --
    .processBook = () =>
        -- Start processing the book from the base directory
        @processDirectory("")

        -- Write any memory-cached assets to disk
        @vfs\writeFileSync(join(BUILD_DIRS.fragments, fragment.link..".html"), fragment.render) for fragment in *@cache

        --@vfs\writeFileSync(join(BUILD_DIRS.scripts, "lunarbook.components.js", @theme\getComputedScript())
        @vfs\writeFileSync(join(BUILD_DIRS.styles, "lunarbook.components.css"), @theme\getComputedStyle(true, @styleEnvironment))

    -- Book::processDirectory(string directory) -> void
    -- Processes the directory of the book
    --
    .processDirectory = (directory) =>
        entries     = @vfs\readdirSync("book://"..directory)
        directories = [entry for entry in *entries when isdirSync(@vfs, "book://"..join(directory, entry))]
        files       = [entry for entry in *entries when isfileSync(@vfs, "book://"..join(directory, entry)) and ALLOWED_FRAGMENT_TYPES[lower(extname(entry))]]
        fragments   = [@processFragment(join(directory, fragment)) for fragment in *files]

        if #directories > 0 or #files > 0
            @vfs\mkdirSync("build://#{directory}") unless isdirSync(@vfs, "build://#{directory}")
            @vfs\mkdirSync(join(BUILD_DIRS.fragments, directory)) unless isdirSync(@vfs, join(BUILD_DIRS.fragments, directory))

        @processDirectory(join(directory, entry)) for entry in *directories
        @createFragment(join(directory, entry), #fragments > 1 and fragments) for entry in *files
        --@createNavigation(directory, files) if #files > 1

    -- Book::processFragment(string file) -> table
    -- Processes the LunarBook fragment for metadata
    --
    .processFragment = (file) =>
        unless @cache[file]
            -- Load the fragment from disk and then have the theme process and render it
            contents    = @vfs\readFileSync("book://"..file)
            contents    = @transformers\processFragment(file, false, contents)
            layout      = @theme\render("Fragment", true, @layoutEnvironment, fragment: contents)

            -- Slugify and use the title of the fragment as the link
            -- Or, if the link is an index file, use the base directory
            link    = dirname(file)
            link    = "" if link == "."
            title   = extractTitle(layout)

            unless basename(file, extname(file)) == "index"
                link = join(link, slugify(title))
                error("bad argument #1 to 'processFragment' (missing or malformed title)") unless #link > 0

            sections        = [{title: section, link: link.."#"..slugify(section)} for section in *extractSections(layout)]
            @cache[file]    = ProcessedFragment(layout, link, title, sections)

        return @cache[file]