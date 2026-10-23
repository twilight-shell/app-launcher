import QtQuick
import Twilight.Core

// Key hints under the grid.
Row {
    spacing: 10

    Repeater {
        model: [
            { key: "↵", label: "cast" },
            { key: "←↑↓→", label: "select" },
            { key: "esc", label: "close" }
        ]

        Row {
            required property var modelData

            spacing: 6

            Sticker {
                width: keyText.implicitWidth + 14
                height: 22
                radius: 7
                lift: 2
                fill: Theme.surfaceHigh
                gloss: false

                StyledText {
                    id: keyText

                    anchors.centerIn: parent
                    text: modelData.key
                    color: Theme.primary
                    font.pixelSize: 11
                }
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.label
                color: Theme.muted
                font.pixelSize: 11
            }
        }
    }
}
