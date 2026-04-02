{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.shell.ambxstColorBridge;

  script = pkgs.writeScriptBin "ambxst-color-bridge" ''
    #!${pkgs.python3}/bin/python3
    """Watch ~/.cache/wal/wal (wallpaper path) and re-run pywal + ytm theme when ambxst changes wallpaper."""

    import ctypes
    import json
    import os
    import shutil
    import struct
    import subprocess
    from pathlib import Path

    WAL_FILE   = Path.home() / ".cache/wal/wal"
    THEME_FILE = Path.home() / ".config/ytm-player/theme.toml"
    AMBXST_COLORS = Path.home() / ".cache/ambxst/colors.json"
    SWAYNC_WAL_SRC  = Path.home() / ".cache/wal/swaync"
    SWAYNC_STYLE_DST = Path.home() / ".config/swaync/style.css"

    YTM_TEMPLATE = """\
    background      = "rgba(0,0,0,0)"
    foreground      = "{overSurface}"
    text            = "{overSurface}"
    muted_text      = "{outline}"
    primary         = "{primary}"
    secondary       = "{secondary}"
    accent          = "{tertiary}"
    surface         = "{surfaceContainer}"
    border          = "{outlineVariant}"
    active_tab      = "{primary}"
    inactive_tab    = "{outline}"
    selected_item   = "{primaryContainer}"
    playback_bar_bg = "{surfaceContainerLow}"
    progress_filled = "{primary}"
    progress_empty  = "{outlineVariant}"
    lyrics_played   = "{outline}"
    lyrics_current  = "{primary}"
    lyrics_upcoming = "{overSurface}"
    success         = "{green}"
    warning         = "{yellow}"
    error           = "{error}"
    """

    IN_CLOSE_WRITE = 0x00000008
    IN_MOVED_TO    = 0x00000080

    def inotify_watch(path):
        libc = ctypes.CDLL("libc.so.6", use_errno=True)
        fd = libc.inotify_init()
        if fd < 0:
            raise OSError(ctypes.get_errno(), "inotify_init failed")
        wd = libc.inotify_add_watch(fd, str(path.parent).encode(), IN_CLOSE_WRITE | IN_MOVED_TO)
        if wd < 0:
            os.close(fd)
            raise OSError(ctypes.get_errno(), "inotify_add_watch failed")
        target = path.name.encode()
        try:
            buf = b""
            while True:
                buf += os.read(fd, 4096)
                while len(buf) >= 16:
                    _, mask, cookie, name_len = struct.unpack_from("iIII", buf)
                    total = 16 + name_len
                    if len(buf) < total:
                        break
                    name = buf[16:total].rstrip(b"\x00")
                    buf = buf[total:]
                    if name == target:
                        return
        finally:
            os.close(fd)

    def run_wal(wallpaper):
        print(f"[ambxst-color-bridge] wal -i {wallpaper}")
        subprocess.run(["${pkgs.pywal}/bin/wal", "-i", wallpaper, "-q", "-n"], check=False)

    def write_ytm_theme():
        if not AMBXST_COLORS.exists():
            return
        try:
            colors = json.loads(AMBXST_COLORS.read_text())
            THEME_FILE.parent.mkdir(parents=True, exist_ok=True)
            THEME_FILE.write_text(YTM_TEMPLATE.format_map(colors))
            print(f"[ambxst-color-bridge] updated {THEME_FILE}")
        except Exception as e:
            print(f"[ambxst-color-bridge] ytm theme error: {e}")

    def reload_swaync():
        if not SWAYNC_WAL_SRC.exists():
            return
        try:
            SWAYNC_STYLE_DST.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(str(SWAYNC_WAL_SRC), str(SWAYNC_STYLE_DST))
            subprocess.run(["swaync-client", "--reload-css"], check=False)
            print(f"[ambxst-color-bridge] reloaded swaync style")
        except Exception as e:
            print(f"[ambxst-color-bridge] swaync reload error: {e}")

    def apply():
        try:
            wallpaper = WAL_FILE.read_text().strip()
        except FileNotFoundError:
            print("[ambxst-color-bridge] no wallpaper path, skipping")
            return
        run_wal(wallpaper)
        write_ytm_theme()
        reload_swaync()

    def main():
        print(f"[ambxst-color-bridge] watching {WAL_FILE}")
        apply()
        while True:
            try:
                inotify_watch(WAL_FILE)
            except OSError as e:
                import time
                print(f"[ambxst-color-bridge] inotify error: {e}, retrying in 5s")
                time.sleep(5)
                continue
            apply()

    main()
  '';
in
{
  options.nyx.modules.shell.ambxstColorBridge = {
    enable = mkEnableOption "ambxst → pywal color bridge (re-runs wal -i + ytm theme on wallpaper change)";
  };

  config = mkIf cfg.enable {
    home.packages = [ script ];

    systemd.user.services.ambxst-color-bridge = {
      Unit = {
        Description = "Sync ambxst wallpaper changes to pywal and ytm-player theme";
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${script}/bin/ambxst-color-bridge";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}
