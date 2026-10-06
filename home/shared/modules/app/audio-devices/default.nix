{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.app.audio-devices;

  # WirePlumber match value: exact name, or "~glob" for a pattern match
  rule = key: name: props: ''
    {
      matches = [ { ${key} = "${name}" } ]
      actions = { update-props = { ${concatStringsSep " " (mapAttrsToList (k: v: "${k} = ${v}") props)} } }
    }
  '';

  rules =
    map (c: rule "device.name" c { "device.disabled" = "true"; }) cfg.disabledCards
    ++ mapAttrsToList (c: p: rule "device.name" c { "device.profile" = ''"${p}"''; }) cfg.cardProfiles
    ++ map (n: rule "node.name" n { "node.disabled" = "true"; }) cfg.disabledNodes
    ++ mapAttrsToList (n: p: rule "node.name" n { "priority.session" = toString p; }) cfg.outputPriorities;
in
{
  options.nyx.modules.app.audio-devices = {
    enable = mkEnableOption "WirePlumber output device policy (disable unused cards, pin profiles, rank outputs)";

    disabledCards = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "ALSA card names (device.name) to disable entirely. Prefix with ~ for a glob.";
      example = [ "alsa_card.pci-0000_03_00.1" ];
    };

    disabledNodes = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Individual node names to hide, e.g. the headphone jack on a USB mic. Prefix with ~ for a glob.";
    };

    cardProfiles = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Card name -> profile to apply when the card appears. Stops cards landing on bogus profiles like IEC958/AC3.";
      example = { "alsa_card.usb-Logitech_PRO_X_2_LIGHTSPEED_0000000000000000-00" = "output:analog-stereo+input:mono-fallback"; };
    };

    outputPriorities = mkOption {
      type = types.attrsOf types.int;
      default = { };
      description = "Sink node name -> priority.session. Highest available sink becomes the fallback default.";
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."wireplumber/wireplumber.conf.d/60-audio-devices.conf".text = ''
      monitor.alsa.rules = [
      ${concatStrings rules}
      ]
    '';
  };
}
