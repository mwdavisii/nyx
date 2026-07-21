{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.dev.qmk;
in
{
  options.nyx.modules.dev.qmk = {
    enable = mkEnableOption "QMK / Vial-QMK firmware toolchain";

    # Match the nyx app-module convention: package=null means "installed elsewhere"
    # (pacman/pipx/system), skip the nix install of the QMK CLI. avr/arm toolchains
    # still come in via `enable = true` because they're clean nix builds and don't
    # collide with anything on Arch.
    package = mkOption {
      description = "Package for the QMK CLI (set to null to install via pacman/pipx).";
      type = with types; nullOr package;
      default = pkgs.qmk;
    };

    qmkHome = mkOption {
      description = ''
        Path used for QMK_HOME. `qmk compile` and `qmk flash` look here for the
        firmware tree. Set to null to leave QMK_HOME unset (CLI default: ~/qmk_firmware).
      '';
      type = with types; nullOr str;
      default = "${config.home.homeDirectory}/code/keyboards/vial-qmk";
    };

    installAvr = mkOption {
      description = "Install the AVR toolchain (needed for atmega32u4-based boards like classic Pro Micro).";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      lib.optionals (cfg.package != null) [ cfg.package ]
      ++ [
        # ARM Cortex-M toolchain — required for RP2040, STM32, nRF52 boards.
        # Sofle Choc (Brian Low) on Elite-Pi/Liatris/KB2040 lives here.
        gcc-arm-embedded

        # Flashing helpers. dfu-util for STM32 DFU bootloaders, picotool for
        # RP2040 (also handles UF2 without needing to drag-drop).
        dfu-util
        picotool
      ]
      ++ lib.optionals cfg.installAvr [
        avrdude
        pkgsCross.avr.buildPackages.gcc
      ];

    home.sessionVariables = lib.mkIf (cfg.qmkHome != null) {
      QMK_HOME = cfg.qmkHome;
    };
  };
}
