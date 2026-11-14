{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.streaming;

  wireplumberConfig = ''
    monitor.alsa.rules = [
      {
        matches = [
          {
            node.name = "${cfg.primaryMic}"
          }
        ]
        actions = {
          update-props = {
            priority.session = 2000
          }
        }
      }
      ${optionalString (cfg.deprioritizeMic != null) ''
      {
        matches = [
          {
            node.name = "${cfg.deprioritizeMic}"
          }
        ]
        actions = {
          update-props = {
            priority.session = 500
          }
        }
      }
      ''}
    ]
  '';

  easyeffectsPreset = builtins.toJSON {
    input = {
      blocklist = [ ];
      plugins_order = [
        "rnnoise#0"
        "gate#0"
        "compressor#0"
        "limiter#0"
      ];
      "rnnoise#0" = {
        bypass = false;
        enable-vad = true;
        input-gain = 0.0;
        output-gain = 0.0;
        release = 20.0;
        vad-threshold = 50.0;
      };
      "gate#0" = {
        bypass = false;
        attack = 5.0;
        input-gain = 0.0;
        knee = 9.0;
        makeup = 0.0;
        output-gain = 0.0;
        range = -24.0;
        ratio = 4.0;
        release = 50.0;
        threshold = -45.0;
      };
      "compressor#0" = {
        bypass = false;
        attack = 10.0;
        boost-amount = 6.0;
        boost-threshold = -72.0;
        dry = -100.0;
        hpf-frequency = 10.0;
        hpf-mode = "off";
        input-gain = 0.0;
        knee = 6.0;
        lpf-frequency = 20000.0;
        lpf-mode = "off";
        makeup = 4.0;
        mode = "Downward";
        output-gain = 0.0;
        ratio = 3.0;
        release = 100.0;
        sidechain-input-device = "";
        sidechain-lookahead = 0.0;
        sidechain-mode = "RMS";
        sidechain-preamp = 0.0;
        sidechain-reactivity = 10.0;
        sidechain-source = "Middle";
        sidechain-type = "Feed-forward";
        stereo-split = false;
        threshold = -20.0;
        wet = 0.0;
      };
      "limiter#0" = {
        bypass = false;
        alr = false;
        alr-attack = 5.0;
        alr-knee = 0.0;
        alr-release = 50.0;
        attack = 5.0;
        dithering = "None";
        external-sidechain = false;
        gain-boost = true;
        input-gain = 0.0;
        lookahead = 5.0;
        mode = "Herm Thin";
        output-gain = 0.0;
        oversampling = "None";
        release = 20.0;
        sidechain-preamp = 0.0;
        stereo-link = 100.0;
        threshold = -1.0;
      };
    };
  };

  easyeffectsRc = generators.toINI { } {
    StreamInputs = {
      inputDevice = cfg.primaryMic;
    };
    StreamOutputs = {
      outputDevice = cfg.outputDevice;
    };
  };

  litraAutotoggleScript = pkgs.writeShellScript "litra-autotoggle" ''
    set -euo pipefail

    LITRA="''${LITRA_BIN:-litra}"
    WEBCAM="''${WEBCAM_DEVICE:-/dev/video0}"
    POLL_INTERVAL="''${POLL_INTERVAL:-2}"
    BRIGHTNESS="''${LITRA_BRIGHTNESS:-${toString cfg.litra.brightness}}"
    TEMPERATURE="''${LITRA_TEMPERATURE:-${toString cfg.litra.temperature}}"

    was_active=false

    cleanup() {
        "$LITRA" off 2>/dev/null || true
        exit 0
    }
    trap cleanup SIGTERM SIGINT

    echo "litra-autotoggle: watching $WEBCAM (poll ''${POLL_INTERVAL}s)"
    echo "litra-autotoggle: brightness=''${BRIGHTNESS}% temperature=''${TEMPERATURE}K"

    while true; do
        if ${pkgs.psmisc}/bin/fuser "$WEBCAM" >/dev/null 2>&1; then
            if [ "$was_active" = false ]; then
                echo "litra-autotoggle: webcam active — turning light on"
                "$LITRA" on 2>/dev/null || true
                "$LITRA" brightness --percentage "$BRIGHTNESS" 2>/dev/null || true
                "$LITRA" temperature --value "$TEMPERATURE" 2>/dev/null || true
                was_active=true
            fi
        else
            if [ "$was_active" = true ]; then
                echo "litra-autotoggle: webcam inactive — turning light off"
                "$LITRA" off 2>/dev/null || true
                was_active=false
            fi
        fi
        sleep "$POLL_INTERVAL"
    done
  '';

  # golive / endlive: Home Assistant guest-room lights + OBS Virtual Camera.
  # The scripts find obs-vcam.mjs next to themselves, so they stay together in
  # share/golive and bin/ gets wrappers that supply curl, jq and node.
  golivePackage = pkgs.runCommand "golive" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/share/golive $out/bin
    cp ${./golive}/golive.sh ${./golive}/endlive.sh ${./golive}/obs-vcam.mjs $out/share/golive/
    chmod +x $out/share/golive/*
    patchShebangs $out/share/golive
    for s in golive endlive; do
      makeWrapper $out/share/golive/$s.sh $out/bin/$s \
        --prefix PATH : ${lib.makeBinPath [ pkgs.curl pkgs.jq pkgs.nodejs ]}
    done
  '';
in
{
  options.nyx.modules.app.streaming = {
    enable = mkEnableOption "Streaming audio pipeline (WirePlumber + EasyEffects + OBS)";

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.easyeffects;
      description = "The easyeffects package to install. Set to null to skip (e.g. on Arch where it's installed via pacman).";
    };

    primaryMic = mkOption {
      type = types.str;
      description = "ALSA node name for the primary microphone.";
      example = "alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_797_2021_02_02_48276-00.analog-stereo";
    };

    deprioritizeMic = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "ALSA node name for a mic to deprioritize (e.g. a webcam mic that keeps stealing default).";
      example = "alsa_input.usb-046d_Logitech_StreamCam_2F9E86A5-02.analog-stereo";
    };

    outputDevice = mkOption {
      type = types.str;
      default = "default";
      description = "ALSA node name for the audio output device.";
    };

    webcamDevice = mkOption {
      type = types.str;
      default = "/dev/video0";
      description = "Video device path for the webcam (used by litra auto-toggle).";
    };

    obsUseEasyeffects = mkOption {
      type = types.bool;
      default = true;
      description = "Whether OBS should use the EasyEffects virtual source instead of the raw mic.";
    };

    litra = {
      enable = mkEnableOption "Logitech Litra Glow auto-toggle with webcam";

      brightness = mkOption {
        type = types.ints.between 0 100;
        default = 70;
        description = "Litra brightness percentage when active.";
      };

      temperature = mkOption {
        type = types.ints.between 2700 6500;
        default = 4500;
        description = "Litra color temperature in Kelvin when active.";
      };
    };

    golive.enable = mkEnableOption "golive/endlive commands (HA lights + OBS Virtual Camera) bound to SUPER+T / SUPER+SHIFT+T in Hyprland";
  };

  config = mkIf cfg.enable {
    home.packages = optional (cfg.package != null) cfg.package
      ++ optional cfg.golive.enable golivePackage;

    # Home Manager writes hypr/golive.lua and requires it from the generated hyprland.lua
    #
    # The macro pad (3 buttons + 1 knob, CH57x chip, USB 1189:8890) is programmed
    # on the device itself with ch57x-keyboard-tool -- the stock firmware sends
    # the same bare "C" for every button and knob click, so it cannot be told
    # apart host-side. Its mapping lives in
    # home/config/.config/macrokeyboard/3x1-knob.yaml and is re-flashed from the
    # repo with:
    #   sudo ch57x-keyboard-tool upload home/config/.config/macrokeyboard/3x1-knob.yaml
    # Buttons emit KEY_F13 (left, go live), KEY_F14 (right, end live) and KEY_F24
    # (middle, spare); the knob emits volumedown/volumeup plus mute on press,
    # which the media_binds table in hypr/binds.lua already handles.
    #
    # The buttons fire XF86Tools and XF86Launch5, not F13/F14: the pad sends
    # KEY_F13/KEY_F14 (evdev 183/184), but the xkb "us" keymap maps <FK13>/<FK14>
    # to those XF86 keysyms, so hl.bind("F13", ...) would never match.
    wayland.windowManager.hyprland.extraLuaFiles.golive = mkIf cfg.golive.enable ''
      hl.bind("SUPER + T", hl.dsp.exec_cmd("golive"))
      hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("endlive"))
      hl.bind("XF86Tools", hl.dsp.exec_cmd("golive"))
      hl.bind("XF86Launch5", hl.dsp.exec_cmd("endlive"))
    '';

    # WirePlumber: prioritize primary mic over webcam mic
    xdg.configFile."wireplumber/wireplumber.conf.d/50-default-input.conf" = {
      text = wireplumberConfig;
    };

    # EasyEffects: streaming preset with noise suppression, gate, compressor, limiter
    xdg.configFile."easyeffects/input/Streaming.json" = {
      text = easyeffectsPreset;
    };

    # EasyEffects: point at the correct input/output devices
    xdg.configFile."easyeffects/db/easyeffectsrc" = {
      text = easyeffectsRc;
    };

    # Litra auto-toggle: turn light on/off with webcam
    systemd.user.services.litra-autotoggle = mkIf cfg.litra.enable {
      Unit = {
        Description = "Auto-toggle Logitech Litra Glow with webcam usage";
        After = [ "pipewire.service" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${litraAutotoggleScript}";
        Restart = "on-failure";
        RestartSec = 5;
        Environment = [
          "WEBCAM_DEVICE=${cfg.webcamDevice}"
          "LITRA_BRIGHTNESS=${toString cfg.litra.brightness}"
          "LITRA_TEMPERATURE=${toString cfg.litra.temperature}"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
