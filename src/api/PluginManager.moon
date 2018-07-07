import type from _G

import Object from require "core"
import ChunkEnvironment from "novacbn/lunarbook/api/ChunkEnvironment"
import Transformers from "novacbn/lunarbook/api/Transformers"

-- HACK: temp for now
-- TODO:
--      * once gmodproj has installing support, query .gmodpackages for 'lunarbook-plugin-*' packages
--          * load those from '~/.gmodproj/packages/'
--      * also support book-local plugins via '$BOOK_HOME/.lunarbook/plugins'

LOADED_PLUGINS = {
    {name: builtin, exports: loadfile(dependency("novacbn/lunarbook/lib/constants").BOOK_HOME.plugins.."/lunarbook-plugin-builtin.lua")()}
}

-- ::LoadedPlugin(string name, table exports) -> table
-- Represents a plugin loaded by the PluginManager
--
LoadedPlugin = (name, exports) -> {
    -- LoadedPlugin::exports -> table
    -- Represents the exports of the plugin
    --
    exports: exports

    -- LoadedPlugin::exports -> table
    -- Represents the name of the plugin
    --
    name: name
}

-- PluginManager::PluginManager()
-- Represents the manager of user-installed plugins
-- export
export PluginManager = with Object\extend()
    -- PluginManager::plugins -> table
    -- Represents the plugins loaded into the manager
    --
    .plugins = nil

    -- PluginManager::initialize(table plugins) -> void
    -- Constructor for PluginManager
    --
    .initialize = (plugins=LOADED_PLUGINS) =>
        @plugins = plugins

    -- PluginManager::dispatch(string name, any ...) -> void
    -- Dispatches and event to the loaded plugins
    --
    .dispatch = (name, ...) =>
        for plugin in *@plugins
            plugin.exports[name](...) if plugin.exports[name]

    -- PluginManager::configureLayoutEnvironment(ChunkEnvironment environment) -> ChunkEnvironment
    -- Configures the Layout ChunkEnvironment via the loaded plugins
    --
    .configureLayoutEnvironment = (environment=ChunkEnvironment\new()) =>
        error("bad argument #1 to 'configureLayoutEnvironment' (expected ChunkEnvironment)") unless type(environment) == "table"

        @dispatch("configureLayoutEnvironment", environment)
        return environment

    -- PluginManager::configureStyleEnvironment(ChunkEnvironment environment) -> ChunkEnvironment
    -- Configures the Style ChunkEnvironment via the loaded plugins
    --
    .configureStyleEnvironment = (environment=ChunkEnvironment\new()) =>
        error("bad argument #1 to 'configureStyleEnvironment' (expected ChunkEnvironment)") unless type(environment) == "table"

        @dispatch("configureStyleEnvironment", environment)
        return environment

    -- PluginManager::configureTransformers(Transformers transformers?) -> Transformers
    -- Configures a Transformers instance via the loaded plugins
    --
    .configureTransformers = (transformers=Transformers\new()) =>
        error("bad argument #1 to 'configureTransformers' (expected Transformers)") unless type(transformers) == "table"

        @dispatch("configureTransformers", transformers)
        return transformers

    -- PluginManager::processConfiguration(table configuration) -> void
    -- Configures the loaded plugins via the provided table
    --
    .processConfiguration = (configuration) =>
        error("bad argument #1 to 'processConfiguration' (expected table)") unless type(configuration) == "table"

        local err
        for plugin in *@plugins
            if plugin.exports.processConfiguration and configuration[plugin.name] ~= nil
                err = plugin.exports.processConfiguration(configuration[plugin.name])
                error("bad dispatch to 'processConfiguration' (malformed configuration)\n#{err}") if err