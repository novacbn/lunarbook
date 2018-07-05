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
    environment: types.map_of(types.any, types.any) + types["nil"] / {}

    -- ThemeConfig::omnibar -> table
    -- Represents link to be present in a theme's omnibar
    --
    omnibar: types.array_of(
        types.shape(link: types.string, text: types.string)
    ) + types["nil"] / {}