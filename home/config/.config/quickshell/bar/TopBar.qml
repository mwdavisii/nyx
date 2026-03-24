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

    anchors { right: true; top: true; bottom: true }
    implicitWidth: 48

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "shell-right"
    WlrLayershell.exclusiveZone: width

    color: Qt.rgba(0, 0, 0, 0)

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Shared.PaletteBridge.background.r, Shared.PaletteBridge.background.g, Shared.PaletteBridge.background.b, 0.85)

        // Top section
        ColumnLayout {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            anchors.topMargin: 12
            spacing: 8
            IdleInhibitor {}
            Workspaces {}
        }

        // Center section
        MediaPlayer {
            anchors { verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter }
        }

        // Bottom section
        ColumnLayout {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            anchors.bottomMargin: 12
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
