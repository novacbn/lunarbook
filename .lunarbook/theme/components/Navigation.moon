_ = [[link:
    "not([data-active]):hover::before":
        position:   "absolute"
        left:       "0"
        width:      "100%"
        height:     "24px"

        backgroundColor:    lighten(env.colors.navy, 0.25)
        content:            "''"
        opacity:            "0.05"

    "[data-active]::before":
        position:   "absolute"
        left:       "0"
        width:      "100%"
        height:     "24px"

        backgroundColor:    lighten(env.colors.navy, 0.25)
        content:            "''"
        opacity:            "0.2"

    "[data-active]::after":
        position:   "absolute"
        left:       "0"
        width:      "5px"
        height:     "24px"

        backgroundColor:    lighten(env.colors.navy, 0.25)
        content:            "''"]]

Style (env) ->
    root {
        zIndex: 2
    }

    div {
        backgroundColor: env.colors.white

        maxWidth:       "20rem"
        paddingTop:     env.spacing.five
        paddingLeft:    env.spacing.five
    }

    h6 {
        color:          env.colors.black
        fontWeight:     "bold"

        marginBottom: env.spacing.two
    }

    ul {
        listStyleType:  "none"
        padding:        0
    }

    li {
        marginBottom: 0
    }

    a {
        color:          "#{lighten(env.colors.navy, 0.25)} !important"
        outline:        "none"
        textDecoration: "none"
    }

Layout (env, state) ->
    div class: "fill-1", id: "navigation", ->
        for fragment in *state.fragments
            h6 fragment.title

            if fragment.sections
                ul ->
                    for section in *fragment.sections
                        li ->
                            link = "#"..section.slug
                            unless fragment.link == state.link then link = env.basePath..fragment.link..link

                            a href: link, section.title