import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // --------------------------------------------------------
    // MATUGEN PALETTE
    // --------------------------------------------------------

    MatugenColors {
        id: palette
    }

    readonly property color base: palette.base
    readonly property color mantle: palette.mantle
    readonly property color crust: palette.crust

    readonly property color text: palette.text
    readonly property color subtext0: palette.subtext0
    readonly property color subtext1: palette.subtext1

    readonly property color surface0: palette.surface0
    readonly property color surface1: palette.surface1
    readonly property color surface2: palette.surface2

    // Main wallpaper-derived accent
    readonly property color accent: palette.blue

    readonly property color accentSecondary: palette.teal
    readonly property color accentTertiary: palette.peach

    readonly property color success: palette.green
    readonly property color warning: palette.yellow
    readonly property color danger: palette.red


    // --------------------------------------------------------
    // DESIGN METRICS
    // --------------------------------------------------------

    property int radiusSmall: 10
    property int radiusMedium: 14
    property int radiusLarge: 18

    property int borderWidth: 1

    property real popupOpacity: 0.90
    property real panelOpacity: 0.75
    property real hoverOpacity: 0.55

    property int animationFast: 160
    property int animationNormal: 220
    property int animationSlow: 320


    // --------------------------------------------------------
    // JSON READER
    // --------------------------------------------------------

    readonly property string configPath:
        Quickshell.env("HOME")
        + "/.config/hypr/design.json"

    Process {
        id: reader

        command: [
            "cat",
            root.configPath
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let d = JSON.parse(this.text)

                    if (d.radiusSmall !== undefined)
                        root.radiusSmall = d.radiusSmall

                    if (d.radiusMedium !== undefined)
                        root.radiusMedium = d.radiusMedium

                    if (d.radiusLarge !== undefined)
                        root.radiusLarge = d.radiusLarge

                    if (d.borderWidth !== undefined)
                        root.borderWidth = d.borderWidth

                    if (d.popupOpacity !== undefined)
                        root.popupOpacity = d.popupOpacity

                    if (d.panelOpacity !== undefined)
                        root.panelOpacity = d.panelOpacity

                    if (d.hoverOpacity !== undefined)
                        root.hoverOpacity = d.hoverOpacity

                    if (d.animationFast !== undefined)
                        root.animationFast = d.animationFast

                    if (d.animationNormal !== undefined)
                        root.animationNormal = d.animationNormal

                    if (d.animationSlow !== undefined)
                        root.animationSlow = d.animationSlow

                } catch(e) {
                    console.log(
                        "Design.qml: invalid design.json",
                        e
                    )
                }
            }
        }
    }


    Process {
        id: watcher

        command: [
            "bash",
            "-c",
            "inotifywait -qq -e close_write,modify '"
            + root.configPath
            + "'"
        ]

        running: true

        onExited: {
            reader.running = false
            reader.running = true

            watcher.running = false
            watcher.running = true
        }
    }


    Component.onCompleted: {
        reader.running = true
    }
}
