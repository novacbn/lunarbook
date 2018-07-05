import parse from "msva/htmlparser/exports"

-- ::PATTERN_HTML_ATTRIBUTES -> string
-- Represents a Lua pattern of possible HTML attributes
-- export
export PATTERN_HTML_ATTRIBUTES = "%w%s%-='\""

-- ::PATTERN_HTML_STRING -> string
-- Represents a Lua pattern of possible HTML strings
-- export
export PATTERN_HTML_STRING = "%w%s%p"

-- ::PATTERN_SECTION_EXTRACT -> string
-- Represents a Lua pattern to extract H2-sections from pages
-- export
export PATTERN_SECTION_EXTRACT = "<h2[${PATTERN_HTML_ATTRIBUTES}]*>([#{PATTERN_HTML_STRING}]+)</h2>"

-- ::PATTERN_TITLE_EXTRACT -> string
-- Represents a Lua pattern to extract H1-titles from pages
-- export
export PATTERN_TITLE_EXTRACT = "<h1[${PATTERN_HTML_ATTRIBUTES}]*>([#{PATTERN_HTML_STRING}]+)</h1>"

-- ::TABLE_HEADER_TAGS -> table
--
--
TABLE_HEADER_TAGS = {"h1", "h2", "h3", "h4", "h5", "h6"}

-- ::extractTitle(string value) -> string or void
-- Extracts the page title from the HTML
-- export
export extractTitle = (value) ->
    root = parse(value)
    for tag in *TABLE_HEADER_TAGS
        elements = root\select(tag)
        if #elements > 0
            return elements[1]\getcontent()

-- ::extractSections(string value) -> table or void
-- Extracts the page sections from the HTML
-- export
export extractSections = (value) ->
    root            = parse(value)
    titleSpotted    = false

    for tag in *TABLE_HEADER_TAGS
        elements = root\select(tag)
        if titleSpotted
            return [element\getcontent() for element in *elements]

        titleSpotted = #elements > 0