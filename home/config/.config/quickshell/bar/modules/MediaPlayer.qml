import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import "../../shared" as Shared

RowLayout {
    id: root
    spacing: 8
    visible: Mpris.players.length > 0

    property var player: Mpris.players.length > 0
        ? Mpris.players[0]
        : null

    // Prev button
    Text {
        text: "󰒮"
        color: Shared.PaletteBridge.foreground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        MouseArea {
            anchors.fill: parent
            onClicked: if (root.player) root.player.previous()
        }
    }

    // Play/Pause
    Text {
        text: {
            const p = root.player
            if (!p) return "󰐌"
            return p.playbackState === MprisPlaybackState.Playing ? "󰏥" : "󰐌"
        }
        color: Shared.PaletteBridge.color5
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        MouseArea {
            anchors.fill: parent
            onClicked: if (root.player) root.player.playPause()
        }
    }

    // Next button
    Text {
        text: "󰒭"
        color: Shared.PaletteBridge.foreground
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        MouseArea {
            anchors.fill: parent
            onClicked: if (root.player) root.player.next()
        }
    }

    // Track label
    Text {
        property string title: root.player ? root.player.trackTitle : ""
        property string artist: root.player ? root.player.trackArtists.join(", ") : ""
        text: artist && title ? `${artist} - ${title}` : title
        color: Shared.PaletteBridge.foreground
        font.pixelSize: 12
        font.family: "Roboto Condensed"
        elide: Text.ElideRight
        maximumLineCount: 1
        Layout.maximumWidth: 300
    }
}
