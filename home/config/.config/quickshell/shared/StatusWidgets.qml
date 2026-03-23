import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Shell.Shared

RowLayout {
    spacing: 8

    // --- Volume ---
    Item {
        id: volItem
        width: volRow.implicitWidth + 8
        height: parent.height

        RowLayout {
            id: volRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                color: PaletteBridge.foreground
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                text: "󰕾"
            }
            Text {
                id: volText
                color: PaletteBridge.foreground
                font.pixelSize: 12
                text: "--%"
            }
        }

        Process {
            id: volPoll
            command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
            running: true
            stdout: SplitParser {
                onRead: data => {
                    const m = data.match(/(\d+)%/)
                    if (m) volText.text = m[1] + "%"
                }
            }
        }

        Timer {
            interval: 3000
            repeat: true
            running: true
            onTriggered: if (!volPoll.running) volPoll.running = true
        }
    }

    // --- Bluetooth ---
    Item {
        width: btText.implicitWidth + 8
        height: parent.height

        Text {
            id: btText
            anchors.verticalCenter: parent.verticalCenter
            color: PaletteBridge.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            text: "󰂯"
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: btToggleProc.running = true
        }

        Process {
            id: btToggleProc
            command: ["bluetooth_toggle"]
        }
    }

    // --- WiFi ---
    Item {
        width: wifiText.implicitWidth + 8
        height: parent.height

        Text {
            id: wifiText
            anchors.verticalCenter: parent.verticalCenter
            color: PaletteBridge.foreground
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            text: "󰤨"
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: nmtuiProc.running = true
        }

        Process {
            id: nmtuiProc
            command: ["kitty", "--", "nmtui"]
        }
    }

    // --- Battery (hidden when absent) ---
    Item {
        id: batteryItem
        visible: false
        width: visible ? (batRow.implicitWidth + 8) : 0
        height: parent.height

        RowLayout {
            id: batRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                color: PaletteBridge.foreground
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                text: ""
            }
            Text {
                id: batText
                color: PaletteBridge.foreground
                font.pixelSize: 12
                text: "--%"
            }
        }

        FileView {
            path: "/sys/class/power_supply/BAT0/capacity"
            watchChanges: true
            onTextChanged: {
                batteryItem.visible = true
                batText.text = text.trim() + "%"
            }
        }
    }

    // --- Backlight (hidden when absent) ---
    Item {
        id: backlightItem
        visible: false
        width: visible ? (blRow.implicitWidth + 8) : 0
        height: parent.height

        RowLayout {
            id: blRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                color: PaletteBridge.foreground
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                text: "󰃠"
            }
            Text {
                id: blText
                color: PaletteBridge.foreground
                font.pixelSize: 12
                text: "--%"
            }
        }

        Process {
            id: blPoll
            command: ["brightnessctl", "--percentage", "get"]
            running: true
            stdout: SplitParser {
                onRead: data => {
                    backlightItem.visible = true
                    blText.text = data.trim() + "%"
                }
            }
        }

        Timer {
            interval: 5000
            repeat: true
            running: true
            onTriggered: if (!blPoll.running) blPoll.running = true
        }
    }
}
