{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.audio-recording;

  trayPython = pkgs.python3.withPackages (ps: [ ps.dbus-next ]);

  # Toggle: first run starts recording, second run stops it.
  # Mixes the default output's monitor (the other side of the call) with the
  # default mic into one M4A. Fragmented MP4 so the file stays playable even if
  # ffmpeg is killed before it can finalize.
  # ffmpeg/pactl/notify-send come from PATH (pacman on Arch).
  meetingRecord = pkgs.writeShellScriptBin "meeting-record" ''
    set -euo pipefail
    pidfile="''${XDG_RUNTIME_DIR:-/tmp}/meeting-record.pid"

    if [[ -f "$pidfile" ]] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
      kill -INT "$(cat "$pidfile")"
      rm -f "$pidfile"
      notify-send -a meeting-record "Recording stopped" "Saved to ${cfg.meetingDir}"
      exit 0
    fi

    mkdir -p "${cfg.meetingDir}"
    out="${cfg.meetingDir}/$(date +%F_%H%M%S).m4a"
    monitor="$(pactl get-default-sink).monitor"
    mic="$(pactl get-default-source)"

    setsid ffmpeg -hide_banner -loglevel error -nostdin \
      -f pulse -i "$monitor" -f pulse -i "$mic" \
      -filter_complex "[0:a][1:a]amix=inputs=2:duration=longest:normalize=0" \
      -ac 1 -c:a aac -b:a 96k \
      -movflags +frag_keyframe+empty_moov+default_base_moof -frag_duration 2000000 -flush_packets 1 \
      "$out" &
    echo $! > "$pidfile"
    # Tray icon; exits by itself once ffmpeg is gone
    setsid ${trayPython}/bin/python3 ${./tray.py} "$(cat "$pidfile")" >/dev/null 2>&1 &
    notify-send -a meeting-record "Recording meeting" "$(basename "$out")"
  '';
in
{
  options.nyx.modules.app.audio-recording = {
    enable = mkEnableOption "PipeWire audio recording tools (pw-record and Helvum patchbay)";

    pwRecordPackage = mkOption {
      description = "Package providing pw-record";
      type = with types; nullOr package;
      default = pkgs.pipewire;
    };

    helvumPackage = mkOption {
      description = "Package for Helvum PipeWire patchbay";
      type = with types; nullOr package;
      default = pkgs.helvum;
    };

    meetingDir = mkOption {
      description = "Where meeting-record saves recordings";
      type = types.str;
      default = "${config.home.homeDirectory}/Recordings/meetings";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      optional (cfg.pwRecordPackage != null) cfg.pwRecordPackage
      ++ optional (cfg.helvumPackage != null) cfg.helvumPackage
      ++ [ meetingRecord ];
  };
}
