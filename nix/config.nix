{
  allowUnfree = true;
  # Hyprland's home-manager module references wayland at option-definition
  # time, even on Darwin where it's never built (behind mkIf enable).
  # Without this, nix refuses to evaluate wayland on aarch64-darwin.
  allowUnsupportedSystem = true;
}
