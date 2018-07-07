Style (env) ->
    root {
        backgroundColor: lighten(env.colors.silver, 0.75)

        paddingTop:     env.spacing.five
        paddingLeft:    env.spacing.six
        paddingRight:   env.spacing.eight

        animationName:      "fadeIn, slideInLeft"
        animationDuration:  "0.5s, 0.2s"

        color:              env.colors.black
        fontSize:           "1.7rem"

        zIndex:     1
        overflowY:  "auto"
    }

    root * a {
        position:           "relative"
        color:              lighten(env.colors.navy, 0.25)
        textDecoration:     "none"
        outline:            "none"
    }

    root * a.hover {
        borderRadius:   "2px"
        borderBottom:   "2px solid #{lighten(env.colors.navy, 0.25)}"
        color:          env.colors.navy
    }

    root * code {
        position: "relative"

        backgroundColor:    darken(env.colors.navy, 0.25)
        border:             "1px solid #{lighten(env.colors.navy, 0.75)}"
        color:              env.colors.white
    }

    root * h4 {
        paddingBottom:  env.spacing.three
        marginBottom:   env.spacing.five

        borderBottom:   "2px solid #{lighten(env.colors.navy, 0.75)}"
    }

Layout (env, state) ->
    div class: "animated fill-5", id: "fragment", state.fragment