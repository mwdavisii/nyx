{ config, pkgs, lib, inputs, ... }:

# hestia — agent-run M1 MacBook (Hermes), standalone home-manager.
#
# NO SECRETS ON THIS HOST. nyx.secrets.* is not merely disabled here — those
# options are defined only in system/shared/secrets/*.nix (system-level
# modules), which the standalone Darwin builder never imports. Setting them
# to false would be an eval error: the options do not exist in this scope.
# That absence is the guarantee. Do not import system/shared/secrets, do not
# define age.secrets. Matches headless.nix / prometheus / L242731 behavior.
#
# The only credential on this machine is the pre-existing ~/.ssh/id_ed25519,
# which nyx does not manage.

{
  programs.home-manager.enable = true;
  programs.man.enable = true;
  manual.manpages.enable = true;

  home = {
    stateVersion = "26.05";
    packages = with pkgs; [
      ripgrep
      fd
      sd
      dua
      just
      comma
      wget
      vim
    ];
  };

  nyx.modules = {
    app = {
      alacritty = {
        enable = true;
        package = null;   # installed via Homebrew; nix manages config only
      };
      kitty = {
        enable = true;
        package = null;
      };
      wezterm = {
        enable = true;
        package = null;
        fontSize = 14;
      };
      iterm2.enable = true;   # config-only module, no package
    };

    shell = {
      atuin.enable = true;
      bash.enable = true;
      bat.enable = true;
      bottom.enable = true;
      direnv.enable = true;
      dysk.enable = true;
      eza.enable = true;
      fastfetch.enable = true;
      fzf.enable = true;
      git = {
        enable = true;
        signing.signByDefault = false;
      };
      glow.enable = true;
      jq.enable = true;
      lazygit.enable = true;
      lf.enable = true;
      navi.enable = true;
      ncdu.enable = true;
      networking.enable = true;
      nixvim.enable = true;
      openssl.enable = true;
      ranger.enable = true;
      starship.enable = true;
      tmux.enable = true;
      xdg.enable = true;
      yq.enable = true;
      zellij.enable = true;
      zoxide.enable = true;
      zsh.enable = true;
    };
  };
}
