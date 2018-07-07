import loadstring, pcall, setfenv, type from _G
import concat, insert from table

import Object from require "core"
import basename, extname, join from require "path"
import decode from "novacbn/properties/exports"
import createHash from "novacbn/luvit-extras/crypto"
import VirtualFileSystem from "novacbn/luvit-extras/vfs"
import FileSystemAdapter from "novacbn/luvit-extras/adapters/FileSystemAdapter"
layoutViz   = dependency "novacbn/lunarviz/layout"
moonscript  = require "moonscript/base"
styleViz    = dependency "novacbn/lunarviz/style"

import merge from "novacbn/lunarbook/lib/utilities/table"
import isfileSync from "novacbn/lunarbook/lib/utilities/vfs"
import ThemeConfig from "novacbn/lunarbook/schemas/ThemeConfig"

-- ::LoadedComponent(string hash, function layout, string script?, string style?) -> LoadedComponent
-- Represents a component already loaded into the theme cache
--
LoadedComponent = (hash, layout, script, style) -> {
    -- LoadedComponent::hash -> string
    -- Represents the hash of the component path
    --
    hash: hash

    -- LoadedComponent::layout -> function
    -- Represents the layout generator for the component
    --
    layout: layout

    -- LoadedComponent::script -> function?
    -- Represents the script generator of the component
    --
    script: script

    -- LoadedComponent::style -> function?
    -- Represents the style generator of the component
    --
    style: style
}

-- Theme::Theme()
-- Represents a LunarBook theme
-- export
export Theme = with Object\extend()
    -- Theme::cache -> table
    -- Represents the cache of previously loaded components
    --
    .cache = nil

    -- Theme::configuration -> table
    -- Represents the configuration of the theme
    --
    .configuration = nil

    -- Theme::includedAssets -> table
    -- Represents the assets included for distribution by the theme
    --
    .includedAssets = nil

    -- Theme::layoutEnvironment -> table
    -- Represents the current environment for layouts
    --
    .layoutEnvironment = nil

    -- Theme::scriptEnvironment -> table
    -- Represents the current environment for scripts
    --
    .scriptEnvironment = nil

    -- Theme::vfs -> VirtualFileSystem
    -- Represents the virtual file system of the theme
    --
    .vfs = nil

    -- Theme::initialize(string directory, table configuration?) -> string
    -- Constructor for Theme
    --
    .initialize = (directory, configuration={}) =>
        error("bad argument #1 to 'initialize' (expected string)") unless type(directory) == "string"
        error("bad argument #2 to 'initialize' (expected table)") unless type(configuration) == "table"

        @vfs = VirtualFileSystem\new()
        @vfs\mount("theme", FileSystemAdapter\new(directory))

        if isfileSync(@vfs, "theme://theme.mprop")
            contents        = @vfs\readFileSync("theme://theme.mprop")
            config          = decode(contents, propertiesEncoder: "moonscript")
            configuration   = merge(configuration, config) if config

        @cache              = {}
        @configuration, err = ThemeConfig\transform(configuration)
        error("bad dispatch to 'initialize' (malformed theme config)\n#{err}") if err

    -- Theme::getIncludedAssets() -> table
    -- Returns the assets required by the theme
    --
    .getIncludedAssets = () =>
        unless @includedAssets
            @includedAssets = {}

            for asset in *@configuration.assets
                error("bad dispatch to 'getIncludedAssets' (missing '#{asset}')") unless isfileSync(@vfs, "theme://assets/#{asset}")
                insert(@includedAssets, {contents: @vfs\readFileSync("theme://assets/#{asset}"), name: asset})

        return @includedAssets

    -- Theme::getComputedStyle(boolean format?, table environment?) -> string
    -- Returns the computed Stylesheet of all the components
    --
    .getComputedStyle = (format, environment) =>
        computed = {}

        for file in *@vfs\readdirSync("theme://components")
            component = @loadComponent(basename(file, extname(file)))
            insert(computed, component.style(format, environment)) if component.style

        return concat(computed, "\n")

    -- Theme::loadComponent(string name) -> ComponentRender
    -- Loads a component into the memory
    --
    .loadComponent = (name) =>
        file = "theme://components/#{name}.moon"
        error("bad argument #1 to 'loadComponent' (missing component)") unless isfileSync(@vfs, file)

        unless @cache[name]
            hash            = createHash(name, "SHA1")
            contents        = @vfs\readFileSync(file)
            --script      = @loadScript("theme://components/#{name}/script.js") if isfileSync(@vfs, "theme://components/#{name}/script.js")
            component, err  = moonscript.loadstring(contents, file)
            error("bad argument #1 to 'loadComponent' (failed to parse)\n#{err}") unless component

            environment = @makeComponentEnvironment(hash)
            setfenv(component, environment)
            success, err = pcall(component)
            error("bad argument #1 to 'loadComponent' (failed to dispatch)\n#{err}") unless success

            error("bad argument #1 to 'loadComponent' (component is missing layout)") unless environment.layout
            @cache[name] = LoadedComponent(hash, environment.layout, environment.script, environment.style)

        return @cache[name]

    -- Theme::makeComponentEnvironment(string hash) -> table
    -- Makes a fresh environment for a component
    --
    .makeComponentEnvironment = (hash) =>
        local environment
        environment = {
            include: (name) ->
                return @loadComponent(name).layout

            Layout: (chunk) ->
                error("bad dispatch to 'Layout' (layout already set)") if environment.layout

                environment.layout = (...) ->
                    return layoutViz.parse(chunk, hash, @layoutEnvironment, @configuration.environment, ...)

            Style: (chunk) ->
                error("bad dispatch to 'Style' (style already set)") if environment.style

                environment.style = (format, styleEnv, ...) ->
                    syntaxtree = styleViz.parse(chunk, hash, styleEnv, @configuration.environment, ...)
                    return styleViz.compile(syntaxtree, format)
        }

        return environment

    -- Theme::render(string name, boolean format, table environment, table state?) -> string
    -- Renders the specified theme component with the given state
    --
    .render = (name, format, environment={}, state={}) =>
        environment = {}
        error("bad argument #1 to 'parseComponent' (expected string)") unless type(name) == "string"
        error("bad argument #2 to 'parseComponent' (expected boolean)") unless type(format) == "boolean"
        error("bad argument #3 to 'parseComponent' (expected table)") unless type(environment) == "table"
        error("bad argument #4 to 'parseComponent' (expected table)") unless type(state) == "table"

        @layoutEnvironment  = environment
        component           = @loadComponent(name)
        syntaxtree          = component.layout(state)
        return layoutViz.compile(syntaxtree, format)