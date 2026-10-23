import QtQuick
import QtQuick.Layouts
import Twilight.Core

// The search box: a spinning star, the query and how many apps match.
// Keys are reported as signals; what they do is up to the host.
Sticker {
    id: root

    property alias text: input.text
    property int count: 0
    // Whether the launcher is drawn, so idle motion stops.
    property bool active: false
    property bool opened: false

    // Where the cursor is, in window coordinates, after each typed character.
    signal typed(real x, real y)
    signal accepted
    signal escaped
    // "left", "right", "up", "down", "next" or "prev".
    signal navigate(string direction)

    function focusInput(): void {
        input.forceActiveFocus();
    }

    implicitHeight: 54
    radius: 18
    lift: 4
    fill: Theme.surfaceHigh
    edge: input.activeFocus ? Theme.primary : Theme.ink

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 16
            rightMargin: 12
        }
        spacing: 12

        Text {
            id: wand

            text: "★"
            color: Theme.star
            font.pixelSize: 22
            style: Text.Outline
            styleColor: Theme.ink

            RotationAnimation on rotation {
                running: root.active
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 7000
            }

            NumberAnimation {
                id: wandBounce

                target: wand
                property: "scale"
                from: 1.6
                to: 1
                duration: 380
                easing.type: Easing.OutBack
                easing.overshoot: 3
            }
        }

        TextInput {
            id: input

            Layout.fillWidth: true
            color: Theme.text
            selectionColor: Theme.secondary
            font.family: Theme.font
            font.pixelSize: 17
            clip: true

            onTextChanged: {
                if (!root.opened)
                    return;
                wandBounce.restart();
                const r = cursorRectangle;
                const p = mapToItem(null, r.x, r.y + r.height / 2);
                root.typed(p.x, p.y);
            }

            Keys.onPressed: event => {
                const ctrl = event.modifiers & Qt.ControlModifier;
                if (event.key === Qt.Key_Escape)
                    root.escaped();
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                    root.accepted();
                else if (event.key === Qt.Key_Left)
                    root.navigate("left");
                else if (event.key === Qt.Key_Right)
                    root.navigate("right");
                else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_K))
                    root.navigate("up");
                else if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_J))
                    root.navigate("down");
                else if (event.key === Qt.Key_Tab)
                    root.navigate("next");
                else if (event.key === Qt.Key_Backtab)
                    root.navigate("prev");
                else
                    return;
                event.accepted = true;
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                visible: input.text === ""
                text: "search for a spell..."
                color: Theme.muted
                font.pixelSize: input.font.pixelSize
            }
        }

        Sticker {
            implicitWidth: countText.implicitWidth + 18
            implicitHeight: 26
            radius: 13
            lift: 2
            fill: Theme.accent

            StyledText {
                id: countText

                anchors.centerIn: parent
                text: root.count
                font.pixelSize: 12
            }
        }
    }
}
