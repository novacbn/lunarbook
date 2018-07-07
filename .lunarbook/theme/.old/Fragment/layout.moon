style ->
    root {
        backgroundColor: lighten(env.colors.silver, 0.75)

        paddingTop:     env.spacing.five
        paddingLeft:    env.spacing.six
        paddingRight:   env.spacing.eight

        animationDuration:  "0.15s !important"
        color:              env.colors.black
        fontSize:           "1.7rem"
    }

    root a {
        position:           "relative"
        color:              lighten(env.colors.navy, 0.25)
        textDecoration:     "none"
        outline:            "none"
    }

    root a\hover {
        borderRadius:   "2px"
        borderBottom:   "2px solid #{lighten(env.colors.navy, 0.25)}"
        color:          env.colors.navy
    }

    root code {
        position: "relative"

        backgroundColor:    darken(env.colors.navy, 0.25)
        border:             "1px solid #{lighten(env.colors.navy, 0.75)}"
        color:              env.colors.white
    }

    root h4 {
        paddingBottom:  env.spacing.three
        marginBottom:   env.spacing.five

        borderBottom:   "2px solid #{lighten(env.colors.navy, 0.75)}"
    }

html ->
    head ->
        if @includes and @includes.styles
            for stylesheet in *@includes.styles
                link rel: "stylesheet", href: env.basePath..stylesheet

        if @includes and @includes.scripts
            for scriptsrc in *@includes.scripts
                script type: "application/javascript", src: env.basePath..scriptsrc, ""

    body class: "#{style.body} animated fadeInLeftBig", @fragment