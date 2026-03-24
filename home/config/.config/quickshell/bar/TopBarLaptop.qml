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
    implicitWidth: 40

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "shell-laptop-right"
    WlrLayershell.exclusiveZone: width

    color: Qt.rgba(0, 0, 0, 0)

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Shared.PaletteBridge.background.r, Shared.PaletteBridge.background.g, Shared.PaletteBridge.background.b, 0.85)

        ColumnLayout {
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            anchors.topMargin: 8
            Workspaces {}
        }

        ColumnLayout {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            anchors.bottomMargin: 12
            spacing: 8
            Shared.StatusWidgets {}
            Clock {}
        }
    }
}
