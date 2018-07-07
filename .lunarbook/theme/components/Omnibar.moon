Style (env) ->
    root {
        backgroundColor: env.colors.navy

        paddingLeft:    env.spacing.five
        paddingRight:   env.spacing.five

        maxHeight:  "5rem"
        overflow:   "hidden"
    }

    root * a {
        color:          env.colors.silver
        fontSize:       "2rem"
        textDecoration: "none"
        outline:        "none"
    }

    root * a.hover {
        color: lighten(env.colors.navy, 0.25)
    }

    root * a.header {
        fontSize: "2.5rem !important"
    }

Layout (env, state) ->
    nav class: "row middle fill-1", ->
        a class: "header", env.title

        div class: "row right gap-4 fill-5", ->
            for entry in *env.omnibar
                a href: entry.link, entry.text