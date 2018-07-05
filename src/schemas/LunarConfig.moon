import types from "leafo/tableshape/exports"

import ThemeConfig from "novacbn/lunarbook/schemas/ThemeConfig"

-- LunarConfig::LunarConfig()
-- Represents the configuration available to books
-- export
export LunarConfig = types.table
    -- LunarConfig::theme -> ThemeConfig
    -- Represents book-specific theme configuration
    --
    theme: types.any + types["nil"] / {}