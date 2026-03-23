import QtQuick
import Quickshell.Io
import "../../shared" as Shared

Item {
    id: root
    width: badgeText.width + 4
    height: parent.height

    property int unreadCount: 0
    property bool dnd: false

    Text {
        id: badgeText
        anchors.centerIn: parent
        color: root.dnd
            ? Shared.PaletteBridge.color8
            : (root.unreadCount > 0
                ? Shared.PaletteBridge.color1
                : Shared.PaletteBridge.foreground)
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        text: {
            if (root.dnd) return "󰂛"
            return root.unreadCount > 0 ? `󰂚 ${root.unreadCount}` : "󰂚"
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: event => {
            if (event.button === Qt.RightButton) dndProc.running = true
            else toggleProc.running = true
        }
        cursorShape: Qt.PointingHandCursor
    }

    // Persistent subscription — emits JSON lines continuously
    Process {
        id: swayncProc
        command: ["swaync-client", "-swb"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    const obj = JSON.parse(data)
                    if (typeof obj.count !== "undefined") root.unreadCount = obj.count
                    if (typeof obj.dnd !== "undefined") root.dnd = obj.dnd
                } catch (e) {}
            }
        }
        onExited: Qt.callLater(() => { running = true })
    }

    Process { id: toggleProc; command: ["swaync-client", "-t", "-sw"] }
    Process { id: dndProc;    command: ["swaync-client", "-d", "-sw"] }
}
