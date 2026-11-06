{ config, lib, ... }:

with lib;
let
  cfg = config.nyx.modules.app.bambu-studio;
in
{
  options.nyx.modules.app.bambu-studio = {
    enable = mkEnableOption "Bambu Studio desktop entry override (XWayland backend)";
  };

  # The AUR bambu-studio package is installed by setup/arch/02-install-packages.sh
  # (kept for firmware pushes and cloud features OrcaSlicer doesn't mirror yet),
  # so this module only ships the launcher fix — no package option.
  config = mkIf cfg.enable {
    # The package's /usr/share/applications/BambuStudio.desktop launches with
    # Qt's Wayland backend, which on Hyprland maps a window that never paints:
    # the app comes up as an empty white frame with a healthy log and no error
    # dialog. Forcing the XWayland backend makes it render normally.
    #
    # Same basename as the package's entry, so XDG deduplicates them and the app
    # launcher shows a single "Bambu Studio" icon — this one wins.
    xdg.dataFile."applications/BambuStudio.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Bambu Studio
      GenericName=3D Printing Slicer
      Comment=Slice and print models on Bambu Lab printers
      Exec=env QT_QPA_PLATFORM=xcb /usr/bin/bambu-studio %U
      Icon=BambuStudio
      Terminal=false
      Categories=Graphics;3DGraphics;Engineering;
      MimeType=model/stl;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;
      Keywords=3D;printing;slicer;bambu;
      StartupWMClass=BambuStudio
    '';
  };
}
