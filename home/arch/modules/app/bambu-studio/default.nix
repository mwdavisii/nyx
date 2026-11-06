{ config, lib, ... }:

with lib;
let
  cfg = config.nyx.modules.app.bambu-studio;
in
{
  options.nyx.modules.app.bambu-studio = {
    enable = mkEnableOption "Bambu Studio desktop entry override (XWayland backend + CA bundle)";
  };

  # Installed by setup/arch/02-install-packages.sh, so this module only ships
  # the launcher fixes — no package option.
  config = mkIf cfg.enable {
    # Two independent workarounds, both only expressible through the launcher
    # because the AUR build ignores them otherwise:
    #
    # 1. QT_QPA_PLATFORM=xcb — with Qt's Wayland backend the app maps a window
    #    that never paints: an empty white frame, healthy log, no error dialog.
    #
    # 2. SSL_CERT_FILE / CURL_CA_BUNDLE — sign-in silently fails without them.
    #    The sign-in *web page* runs in WebKitGTK (system CA store) so the
    #    emailed verification code arrives and is accepted, but the follow-up
    #    ticket -> token -> profile exchange runs inside the closed-source
    #    libbambu_networking.so plugin on its own libcurl/OpenSSL stack. The
    #    AUR package builds against system OpenSSL (DEP_BUILD_OPENSSL=0) and
    #    no longer exports the CA bundle path, so that exchange dies on TLS
    #    validation and the login dialog just closes with no error.
    #    Symptom: page loads, code accepted, back to the login screen.
    #
    # Same basename as the package's /usr/share/applications/BambuStudio.desktop,
    # so XDG deduplicates them and the app launcher shows a single entry (this
    # one wins).
    xdg.dataFile."applications/BambuStudio.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Bambu Studio
      GenericName=3D Printing Slicer
      Comment=Slice and print models on Bambu Lab printers
      Exec=env QT_QPA_PLATFORM=xcb SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt /usr/bin/bambu-studio %U
      Icon=BambuStudio
      Terminal=false
      Categories=Graphics;3DGraphics;Engineering;
      MimeType=model/stl;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;
      Keywords=3D;printing;slicer;bambu;
      StartupWMClass=BambuStudio
    '';
  };
}
