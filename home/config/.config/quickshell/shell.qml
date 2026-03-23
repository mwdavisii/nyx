import Quickshell
import Quickshell.Wayland
import "bar"
import "shared" as Shared

ShellRoot {
    id: shell

    // IPC handler — triggered by: quickshell ipc call openLauncher
    // (IPC syntax verified in Task 1: "quickshell ipc call" not "quickshell msg send")
    IpcHandler {
        target: "openLauncher"
        function handle() {
            launcherLoader.active = true
        }
    }

    // Launcher overlay (loaded on demand)
    // TODO Task 10: replace sourceComponent with actual Launcher
    Loader {
        id: launcherLoader
        active: false
        // sourceComponent: Launcher { onDismissed: launcherLoader.active = false }
    }

    Variants {
        model: Quickshell.screens

        delegate: QtObject {
            required property var modelData  // QuickshellScreen

            readonly property bool isEDP: modelData.name.startsWith("eDP")
            readonly property bool isFull: !isEDP && modelData.width > 2560
            readonly property bool isSolo: Quickshell.screens.length === 1

            // Solo screen always gets full bar regardless of type
            readonly property string barVariant: isSolo ? "full"
                : isEDP ? "laptop"
                : isFull ? "full"
                : "compact"

            // Full bar
            Loader {
                active: barVariant === "full"
                sourceComponent: TopBar { screen_: modelData }
            }

            // Laptop bar
            Loader {
                active: barVariant === "laptop"
                sourceComponent: TopBarLaptop { screen_: modelData }
            }

            // Compact bar
            Loader {
                active: barVariant === "compact"
                sourceComponent: TopBarCompact { screen_: modelData }
            }

            // Dock — only on the "full" bar screen
            // TODO Task 9: uncomment when Dock.qml exists
            // Loader {
            //     active: barVariant === "full"
            //     sourceComponent: Dock { screen_: modelData }
            // }
        }
    }
}
