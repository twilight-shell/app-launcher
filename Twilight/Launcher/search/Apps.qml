pragma Singleton

import QtQuick
import Quickshell
import "Match.js" as Match

// Installed applications and search over them.
Singleton {
    id: root

    readonly property var all: DesktopEntries.applications.values
        .filter(app => !app.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))

    function search(text) {
        return Match.search(all, text);
    }

    function launch(app, terminal) {
        if (app.runInTerminal)
            Quickshell.execDetached([...terminal, ...app.command]);
        else
            app.execute();
    }
}
