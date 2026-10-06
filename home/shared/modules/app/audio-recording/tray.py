"""StatusNotifierItem tray icon for meeting-record.

Usage: tray.py <recorder-pid>
Shows a red dot in the system tray while <recorder-pid> is alive.
Left click runs `meeting-record` (which stops the recording).
Exits on its own when the recorder process goes away.
"""

import asyncio
import os
import subprocess
import sys

from dbus_next import PropertyAccess
from dbus_next.aio import MessageBus
from dbus_next.service import ServiceInterface, dbus_property, method, signal


def red_dot(size):
    """ARGB32 (network byte order) pixmap of an anti-aliased red disc."""
    c, r = (size - 1) / 2, size / 2 - 1
    data = bytearray()
    for y in range(size):
        for x in range(size):
            d = ((x - c) ** 2 + (y - c) ** 2) ** 0.5
            a = max(0.0, min(1.0, r - d + 0.5))
            data += bytes((int(a * 255), 0xE0, 0x1B, 0x24))
    return [size, size, bytes(data)]


PIXMAPS = [red_dot(s) for s in (16, 22, 24, 32, 48, 64)]


class Item(ServiceInterface):
    def __init__(self):
        super().__init__("org.kde.StatusNotifierItem")

    @dbus_property(access=PropertyAccess.READ)
    def Category(self) -> "s":
        return "ApplicationStatus"

    @dbus_property(access=PropertyAccess.READ)
    def Id(self) -> "s":
        return "meeting-record"

    @dbus_property(access=PropertyAccess.READ)
    def Title(self) -> "s":
        return "Recording meeting"

    @dbus_property(access=PropertyAccess.READ)
    def Status(self) -> "s":
        return "Active"

    @dbus_property(access=PropertyAccess.READ)
    def IconName(self) -> "s":
        return ""

    @dbus_property(access=PropertyAccess.READ)
    def IconPixmap(self) -> "a(iiay)":
        return PIXMAPS

    @dbus_property(access=PropertyAccess.READ)
    def ToolTip(self) -> "(sa(iiay)ss)":
        return ["", PIXMAPS, "Recording meeting", "Click to stop"]

    @dbus_property(access=PropertyAccess.READ)
    def ItemIsMenu(self) -> "b":
        return False

    @dbus_property(access=PropertyAccess.READ)
    def Menu(self) -> "o":
        return "/NO_DBUSMENU"

    @method()
    def Activate(self, x: "i", y: "i"):
        subprocess.Popen(["meeting-record"])

    @method()
    def SecondaryActivate(self, x: "i", y: "i"):
        subprocess.Popen(["meeting-record"])

    @method()
    def ContextMenu(self, x: "i", y: "i"):
        pass

    @method()
    def Scroll(self, delta: "i", orientation: "s"):
        pass

    @signal()
    def NewIcon(self):
        pass

    @signal()
    def NewStatus(self) -> "s":
        return "Active"


def alive(pid):
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


async def main(pid):
    bus = await MessageBus().connect()
    bus.export("/StatusNotifierItem", Item())
    name = f"org.kde.StatusNotifierItem-{os.getpid()}-1"
    await bus.request_name(name)

    intro = await bus.introspect("org.kde.StatusNotifierWatcher", "/StatusNotifierWatcher")
    watcher = bus.get_proxy_object(
        "org.kde.StatusNotifierWatcher", "/StatusNotifierWatcher", intro
    ).get_interface("org.kde.StatusNotifierWatcher")
    await watcher.call_register_status_notifier_item(name)

    while alive(pid):
        await asyncio.sleep(1)
    bus.disconnect()


if __name__ == "__main__":
    asyncio.run(main(int(sys.argv[1])))
