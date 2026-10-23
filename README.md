# twilight-shell/app-launcher

"Twilight's Library": an app grid over a starry sky. Part of the
[twilight-shell](https://github.com/twilight-shell) organization; it works on its
own or as a piece of the full shell.

Search matches names, keywords and categories, and also a query typed with the
Russian layout active.

## Requirements

[Quickshell](https://quickshell.org) 0.3 or newer and
[twilight-shell/core](https://github.com/twilight-shell/core) installed.

## Running on its own

```sh
qs -p /path/to/app-launcher
qs -p /path/to/app-launcher ipc call launcher toggle
```

Bind the second command to a key in your compositor. If `Twilight.Core` is not in
a directory Qt searches, point `QML_IMPORT_PATH` at its parent.

## Using it in a shell

```sh
sudo make install        # to /usr/lib/qt6/qml/Twilight/Launcher
```

```qml
import Twilight.Launcher

Launcher {
    id: launcher
    outputName: "DP-1"          // where to open; the first screen by default
    terminal: ["ghostty", "-e"] // runs apps that need a terminal
    onLaunched: app => console.log(app.name)
}
```

`launcher.open()`, `launcher.close()` and `launcher.toggle()` control it.

## License

MIT, see `LICENSE`.
