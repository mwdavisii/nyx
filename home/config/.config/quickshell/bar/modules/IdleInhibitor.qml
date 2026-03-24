import QtQuick
import Quickshell.Io
import "../../shared" as Shared

Item {
    id: root
    width: 32
    height: parent.height

    property bool inhibiting: false

    Text {
        anchors.centerIn: parent
        text: root.inhibiting ? "" : ""
        color: root.inhibiting
            ? Shared.PaletteBridge.color3
            : Shared.PaletteBridge.foreground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.inhibiting) {
                inhibitProc.running = false
                root.inhibiting = false
            } else {
                inhibitProc.running = true
                root.inhibiting = true
            }
        }
    }

    Process {
        id: inhibitProc
        command: ["systemd-inhibit", "--what=idle:sleep", "--who=QuickShell",
                  "--why=User requested", "--mode=block", "sleep", "infinity"]
    }
}
