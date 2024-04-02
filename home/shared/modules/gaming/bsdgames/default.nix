{ config, pkgs, lib, inputs, ... }:
/*
  Includes:
  canfield rot13 rain trek monop hunt fortune 
  primes wargames mille caesar banner atc arithmetic 
  cribbage quiz cfscores morse bcd wump tetris-bsd 
  teachgammon pig fish hangman adventure wtf worm 
  countmail battlestar strfile ppt number snscore 
  backgammon robots factor snake pom boggle gomoku 
  random worms huntd
*/


with lib;
let
  cfg = config.nyx.modules.gaming.bsdgames;
in
{
  options.nyx.modules.gaming.bsdgames = {
    enable = mkEnableOption "BSD Games Configuration";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          bsdgames
        ];
    };
  };
}














