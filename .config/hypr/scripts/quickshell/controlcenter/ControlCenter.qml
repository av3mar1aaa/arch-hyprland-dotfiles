import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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


    // ========================================================
    // STATE
    // ========================================================

    property string wifiState: "unavailable"
    property string btState: "unavailable"

    property string audioState: "unavailable"
    property int volume: 0

    property string nightState: "unavailable"
    property string dndState: "off"

    property string powerProfile: "unavailable"

    property string confirmAction: ""


    readonly property string scripts:
        Quickshell.env("HOME")
        + "/.config/hypr/scripts/control-center"


    // ========================================================
    // STATE READER
    // ========================================================

    Process {
        id: stateReader

        command: [
            "bash",
            root.scripts + "/state.sh"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let d = JSON.parse(this.text)

                    root.wifiState =
                        d.wifi || "unavailable"

                    root.btState =
                        d.bluetooth || "unavailable"

                    root.audioState =
                        d.audio || "unavailable"

                    root.volume =
                        d.volume || 0

                    root.nightState =
                        d.nightlight || "unavailable"

                    root.dndState =
                        d.dnd || "off"

                    root.powerProfile =
                        d.profile || "unavailable"

                } catch(e) {
                    console.log(
                        "Control Center state error:",
                        e
                    )
                }
            }
        }
    }


    Timer {
        interval: 1200
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            stateReader.running = false
            stateReader.running = true
        }
    }


    // ========================================================
    // ACTIONS
    // ========================================================

    Process {
        id: actionProcess

        onExited: {
            refreshTimer.restart()
        }
    }


    Timer {
        id: refreshTimer
        interval: 250

        onTriggered: {
            stateReader.running = false
            stateReader.running = true
        }
    }


    function action(name) {
        actionProcess.running = false

        actionProcess.command = [
            "bash",
            root.scripts + "/action.sh",
            name
        ]

        actionProcess.running = true
    }


    function dangerousAction(name) {
        if (root.confirmAction === name) {
            root.confirmAction = ""
            root.action(name)
            return
        }

        root.confirmAction = name
        confirmationTimer.restart()
    }


    Timer {
        id: confirmationTimer
        interval: 2800

        onTriggered: {
            root.confirmAction = ""
        }
    }


    // ========================================================
    // REUSABLE QUICK TILE
    // ========================================================

    component QuickTile: Rectangle {
        id: tile

        property string icon: ""
        property string title: ""
        property string subtitle: ""

        property bool enabledState: false
        property bool available: true

        property color accentColor: design.accent

        signal activated()

        Layout.fillWidth: true
        Layout.preferredHeight: root.s(105)

        radius: design.radiusMedium

        color: {
            if (!available)
                return Qt.rgba(
                    design.surface0.r,
                    design.surface0.g,
                    design.surface0.b,
                    0.28
                )

            if (enabledState)
                return Qt.rgba(
                    accentColor.r,
                    accentColor.g,
                    accentColor.b,
                    0.16
                )

            return Qt.rgba(
                design.surface0.r,
                design.surface0.g,
                design.surface0.b,
                mouse.containsMouse ? 0.78 : 0.55
            )
        }

        border.width: design.borderWidth

        border.color: enabledState
            ? Qt.rgba(
                accentColor.r,
                accentColor.g,
                accentColor.b,
                0.55
            )
            : Qt.rgba(
                design.text.r,
                design.text.g,
                design.text.b,
                0.08
            )

        opacity: available ? 1.0 : 0.42

        Behavior on color {
            ColorAnimation {
                duration: design.animationFast
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: design.animationFast
            }
        }

        RowLayout {
            anchors.fill: parent

            anchors.leftMargin: root.s(16)
            anchors.rightMargin: root.s(16)

            spacing: root.s(13)

            Rectangle {
                Layout.preferredWidth: root.s(45)
                Layout.preferredHeight: root.s(45)

                radius: root.s(13)

                color: tile.enabledState
                    ? Qt.rgba(
                        tile.accentColor.r,
                        tile.accentColor.g,
                        tile.accentColor.b,
                        0.22
                    )
                    : Qt.rgba(
                        design.surface1.r,
                        design.surface1.g,
                        design.surface1.b,
                        0.7
                    )

                Text {
                    anchors.centerIn: parent

                    text: tile.icon

                    font.family: "Iosevka Nerd Font"
                    font.pixelSize: root.s(21)

                    color: tile.enabledState
                        ? tile.accentColor
                        : design.subtext0
                }
            }


            ColumnLayout {
                Layout.fillWidth: true

                spacing: root.s(3)

                Text {
                    text: tile.title

                    font.family: "JetBrains Mono"
                    font.pixelSize: root.s(14)
                    font.weight: Font.DemiBold

                    color: design.text
                }

                Text {
                    text: tile.subtitle

                    font.family: "JetBrains Mono"
                    font.pixelSize: root.s(10)

                    color: tile.enabledState
                        ? tile.accentColor
                        : design.subtext0

                    elide: Text.ElideRight

                    Layout.fillWidth: true
                }
            }
        }


        MouseArea {
            id: mouse

            anchors.fill: parent

            hoverEnabled: true

            enabled: tile.available

            cursorShape: Qt.PointingHandCursor

            onClicked: tile.activated()
        }


        scale: mouse.pressed ? 0.97 :
               mouse.containsMouse ? 1.015 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: design.animationFast
                easing.type: Easing.OutCubic
            }
        }
    }


    // ========================================================
    // POWER BUTTON
    // ========================================================

    component PowerButton: Rectangle {
        id: powerButton

        property string icon: ""
        property string label: ""

        property string actionName: ""

        property bool dangerous: false
        property color accentColor: design.text

        Layout.fillWidth: true
        Layout.preferredHeight: root.s(72)

        radius: design.radiusMedium

        color: mouse.containsMouse
            ? Qt.rgba(
                accentColor.r,
                accentColor.g,
                accentColor.b,
                0.13
            )
            : Qt.rgba(
                design.surface0.r,
                design.surface0.g,
                design.surface0.b,
                0.46
            )

        border.width: design.borderWidth

        border.color:
            root.confirmAction === actionName
                ? design.danger
                : Qt.rgba(
                    design.text.r,
                    design.text.g,
                    design.text.b,
                    0.07
                )


        Column {
            anchors.centerIn: parent

            spacing: root.s(4)

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: powerButton.icon

                font.family: "Iosevka Nerd Font"
                font.pixelSize: root.s(20)

                color:
                    root.confirmAction === actionName
                        ? design.danger
                        : accentColor
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text:
                    root.confirmAction === actionName
                        ? "Confirm"
                        : powerButton.label

                font.family: "JetBrains Mono"
                font.pixelSize: root.s(9)

                color:
                    root.confirmAction === actionName
                        ? design.danger
                        : design.subtext0
            }
        }


        MouseArea {
            id: mouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (powerButton.dangerous)
                    root.dangerousAction(
                        powerButton.actionName
                    )
                else
                    root.action(
                        powerButton.actionName
                    )
            }
        }


        scale: mouse.pressed ? 0.96 :
               mouse.containsMouse ? 1.02 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: design.animationFast
            }
        }
    }


    // ========================================================
    // MAIN CARD
    // ========================================================

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

            spacing: root.s(17)


            // ------------------------------------------------
            // HEADER
            // ------------------------------------------------

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Control Center"

                    font.family: "JetBrains Mono"
                    font.pixelSize: root.s(20)
                    font.weight: Font.Bold

                    color: design.text
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "SUPER + ESC"

                    font.family: "JetBrains Mono"
                    font.pixelSize: root.s(9)

                    color: design.subtext1
                }
            }


            // ------------------------------------------------
            // QUICK CONTROLS
            // ------------------------------------------------

            GridLayout {
                Layout.fillWidth: true

                columns: 3

                columnSpacing: root.s(10)
                rowSpacing: root.s(10)


                QuickTile {
                    icon: "󰖩"
                    title: "Wi-Fi"

                    subtitle:
                        root.wifiState === "on"
                            ? "Enabled"
                            : root.wifiState === "off"
                                ? "Disabled"
                                : "Unavailable"

                    enabledState:
                        root.wifiState === "on"

                    available:
                        root.wifiState !== "unavailable"

                    accentColor: design.accent

                    onActivated:
                        root.action("wifi")
                }


                QuickTile {
                    icon: "󰂯"
                    title: "Bluetooth"

                    subtitle:
                        root.btState === "on"
                            ? "Enabled"
                            : root.btState === "off"
                                ? "Disabled"
                                : "Unavailable"

                    enabledState:
                        root.btState === "on"

                    available:
                        root.btState !== "unavailable"

                    accentColor:
                        design.accentSecondary

                    onActivated:
                        root.action("bluetooth")
                }


                QuickTile {
                    icon:
                        root.audioState === "off"
                            ? "󰖁"
                            : "󰕾"

                    title: "Sound"

                    subtitle:
                        root.audioState === "unavailable"
                            ? "Unavailable"
                            : root.audioState === "off"
                                ? "Muted"
                                : root.volume + "%"

                    enabledState:
                        root.audioState === "on"

                    available:
                        root.audioState !== "unavailable"

                    accentColor:
                        design.accentTertiary

                    onActivated:
                        root.action("audio")
                }


                QuickTile {
                    icon: "󰌵"
                    title: "Night Light"

                    subtitle:
                        root.nightState === "on"
                            ? "4000 K"
                            : root.nightState === "off"
                                ? "Off"
                                : "Unavailable"

                    enabledState:
                        root.nightState === "on"

                    available:
                        root.nightState !== "unavailable"

                    accentColor:
                        design.warning

                    onActivated:
                        root.action("nightlight")
                }


                QuickTile {
                    icon:
                        root.dndState === "on"
                            ? "󰂛"
                            : "󰂚"

                    title: "Do Not Disturb"

                    subtitle:
                        root.dndState === "on"
                            ? "Notifications silent"
                            : "Notifications active"

                    enabledState:
                        root.dndState === "on"

                    accentColor:
                        design.accent

                    onActivated:
                        root.action("dnd")
                }


                QuickTile {
                    icon: "󰓅"
                    title: "Power"

                    subtitle: {
                        if (root.powerProfile === "performance")
                            return "Performance"

                        if (root.powerProfile === "balanced")
                            return "Balanced"

                        if (root.powerProfile === "power-saver")
                            return "Power Saver"

                        return "Unavailable"
                    }

                    enabledState:
                        root.powerProfile === "performance"

                    available:
                        root.powerProfile !== "unavailable"

                    accentColor:
                        design.accentSecondary

                    onActivated:
                        root.action("power-profile")
                }
            }


            // ------------------------------------------------
            // SETTINGS
            // ------------------------------------------------

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.s(48)

                radius: design.radiusMedium

                color: settingsMouse.containsMouse
                    ? Qt.rgba(
                        design.surface1.r,
                        design.surface1.g,
                        design.surface1.b,
                        0.70
                    )
                    : Qt.rgba(
                        design.surface0.r,
                        design.surface0.g,
                        design.surface0.b,
                        0.43
                    )

                RowLayout {
                    anchors.fill: parent

                    anchors.leftMargin: root.s(16)
                    anchors.rightMargin: root.s(16)

                    Text {
                        text: "󰒓"

                        font.family:
                            "Iosevka Nerd Font"

                        font.pixelSize:
                            root.s(17)

                        color:
                            design.accent
                    }

                    Text {
                        text: "Settings"

                        font.family:
                            "JetBrains Mono"

                        font.pixelSize:
                            root.s(12)

                        color:
                            design.text
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "›"

                        font.pixelSize:
                            root.s(21)

                        color:
                            design.subtext0
                    }
                }

                MouseArea {
                    id: settingsMouse

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.action("settings")
                }
            }


            // ------------------------------------------------
            // POWER ACTIONS
            // ------------------------------------------------

            RowLayout {
                Layout.fillWidth: true

                spacing: root.s(9)

                PowerButton {
                    icon: ""
                    label: "Lock"

                    actionName: "lock"

                    accentColor:
                        design.accent
                }


                PowerButton {
                    icon: "󰒲"
                    label: "Suspend"

                    actionName: "suspend"

                    accentColor:
                        design.accentSecondary
                }


                PowerButton {
                    icon: "󰍃"
                    label: "Logout"

                    actionName: "logout"
                    dangerous: true

                    accentColor:
                        design.warning
                }


                PowerButton {
                    icon: "󰜉"
                    label: "Reboot"

                    actionName: "reboot"
                    dangerous: true

                    accentColor:
                        design.warning
                }


                PowerButton {
                    icon: ""
                    label: "Shutdown"

                    actionName: "shutdown"
                    dangerous: true

                    accentColor:
                        design.danger
                }
            }
        }
    }
}
