import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../../shared" as Shared

RowLayout {
    spacing: 6

    Repeater {
        model: SystemTray.items

        delegate: Item {
            required property SystemTrayItem modelData
            width: 22
            height: 22

            Image {
                anchors.fill: parent
                source: parent.modelData.icon
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: event => {
                    if (event.button === Qt.RightButton) {
                        parent.modelData.secondaryActivate(0, 0)
                    } else {
                        parent.modelData.activate(0, 0)
                    }
                }
            }
        }
    }
}
