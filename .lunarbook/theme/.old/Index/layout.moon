html ->
    head ->
        title env.title

        if @includes and @includes.styles
            for stylesheet in *@includes.styles
                link rel: "preload", as: "stylesheet", href: env.basePath..stylesheet
                link rel: "stylesheet", href: env.basePath..stylesheet

        if @includes and @includes.scripts
            for scriptsrc in *@includes.scripts
                link rel: "preload", as: "script", href: env.basePath..scriptsrc
                script type: "application/javascript", src: env.basePath..scriptsrc, ""

    body class: "cover col", ->
        if env.omnibar
            nav class: "#{style.omnibar} row middle fill-1", ->
                a class: style.header, href: env.basePath, env.title

                div class: "row right gap-4 fill-5", ->
                    for entry in *env.omnibar
                        a href: entry.link, entry.text

        div class: "row fill-5", ->
            if @navigation
                iframe class: "#{style.iframe} #{style.navigation} fill-1", id: "navigation", src: env.basePath..@navigation, ""

            iframe class: "#{style.iframe} fill-5", id: "fragment", src: env.basePath..@fragment, ""
