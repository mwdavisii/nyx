{ config, pkgs, lib, inputs, ... }:

# Castor — ASUS DGX box, headless. Nix drivers/CUDA remain vendor-managed.
# Host-specific overrides go here; nothing needed at first.

{
  imports = [ ../../../../home/shared/profiles/headless.nix ];
}
