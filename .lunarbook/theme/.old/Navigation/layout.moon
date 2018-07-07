head ->
    if @includes and @includes.styles
        for stylesheet in *@includes.styles
            link rel: "stylesheet", href: env.basePath..stylesheet

    if @includes and @includes.scripts
        for scriptsrc in *@includes.scripts
            script type: "application/javascript", src: env.basePath..scriptsrc, ""

body class: style.body, ->
    for fragment in *@fragments
        h6 class: style.header, fragment.title

        if fragment.sections
            ul class: style.list, ->
                for section in *fragment.sections
                    link = env.basePath..fragment.link.."#"..section.slug

                    li class: style.item, ->
                        a class: style.link, target: "_top", href: link, section.name