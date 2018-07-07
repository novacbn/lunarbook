Navigation  = include "Navigation"
Omnibar     = include "Omnibar"

Style (env) ->
    div.container {
        overflow: "hidden"
    }

Layout (env, state) ->
    html ->
        head ->
            title env.title

            if env.styles
                for stylesheet in *env.styles
                    link rel: "stylesheet", href: env.basePath..stylesheet

            if env.scripts
                for scriptsrc in *env.scripts
                    script type: "application/javascript", src: env.basePath..scriptsrc

            link rel: "stylesheet", href: env.basePath..env.stylePath
            script type: "application/javascript", src: env.basePath..env.scriptPath

        body class: "cover col", ->
            Omnibar env.omnibar if #env.omnibar > 0

            div class: "row container fill-5", id: "container", ->
                Navigation fragments: state.navigation, link: state.link if state.navigation
                raw state.fragment