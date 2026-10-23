import QtQuick
import QtQuick.Particles
import Quickshell
import Quickshell.Widgets
import Twilight.Core

// One app in the launcher grid: an icon sticker that pops in, and when
// selected lifts up, wobbles, pulses a magic ring and sheds sparkles.
Item {
    id: tile

    required property var modelData
    required property int index

    readonly property bool current: GridView.isCurrentItem
    readonly property bool hovered: mouse.containsMouse

    signal activated

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    // 0 -> 1 when the tile appears, staggered by position.
    property real pop: 0
    property real wobble: 0

    Component.onCompleted: popIn.start()
    onCurrentChanged: if (!current) wobble = 0

    SequentialAnimation {
        id: popIn

        PauseAnimation { duration: Math.min(tile.index, 24) * 24 }
        NumberAnimation {
            target: tile
            property: "pop"
            from: 0
            to: 1
            duration: 480
            easing.type: Easing.OutBack
            easing.overshoot: 2.2
        }
    }

    SequentialAnimation on wobble {
        running: tile.current
        loops: Animation.Infinite

        NumberAnimation { to: 4; duration: 500; easing.type: Easing.InOutSine }
        NumberAnimation { to: -4; duration: 1000; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0; duration: 500; easing.type: Easing.InOutSine }
    }

    Item {
        anchors.fill: parent
        scale: tile.pop
        opacity: Math.min(1, tile.pop * 1.5)

        Item {
            id: body

            anchors.fill: parent
            scale: tile.current ? 1.12 : tile.hovered ? 1.05 : 1
            rotation: tile.wobble

            Behavior on scale {
                NumberAnimation { duration: 260; easing.type: Easing.OutBack; easing.overshoot: 3 }
            }

            Item {
                id: box

                width: 64
                height: 64
                anchors.horizontalCenter: parent.horizontalCenter
                y: 10 - (tile.current ? 5 : 0)

                Behavior on y {
                    NumberAnimation { duration: 220; easing.type: Easing.OutBack }
                }

                // Expanding ring of magic around the selected icon.
                Rectangle {
                    id: ring

                    anchors.centerIn: parent
                    width: parent.width + 10
                    height: width
                    radius: 22
                    color: "transparent"
                    border.color: Theme.star
                    border.width: 2
                    visible: tile.current
                    opacity: 0

                    ParallelAnimation {
                        running: tile.current
                        loops: Animation.Infinite

                        NumberAnimation { target: ring; property: "scale"; from: 0.95; to: 1.35; duration: 1100; easing.type: Easing.OutCubic }
                        NumberAnimation { target: ring; property: "opacity"; from: 0.9; to: 0; duration: 1100; easing.type: Easing.OutCubic }
                    }
                }

                // Soft pink glow under the selected icon.
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 18
                    height: width
                    radius: width / 2
                    color: Theme.alpha(Theme.star, 0.18)
                    visible: tile.current
                }

                Sticker {
                    anchors.fill: parent
                    radius: 18
                    lift: tile.current ? 7 : Theme.lift
                    fill: tile.current ? Theme.primary : tile.hovered ? Theme.border : Theme.surfaceHigh

                    IconImage {
                        id: appIcon

                        anchors.centerIn: parent
                        implicitSize: 38
                        source: Icons.find([tile.modelData.icon])
                        visible: source != ""
                    }

                    // No icon in the theme: a star stands in.
                    Text {
                        anchors.centerIn: parent
                        visible: !appIcon.visible
                        text: "★"
                        color: Theme.star
                        font.pixelSize: 30
                        style: Text.Outline
                        styleColor: Theme.ink
                    }
                }

                // Sparkles drifting off the selected icon.
                Loader {
                    anchors.fill: parent
                    active: tile.current

                    sourceComponent: ParticleSystem {
                        id: aura

                        ItemParticle {
                            system: aura
                            fade: true

                            delegate: Text {
                                text: Math.random() < 0.5 ? "✦" : "⋆"
                                color: Math.random() < 0.6 ? Theme.star : Theme.text
                                font.pixelSize: 8 + Math.random() * 8
                            }
                        }

                        Emitter {
                            system: aura
                            anchors.fill: parent
                            emitRate: 7
                            lifeSpan: 1100
                            lifeSpanVariation: 300
                            shape: EllipseShape { fill: false }

                            velocity: PointDirection {
                                y: -40
                                yVariation: 20
                                xVariation: 25
                            }
                        }
                    }
                }
            }

            Text {
                anchors {
                    top: box.bottom
                    topMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }
                width: tile.width - 10
                horizontalAlignment: Text.AlignHCenter
                text: tile.modelData.name
                color: tile.current ? Theme.star : Theme.text
                font.family: Theme.font
                font.pixelSize: 12
                style: tile.current ? Text.Outline : Text.Normal
                styleColor: Theme.ink
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            if (tile.GridView.view.hoverSelects)
                tile.GridView.view.currentIndex = tile.index;
        }
        onClicked: tile.activated()
    }
}
