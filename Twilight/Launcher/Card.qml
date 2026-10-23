import QtQuick
import QtQuick.Layouts
import Twilight.Core
import "parts"

// The spellbook card: header, search, the grid of apps and key hints.
// The host animates it through rise, spin and poof.
Item {
    id: root

    // The full-window item the card sits in, and the pointer over it.
    required property Item scene
    required property HoverHandler pointer

    // 1 = card is below the screen, 0 = in place.
    property real rise: 1
    property real spin: -10
    property real poof: 1
    // Whether the launcher is open and drawn, and whether the card has landed.
    property bool opened: false
    property bool active: false
    property bool settled: false

    // Apps for the current query, best first.
    property var apps: []
    property alias query: search.text

    signal launchRequested(var app, var origin)
    signal burst(real x, real y, int count)
    signal closeRequested

    // Fresh start on every open: empty query, first tile, keyboard on the search.
    function reset(): void {
        search.text = "";
        grid.reset();
        Qt.callLater(() => search.focusInput());
    }

    // Lean after the pointer, smoothed.
    property real leanY: pointer.hovered ? (pointer.point.position.x / scene.width - 0.5) * 10 : 0
    property real leanX: pointer.hovered ? -(pointer.point.position.y / scene.height - 0.5) * 8 : 0

    readonly property int rows: Math.max(1, Math.min(3, Math.ceil(grid.count / 5)))

    width: 640
    height: 278 + rows * grid.cellHeight
    x: (scene.width - width) / 2
    y: (scene.height - height) / 2 + rise * scene.height * 0.75
    scale: poof
    opacity: Math.min(1, poof * 1.4 - 0.4)

    Behavior on height {
        NumberAnimation { duration: 320; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
    }

    Behavior on leanX {
        NumberAnimation { duration: 450; easing.type: Easing.OutCubic }
    }
    Behavior on leanY {
        NumberAnimation { duration: 450; easing.type: Easing.OutCubic }
    }

    transform: [
        Rotation {
            origin.x: root.width / 2
            origin.y: root.height / 2
            angle: root.spin - 1.2
        },
        Rotation {
            origin.x: root.width / 2
            origin.y: root.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: root.leanY
        },
        Rotation {
            origin.x: root.width / 2
            origin.y: root.height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: root.leanX
        }
    ]

    // Swallow clicks so they don't reach the backdrop.
    MouseArea {
        anchors.fill: parent
    }

    Sticker {
        anchors.fill: parent
        radius: 26
        lift: 9
        fill: Theme.surface

        ColumnLayout {
            anchors {
                fill: parent
                margins: 24
                bottomMargin: 20
            }
            spacing: 14

            Header {
                Layout.fillWidth: true
            }

            SearchField {
                id: search

                Layout.fillWidth: true
                count: grid.count
                active: root.active
                opened: root.opened

                onTextChanged: grid.currentIndex = 0
                onTyped: (x, y) => root.burst(x, y, 5)
                onAccepted: grid.activated(grid.currentIndex)
                onEscaped: root.closeRequested()
                onNavigate: direction => grid.move(direction)
            }

            AppGrid {
                id: grid

                Layout.fillWidth: true
                Layout.fillHeight: true
                apps: root.apps
                active: root.active
                hoverSelects: root.settled

                onActivated: index => {
                    const app = appAt(index);
                    if (app)
                        root.launchRequested(app, tileOrigin(index));
                }
            }

            Hints {
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    Corners {
        active: root.active
    }
}
