import QtQuick
import QtQuick.Layouts
import Quickshell
import Twilight.Core

// Title, the clock and a greeting that follows the time of day.
ColumnLayout {
    spacing: 14

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Text {
            id: title

            text: "✦ Twilight's Library"
            color: Theme.star
            font.family: Theme.font
            font.pixelSize: 24
            font.bold: true
            style: Text.Outline
            styleColor: Theme.ink
        }

        Item {
            Layout.fillWidth: true
        }

        Sticker {
            Layout.rightMargin: 34
            implicitWidth: clockText.implicitWidth + 24
            implicitHeight: 30
            radius: 15
            lift: 3
            fill: Theme.secondary

            StyledText {
                id: clockText

                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "HH:mm")
                font.pixelSize: 13

                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }
            }
        }
    }

    StyledText {
        text: {
            const h = clock.date.getHours();
            const part = h < 5 ? "Good night" : h < 12 ? "Good morning" : h < 18 ? "Good afternoon" : "Good evening";
            return part + " ✧ what shall we cast today?";
        }
        color: Theme.muted
        font.pixelSize: 13
    }
}
