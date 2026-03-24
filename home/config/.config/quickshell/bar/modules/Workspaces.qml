import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../shared" as Shared

RowLayout {
    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            required property HyprlandWorkspace modelData

            property bool isActive: Hyprland.focusedMonitor !== null
                && Hyprland.focusedMonitor.activeWorkspace.id === modelData.id

            width: 28
            height: 28
            radius: 14
            color: isActive
                ? Shared.PaletteBridge.color4
                : "transparent"

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: isActive ? "" : (modelData.windows > 0 ? "" : "")
                color: isActive
                    ? Shared.PaletteBridge.background
                    : Shared.PaletteBridge.color8
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + modelData.id)
                onWheel: event => {
                    Hyprland.dispatch(event.angleDelta.y > 0
                        ? "workspace -1"
                        : "workspace +1")
                }
            }
        }
    }
}
