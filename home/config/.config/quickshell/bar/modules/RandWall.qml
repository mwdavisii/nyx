import QtQuick
import Quickshell.Io
import "../../shared" as Shared

Item {
    width: 32
    height: parent.height

    Text {
        anchors.centerIn: parent
        text: "󰏘"
        color: Shared.PaletteBridge.foreground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton) wallDefaultProc.running = true
            else wallRandomProc.running = true
        }
        cursorShape: Qt.PointingHandCursor
    }

    Process { id: wallRandomProc;  command: ["wallpaper_random"] }
    Process { id: wallDefaultProc; command: ["wallpaper_default"] }
}
