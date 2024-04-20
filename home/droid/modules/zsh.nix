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
