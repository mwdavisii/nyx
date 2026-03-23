pragma Singleton
import QtQuick
import QtCore
import Quickshell.Io

QtObject {
    id: root

    // Pywal colors — defaults match a dark gruvbox fallback
    property color background: "#282828"
    property color foreground: "#ebdbb2"
    property color color0:  "#282828"
    property color color1:  "#cc241d"
    property color color2:  "#98971a"
    property color color3:  "#d79921"
    property color color4:  "#458588"
    property color color5:  "#b16286"
    property color color6:  "#689d6a"
    property color color7:  "#a89984"
    property color color8:  "#928374"
    property color color9:  "#fb4934"
    property color color10: "#b8bb26"
    property color color11: "#fabd2f"
    property color color12: "#83a598"
    property color color13: "#d3869b"
    property color color14: "#8ec07c"
    property color color15: "#ebdbb2"

    property FileView _watcher: FileView {
        path: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.cache/wal/colors.json"
        watchChanges: true
        onTextChanged: root._parseColors(text)
    }

    function _parseColors(json) {
        try {
            const data = JSON.parse(json)
            const c = data.colors
            root.background = data.special?.background ?? root.background
            root.foreground = data.special?.foreground ?? root.foreground
            root.color0  = c?.color0  ?? root.color0
            root.color1  = c?.color1  ?? root.color1
            root.color2  = c?.color2  ?? root.color2
            root.color3  = c?.color3  ?? root.color3
            root.color4  = c?.color4  ?? root.color4
            root.color5  = c?.color5  ?? root.color5
            root.color6  = c?.color6  ?? root.color6
            root.color7  = c?.color7  ?? root.color7
            root.color8  = c?.color8  ?? root.color8
            root.color9  = c?.color9  ?? root.color9
            root.color10 = c?.color10 ?? root.color10
            root.color11 = c?.color11 ?? root.color11
            root.color12 = c?.color12 ?? root.color12
            root.color13 = c?.color13 ?? root.color13
            root.color14 = c?.color14 ?? root.color14
            root.color15 = c?.color15 ?? root.color15
        } catch (e) {
            console.warn("PaletteBridge: failed to parse colors.json:", e)
        }
    }
}
