# Home-Manager + Flake

## Overview
This is my personal configuration that I use for WSL on Windows and MacOS. The WSL version primarily installs and configures my preferred shell with development and administration tools while the mac version configures the system and profile. 



### Influences & Inspirations

These public repositories heavily influenced my configuration. You'll see bit of stuff from each.

- https://github.com/dustinlyons/nixos-config
- https://github.com/EdenEast/nyx


### Secrets Configuration

This repository uses [ryantm/agenix](https://github.com/ryantm/agenix) to manage secrets. The secrets are stored as encrypted age files in a private repository. To run this as is, you will need to either remove all references to secrets or create your own secrets repository. 

The easiest way to run this is to create an empty secrets repository and update the inputs in flake.nix. Then make sure the options in '/system/hosts/<darwin or wsl2>/hostname/system.nix are all marked false as shown below.
```nix
  nyx.modules = {
    secrets = {
        enable = false;
        awsKeys.enable = false;
        awsConfig.enable = false;
        userKeys.enable = false;
    };
  };
```
This will maintain the secrets skeleton, but should not error since no decryption configuration is provided.

If you want to actually build and decrypt secrets, here is what my secrets repository looks like:

```Markdown
.
├─ secrets.nix    # The secrets file you're instructed to create in this tutorial => https://github.com/ryantm/agenix?tab=readme-ov-file#tutorial
├─ encrypted      # Subdirectory to hold encrypted files
├─── id_ed25519.age files  # Example encrypted file
```


### WSL2 Installation

1. Make sure you have WSL enabled and installed. [Click here if you need help setting up basic WSL2.](https://learn.microsoft.com/en-us/windows/wsl/install)
2. Make sure you have git installed in windows. You can download it [here.](https://git-scm.com/downloads) 
3. Open up a PowerShell window
4. Clone this repo and start the windows side of the installation by executing [start_here.ps1](https://github.com/mwdavisii/nix-config/blob/main/setup/wsl/start_here.ps1).

```powershell
git clone https://github.com/mwdavisii/nix-config.git
set-location ./nix-config/setup/wsl
./start_here.ps1
```

5. You should now be in your windows user directory, but in the NixOS shell. Move back into the startup directory and launch [step2.sh](https://github.com/mwdavisii/nix-config/blob/main/setup/wsl/step2.sh). 

```shell
cd ./nix-config/setup/wsl
./step2.sh
```

6. Before running the last step, open ./flake.nix in your favorite text editor and look for the lines below and change the following values:

- **displayName** => Display Name used in GitHub config
- **email** => Display Name used in GitHub config`
- **windowsUserDirName** => This is the folder name of your windows profile. It is used to create the symlink from WSL to VS Code and add it to your path.

****Note:*** Leave the userName as nixos for wsl unless you know how to configure non-default users in nixos for WSL.

```haskell
{
  userName = "nixos";
  email = "mwdavisii@gmail.com";
  displayName = "Mike D.";
  signingKey = "";
  hashedPassword = "";
  windowsUserDirName = "mwdav";
}
```

7. Finally, run the last script, [step3.sh](https://github.com/mwdavisii/nix-config/blob/main/setup/wsl/step3.sh).

```shell 
./step3.sh
```

Now close the current shell and open a new one. After the initial install, you can apply updates by executing the refresh script. 

``` shell
./reload.sh #Rebuilds and switches to the home environment.
```



### MacOS Installation

1. Make sure you have git installed. You can download it [here.](https://git-scm.com/downloads) 
2. Clone this repository.

```shell
git clone https://github.com/mwdavisii/nix-config.git
cd ./nix-config/macos
```

3. Launch the installation script

```shell
./start_here.sh
```

4. Copy the `./users/mwdavisii.nix` file into a new file with your username. Then use your favorite text editor and update the information in the file. You can safely ignore the windowsUserDirName value, that is exclusively for WSL2 and VS Code.

- **displayName** => Display Name used in GitHub config
- **email** => Display Name used in GitHub config`

****Note:*** Leave the userName as nixos for wsl unless you know how to configure non-default users in nixos for WSL.

```haskell
{
  userName = "mwdavisii";
  email = "mwdavisii@gmail.com";
  displayName = "Mike D.";
  signingKey = "";
  hashedPassword = "";
  windowsUserDirName = "";
}

```


5. Edit the `./flake.nix` file and look for the following lines. Change the user to the user you created above and if you are running an intel mac, change `aarch64-darwin` to `x86_64-darwin`.

```haskel
darwinConfigurations = mapAttrs' mkDarwinConfiguration{
        mwdavis-workm1 = {system = "aarch64-darwin"; user = "mwdavisii";};
      };
```


6. Apply the changes

```shell
./step2.sh
```

7. Now close the current shell and open a new one. After the initial install, you can apply updates by executing the refresh script. 

```shell
./reload.sh #Rebuilds and switches to the home environment.
```


### Configuring Neovim

I'm using a config file for neovim (/.config/nvim/init.vim) because I haven't taken the time to migrate to flake settings. Since it's static, you'll need to do a few things manually to get it to work:

1. Install VIMPlug

    ```
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'    ```

2. Launch Neovim and click `<enter>` through the errors.

3. Use VIMPlug to install the plugins.

    ```vim
    :PlugInstall 
    ```

4. Load any package info you want:

    ```vim
    :TSInstall yaml toml go javascript python rust cpp
    ```

5. Install any binaries you want:

    ```vim
    :GoInstallBinaries
    ```


### Project Information

#### Directory Structure

```Markdown
.
├─ home        # Home manager configurations
├─ lib         # Shared Functions
├─ nix         # Configs and overlays
├─ setup       # Contains Installation Scripts
├─ system      # MacOS and nix-darwin, wsl2, and shared configuration
├─ users       # User Settings
```