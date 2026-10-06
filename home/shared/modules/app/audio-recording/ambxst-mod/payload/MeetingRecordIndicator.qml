import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.modules.theme
import qs.modules.components

// Red "REC mm:ss" pill shown while `meeting-record` is running.
// Click stops the recording. Hidden (zero width) otherwise.
Item {
    id: root

    required property var bar

    property bool vertical: bar.orientation === "vertical"
    property bool layerEnabled: true
    property real radius: 0
    property real startRadius: radius
    property real endRadius: radius

    property bool recording: false
    property int startedAt: 0
    property int elapsed: 0

    visible: recording
    Layout.preferredWidth: vertical ? 36 : buttonBg.implicitWidth
    Layout.preferredHeight: vertical ? buttonBg.implicitHeight : 36

    // Prints the pidfile's mtime if the recorder is alive; prints nothing otherwise.
    Process {
        id: probe
        command: ["sh", "-c", "f=\"${XDG_RUNTIME_DIR:-/tmp}/meeting-record.pid\"; [ -f \"$f\" ] && kill -0 \"$(cat \"$f\")\" 2>/dev/null && stat -c %Y \"$f\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = parseInt(text.trim());
                root.recording = !isNaN(t);
                if (root.recording) {
                    root.startedAt = t;
                    root.elapsed = Math.max(0, Math.floor(Date.now() / 1000) - t);
                }
            }
        }
    }

    Process {
        id: stopper
        command: ["meeting-record"]
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }

    function fmt(s) {
        const h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60), sec = s % 60;
        const pad = n => n < 10 ? "0" + n : "" + n;
        return (h > 0 ? h + ":" + pad(m) : pad(m)) + ":" + pad(sec);
    }

    StyledRect {
        id: buttonBg
        variant: "bg"
        anchors.fill: parent
        enableShadow: root.layerEnabled

        topLeftRadius: root.startRadius
        topRightRadius: root.vertical ? root.startRadius : root.endRadius
        bottomLeftRadius: root.vertical ? root.endRadius : root.startRadius
        bottomRightRadius: root.endRadius

        implicitWidth: root.vertical ? 36 : row.implicitWidth + 24
        implicitHeight: root.vertical ? 36 : 36

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 6

            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: Colors.red

                SequentialAnimation on opacity {
                    running: root.recording
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.25; duration: 700 }
                    NumberAnimation { to: 1.0; duration: 700 }
                }
            }

            Text {
                visible: !root.vertical
                text: "REC " + root.fmt(root.elapsed)
                color: Colors.red
                font.pixelSize: Config.theme.fontSize
                font.family: Config.theme.font
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: stopper.running = true
        }
    }
}
