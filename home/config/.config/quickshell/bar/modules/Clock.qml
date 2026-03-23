import QtQuick
import "../../shared" as Shared

Item {
    width: clockText.width + 16
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
                if (parent.parent.longFormat) {
                    const d = now.toLocaleDateString('en-US', {month:'2-digit', day:'2-digit', year:'numeric'})
                    parent.text = `${h12}:${m} ${ampm} | ${d}`
                } else {
                    parent.text = `${h12}:${m} ${ampm}`
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.longFormat = !parent.longFormat
        cursorShape: Qt.PointingHandCursor
    }
}
