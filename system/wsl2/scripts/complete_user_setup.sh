#Enable VS Code
systemctl --user enable auto-fix-vscode-server.service
ln -sfT /run/current-system/etc/systemd/user/auto-fix-vscode-server.service ~/.config/systemd/user/auto-fix-vscode-server.service