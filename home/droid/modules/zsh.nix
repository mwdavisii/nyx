{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
      "ls"="eza -alG";
      "clr"="clear";
      "ip"="curl -4 icanhazip.com"; #public IP address
      "ll"="ls -alG";
      "ldir"="ls -al | grep ^d";
      "o"="open .";
      "ut"="uptime";
      "lip"="ifconfig | grep \"inet \" | grep -Fv 127.0.0.1 | awk '{print $2}'";
      "k"="kubectl";
      "kap"="kubectl apply -f ";
      "kad"="kubectl delete -f ";
    };
    syntaxHighlighting.enable = true;
    enableAutosuggestions = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "docker"
        "git"
        "tmux"
        "python"
      ];
    };
    initExtra = ''
      function _hid() {
        /usr/local/bin/hidapitester --vidpid 046D/C900 --open --length 20 --send-output $1
      }
      # 2/17/22 Litra Glow aliases from https://github.com/kharyam/litra-driver/issues/13
      function light() {
        _hid 0x11,0xff,0x04,0x1c,0x01
      }
      function dark() {
        _hid 0x11,0xff,0x04,0x1c
      }
      # ~10%
      function glow(){
        _hid 0x11,0xff,0x04,0x4c,0x00,20
      }
      # ~20%
      function dim(){
        _hid 0x11,0xff,0x04,0x4c,0x00,50
      }
      # tweaking by hand - less than 50%
      function normal() {
        _hid 0x11,0xff,0x04,0x4c,0x00,70
      }
      # ~50%
      function medium() {
        _hid 0x11,0xff,0x04,0x4c,0x00,100
      }
      # 90%
      function bright(){
        _hid 0x11,0xff,0x04,0x4c,0x00,204
      }
      # 2700K
      function warmest() {
        _hid 0x11,0xff,0x04,0x9c,10,140
      }
      # 3200K
      function warm() {
        _hid 0x11,0xff,0x04,0x9c,12,128
      }
      # 6500K
      function coldest() {
        _hid 0x11,0xff,0x04,0x9c,25,100
      }
      function cd() {
        builtin cd "$@"

        if [[ -z "$VIRTUAL_ENV" ]] ; then
          ## If env folder is found then activate the vitualenv
            if [[ -d ./.venv ]] ; then
              echo "Detected .venv folder."
        echo "Activating .venv"
        source ./.venv/bin/activate
        ## If there is a requirements.txt file, go ahead and create a venv.
            elif [[ -f ./requirements.text ]]; then
        echo "Detected requirements.txt but no venv."
        echo "Creating venv at .venv"
        python3 -m venv .venv
        echo "Activating venv"
        source ./.venv/bin/activate
            fi
        else
          ## check the current folder belong to earlier VIRTUAL_ENV folder
          # if yes then do nothing
          # else deactivate
            parentdir="$(dirname "$VIRTUAL_ENV")"
            if [[ "$PWD"/ != "$parentdir"/* ]] ; then
        echo "Leaving project directory and deactivating .venv"
              deactivate
            fi
        fi
      }
      source <(kubectl completion zsh) #Kubectl Autocompletion
      . <(flux completion zsh) # Flux Autocompletion
      [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh #fuzzyfind

      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
  };
}
