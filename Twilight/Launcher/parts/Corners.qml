import QtQuick
import Twilight.Core

// Big stars poking out of the corners of the card it sits on.
Item {
    id: root

    property bool active: false

    anchors.fill: parent

    Text {
        x: root.width - 52
        y: -34
        text: "★"
        color: Theme.star
        font.pixelSize: 64
        style: Text.Outline
        styleColor: Theme.ink

        SequentialAnimation on rotation {
            running: root.active
            loops: Animation.Infinite

            NumberAnimation { to: 14; duration: 1800; easing.type: Easing.InOutSine }
            NumberAnimation { to: -8; duration: 1800; easing.type: Easing.InOutSine }
        }
    }

    Text {
        x: -26
        y: root.height - 46
        text: "✦"
        color: Theme.primary
        font.pixelSize: 46
        style: Text.Outline
        styleColor: Theme.ink

        SequentialAnimation on scale {
            running: root.active
            loops: Animation.Infinite

            NumberAnimation { to: 1.2; duration: 1300; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.9; duration: 1300; easing.type: Easing.InOutSine }
        }
    }

    Text {
        x: root.width - 30
        y: root.height * 0.55
        text: "✧"
        color: Theme.text
        font.pixelSize: 26
        style: Text.Outline
        styleColor: Theme.ink

        SequentialAnimation on opacity {
            running: root.active
            loops: Animation.Infinite

            NumberAnimation { to: 0.2; duration: 900; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
        }
    }
}
