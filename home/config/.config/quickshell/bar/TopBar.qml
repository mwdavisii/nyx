import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "./modules"
import "../shared" as Shared

PanelWindow {
    id: root
    required property var screen_
    screen: screen_

    anchors { top: true; left: true; right: true }
    implicitHeight: 48

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "shell-top"
    WlrLayershell.exclusiveZone: height

    color: Qt.rgba(0, 0, 0, 0)

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Shared.PaletteBridge.background.r, Shared.PaletteBridge.background.g, Shared.PaletteBridge.background.b, 0.85)

        // Left section
        RowLayout {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            anchors.leftMargin: 12
            spacing: 8
            IdleInhibitor {}
            Workspaces {}
        }

        // Center section
        MediaPlayer {
            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        }

        // Right section
        RowLayout {
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            anchors.rightMargin: 12
            spacing: 12
            SystemStats {}
            Shared.StatusWidgets {}
            RandWall {}
            NotificationBadge {}
            Clock {}
            PowerMenu {}
            Tray {}
        }
    }
}
