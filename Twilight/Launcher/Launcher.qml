import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Twilight.Core

// App launcher: Twilight's library, a spellbook card over a night sky.
// Toggle with `qs -c app-launcher ipc call launcher toggle`.
Scope {
    id: root

    property bool opened: false
    // Name of the output to open on; the first screen when empty or unknown.
    // The compositor is the host's business, so the host sets it.
    property string outputName: ""
    // Command that runs terminal apps; the app's own command is appended.
    // Read from app-launcher.toml, or set by the host.
    property var terminal: config.get("terminal")

    signal launched(var app)

    function open(): void {
        opened = true;
    }

    function close(): void {
        opened = false;
    }

    function toggle(): void {
        // A held hotkey repeats: ignore toggles that come too fast.
        const now = Date.now();
        if (now - lastToggle < 250)
            return;
        lastToggle = now;
        opened = !opened;
    }

    property double lastToggle: 0
    property bool launching: false

    ConfigFile {
        id: config

        name: "app-launcher"
        defaults: Qt.resolvedUrl("app-launcher.defaults.toml")
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.toggle();
        }
    }

    PanelWindow {
        id: window

        // 1 = card is below the screen, 0 = in place.
        property real rise: 1
        property real spin: -10
        property real poof: 1

        // Set by hand rather than bound to the animations' running state:
        // when `open` flips, the binding would see no animation running yet,
        // unmap the window for a frame and flicker.
        property bool shown: false

        visible: shown
        screen: Quickshell.screens.find(s => s.name === root.outputName) ?? Quickshell.screens[0]
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.namespace: "twilight-launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        function launch(app, origin) {
            if (origin)
                sparks.burst(origin.x, origin.y, 48);

            Apps.launch(app, root.terminal);
            root.launched(app);
            root.launching = true;
            root.close();
        }

        Connections {
            target: root

            function onOpenedChanged() {
                if (root.opened) {
                    // Reopening mid-close continues from where the card is;
                    // from fully closed it starts below the screen.
                    const wasHidden = !window.shown;
                    closeAnim.stop();
                    launchAnim.stop();
                    if (wasHidden) {
                        window.rise = 1;
                        window.spin = -10;
                        window.poof = 1;
                        backdrop.opacity = 0;
                    }
                    window.shown = true;
                    card.reset();
                    openAnim.restart();
                } else if (root.launching) {
                    launchAnim.restart();
                } else {
                    closeAnim.restart();
                }
            }
        }

        ParallelAnimation {
            id: openAnim

            NumberAnimation { target: window; property: "rise"; to: 0; duration: 560; easing.type: Easing.OutBack; easing.overshoot: 1 }
            NumberAnimation { target: window; property: "spin"; to: 0; duration: 760; easing.type: Easing.OutBack; easing.overshoot: 1.8 }
            NumberAnimation { target: window; property: "poof"; to: 1; duration: 300; easing.type: Easing.OutBack }
            NumberAnimation { target: backdrop; property: "opacity"; to: 1; duration: 320; easing.type: Easing.OutCubic }
        }

        SequentialAnimation {
            id: closeAnim

            ParallelAnimation {
                NumberAnimation { target: window; property: "rise"; to: 1; duration: 340; easing.type: Easing.InBack; easing.overshoot: 0.8 }
                NumberAnimation { target: window; property: "spin"; to: 6; duration: 340; easing.type: Easing.InQuad }
                NumberAnimation { target: window; property: "poof"; to: 0.9; duration: 340; easing.type: Easing.InQuad }
                NumberAnimation { target: backdrop; property: "opacity"; to: 0; duration: 340; easing.type: Easing.InQuad }
            }
            ScriptAction { script: window.shown = false }
        }

        // The card puffs up and vanishes into the sparks.
        SequentialAnimation {
            id: launchAnim

            NumberAnimation { target: window; property: "poof"; to: 1.06; duration: 110; easing.type: Easing.OutQuad }
            ParallelAnimation {
                NumberAnimation { target: window; property: "poof"; to: 0.4; duration: 260; easing.type: Easing.InBack; easing.overshoot: 2 }
                NumberAnimation { target: backdrop; property: "opacity"; to: 0; duration: 380 }
            }
            PauseAnimation { duration: 450 }
            ScriptAction {
                script: {
                    root.launching = false;
                    window.rise = 1;
                    window.shown = false;
                }
            }
        }

        Item {
            id: stage

            anchors.fill: parent

            HoverHandler {
                id: pointer
            }

            Rectangle {
                id: backdrop

                anchors.fill: parent
                opacity: 0
                gradient: Gradient {
                    GradientStop { position: 0; color: Theme.alpha(Theme.bg, 0.88) }
                    GradientStop { position: 1; color: Qt.rgba(0.18, 0.07, 0.26, 0.82) }
                }

                Starfield {
                    anchors.fill: parent
                    running: window.visible
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.close()
                }
            }

            // Pink glow behind the card, breathing slowly.
            Shape {
                id: glow

                width: 1200
                height: 1000
                x: card.x + (card.width - width) / 2
                y: card.y + (card.height - height) / 2
                opacity: backdrop.opacity * (1 - window.rise)

                SequentialAnimation on scale {
                    running: window.visible
                    loops: Animation.Infinite

                    NumberAnimation { to: 1.08; duration: 2600; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.95; duration: 2600; easing.type: Easing.InOutSine }
                }

                ShapePath {
                    strokeWidth: 0
                    strokeColor: "transparent"
                    startX: 0
                    startY: 0

                    fillGradient: RadialGradient {
                        centerX: 600
                        centerY: 500
                        centerRadius: 520
                        focalX: 600
                        focalY: 500

                        GradientStop { position: 0; color: Theme.alpha(Theme.accent, 0.26) }
                        GradientStop { position: 0.5; color: Theme.alpha(Theme.secondary, 0.12) }
                        GradientStop { position: 1; color: "transparent" }
                    }

                    PathLine { x: 1200; y: 0 }
                    PathLine { x: 1200; y: 1000 }
                    PathLine { x: 0; y: 1000 }
                    PathLine { x: 0; y: 0 }
                }
            }

            Card {
                id: card

                scene: stage
                pointer: pointer
                rise: window.rise
                spin: window.spin
                poof: window.poof
                opened: root.opened
                active: window.visible
                settled: !openAnim.running
                apps: Apps.search(query)

                onLaunchRequested: (app, origin) => window.launch(app, origin)
                onBurst: (x, y, count) => sparks.burst(x, y, count)
                onCloseRequested: root.close()
            }

            SparkleBurst {
                id: sparks

                anchors.fill: parent
            }
        }
    }
}
