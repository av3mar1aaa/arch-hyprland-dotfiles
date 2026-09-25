import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: root

    focus: true

    property var notifModel
    property var liveNotifs

    property real layoutWidth: width
    property real layoutHeight: height

    property int totalBinds: 0
    property string errorText: ""

    MatugenColors {
        id: theme
    }

    ListModel {
        id: bindsModel
    }

    function loadBinds() {
        errorText = ""

        if (!loader.running)
            loader.running = true
    }

    Component.onCompleted: loadBinds()

    onVisibleChanged: {
        if (visible)
            loadBinds()
    }

    Process {
        id: loader

        command: [
            "python3",
            Quickshell.env("HOME")
                + "/.config/hypr/scripts/keybinds_export.py"
        ]

        stdout: StdioCollector {
            onStreamFinished: {

                bindsModel.clear()

                try {
                    let data = JSON.parse(this.text)

                    root.totalBinds =
                        data.count || 0

                    let items =
                        data.items || []

                    for (
                        let i = 0;
                        i < items.length;
                        i++
                    ) {
                        bindsModel.append(
                            items[i]
                        )
                    }

                } catch (e) {

                    root.errorText =
                        "Не удалось загрузить бинды"

                    console.log(
                        "Keybinds:",
                        e
                    )
                }
            }
        }
    }


    Rectangle {
        anchors.fill: parent

        radius: 20

        color: Qt.rgba(
            theme.base.r,
            theme.base.g,
            theme.base.b,
            0.94
        )

        border.width: 1

        border.color: Qt.rgba(
            theme.teal.r,
            theme.teal.g,
            theme.teal.b,
            0.48
        )


        // accent line

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top

                leftMargin: 24
                rightMargin: 24
            }

            height: 1

            color: Qt.rgba(
                theme.teal.r,
                theme.teal.g,
                theme.teal.b,
                0.45
            )
        }


        // ====================================================
        // HEADER
        // ====================================================

        Item {
            id: header

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            height: 92


            Rectangle {
                id: iconBox

                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter

                    leftMargin: 26
                }

                width: 48
                height: 48

                radius: 13

                color: Qt.rgba(
                    theme.surface1.r,
                    theme.surface1.g,
                    theme.surface1.b,
                    0.50
                )

                Text {
                    anchors.centerIn: parent

                    text: "󰌌"

                    color: theme.teal

                    font.family:
                        "JetBrainsMono Nerd Font"

                    font.pixelSize: 23
                }
            }


            Column {
                anchors {
                    left: iconBox.right
                    verticalCenter:
                        parent.verticalCenter

                    leftMargin: 16
                }

                spacing: 4


                Text {
                    text: "KEYBINDS"

                    color: theme.text

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 21
                    font.bold: true
                }


                Text {
                    text:
                        root.totalBinds
                        + " активных горячих клавиш"

                    color: theme.subtext0

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 11
                }
            }


            Rectangle {
                anchors {
                    right: parent.right
                    verticalCenter:
                        parent.verticalCenter

                    rightMargin: 26
                }

                width: 124
                height: 34

                radius: 10

                color: Qt.rgba(
                    theme.surface0.r,
                    theme.surface0.g,
                    theme.surface0.b,
                    0.55
                )

                Text {
                    anchors.centerIn: parent

                    text: "SUPER + \\"

                    color: theme.teal

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }


        Rectangle {
            id: separator

            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right

                leftMargin: 24
                rightMargin: 24
            }

            height: 1

            color: Qt.rgba(
                theme.surface2.r,
                theme.surface2.g,
                theme.surface2.b,
                0.40
            )
        }


        // ====================================================
        // LIST
        // ====================================================

        ListView {
            id: list

            anchors {
                top: separator.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right

                topMargin: 16
                bottomMargin: 22

                leftMargin: 24
                rightMargin: 24
            }

            model: bindsModel

            spacing: 7
            clip: true


            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }


            delegate: Rectangle {
                id: card

                required property string combo
                required property string action
                required property string category

                width: list.width - 8
                height: 58

                radius: 12

                color: hover.hovered

                    ? Qt.rgba(
                        theme.surface1.r,
                        theme.surface1.g,
                        theme.surface1.b,
                        0.52
                    )

                    : Qt.rgba(
                        theme.surface0.r,
                        theme.surface0.g,
                        theme.surface0.b,
                        0.22
                    )


                border.width: 1

                border.color: hover.hovered

                    ? Qt.rgba(
                        theme.teal.r,
                        theme.teal.g,
                        theme.teal.b,
                        0.36
                    )

                    : Qt.rgba(
                        theme.surface2.r,
                        theme.surface2.g,
                        theme.surface2.b,
                        0.18
                    )


                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }


                HoverHandler {
                    id: hover
                }


                Rectangle {
                    id: shortcutBox

                    anchors {
                        left: parent.left
                        verticalCenter:
                            parent.verticalCenter

                        leftMargin: 13
                    }

                    width: 260
                    height: 34

                    radius: 9

                    color: Qt.rgba(
                        theme.mantle.r,
                        theme.mantle.g,
                        theme.mantle.b,
                        0.78
                    )

                    border.width: 1

                    border.color: Qt.rgba(
                        theme.teal.r,
                        theme.teal.g,
                        theme.teal.b,
                        0.25
                    )


                    Text {
                        anchors.centerIn: parent

                        text: card.combo

                        color: theme.text

                        font.family:
                            "JetBrains Mono"

                        font.pixelSize: 12
                        font.bold: true
                    }
                }


                Text {
                    anchors {
                        left: shortcutBox.right
                        right: categoryBox.left

                        verticalCenter:
                            parent.verticalCenter

                        leftMargin: 17
                        rightMargin: 17
                    }

                    text: card.action

                    color: theme.text

                    elide: Text.ElideRight

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize: 12
                }


                Rectangle {
                    id: categoryBox

                    anchors {
                        right: parent.right
                        verticalCenter:
                            parent.verticalCenter

                        rightMargin: 13
                    }

                    width: 145
                    height: 28

                    radius: 8

                    color: Qt.rgba(
                        theme.teal.r,
                        theme.teal.g,
                        theme.teal.b,
                        0.10
                    )


                    Text {
                        anchors.centerIn: parent

                        text: card.category

                        color: theme.teal

                        font.family:
                            "JetBrains Mono"

                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }


            Text {
                anchors.centerIn: parent

                visible:
                    bindsModel.count === 0

                text:
                    root.errorText !== ""
                    ? root.errorText
                    : "Загрузка..."

                color: theme.subtext0

                font.family:
                    "JetBrains Mono"

                font.pixelSize: 14
            }
        }
    }
}
