import QtQuick
import Twilight.Core

// The grid of app tiles, or a note when nothing matches.
Item {
    id: root

    // Matching apps, best first.
    property var apps: []
    // Whether the launcher is drawn, so idle motion stops.
    property bool active: false
    // Off while the card flies in under a resting pointer.
    property bool hoverSelects: true
    // Bumped on every open so the grid rebuilds and the tiles pop in again.
    property int epoch: 0

    readonly property alias count: grid.count
    readonly property alias cellHeight: grid.cellHeight
    property alias currentIndex: grid.currentIndex

    signal activated(int index)

    function reset(): void {
        epoch++;
        grid.currentIndex = 0;
    }

    function appAt(index) {
        return grid.model[index];
    }

    // Top center of a tile in window coordinates, null if it isn't drawn.
    function tileOrigin(index) {
        const tile = grid.itemAtIndex(index);
        return tile ? tile.mapToItem(null, tile.width / 2, 42) : null;
    }

    function move(direction): void {
        const n = Math.max(1, grid.count);
        if (direction === "left")
            grid.moveCurrentIndexLeft();
        else if (direction === "right")
            grid.moveCurrentIndexRight();
        else if (direction === "up")
            grid.moveCurrentIndexUp();
        else if (direction === "down")
            grid.moveCurrentIndexDown();
        else if (direction === "next")
            grid.currentIndex = (grid.currentIndex + 1) % n;
        else if (direction === "prev")
            grid.currentIndex = (grid.currentIndex - 1 + n) % n;
    }

    GridView {
        id: grid

        // Tiles read this to know whether hovering selects them.
        property bool hoverSelects: root.hoverSelects

        anchors.fill: parent
        // Room inside the clip for the selected tile, which
        // lifts, grows and pulses a ring past its cell.
        topMargin: 18
        bottomMargin: 8
        cellWidth: width / 5
        cellHeight: 120
        clip: true
        keyNavigationWraps: true
        boundsBehavior: Flickable.StopAtBounds
        highlightFollowsCurrentItem: false
        model: {
            root.epoch;
            return root.apps.slice();
        }

        delegate: AppTile {
            onActivated: root.activated(index)
        }
    }

    // Nothing found
    Column {
        anchors.centerIn: parent
        visible: grid.count === 0
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "✧"
            color: Theme.primary
            font.pixelSize: 48
            style: Text.Outline
            styleColor: Theme.ink

            SequentialAnimation on y {
                running: grid.count === 0 && root.active
                loops: Animation.Infinite

                NumberAnimation { to: -8; duration: 700; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0; duration: 700; easing.type: Easing.InOutSine }
            }
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "not even Canterlot's library has that"
            color: Theme.muted
        }
    }
}
