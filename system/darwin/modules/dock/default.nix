{ config, pkgs, lib, userConf, ... }:
with lib;
let
  cfg = config.local.dock;
  inherit (pkgs) stdenv dockutil;
in
{
  options = {
    local.dock.enable = mkOption {
      description = "Enable dock";
      default = stdenv.isDarwin;
      example = false;
    };
    local.dock.spring-load-actions-on-all-items = mkOption {
      default = true;
    };
    local.dock.show-recents = mkOption {
      type = types.nullOr types.bool;
      default = false;
    };
    local.dock.autohide = mkOption {
      default = false;
    };
    local.dock.tilesize = mkOption {
      type = types.nullOr types.int;
      default = 32;
    };
    local.dock.entries = mkOption
      {
        description = "Entries on the Dock";
        type = with types; listOf (submodule {
          options = {
            path = lib.mkOption { type = str; };
            section = lib.mkOption {
              type = str;
              default = "apps";
            };
            options = lib.mkOption {
              type = str;
              default = "";
            };
          };
        });
        readOnly = true;
      };
  };

  config =
    mkIf cfg.enable
      (
        let
          normalize = path: if hasSuffix ".app" path then path + "/" else path;
          entryURI = path: "file://" + (builtins.replaceStrings
            [" "   "!"   "\""  "#"   "$"   "%"   "&"   "'"   "("   ")"]
            ["%20" "%21" "%22" "%23" "%24" "%25" "%26" "%27" "%28" "%29"]
            (normalize path)
          );
          wantURIs = concatMapStrings
            (entry: "${entryURI entry.path}\n")
            cfg.entries;
          primaryUser = userConf.userName;
          asPrimaryUser = ''launchctl asuser "$(id -u -- ${primaryUser})" sudo --user=${primaryUser} --set-home --'';
          entryOptions = entry: if entry.options == "" then "" else " ${entry.options}";
          createEntries = concatMapStrings
            (entry:
              "${asPrimaryUser} ${dockutil}/bin/dockutil --no-restart --add ${escapeShellArg (normalize entry.path)} --section ${escapeShellArg entry.section}${entryOptions entry}\n"
            )
            cfg.entries;
        in
        {
          system.primaryUser = userConf.userName;
          system.defaults.dock.autohide = cfg.autohide;          
          system.activationScripts.postActivation.text =
            mkAfter ''
              echo >&2 "Setting up the Dock..."
              haveURIs="$(
                ${asPrimaryUser} ${dockutil}/bin/dockutil --list |
                ${pkgs.coreutils}/bin/cut -f2
              )"
              if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 ; then
                echo >&2 "Resetting Dock."
                ${asPrimaryUser} ${dockutil}/bin/dockutil --no-restart --remove all
                ${createEntries}
                ${asPrimaryUser} /usr/bin/killall Dock || true
              else
                echo >&2 "Dock setup complete."
              fi
            '';
        }
      );
}
