import Quickshell
import Shell.Shared

ShellRoot {
    id: shell

    Component.onCompleted: {
        console.log("Shell loaded. Background color:", PaletteBridge.background)
    }
}
