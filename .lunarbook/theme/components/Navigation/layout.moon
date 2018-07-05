html ->
    head ->
        if @includes and @includes.styles
            for stylesheet in *@includes.styles
                link rel: "stylesheet", href: stylesheet

        if @includes and @includes.scripts
            for scriptsrc in *@includes.scripts
                script type: "application/javascript", src: scriptsrc, ""

    body class: style.body, ->
        for fragment in *@fragments
            h6 class: style.header, fragment.title

            if fragment.sections
                ul class: style.list, ->
                    for section in *fragment.sections
                        link = "/"..fragment.link.."#"..section.slug

                        li class: style.item, ->
                            a class: style.link, target: "_top", href: link, section.name