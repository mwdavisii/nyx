{ config, inputs, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.profiles.desktop;
in
{
  options.nyx.profiles.desktop = {
    enable = mkEnableOption "desktop profile";
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      twemoji-color-font
    ];
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        twemoji-color-font
        fira-code
        fira-code-symbols
        nerd-fonts._3270
        nerd-fonts.agave
        nerd-fonts.anonymice
        nerd-fonts.arimo
        nerd-fonts.aurulent-sans-mono
        nerd-fonts.bigblue-terminal
        nerd-fonts.bitstream-vera-sans-mono
        nerd-fonts.blex-mono
        nerd-fonts.caskaydia-cove
        nerd-fonts.caskaydia-mono
        nerd-fonts.code-new-roman
        nerd-fonts.comic-shanns-mono
        nerd-fonts.commit-mono
        nerd-fonts.cousine
        nerd-fonts.d2coding
        nerd-fonts.daddy-time-mono
        nerd-fonts.departure-mono
        nerd-fonts.dejavu-sans-mono
        nerd-fonts.droid-sans-mono
        nerd-fonts.envy-code-r
        nerd-fonts.fantasque-sans-mono
        nerd-fonts.fira-code
        nerd-fonts.fira-mono
        nerd-fonts.geist-mono
        nerd-fonts.go-mono
        nerd-fonts.gohufont
        nerd-fonts.hack
        nerd-fonts.hasklug
        nerd-fonts.heavy-data
        nerd-fonts.hurmit
        nerd-fonts.im-writing
        nerd-fonts.inconsolata
        nerd-fonts.inconsolata-go
        nerd-fonts.inconsolata-lgc
        nerd-fonts.intone-mono
        nerd-fonts.iosevka
        nerd-fonts.iosevka-term
        nerd-fonts.iosevka-term-slab
        nerd-fonts.jetbrains-mono
        nerd-fonts.lekton
        nerd-fonts.liberation
        nerd-fonts.lilex
        nerd-fonts.martian-mono
        nerd-fonts.meslo-lg
        nerd-fonts.monaspace
        nerd-fonts.monofur
        nerd-fonts.monoid
        nerd-fonts.mononoki
        nerd-fonts.mplus
        nerd-fonts.noto
        nerd-fonts.open-dyslexic
        nerd-fonts.overpass
        nerd-fonts.profont
        nerd-fonts.proggy-clean-tt
        nerd-fonts.recursive-mono
        nerd-fonts.roboto-mono
        nerd-fonts.shure-tech-mono
        nerd-fonts.sauce-code-pro
        nerd-fonts.space-mono
        nerd-fonts.symbols-only
        nerd-fonts.terminess-ttf
        nerd-fonts.tinos
        nerd-fonts.ubuntu
        nerd-fonts.ubuntu-mono
        nerd-fonts.ubuntu-sans
        nerd-fonts.victor-mono
        nerd-fonts.zed-mono
      ];
    fontconfig = {
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd"
        <fontconfig>
          <!-- Default system-ui fonts -->
          <match target="pattern">
            <test name="family">
              <string>system-ui</string>
            </test>
            <edit name="family" mode="prepend" binding="strong">
              <string>sans-serif</string>
            </edit>
          </match>

          <!-- Default sans-serif fonts-->
          <match target="pattern">
            <test name="family">
              <string>sans-serif</string>
            </test>
            <edit name="family" mode="prepend" binding="strong">
              <string>Noto Sans CJK SC</string>
              <string>Noto Sans</string>
              <string>Twemoji</string>
            </edit>
          </match>

          <!-- Default serif fonts-->
          <match target="pattern">
            <test name="family">
              <string>serif</string>
            </test>
            <edit name="family" mode="prepend" binding="strong">
              <string>Noto Serif CJK SC</string>
              <string>Noto Serif</string>
              <string>Twemoji</string>
            </edit>
          </match>

          <!-- Default monospace fonts-->
          <match target="pattern">
            <test name="family">
              <string>monospace</string>
            </test>
            <edit name="family" mode="prepend" binding="strong">
              <string>Noto Sans Mono CJK SC</string>
              <string>Symbols Nerd Font</string>
              <string>Twemoji</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>zh-HK</string>
            </test>
            <test name="family">
              <string>Noto Sans CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Sans CJK HK</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>zh-HK</string>
            </test>
            <test name="family">
              <string>Noto Serif CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <!-- not have HK -->
              <string>Noto Serif CJK TC</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>zh-HK</string>
            </test>
            <test name="family">
              <string>Noto Sans Mono CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Sans Mono CJK HK</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>zh-TW</string>
            </test>
            <test name="family">
              <string>Noto Sans CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Sans CJK TC</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>zh-TW</string>
            </test>
            <test name="family">
              <string>Noto Serif CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Serif CJK TC</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>zh-TW</string>
            </test>
            <test name="family">
              <string>Noto Sans Mono CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Sans Mono CJK TC</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>ja</string>
            </test>
            <test name="family">
              <string>Noto Sans CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Sans CJK JP</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
                <string>ja</string>
            </test>
            <test name="family">
              <string>Noto Serif CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Serif CJK JP</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>ja</string>
            </test>
            <test name="family">
              <string>Noto Sans Mono CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Sans Mono CJK JP</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>ko</string>
            </test>
            <test name="family">
              <string>Noto Sans CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Sans CJK KR</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>ko</string>
            </test>
            <test name="family">
              <string>Noto Serif CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Serif CJK KR</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang">
              <string>ko</string>
            </test>
            <test name="family">
              <string>Noto Sans Mono CJK SC</string>
            </test>
            <edit name="family" binding="strong">
              <string>Noto Sans Mono CJK KR</string>
            </edit>
          </match>

          <!-- Replace monospace fonts -->
          <match target="pattern">
            <test name="family" compare="contains">
              <string>Source Code</string>
            </test>
            <edit name="family" binding="strong">
              <string>Iosevka Term</string>
            </edit>
          </match>
          <match target="pattern">
            <test name="lang" compare="contains">
              <string>en</string>
            </test>
            <test name="family" compare="contains">
              <string>Noto Sans CJK</string>
            </test>
            <edit name="family" mode="prepend" binding="strong">
              <string>Noto Sans</string>
            </edit>
          </match>

          <match target="pattern">
            <test name="lang" compare="contains">
              <string>en</string>
            </test>
            <test name="family" compare="contains">
              <string>Noto Serif CJK</string>
            </test>
            <edit name="family" mode="prepend" binding="strong">
              <string>Noto Serif</string>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };
};
}
