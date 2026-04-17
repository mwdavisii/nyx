#!/usr/bin/env bash
set -e

# Ensure homebrew is in PATH and up to date
eval "$(/opt/homebrew/bin/brew shellenv)"
brew update

# Bootstrap nix-darwin (requires sudo; pass SSH agent for private flake inputs)
sudo SSH_AUTH_SOCK="$SSH_AUTH_SOCK" nix run nix-darwin -- switch --flake ".#$(hostname)"
