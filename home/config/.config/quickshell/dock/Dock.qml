import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Wayland._ToplevelManagement
import Quickshell.Io
import "../shared" as Shared

PanelWindow {
    id: root
    required property var screen_
    screen: screen_

    anchors.bottom: true
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "shell-dock"
    WlrLayershell.exclusiveZone: height + 8

    implicitHeight: 60
    // Width is sized to content; centering achieved via left margin
    implicitWidth: dockPill.implicitWidth

    color: Qt.rgba(0, 0, 0, 0)


    // Floating pill — centered horizontally on the screen
    Rectangle {
        id: dockPill
        anchors.centerIn: parent
        implicitWidth: dockRow.implicitWidth + 32
        implicitHeight: parent.height - 8
        radius: implicitHeight / 2
        color: Qt.rgba(Shared.PaletteBridge.background.r, Shared.PaletteBridge.background.g, Shared.PaletteBridge.background.b, 0.85)

        RowLayout {
            id: dockRow
            anchors.centerIn: parent
            spacing: 8

            // Pinned launcher icon — opens Launcher overlay via IPC
            Item {
                id: launcherBtn
                width: 44
                height: 44

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: Shared.PaletteBridge.color4

                    Text {
                        anchors.centerIn: parent
                        text: "󰈸"
                        color: Shared.PaletteBridge.background
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 20
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: launcherProc.running = true
                }

                // IPC call — verified syntax from Task 1: "quickshell ipc call"
                Process {
                    id: launcherProc
                    command: ["quickshell", "ipc", "call", "openLauncher"]
                }
            }

            // Running windows — exclude Alacritty
            Repeater {
                model: ToplevelManager.toplevels

                delegate: Item {
                    id: winItem
                    required property var modelData  // ToplevelHandle
                    visible: modelData.appId !== "Alacritty" && modelData.appId !== "alacritty"
                    width: visible ? 44 : 0
                    height: 44

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: winItem.modelData.activated
                            ? Qt.rgba(Shared.PaletteBridge.color4.r, Shared.PaletteBridge.color4.g, Shared.PaletteBridge.color4.b, 0.35)
                            : "transparent"

                        // App icon from XDG desktop entry
                        Image {
                            id: appIcon
                            anchors { fill: parent; margins: 6 }
                            source: {
                                // Quickshell DesktopEntries API — try byId first
                                const entry = DesktopEntries.byId(winItem.modelData.appId)
                                return entry ? entry.icon : ""
                            }
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            visible: status === Image.Ready
                        }

                        // Fallback text initial when no icon found
                        Text {
                            anchors.centerIn: parent
                            visible: appIcon.status !== Image.Ready
                            text: (winItem.modelData.appId || "?").charAt(0).toUpperCase()
                            color: Shared.PaletteBridge.foreground
                            font.pixelSize: 18
                            font.bold: true
                        }
                    }

                    // Hover scale animation
                    Behavior on scale { NumberAnimation { duration: 100 } }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onEntered: winItem.scale = 1.1
                        onExited: winItem.scale = 1.0
                        onClicked: event => {
                            if (event.button === Qt.RightButton) {
                                winItem.modelData.requestClose()
                            } else {
                                winItem.modelData.requestActivate()
                            }
                        }
                        ToolTip.visible: containsMouse
                        ToolTip.text: winItem.modelData.title || winItem.modelData.appId
                        ToolTip.delay: 500
                    }
                }
            }
        }
    }
}
