import types from "leafo/tableshape/exports"

import ThemeConfig from "novacbn/lunarbook/schemas/ThemeConfig"

-- LunarConfig::LunarConfig()
-- Represents the configuration available to books
-- export
export LunarConfig = types.shape
    -- LunarConfig::theme -> ThemeConfig
    -- Represents book-specific theme configuration
    --
    theme: types.any + types["nil"] / {}

    -- LunarConfig::plugins -> table
    -- Represents user-supplied configuration to plugins
    --
    plugins: types.map_of(types.string, types.any) + types["nil"] / {}