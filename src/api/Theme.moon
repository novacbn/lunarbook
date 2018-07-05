import loadstring, pairs, type from _G
import insert from table

import Object from require "core"
import basename, extname, join from require "path"
import encode from require "json"
import decode from "novacbn/properties/exports"
import createHash from "novacbn/luvit-extras/crypto"
import VirtualFileSystem from "novacbn/luvit-extras/vfs"
import FileSystemAdapter from "novacbn/luvit-extras/adapters/FileSystemAdapter"
moonscript = require "moonscript/base"

import Layout from "novacbn/lunarbook/api/Layout"
import Stylesheet from "novacbn/lunarbook/api/Stylesheet"
import BOOK_HOME from "novacbn/lunarbook/lib/constants"
import isfileSync from "novacbn/lunarbook/lib/utilities/vfs"
import ThemeConfig from "novacbn/lunarbook/schemas/ThemeConfig"

-- ::MAP_ASSET_TYPES -> table
-- Represents the mapping of accepted asset extensions
--
MAP_ASSET_TYPES = {
    ".js":  "script"
    ".css": "style"
}

-- ::TEMPLATE_STYLESHEET_MOONSCRIPT(string code) -> string
-- Formats MoonScript code into a simplistic data format for styles
--
TEMPLATE_STYLESHEET_MOONSCRIPT = (code) -> "return { #{code} }"

-- ::TEMPLATE_LAYOUT_LUA(string code) -> string
-- Formats Lua code into a simplistic DSL for layouts
--
TEMPLATE_LAYOUT_LUA = (code) -> "return function (self, env, style) #{code} end"

-- ::ComponentRender(string hash, string layout, string script?, string style?) -> ComponentRender
-- Represents the rendered output of a component
--
ComponentRender = (hash, layout, script, style) -> {
    -- ComponentRender::hash -> string
    -- Represents the hash of the component path
    --
    hash: hash

    -- ComponentRender::layout -> string
    -- Represents the rendered layout of the component
    --
    layout: layout

    -- ComponentRender::script -> string
    -- Represents the generated script of the component
    --
    script: script

    -- ComponentRender::style -> string
    -- Represents the generated style of the component
    --
    style:  style
}

-- ::IncludedAsset(string path, string type) -> IncludedAsset
-- Represents an asset that was included by configuration
--
IncludedAsset = (path, type) -> {
    -- IncludedAsset::name -> string
    -- Represents the name of the component
    --
    name: basename(path)

    -- IncludedAsset::path -> string
    -- Represents the path of the asset being included
    --
    path: path

    -- IncludedAsset::type -> string
    -- Represents the type of asset being included
    --
    type: type
}

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

    -- LoadedComponent::script -> string
    -- Represents the generated script of the component
    --
    script: script

    -- LoadedComponent::style -> string
    -- Represents the generated style of the component
    --
    style: style
}

-- ::merge(table target, table source) -> table
-- Merges the source table with the target table
--
merge = (target, source) ->
    for key, value in pairs(source)
        if type(target[key]) == "table" and type(value) == "table" then merge(target[key], value)
        elseif target[key] == nil then target[key] = value

    return target

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

        config, err = ThemeConfig\transform(configuration)
        error("bad argument #2 to 'initialize' (malformed theme config)\n#{err}") if err

        @vfs = VirtualFileSystem\new()
        @vfs\mount("theme", FileSystemAdapter\new(directory))

        if isfileSync(@vfs, "theme://theme.mprop")
            contents        = @vfs\readFileSync("theme://theme.mprop")
            config          = decode(contents, propertiesEncoder: "moonscript")

            config, err = ThemeConfig\transform(config)
            error("bad dispatch to 'initialize' (malformed theme config)\n#{err}") if err
            configuration = merge(configuration, config)

        @cache          = {}
        @configuration  = configuration

    -- Theme::getIncludedAssets() -> table
    -- Returns the assets required by the theme
    --
    .getIncludedAssets = () =>
        assets  = {}
        root    = @vfs.adapters["theme"].root

        for asset in *@configuration.assets
            error("bad dispatch to 'getIncludedAssets' (missing '#{asset}')") unless isfileSync(@vfs, "theme://assets/#{asset}")

            assetType = MAP_ASSET_TYPES[extname(asset)]
            error("bad dispatch to 'getIncludedAssets' (unrecognized extension '#{extname(asset)}'") unless assetType

            insert(assets, IncludedAsset(join(root, "assets", asset), assetType))
    
        return assets

    -- Theme::loadComponent(string name) -> ComponentRender
    --
    --
    .loadComponent = (name) =>
        error("bad argument #1 to 'loadComponent' (missing component)") unless isfileSync(@vfs, "theme://components/#{name}/layout.moon")

        unless @cache[name]
            hash        = createHash(name, "SHA1")
            script      = @loadScript("theme://components/#{name}/script.js") if isfileSync(@vfs, "theme://components/#{name}/script.js")
            stylesheet  = @loadStyle("theme://components/#{name}/style.mprop", hash) if isfileSync(@vfs, "theme://components/#{name}/style.mprop")
            layout      = @loadLayout("theme://components/#{name}/layout.moon", stylesheet and stylesheet.classes) if isfileSync(@vfs, "theme://components/#{name}/layout.moon")

            @cache[name] = LoadedComponent(hash, layout, script, stylesheet and stylesheet.contents)

        return @cache[name]

    -- Theme::loadLayout(string file, table stylesheet?) -> function
    -- Loads a layout into memory and returns a generator function
    --
    .loadLayout = (file, stylesheet) =>
        contents    = @vfs\readFileSync(file)
        code, err   = moonscript.to_lua(contents)
        error("bad argument #1 to 'loadLayout' (failed to parse '#{file}')\n#{err}") unless code

        code        = TEMPLATE_LAYOUT_LUA(code)
        chunk, err  = loadstring(code, file)
        error("bad argument #1 to 'loadLayout' (failed to load '#{file}')\n#{err}") if err
        layout      = Layout(chunk, @configuration.environment, stylesheet)

        return layout

    -- Theme::loadScript(string file) -> table
    -- Loads a script into memory and injects theme environment variables
    --
    .loadScript = (file) =>
        -- TODO: environment injection
        contents = @vfs\readFileSync(file)
        return contents

    -- Theme::loadStyle(string file, string hash) -> Stylesheet
    -- Loads a style into memory and performs injection and encoding hash
    --
    .loadStyle = (file, hash) =>
        contents    = @vfs\readFileSync(file)
        chunk, err  = moonscript.loadstring(TEMPLATE_STYLESHEET_MOONSCRIPT(contents), file)
        error("bad argument #1 to 'loadStyle' (failed to load '#{file}')\n#{err}") if err

        return Stylesheet(hash, chunk, @configuration.environment)

    -- Theme::render(string name, table state?) -> ComponentRender
    -- Renders the specified theme with the given state
    --
    .render = (name, state={}) =>
        error("bad argument #1 to 'parseComponent' (expected string)") unless type(name) == "string"
        error("bad argument #2 to 'parseComponent' (expected table)") unless type(state) == "table"

        component   = @loadComponent(name)
        contents    = component.layout(state)
        return ComponentRender(component.hash, contents, component.script, component.style)