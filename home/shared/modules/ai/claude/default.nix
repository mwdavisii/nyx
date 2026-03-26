{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.nyx.modules.ai.claude;

  defaultSettings = {
    statusLine = {
      type = "command";
      command = "bunx -y ccstatusline@latest";
      padding = 0;
    };
    enabledPlugins = {
      "clangd-lsp@claude-plugins-official" = true;
      "superpowers@claude-plugins-official" = true;
      "code-review@claude-plugins-official" = true;
      "playwright@claude-plugins-official" = true;
      "security-guidance@claude-plugins-official" = true;
      "claude-md-management@claude-plugins-official" = true;
      "claude-code-setup@claude-plugins-official" = true;
      "agent-sdk-dev@claude-plugins-official" = true;
      "skill-creator@claude-plugins-official" = true;
      "discord@claude-plugins-official" = true;
    };
    skipDangerousModePermissionPrompt = true;
    hooks = {
      PreToolUse = [
        {
          "_tag" = "ccstatusline-managed";
          matcher = "Skill";
          hooks = [
            {
              type = "command";
              command = "bunx -y ccstatusline@latest --hook";
            }
          ];
        }
        {
          matcher = "Write|Edit";
          hooks = [
            {
              type = "command";
              command = "~/.claude/hooks/protect-settings.sh";
            }
          ];
        }
      ];
      UserPromptSubmit = [
        {
          "_tag" = "ccstatusline-managed";
          hooks = [
            {
              type = "command";
              command = "bunx -y ccstatusline@latest --hook";
            }
          ];
        }
      ];
    };
  };
in
{
  options.nyx.modules.ai.claude = {
    enable = mkEnableOption "Claude Code";

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.claude-code;
      description = "The claude-code package. Set to null to manage via AUR or system package manager.";
    };

    bunPackage = mkOption {
      type = types.nullOr types.package;
      default = pkgs.bun;
      description = "Bun runtime for ccstatusline. Set to null if managing bun via system package manager.";
    };

    settings = mkOption {
      type = types.attrs;
      default = defaultSettings;
      description = "Contents of ~/.claude/settings.json. Shallow-merged with defaults on top-level keys.";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      optional (cfg.package != null) cfg.package
      ++ optional (cfg.bunPackage != null) cfg.bunPackage
      ++ [ pkgs.jq ];

    home.file.".claude/settings.json".text =
      builtins.toJSON (lib.recursiveUpdate defaultSettings cfg.settings);

    home.file.".claude/hooks/protect-settings.sh" = {
      source = ../../../../config/.claude/hooks/protect-settings.sh;
      executable = true;
    };

    home.file.".config/ccstatusline/settings.json".source =
      ../../../../config/.config/ccstatusline/settings.json;
  };
}
