html ->
    head ->
        if @includes and @includes.styles
            for stylesheet in *@includes.styles
                link rel: "stylesheet", href: stylesheet

        if @includes and @includes.scripts
            for scriptsrc in *@includes.scripts
                script type: "application/javascript", src: scriptsrc, ""

body class: "#{style.body} animated fadeInLeftBig", @fragment