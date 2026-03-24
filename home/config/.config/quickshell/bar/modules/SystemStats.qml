import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../shared" as Shared

RowLayout {
    spacing: 12

    // CPU
    Text {
        id: cpuText
        color: Shared.PaletteBridge.foreground
        font.pixelSize: 12
        font.family: "Roboto Condensed"
        text: "󰻠 --%"
        MouseArea {
            anchors.fill: parent
            onClicked: if (!btopProc.running) btopProc.running = true
        }
        Process {
            id: cpuPoll
            command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}'"]
            running: true
            stdout: SplitParser {
                onRead: data => cpuText.text = "󰻠 " + Math.round(parseFloat(data)) + "%"
            }
        }
        Timer { interval: 5000; repeat: true; running: true; onTriggered: if (!cpuPoll.running) cpuPoll.running = true }
    }

    // Memory
    Text {
        id: memText
        color: Shared.PaletteBridge.foreground
        font.pixelSize: 12
        font.family: "Roboto Condensed"
        text: "󰍛 --%"
        MouseArea { anchors.fill: parent; onClicked: if (!btopProc.running) btopProc.running = true }
        Process {
            id: memPoll
            command: ["sh", "-c", "free | awk '/Mem:/ {printf \"%.0f\", $3/$2*100}'"]
            running: true
            stdout: SplitParser { onRead: data => memText.text = "󰍛 " + data.trim() + "%" }
        }
        Timer { interval: 5000; repeat: true; running: true; onTriggered: if (!memPoll.running) memPoll.running = true }
    }

    // Disk
    Text {
        id: diskText
        color: Shared.PaletteBridge.foreground
        font.pixelSize: 12
        font.family: "Roboto Condensed"
        text: "󰋊 --%"
        MouseArea { anchors.fill: parent; onClicked: if (!btopProc.running) btopProc.running = true }
        Process {
            id: diskPoll
            command: ["sh", "-c", "df / | awk 'NR==2 {print $5}'"]
            running: true
            stdout: SplitParser { onRead: data => diskText.text = "󰋊 " + data.trim() }
        }
        Timer { interval: 30000; repeat: true; running: true; onTriggered: if (!diskPoll.running) diskPoll.running = true }
    }

    // Temperature
    Text {
        id: tempText
        color: Shared.PaletteBridge.foreground
        font.pixelSize: 12
        font.family: "Roboto Condensed"
        text: "-°C "
        MouseArea { anchors.fill: parent; onClicked: if (!btopProc.running) btopProc.running = true }
        Process {
            id: tempPoll
            command: ["sh", "-c", "cat /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -1 | awk '{printf \"%.0f\", $1/1000}'"]
            running: true
            stdout: SplitParser {
                onRead: data => {
                    const t = parseInt(data.trim())
                    const icon = t >= 80 ? "" : t >= 60 ? "" : ""
                    tempText.text = `${t}°C ${icon}`
                    tempText.color = t >= 80
                        ? Shared.PaletteBridge.color1
                        : Shared.PaletteBridge.foreground
                }
            }
        }
        Timer { interval: 5000; repeat: true; running: true; onTriggered: if (!tempPoll.running) tempPoll.running = true }
    }

    // btop launcher (shared across all stats clicks)
    Process {
        id: btopProc
        command: ["kitty", "--start-as=fullscreen", "--title", "btop", "--", "btop"]
    }
}
