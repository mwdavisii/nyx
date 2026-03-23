import Quickshell
import "shared" as Shared

ShellRoot {
    id: shell

    Component.onCompleted: {
        console.log("Shell loaded. Background color:", Shared.PaletteBridge.background)
    }
}
