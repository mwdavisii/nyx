import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../shared" as Shared

PanelWindow {
    id: root

    signal dismissed

    anchors { top: true; bottom: true; left: true; right: true }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "shell-launcher"

    color: Qt.rgba(0, 0, 0, 0.6)

    // Dismiss on Escape
    Keys.onEscapePressed: root.dismissed()

    // Dismiss on click outside the content area
    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
    }

    // Content area — stops click propagation to background
    Column {
        id: contentArea
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        anchors.topMargin: 80
        width: 600
        spacing: 24

        // Search box
        Rectangle {
            width: parent.width
            height: 52
            radius: 12
            color: Qt.rgba(Shared.PaletteBridge.background.r, Shared.PaletteBridge.background.g, Shared.PaletteBridge.background.b, 0.92)

            MouseArea {
                anchors.fill: parent
                onClicked: mouse.accepted = true  // prevent click-through to dismiss
            }

            TextField {
                id: searchInput
                anchors { fill: parent; margins: 12 }
                color: Shared.PaletteBridge.foreground
                font.pixelSize: 16
                font.family: "Roboto Condensed"
                placeholderText: "Search apps..."
                placeholderTextColor: Shared.PaletteBridge.color8
                background: null
                focus: true
                selectByMouse: true
                Component.onCompleted: forceActiveFocus()
            }
        }

        // App grid
        Rectangle {
            width: parent.width
            height: Math.min(appGrid.implicitHeight, 480)
            color: "transparent"
            clip: true

            MouseArea {
                anchors.fill: parent
                onClicked: mouse.accepted = true  // prevent click-through to dismiss
            }

            Grid {
                id: appGrid
                width: parent.width
                columns: 6
                spacing: 12

                Repeater {
                    model: {
                        const q = searchInput.text.toLowerCase()
                        const all = DesktopEntries.applications
                        if (!all) return []
                        return all.filter(app =>
                            !app.noDisplay &&
                            (q === "" ||
                             (app.name || "").toLowerCase().includes(q) ||
                             (app.genericName || "").toLowerCase().includes(q))
                        )
                    }

                    delegate: Item {
                        id: appItem
                        required property var modelData

                        width: 88
                        height: 88

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: hoverArea.containsMouse
                                ? Qt.rgba(Shared.PaletteBridge.color4.r, Shared.PaletteBridge.color4.g, Shared.PaletteBridge.color4.b, 0.25)
                                : "transparent"

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                Image {
                                    id: appIcon
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 40; height: 40
                                    source: appItem.modelData.icon || ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    visible: status === Image.Ready
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: appItem.modelData.name || ""
                                    color: Shared.PaletteBridge.foreground
                                    font.pixelSize: 11
                                    font.family: "Roboto Condensed"
                                    elide: Text.ElideRight
                                    width: 80
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    appItem.modelData.launch()
                                    root.dismissed()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
