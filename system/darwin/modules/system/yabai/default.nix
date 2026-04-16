{ config, lib, pkgs, modulesPath, hostName, ... }:
with lib;
let cfg = config.nyx.modules.system.yabai;
in
{
  options.nyx.modules.system.yabai = { 
    enable = mkEnableOption "yabai"; 
  };
  config = mkIf cfg.enable {
    services.yabai = {
      enable = true;
      extraConfig = ''
        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
        sudo yabai --load-sa
        yabai -m config debug_output on

      # ====== Variables =============================

        declare -A gaps
        declare -A color
        
        #GAPS
        gaps["top"]="4"
        gaps["bottom"]="24"
        gaps["left"]="4"
        gaps["right"]="4"
        gaps["inner"]="4"

        color["focused"]="0xE0808080"
        color["normal"]="0x00010101"
        color["preselect"]="0xE02d74da"

        # sudo yabai --load-sa
        # yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
    
        yabai -m config layout                      bsp

        yabai -m config top_padding                 "''${gaps["top"]}"
        yabai -m config bottom_padding              "''${gaps["bottom"]}"
        yabai -m config left_padding                "''${gaps["left"]}"
        yabai -m config right_padding               "''${gaps["right"]}"
        yabai -m config window_gap                  "''${gaps["inner"]}"

        yabai -m config window_placement            first_child
        
        yabai -m config mouse_follows_focus         off
        yabai -m config focus_follows_mouse         off

        yabai -m config window_topmost              off
        yabai -m config window_opacity              off
        yabai -m config window_shadow               float

        yabai -m config window_border               on
        yabai -m config window_border_width         2
        yabai -m config active_window_border_color  "''${color["focused"]}"
        yabai -m config normal_window_border_color  "''${color["normal"]}"
        yabai -m config insert_feedback_color       "''${color["preselect"]}"

        yabai -m config active_window_opacity       1.0
        yabai -m config normal_window_opacity       0.90
        yabai -m config split_ratio                 0.50

        yabai -m config auto_balance                off

        yabai -m config mouse_modifier              fn
        yabai -m config mouse_action1               move
        yabai -m config mouse_action2               resize

        # rules
        yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
        yabai -m rule --add app="^System Settings$"    manage=off
        yabai -m rule --add app="^System Information$" manage=off
        yabai -m rule --add app="^System Preferences$" manage=off
        yabai -m rule --add title="Preferences$"       manage=off
        yabai -m rule --add title="Settings$"          manage=off
        yabai -m rule --add app="^Alacritty"           manage=off
        yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
        yabai -m rule --add label="App Store" app="^App Store$" manage=off
        yabai -m rule --add label="Activity Monitor" app="^Activity Monitor$" manage=off
        yabai -m rule --add label="Calculator" app="^Calculator$" manage=off
        yabai -m rule --add label="Software Update" title="Software Update" manage=off
        yabai -m rule --add app="Zscaler" title="About This Mac" manage=off

        # workspace management
        #yabai -m space 1  --label todo
        #yabai -m space 2  --label productive
        #yabai -m space 3  --label chat
        #yabai -m space 4  --label utils
        #yabai -m space 5  --label code

        # assign apps to spaces
        #yabai -m rule --add app="Reminder" space=todo
        #yabai -m rule --add app="Mail" space=todo
        #yabai -m rule --add app="Calendar" space=todo

        #yabai -m rule --add app="Alacritty" space=productive
        #yabai -m rule --add app="Arc" space=productive

        #yabai -m rule --add app="Microsoft Teams" space=chat
        #yabai -m rule --add app="Slack" space=chat
        #yabai -m rule --add app="Signal" space=chat
        #yabai -m rule --add app="Messages" space=chat

        #yabai -m rule --add app="Spotify" space=utils
        #yabai -m rule --add app="Bitwarden" space=utils
        #yabai -m rule --add app="Ivanti Secure Access" space=utils

        #yabai -m rule --add app="Visual Studio Code" space=code
        #yabai -m rule --add app="IntelliJ IDEA" space=code
        set +x
        printf "yabai: configuration loaded...\\n"
      '';
    };
  };
}