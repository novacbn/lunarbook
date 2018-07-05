import pairs, type from _G
import lower from string

import Object from require "core"
import readFileSync from require "fs"
import basename, dirname, extname from require "path"
import decode from "novacbn/properties/exports"
import VirtualFileSystem from "novacbn/luvit-extras/vfs"
import FileSystemAdapter from "novacbn/luvit-extras/adapters/FileSystemAdapter"
import parse from "sebcat/markdown/exports"
fsx = dependency "novacbn/luvit-extras/fs"

import Theme from "novacbn/lunarbook/api/Theme"
import ALLOWED_FRAGMENT_TYPES, BOOK_HOME, BUILD_DIRS from "novacbn/lunarbook/lib/constants"
import extractSections, extractTitle from "novacbn/lunarbook/lib/utilities"
import slugify from "novacbn/lunarbook/lib/utilities/string"
import isdirSync, isfileSync, join from "novacbn/lunarbook/lib/utilities/vfs"

-- ::TEMPLATE_LAYOUT_ASSETS(string layout, string name, boolean hasStyle, boolean hasScript) -> string
-- Formats a layout to have its style and script included with it
--
TEMPLATE_LAYOUT_ASSETS = (layout, name, hasStyle, hasScript) -> "#{layout}#{hasStyle and '\n<link rel=\'stylesheet\' href=\'/assets/styles/_component.'..name..'.css\' />' or ''}#{hasScript and '\n<script type=\'application/javascript\' src=\'/assets/scripts/_component.'..name..'.js\'></script>' or ''}"

-- ::ProcessedFragment(string render, string link, string title, table sections) -> ProcessedFragments
-- Represents a book fragment that's been processed
--
ProcessedFragment = (render, link, title, sections) -> {
    -- ProcessedFragment::link -> string
    -- Represents the canonical URL link of the fragment
    --
    link: link

    -- ProcessedFragment::render -> string
    -- Represents the rendered data of the fragment
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

    -- Book::includes -> table
    -- Represents the assets included by the theme
    --
    .includes = nil

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

        @cache  = {}
        @theme  = Theme\new(themeDirectory, configuration.theme)

        @vfs = VirtualFileSystem\new()
        @vfs\mount("book", FileSystemAdapter\new(bookDirectory))
        @vfs\mount("build", FileSystemAdapter\new(buildDirectory))

        -- Create the missing asset directories if needed
        @vfs\mkdirSync(BUILD_DIRS.assets) unless isdirSync(@vfs, BUILD_DIRS.assets)
        @vfs\mkdirSync(BUILD_DIRS.fragments) unless isdirSync(@vfs, BUILD_DIRS.fragments)
        @vfs\mkdirSync(BUILD_DIRS.scripts) unless isdirSync(@vfs, BUILD_DIRS.scripts)
        @vfs\mkdirSync(BUILD_DIRS.styles) unless isdirSync(@vfs, BUILD_DIRS.styles)

    -- Book::createFragment(string file, string navigation?, table fragments) -> void
    -- Creates the fragment in the build directory
    --
    .createFragment = (file, navigation, fragments) =>
        fragment    = @processFragment(file)
        render      = @theme\render("Index", fragment: join("assets/fragments", fragment.link), includes: @getIncludes(), navigation: navigation)
        layout      = TEMPLATE_LAYOUT_ASSETS(render.layout, "Index", render.style and true, render.script and true)

        link = join(BUILD_DIRS.fragments, fragment.link)
        @vfs\mkdirSync(link) unless isdirSync(@vfs, link)
        @vfs\writeFileSync(join(link, "index.html"), fragment.render)

        @vfs\mkdirSync(BUILD_DIRS.scheme..fragment.link) unless isdirSync(@vfs, BUILD_DIRS.scheme..fragment.link)
        @vfs\writeFileSync(BUILD_DIRS.scheme..join(fragment.link, "index.html"), layout)

    -- Book::createNavigation(string directory, table files) -> void
    -- Creates a navigation fragment for the specified directory
    --
    .createNavigation = (directory, files) =>
        fragments   = [@processFragment(join(directory, fragment)) for fragment in *files]
        render      = @theme\render("Navigation", fragments: fragments, includes: @getIncludes())
        layout      = TEMPLATE_LAYOUT_ASSETS(render.layout, "Navigation", render.style and true, render.script and true)

        @vfs\writeFileSync(join(BUILD_DIRS.fragments, directory, "_navigation.html"), layout)

    -- Book::getIncludes() -> table
    -- Retreives all the assets being included by the theme
    --
    .getIncludes = () =>
        unless @includes
            scripts = ["/"..join("assets", "scripts", asset.name) for asset in *@theme\getIncludedAssets() when asset.type == "script"]
            styles  = ["/"..join("assets", "styles", asset.name) for asset in *@theme\getIncludedAssets() when asset.type == "style"]

            @includes = {
                scripts:    scripts
                styles:     styles
            }

        return @includes

    -- ::loadFragment(string file) -> string
    -- Loads a fragment from the book
    --
    .loadFragment = (file, vfs) =>
        contents    = @vfs\readFileSync("book://"..file)
        extension   = extname(file)

        if extension == ".md"
            return parse(contents)

        elseif extension == ".html"
            return contents

        error("bad argument #1 to 'processFragment' (unexpected fragment type)")

    -- Book::processBook() -> void
    -- Processes the directory of the LunarBook
    --
    .processBook = () =>
        -- Start processing the book from the base directory
        @processDirectory("")

        -- Write any memory-cached assets to disk
        @vfs\writeFileSync(join(BUILD_DIRS.fragments, fragment.link, "index.html"), fragment.render) for fragment in *@cache

        for name, component in pairs(@theme.cache)
            @vfs\writeFileSync(join(BUILD_DIRS.scripts, "_component.#{name}.js"), component.script) if component.script
            @vfs\writeFileSync(join(BUILD_DIRS.styles, "_component.#{name}.css"), component.style) if component.style

        for asset in *@theme\getIncludedAssets()
            @vfs\writeFileSync(join(BUILD_DIRS.scripts, asset.name), readFileSync(asset.path)) if asset.type == "script"
            @vfs\writeFileSync(join(BUILD_DIRS.styles, asset.name), readFileSync(asset.path)) if asset.type == "style"

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
        @createFragment(join(directory, entry), #files > 1 and join("assets", "fragments", directory, "_navigation.html"), fragments) for entry in *files
        @createNavigation(directory, files) if #files > 1

    -- Book::processFragment(string file) -> table
    -- Processes the LunarBook fragment for metadata
    --
    .processFragment = (file) =>
        unless @cache[file]
            -- Load the fragment from disk and then have the theme process and render it
            contents    = @loadFragment(file)
            render      = @theme\render("Fragment", fragment: contents, includes: @getIncludes())

            -- Slugify and use the title of the fragment as the link
            -- Or, if the link is an index file, use the base directory
            link    = dirname(file)
            link    = "" if link == "."
            title   = extractTitle(render.layout)

            unless basename(file, extname(file)) == "index"
                link = join(link, slugify(title))
                error("bad argument #1 to 'processFragment' (missing or malformed title)") unless #link > 0

            layout          = TEMPLATE_LAYOUT_ASSETS(render.layout, "Fragment", render.style and true, render.script and true)
            sections        = [{name: section, slug: slugify(section)} for section in *extractSections(layout)]
            @cache[file]    = ProcessedFragment(layout, link, title, sections)

        return @cache[file]