### Guide

> **REQUIRES:** `gmodproj >= 0.5.0`

Created for documenting [gmodproj](https://github.com/novacbn/gmodproj), LunarBook is a simplistic static site documentation generation, powered by [Lua](http://lua.org), [LuaJIT](http://luajit.org), and [Luvit](http://luvit.org). With user-provided **books** that are made up of **HTML5** and **Markdown** fragments, LunarBook outputs lightweight HTML with optional JavaScript.

#### Getting Started

LunarBook requires [gmodproj](https://github.com/novacbn/gmodproj) installed and **globally accessible** on your system via CLI. Once it's installed you can install LunarBook via:

`
$ gmodproj -a add novacbn/lunarbook
`

#### Running your Book

Once LunarBook is installed you can start it via:

`
$ gmodproj -a bin lunarbook watch
`

Which by default, will start a server at [http://0.0.0.0:9090](http://0.0.0.0:9090) using the `books` directory of your project. Just add `.html` (HTML5) or `.md` (Markdown) files to the directory and LunarBook will live reload your book while you edit.

#### Exporting your Book

When finished editing your book, you can export it via:

`
$ gmodproj -a bin lunarbook export
`

Which will export it to the `dist` directory by default. From there, simply copy the directory to your web server.