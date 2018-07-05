### Special Files

By default LunarBook runs without needing any configuration and just taking a directory as a book. Below are special files and directories you can use to tailor your output.

#### Index Fragments

Any book fragment that is `index.html` or `index.md` will be used at the containing directory's homepage. Such as `book/guide/index.md` will become `http://0.0.0.0:9090/guide`. Rather than being linked directly like `http://0.0.0.0:9090/guide/index`.

#### .lunarbook Directory

Optionally you can add a `.lunarbook` directory to your project. This directory is a LunarBook configuration directory and contains the following files and directories:

* `.lunarbook/theme` - Contains the current theme being used by the project, see [Theming Guide](/themes)
* `.lunarbook/configuration.mprop` - A [MoonScript](https://moonscript.org)-based configuration file for your book, see [Configuration Reference](/config)