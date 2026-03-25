{ inputs, ... }:
final: prev:
{
  ytm-player = inputs.ytm-player.packages.${prev.stdenv.hostPlatform.system}.ytm-player;
  ytm-player-full = inputs.ytm-player.packages.${prev.stdenv.hostPlatform.system}.ytm-player-full;
}
