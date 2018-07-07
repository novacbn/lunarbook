import types from "leafo/tableshape/exports"

-- ThemeConfig::ThemeConfig()
-- Represents the configuration available to themes
-- export
export ThemeConfig = types.shape
    -- ThemeConfig::assets -> table
    -- Represents assets to be included with the LunarBook
    --
    assets: types.array_of(types.string) + types["nil"] / {}

    -- ThemeConfig::environment -> table
    -- Represents the environment available to theme assets during compilation
    --
    environment: types.shape {
        -- ThemeConfig::environment::basePath -> string
        -- Represents the base pathname of the book
        --
        basePath: types.string + types["nil"] / "/"

        -- ThemeConfig::environment::omnibar -> table
        -- Represents link to be present in a theme's omnibar
        --
        omnibar: types.array_of(
            types.shape(link: types.string, text: types.string)
        ) + types["nil"] / {}

        -- ThemeConfig::environment::title -> string
        -- Represents the title of the book
        --
        title: types.string + types["nil"] / "LunarBook"

        -- ThemeConfig::environment::scriptPath -> string
        -- Represents the pathname of the book's component scripts
        --
        scriptPath: types.string + types["nil"] / "assets/scripts/lunarbook.components.js"

        -- ThemeConfig::environment::stylePath -> string
        -- Represents the pathname of the book's component styling
        --
        stylePath: types.string + types["nil"] / "assets/styles/lunarbook.components.css"
    }, {extra_fields: types.map_of(types.any, types.any)}