import QtQuick
import "../../shared" as Shared

Item {
    id: root
    width: clockText.width + 4
    height: parent.height

    property bool longFormat: false

    Text {
        id: clockText
        anchors.centerIn: parent
        color: Shared.PaletteBridge.foreground
        font.pixelSize: 13
        font.family: "Roboto Condensed"

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                const now = new Date()
                const h = now.getHours()
                const m = String(now.getMinutes()).padStart(2, '0')
                const ampm = h >= 12 ? "PM" : "AM"
                const h12 = h % 12 || 12
                if (root.longFormat) {
                    const mo = String(now.getMonth() + 1).padStart(2, '0')
                    const dy = String(now.getDate()).padStart(2, '0')
                    const yr = now.getFullYear()
                    parent.text = `${h12}:${m} ${ampm} | ${mo}/${dy}/${yr}`
                } else {
                    parent.text = `${h12}:${m} ${ampm}`
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.longFormat = !root.longFormat
        cursorShape: Qt.PointingHandCursor
    }
}
