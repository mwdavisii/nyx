import QtQuick
import Quickshell.Io
import "../../shared" as Shared

Item {
    width: 32
    height: parent.height

    Text {
        anchors.centerIn: parent
        text: "󰐥"
        color: Shared.PaletteBridge.foreground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
    }

    MouseArea {
        anchors.fill: parent
        onClicked: powerProc.running = true
        cursorShape: Qt.PointingHandCursor
    }

    Process {
        id: powerProc
        command: ["rofiPowerMenu"]
    }
}
