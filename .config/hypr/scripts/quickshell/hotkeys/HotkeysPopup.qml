import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: root
    focus: true

    Scaler {
        id: scaler
        currentWidth: Screen.width
    }

    function s(v) {
        return scaler.s(v)
    }

    Design {
        id: design
    }

    property string category: "All"
    property string query: ""

    readonly property string exporter:
        Quickshell.env("HOME")
        + "/.config/hypr/scripts/hotkeys-export.py"

    property var categories: [
        { name: "All",        icon: "󰌌" },
        { name: "Apps",       icon: "󰀻" },
        { name: "Windows",    icon: "󰖯" },
        { name: "Workspaces", icon: "󰍹" },
        { name: "System",     icon: "󰒓" },
        { name: "Media",      icon: "󰎆" }
    ]

    ListModel {
        id: bindsModel
    }


    function reloadBinds() {
        bindReader.running = false

        bindReader.command = [
            "python3",
            root.exporter,
            "--category",
            root.category,
            "--query",
            root.query
        ]

        bindReader.running = true
    }


    Process {
        id: bindReader

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let data = JSON.parse(this.text)

                    bindsModel.clear()

                    for (let i = 0; i < data.length; i++) {
                        bindsModel.append(data[i])
                    }
                } catch(e) {
                    console.log(
                        "Hotkeys parser error:",
                        e
                    )
                }
            }
        }
    }


    Timer {
        id: searchDebounce

        interval: 100

        onTriggered: {
            root.reloadBinds()
        }
    }


    Component.onCompleted: {
        root.reloadBinds()
        search.forceActiveFocus()
    }


    Rectangle {
        anchors.fill: parent

        radius: design.radiusLarge

        color: Qt.rgba(
            design.base.r,
            design.base.g,
            design.base.b,
            design.popupOpacity
        )

        border.width: design.borderWidth

        border.color: Qt.rgba(
            design.text.r,
            design.text.g,
            design.text.b,
            0.09
        )


        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.s(22)

            spacing: root.s(14)


            // =================================================
            // HEADER
            // =================================================

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: root.s(2)

                    Text {
                        text: "Keyboard Shortcuts"

                        font.family: "JetBrains Mono"
                        font.pixelSize: root.s(24)
                        font.weight: Font.Bold

                        color: design.text
                    }

                    Text {
                        text:
                            bindsModel.count
                            + " active bindings"

                        font.family: "JetBrains Mono"
                        font.pixelSize: root.s(13)

                        color: design.subtext1
                    }
                }


                Item {
                    Layout.fillWidth: true
                }


                Rectangle {
                    Layout.preferredWidth: root.s(105)
                    Layout.preferredHeight: root.s(28)

                    radius: root.s(8)

                    color: Qt.rgba(
                        design.surface0.r,
                        design.surface0.g,
                        design.surface0.b,
                        0.65
                    )

                    Text {
                        anchors.centerIn: parent

                        text: "SUPER + K"

                        font.family: "JetBrains Mono"
                        font.pixelSize: root.s(13)
                        font.weight: Font.Bold

                        color: design.accent
                    }
                }
            }


            // =================================================
            // SEARCH
            // =================================================

            TextField {
                id: search

                Layout.fillWidth: true
                Layout.preferredHeight: root.s(52)

                leftPadding: root.s(42)
                rightPadding: root.s(14)

                placeholderText: "Search shortcuts..."

                font.family: "JetBrains Mono"
                font.pixelSize: root.s(13)

                color: design.text
                placeholderTextColor: design.subtext1

                selectByMouse: true


                onTextChanged: {
                    root.query = text
                    searchDebounce.restart()
                }


                background: Rectangle {
                    radius: design.radiusMedium

                    color: Qt.rgba(
                        design.surface0.r,
                        design.surface0.g,
                        design.surface0.b,
                        search.activeFocus ? 0.80 : 0.55
                    )

                    border.width: design.borderWidth

                    border.color:
                        search.activeFocus
                        ? Qt.rgba(
                            design.accent.r,
                            design.accent.g,
                            design.accent.b,
                            0.65
                        )
                        : Qt.rgba(
                            design.text.r,
                            design.text.g,
                            design.text.b,
                            0.07
                        )

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: root.s(15)
                        anchors.verticalCenter: parent.verticalCenter

                        text: ""

                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: root.s(15)

                        color: search.activeFocus
                            ? design.accent
                            : design.subtext0
                    }
                }
            }


            // =================================================
            // CATEGORY BAR
            // =================================================

            RowLayout {
                Layout.fillWidth: true

                spacing: root.s(7)

                Repeater {
                    model: root.categories

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.preferredHeight: root.s(44)

                        radius: root.s(10)

                        property bool selected:
                            root.category === modelData.name

                        color:
                            selected
                            ? Qt.rgba(
                                design.accent.r,
                                design.accent.g,
                                design.accent.b,
                                0.16
                            )
                            : categoryMouse.containsMouse
                                ? Qt.rgba(
                                    design.surface1.r,
                                    design.surface1.g,
                                    design.surface1.b,
                                    0.60
                                )
                                : "transparent"

                        border.width:
                            selected
                            ? design.borderWidth
                            : 0

                        border.color: Qt.rgba(
                            design.accent.r,
                            design.accent.g,
                            design.accent.b,
                            0.40
                        )


                        Row {
                            anchors.centerIn: parent

                            spacing: root.s(7)

                            Text {
                                text: modelData.icon

                                font.family:
                                    "Iosevka Nerd Font"

                                font.pixelSize:
                                    root.s(15)

                                color:
                                    parent.parent.selected
                                    ? design.accent
                                    : design.subtext0
                            }

                            Text {
                                text: modelData.name

                                font.family:
                                    "JetBrains Mono"

                                font.pixelSize:
                                    root.s(9)

                                font.weight:
                                    parent.parent.selected
                                    ? Font.Bold
                                    : Font.Normal

                                color:
                                    parent.parent.selected
                                    ? design.accent
                                    : design.subtext0
                            }
                        }


                        MouseArea {
                            id: categoryMouse

                            anchors.fill: parent
                            hoverEnabled: true

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked: {
                                root.category =
                                    modelData.name

                                root.reloadBinds()
                            }
                        }
                    }
                }
            }


            // =================================================
            // LIST
            // =================================================

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                radius: design.radiusMedium

                color: Qt.rgba(
                    design.surface0.r,
                    design.surface0.g,
                    design.surface0.b,
                    0.30
                )

                clip: true


                ListView {
                    id: list

                    anchors.fill: parent

                    anchors.margins: root.s(8)

                    model: bindsModel

                    spacing: root.s(6)

                    clip: true

                    boundsBehavior:
                        Flickable.StopAtBounds

                    ScrollBar.vertical:
                        ScrollBar {}


                    delegate: Rectangle {
                        required property string combo
                        required property string title
                        required property string raw
                        required property string category

                        width: list.width
                        height: root.s(78)

                        radius: root.s(10)

                        color:
                            rowMouse.containsMouse
                            ? Qt.rgba(
                                design.surface1.r,
                                design.surface1.g,
                                design.surface1.b,
                                0.72
                            )
                            : Qt.rgba(
                                design.surface0.r,
                                design.surface0.g,
                                design.surface0.b,
                                0.38
                            )

                        border.width: design.borderWidth

                        border.color:
                            rowMouse.containsMouse
                            ? Qt.rgba(
                                design.accent.r,
                                design.accent.g,
                                design.accent.b,
                                0.28
                            )
                            : Qt.rgba(
                                design.text.r,
                                design.text.g,
                                design.text.b,
                                0.045
                            )


                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: root.s(11)

                            spacing: root.s(14)


                            Rectangle {
                                Layout.preferredWidth:
                                    Math.max(
                                        root.s(135),
                                        comboText.implicitWidth
                                        + root.s(22)
                                    )

                                Layout.preferredHeight:
                                    root.s(38)

                                radius: root.s(8)

                                color: Qt.rgba(
                                    design.accent.r,
                                    design.accent.g,
                                    design.accent.b,
                                    0.11
                                )

                                border.width:
                                    design.borderWidth

                                border.color: Qt.rgba(
                                    design.accent.r,
                                    design.accent.g,
                                    design.accent.b,
                                    0.25
                                )


                                Text {
                                    id: comboText

                                    anchors.centerIn: parent

                                    text: combo

                                    font.family:
                                        "JetBrains Mono"

                                    font.pixelSize:
                                        root.s(9)

                                    font.weight:
                                        Font.Bold

                                    color:
                                        design.accent
                                }
                            }


                            ColumnLayout {
                                Layout.fillWidth: true

                                spacing: root.s(3)


                                Text {
                                    Layout.fillWidth: true

                                    text: title

                                    elide:
                                        Text.ElideRight

                                    font.family:
                                        "JetBrains Mono"

                                    font.pixelSize:
                                        root.s(13)

                                    font.weight:
                                        Font.DemiBold

                                    color:
                                        design.text
                                }


                                Text {
                                    Layout.fillWidth: true

                                    text: raw

                                    elide:
                                        Text.ElideRight

                                    font.family:
                                        "JetBrains Mono"

                                    font.pixelSize:
                                        root.s(9)

                                    color:
                                        design.subtext1
                                }
                            }


                            Rectangle {
                                Layout.preferredWidth:
                                    categoryText.implicitWidth
                                    + root.s(18)

                                Layout.preferredHeight:
                                    root.s(28)

                                radius: root.s(12)

                                color: Qt.rgba(
                                    design.accentSecondary.r,
                                    design.accentSecondary.g,
                                    design.accentSecondary.b,
                                    0.10
                                )


                                Text {
                                    id: categoryText

                                    anchors.centerIn: parent

                                    text: category

                                    font.family:
                                        "JetBrains Mono"

                                    font.pixelSize:
                                        root.s(9)

                                    color:
                                        design.accentSecondary
                                }
                            }
                        }


                        MouseArea {
                            id: rowMouse

                            anchors.fill: parent
                            hoverEnabled: true

                            acceptedButtons:
                                Qt.NoButton
                        }
                    }


                    Text {
                        anchors.centerIn: parent

                        visible:
                            bindsModel.count === 0

                        text:
                            root.query === ""
                            ? "No shortcuts"
                            : "No matches"

                        font.family:
                            "JetBrains Mono"

                        font.pixelSize:
                            root.s(12)

                        color:
                            design.subtext1
                    }
                }
            }


            // =================================================
            // FOOTER
            // =================================================

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text:
                        "Live data from Hyprland"

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize:
                        root.s(9)

                    color:
                        design.subtext1
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text:
                        "Type to search  •  ESC to close"

                    font.family:
                        "JetBrains Mono"

                    font.pixelSize:
                        root.s(9)

                    color:
                        design.subtext1
                }
            }
        }
    }
}
